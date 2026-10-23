# ADR-0011 — Serviço assinador AGPL para certificados de remetente

- **Status:** aceita
- **Data:** 2026-10-23
- **Relacionada:** [ADR-0004](ADR-0004-servidor-go-do-zero.md), [ADR-0010](ADR-0010-sealed-sender-canal-nao-autenticado-desde-a-fase-0.md)

## Contexto

O sealed sender exige que o servidor emita `SenderCertificate` assinados, no formato da libsignal, por um `ServerCertificate` que deriva de um trust root. Assinar exige XEdDSA sobre curve25519. Três regras se chocam:

1. O projeto proíbe escrever primitivas criptográficas à mão.
2. O `falaai-server` é fechado e, por isso, não pode linkar a libsignal, que é AGPL.
3. Não há implementação Go de XEdDSA madura e auditada.

## Decisão

Criar o repositório público **`falaai-signer`** (Rust, AGPL-3.0), com um binário pequeno cuja única responsabilidade é assinar `ServerCertificate` e `SenderCertificate` usando a libsignal.

- O `accounts` chama o signer por gRPC em loopback ou socket Unix, no mesmo pod.
- O signer não tem estado, banco nem logs com identificadores. As chaves privadas vêm de segredo, nunca do repositório.
- O restante do servidor continua fechado e sem libsignal. O servidor também não verifica assinaturas de prekeys: quem verifica é a libsignal no cliente.

## Consequências

- Mais um repositório e uma rig no Gas Town (`falaai_signer`, prefixo de beads `flg`).
- A parte do servidor que toca criptografia fica pública e auditável, o que reforça a tese "100% auditável".
- O deploy do servidor passa a ter um sidecar; a falha do signer impede emitir certificados, mas não a entrega de mensagens já cifradas.
