# 02 — Segurança e criptografia

Legenda: **[V]** fato verificado em fonte pública em 2026-10-21; **[S]** decisão ou suposição nossa.

## Regra de ouro

Não escrevemos criptografia. Toda primitiva e todo protocolo vêm da `libsignal` (Rust, Signal Foundation), pinada por commit. Nosso código só **orquestra** chamadas à libsignal e **armazena** estado. Ver [ADR-0001](../adr/ADR-0001-signal-protocol-libsignal-pinada.md).

## Acordo de chaves: PQXDH + Triple Ratchet

- **[V]** PQXDH (X25519 + ML-KEM/Kyber, híbrido pós-quântico) está em produção no Signal desde 2023.
- **[V]** SPQR (Sparse Post-Quantum Ratchet) foi anunciado em outubro de 2025 e compõe, com o Double Ratchet, o chamado *Triple Ratchet*. A libsignal atual (série v0.10x) usa SPQR em sessões novas, com proteção contra downgrade.
- **[S]** Usamos o padrão da libsignal pinada: PQXDH para estabelecer a sessão e Triple Ratchet para cada mensagem. Nunca reimplementar nem desligar a parte pós-quântica.
- Cada dispositivo publica um **bundle**: identity key, signed prekey, Kyber prekey assinada (last-resort + one-time) e um pool de one-time prekeys EC. O cliente repõe o pool quando cai abaixo de 20.

## Sealed sender

**[S]** No MVP. O envelope entregue ao servidor não contém o remetente. O servidor emite um **certificado de remetente** de curta duração (24h) que o destinatário valida após decifrar. Regra operacional: **não registrar** quem pediu certificado e quando, além do necessário para rate limit (Redis, TTL curto).

## Safety numbers

**[S]** No MVP. Código de 60 dígitos e QR por conversa. Mudança de identity key do contato gera aviso visível e bloqueia envio automático em conversas marcadas como verificadas. Na UI chamamos de "código de segurança".

## Múltiplos dispositivos (Sesame)

**[S]** O endereço de protocolo nasce como `aci + deviceId` desde o primeiro commit, para que vincular dispositivos seja só uma feature, não uma migração. O MVP tem **um dispositivo por conta**. Fase posterior: telefone primário + até 3 vinculados por QR, cada um com identity key própria e fan-out pairwise.

## Grupos

**[S]** Sender Keys com distribuição pairwise:

1. Cada membro gera sua sender key e a envia a cada outro membro numa mensagem 1:1 cifrada.
2. Mensagens do grupo são cifradas uma vez com a sender key do remetente; o servidor faz fan-out do mesmo ciphertext.
3. Entrada ou saída de membro → todos rotacionam suas sender keys.
4. **Estado do grupo** (nome, avatar, descrição, lista de membros e papéis) é cifrado no cliente com uma *group master key* e guardado no servidor como blob opaco.
5. O servidor conhece apenas `group_id` opaco e a lista de ACIs necessária para entregar. Isso é declarado publicamente como risco residual.

Limite no MVP: 256 membros. **zkgroup** (credenciais anônimas, o servidor não vê membros) fica pós-MVP: exige operar servidor de credenciais e cai sob AGPL no servidor.

## Mídia

1. O núcleo gera chave AES-256 + chave HMAC-SHA256 aleatórias por anexo (formato de anexo do Signal).
2. Arquivo cifrado em streaming, com **padding** até um tamanho de bucket para reduzir fingerprinting.
3. Upload do blob para storage via URL pré-assinada, upload resumível.
4. A mensagem E2EE leva `(blob_id, chave, digest, tamanho, mime, dimensões, blurhash)`.
5. Thumbnail separada (máx. 1024px, WebP), cifrada com chave própria.
6. Blob expira em 30 dias. O servidor não associa blob a conta.

## Chamadas

- **1:1:** oferta/resposta SDP e candidatos ICE viajam **dentro de envelopes E2EE** do tipo `call_signal`. Mídia em DTLS-SRTP; o fingerprint DTLS vai na sinalização cifrada, o que amarra a chamada à sessão Signal. TURN próprio (coturn) com credenciais efêmeras; opção "sempre usar relay" para esconder o IP do contato.
- **Grupo:** SFU LiveKit self-hosted com **frame encryption** (insertable streams / `FrameCryptor`). A chave de mídia é distribuída por mensagem de grupo E2EE e rotacionada a cada entrada/saída. O SFU encaminha frames que não consegue decifrar.
- **[S]** Sem frame encryption, chamada em grupo não é lançada. Seria contradizer o princípio 1.

## Identidade e descoberta de contatos

- **[S]** Registro por número de telefone + **username opcional desde o dia 1**. Número oculto para outros usuários por padrão. **[V]** É o modelo do Signal desde 2024.
- **Sem descoberta pela agenda no MVP.** Hash de número brasileiro não protege nada: o espaço (DDD + 9 + 8 dígitos) é pequeno e um SHA-256 de todos os números cabe em horas de GPU. Convidamos por link, QR code ou username. Ver [ADR-0007](../adr/ADR-0007-sem-descoberta-por-agenda-no-mvp.md).
- Fase 2: PSI (private set intersection). Evitamos enclaves SGX (histórico de side-channels e custo operacional de atestação).

## PIN de registro (anti-sequestro de conta)

- PIN criado no onboarding (pode ser adiado, com lembrete).
- Após o SMS, registrar a conta em novo aparelho exige o PIN.
- Servidor guarda apenas verificador Argon2id; tentativas com lockout exponencial.
- PIN esquecido: *registration lock* expira após **7 dias** sem atividade do aparelho antigo.
- O PIN **não** cifra backup no MVP (sem SVR/enclaves).

## Backup

- Backup completo cifrado no cliente com chave derivada por **Argon2id** de uma frase de recuperação gerada pelo app (6+ palavras) ou passphrase forte do usuário.
- O servidor (ou o storage do usuário) guarda só o blob opaco.
- Perder a frase = perder o histórico. O app diz isso de forma clara, sem alarmismo.
- Reinstalar sem backup recupera a **identidade** (via SMS + PIN), não o histórico; os contatos veem a mudança de safety number.

## Key transparency

**[V]** O Signal lançou verificação automática de chaves em agosto de 2026, com log Merkle auditado por terceiros; o código está na libsignal. **[S]** Fora do MVP: exige operar log auditado e ter ao menos um auditor independente. Para facilitar a migração, o servidor já grava `(ACI, deviceId) → identity key` em tabela **append-only** desde o início.

## Proteção no aparelho

Ver [04 — Cliente](04-cliente.md#segurança-no-aparelho). Resumo: SQLCipher com chave em hardware, biometria opcional, efêmeras com `secure_delete`, `FLAG_SECURE` opcional no Android, aviso (sem bloqueio) em root/jailbreak.

## Transporte

- TLS 1.3 obrigatório; certificate pinning da CA intermediária com dois pins de reserva.
- WebSocket autenticado por token de dispositivo rotacionado; nunca por número de telefone.
- Push sem conteúdo: o push só "acorda" o app para buscar envelopes.

## Processo de segurança

- Revisão de segurança obrigatória em todo PR que toca `falaai-core` ou autenticação no servidor.
- Fuzzing dos parsers de envelope (cargo-fuzz no core, go-fuzz no servidor).
- Dependências auditadas (`cargo deny`, `cargo audit`, `govulncheck`).
- Auditoria externa do core, do FFI e do servidor contratada na Fase 2, executada na Fase 4, **relatório publicado integralmente**.
- Bug bounty público a partir do beta.
- `SECURITY.md` com contato e chave PGP em todos os repositórios.
