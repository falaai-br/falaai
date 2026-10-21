# ADR-0004 — Servidor Go construído do zero

- **Status:** aceita
- **Data:** 2026-10-21

## Contexto

Opções: forkar Signal-Server (Java, AGPL), adotar Matrix, ou construir. O servidor de um mensageiro E2EE é pequeno (diretório de chaves + relay de ciphertext).

## Decisão

Construir em Go, copiando o desenho de protocolo do Signal. Seis módulos (`accounts`, `keys`, `gateway`, `delivery`, `groups`, `media`, mais o worker `push`), começando como um binário modular. Postgres + sqlc + pgx, Redis, RedPanda. O servidor **não linka** libsignal.

## Consequências

- Servidor pode permanecer privado sem violar AGPL.
- Somos responsáveis por compatibilidade de formato com a libsignal no cliente; testes de contrato com envelopes gerados pelo core.
- Signal-Server e Matrix descartados (licença/stack e protocolo/metadados, respectivamente).
