# 04 — Cliente (app + núcleo)

## Camadas

```text
┌──────────────────────────────────────────────┐
│ falaai-app (Flutter / Dart)                  │
│  UI · Async Redux · go_router · flutter_webrtc│
├──────────────────────────────────────────────┤
│ Bindings gerados (flutter_rust_bridge 2.x)   │
├──────────────────────────────────────────────┤
│ falaai-core (Rust)                           │
│  protocol · storage · messaging · transport  │
│  media · api                                 │
│        └── libsignal (pinada por commit)     │
└──────────────────────────────────────────────┘
```

**Rust fica restrito ao núcleo.** Ver [ADR-0002](../adr/ADR-0002-rust-so-na-cripto-go-no-resto.md). Motivos:

1. A libsignal **é** Rust; é a única implementação auditada com PQXDH e SPQR.
2. Zeroização determinística de chaves (`zeroize`); o GC do Dart copia memória livremente.
3. O mesmo núcleo serve o app, a Notification Service Extension do iOS e um futuro cliente desktop.
4. A auditoria externa se concentra em um único artefato.

**Regra:** o Dart nunca vê material de chave. Só recebe texto já decifrado para exibir.

## falaai-core (Rust)

| Módulo | Responsabilidade |
|---|---|
| `protocol/` | Wrapper da `libsignal-protocol`: PQXDH, Triple Ratchet, Sender Keys, sealed sender. Implementa os stores (`IdentityKeyStore`, `SessionStore`, `PreKeyStore`, `SignedPreKeyStore`, `KyberPreKeyStore`, `SenderKeyStore`) sobre SQLite |
| `storage/` | SQLCipher via `rusqlite` (feature `bundled-sqlcipher`). Chave de 256 bits gerada no primeiro uso, guardada no Keychain (`AfterFirstUnlockThisDeviceOnly`) ou Keystore (StrongBox quando houver) |
| `messaging/` | Outbox com retry exponencial, idempotência por `client_message_id`, ordenação, recibos, efêmeras |
| `transport/` | WebSocket e HTTPS (`rustls`, pinning), reconexão com backoff |
| `media/` | Cifra/decifra de anexos em streaming, padding, thumbnails |
| `api/` | Superfície exposta ao Flutter: funções `async` e `Stream<ChatEvent>` |

Build: `opt-level = "z"`, LTO, `panic = "abort"`. Targets: `aarch64-linux-android`, `armv7-linux-androideabi`, `x86_64-linux-android`, `aarch64-apple-ios`, `aarch64-apple-ios-sim`. A libsignal é dependência git pinada por commit (não está no crates.io e a API Rust não tem semver).

## Ponte FFI

- **flutter_rust_bridge 2.13** (estável, agosto de 2026): async e `StreamSink<T>` nativos, handles opacos, erros Rust mapeados para exceções Dart tipadas.
- Empacotamento via **Native Assets**; fallback para xcframework estático se o NSE do iOS exigir.
- Eventos (mensagem recebida, status, progresso de upload, chamada recebida) chegam por stream; o Dart nunca faz polling.

## falaai-app (Flutter)

- **Estado: Async Redux** ([ADR-0003](../adr/ADR-0003-flutter-async-redux-frb.md)). O time já domina; uma store única casa com "o núcleo emite eventos, a UI projeta".
- Padrão: `ChatEvent` do Rust → `Action` → reducer puro → `StoreConnector`. Lista de mensagens paginada por cursor do SQLite; nunca a conversa inteira em memória.
- Navegação `go_router` com deep links (`falaai://chat/<id>`) para notificações e CallKit.
- Material 3 com tema próprio; pt-BR como idioma único no MVP, strings já em arquivos ARB.

## Fluxos críticos

### Registro

Número → SMS → nome. O núcleo gera identity key, registration id, 100 one-time prekeys, signed prekey e Kyber prekeys, e envia o bundle. PIN de registro oferecido logo depois (adiável, com lembrete).

### Envio e recebimento

Envio: outbox → existe sessão? Se não, busca bundle e faz PQXDH → cifra → sealed sender → WebSocket → ACK do servidor marca "enviado" → recibo de entrega chega como mensagem de protocolo. Recebimento: envelope → decifra → persiste → emite evento → ACK. Tratar explicitamente `UntrustedIdentity` e mensagens duplicadas.

### Grupos

Distribuição pairwise da sender key, mensagem cifrada uma vez, rotação em toda mudança de membros. Estado do grupo cifrado com a group master key.

### Mídia

Cifra em streaming para arquivo temporário, upload resumível, thumbnail cifrada separada. Download sob demanda em dados móveis (configurável), automático no Wi-Fi.

### Push

O push só acorda o app, nunca carrega conteúdo.

- **iOS:** APNs com `mutable-content: 1` → **Notification Service Extension** linka `falaai-core`, abre o SQLCipher via **App Group**, busca o envelope e decifra para mostrar remetente e prévia. Limites do NSE: ~24 MB de memória e ~30s. Cuidados: WAL + busy timeout, Keychain compartilhado por access group, **nunca dois processos avançando o mesmo ratchet** (lock de arquivo + sinalização ao app). Fallback: "Nova mensagem".
- **Android:** FCM *data message* de alta prioridade → serviço chama o núcleo → notificação local. Documentar Doze e fabricantes que matam processos (Xiaomi, Samsung em modos agressivos) e guiar o usuário a liberar o app.

### Chamadas

`flutter_webrtc` 1.6.x. Sinalização dentro de mensagens E2EE. iOS: **PushKit + CallKit** (a chamada precisa ser reportada ao CallKit imediatamente ao receber o VoIP push). Android: `ConnectionService` + full-screen intent. Grupo via SDK LiveKit com `FrameCryptor`.

## Segurança no aparelho

| Recurso | Decisão |
|---|---|
| Banco local | SQLCipher, chave em hardware |
| Mídia decifrada | Só em cache cifrado; arquivos temporários apagados |
| Bloqueio do app | Biometria/PIN opcional (`local_auth`), timeout configurável |
| Bloquear captura de tela | Opcional. Android: `FLAG_SECURE`. iOS: só detecção, comunicada como tal |
| Mensagens efêmeras | Timer por conversa, conta a partir da leitura, `secure_delete` |
| Root/jailbreak | **Avisar uma vez, não bloquear** |
| Teclado | `IME_FLAG_NO_PERSONALIZED_LEARNING` no Android, opção "teclado incógnito" |
| Builds reproduzíveis | Android sim (Docker pinado, hashes publicados). iOS: processo publicado |
| Distribuição | Play Store, App Store, APK assinado no site, F-Droid |

## UX para o Brasil

- Onboarding em 3 telas, sem senha.
- Android de entrada: APK menor que 40 MB por ABI, cold start abaixo de 2s em Snapdragon 4xx/Helio G, `armeabi-v7a` mantido.
- Redes ruins: outbox resiliente, mídia com compressão adaptativa, indicação clara de "enviando".
- Acessibilidade: `Semantics` em toda a UI, contraste AA, fontes escaláveis.
- Linguagem: "Só você e quem recebe podem ler" em vez de "criptografia ponta a ponta". Segurança como padrão silencioso, sem pop-ups de medo.
