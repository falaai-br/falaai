# 05 — Roadmap

Time de referência: 2 backend (Go), 2 mobile (Flutter), 1 Rust/cripto, 1 design. A construção é orquestrada por agentes no Gas Town; o time humano revisa, decide e audita.

| Fase | Escopo | Critério de saída | Esforço |
|---|---|---|---|
| **0 — Spike do protocolo** | libsignal compilando para iOS e Android via flutter_rust_bridge; sessão 1:1 entre dois aparelhos físicos; SQLCipher aberto pelo NSE do iOS; envelope em protobuf; servidor mínimo (`accounts` + `keys` + relay); CI gera xcframework e `.so` | Demo: mensagem cifrada entre iPhone e Android, decifrada pelo NSE com app fechado | 4–6 semanas |
| **1 — Texto 1:1** | Registro com SMS e PIN, username, prekeys, Triple Ratchet, sealed sender, outbox, recibos, digitação, push, safety numbers, efêmeras, `delivery` completo | 1.000 mensagens em 3 perfis de rede ruim sem perda nem duplicação; revisão interna do núcleo | 10–12 semanas |
| **2 — Grupos + mídia** | Sender Keys, estado de grupo cifrado, convites por link, anexos com upload resumível, thumbnails, backup cifrado. **Contratar auditoria externa** | Grupo de 50 pessoas com entradas e saídas e rotação de chave correta; fotos enviadas em 3G | 10–12 semanas |
| **3 — Chamadas** | 1:1 com WebRTC + CallKit/ConnectionService + coturn; grupo via LiveKit com frame encryption | Taxa de conexão acima de 95% em teste nacional; chamada recebida com tela bloqueada nas duas plataformas | 12–16 semanas |
| **4 — Beta e lançamento** | Beta fechado com 500 pessoas, auditoria externa, correções, bug bounty, publicação do relatório, lojas, relatório de transparência zero | Nenhum achado crítico aberto; crash-free acima de 99,5% | 10–12 semanas |

**Total estimado: 12 a 14 meses** até o lançamento público.

## Pós-MVP (ordem sugerida)

1. Dispositivos vinculados (desktop/tablet).
2. Key transparency.
3. Descoberta de contatos com PSI.
4. Grupos zero-knowledge (zkgroup).
5. Registro sem número de telefone.

## Maiores riscos de atraso

1. **Chamadas:** CallKit/PushKit, áudio em segundo plano, NAT brasileiro e frame encryption somam facilmente 2 meses.
2. **NSE do iOS** compartilhando o banco sem corromper o ratchet.
3. **Upgrades da libsignal:** API Rust instável; isolar atrás de traits internos.
4. **Push em Android** com otimização agressiva de bateria.
5. **Fila de auditoria externa:** 2 a 3 meses de espera; por isso a contratação acontece na Fase 2.
6. **Licença AGPL × App Store:** ver [licenciamento](../legal/licenciamento-agpl.md).

## Como o trabalho é gerido

- Cada fase é um **epic** no repositório `falaai`.
- As tarefas vivem como **beads** no Gas Town, uma rig por repositório, e são espelhadas em **GitHub Issues** com `bd github sync`.
- O detalhamento da fase N+1 acontece ao final da fase N.
