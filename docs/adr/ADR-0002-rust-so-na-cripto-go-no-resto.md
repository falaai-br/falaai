# ADR-0002 — Rust só no núcleo criptográfico, Go em todo o resto

- **Status:** aceita
- **Data:** 2026-10-21

## Contexto

O time prefere Go. Não existe implementação Go oficial nem auditada do Signal Protocol com PQXDH/SPQR. Os portes Go existentes (ex.: go.mau.fi/libsignal) não têm pós-quântico nem auditoria independente.

## Decisão

Rust fica restrito ao crate `falaai-core` (wrapper fino da libsignal + stores + armazenamento local + transporte do cliente). Servidor, workers, ferramentas internas, CLIs e infraestrutura são **Go**. Flutter conversa com o núcleo via flutter_rust_bridge.

## Consequências

- Uma pessoa com Rust é necessária no time; o restante trabalha em Go e Dart.
- O núcleo é pequeno e fácil de auditar.
- Se no futuro surgir implementação Go auditada e pós-quântica, esta ADR pode ser revista.
