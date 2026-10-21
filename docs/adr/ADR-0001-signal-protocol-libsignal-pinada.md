# ADR-0001 — Signal Protocol via libsignal, pinada por commit

- **Status:** aceita
- **Data:** 2026-10-21

## Contexto

O diferencial do FalaAí é segurança. Protocolos caseiros são a causa mais comum de falhas graves em mensageiros. A libsignal é a implementação de referência do Signal Protocol, auditada, com PQXDH e SPQR (pós-quântico). Ela não está no crates.io e a API Rust não segue semver.

## Decisão

Usar a libsignal como única fonte de primitivas e protocolo (PQXDH, Triple Ratchet, Sender Keys, sealed sender). Dependência git **pinada por commit**, nunca fork. Acesso isolado atrás de traits internas do `falaai-core`. Nenhuma primitiva criptográfica escrita por nós.

## Consequências

- Herdamos a AGPL-3.0 no cliente (ver [licenciamento](../legal/licenciamento-agpl.md)).
- Upgrades da libsignal exigem trabalho periódico; um bead recorrente acompanha releases e avisos de segurança.
- A auditoria externa foca na nossa integração, não nas primitivas.
