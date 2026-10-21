# ADR-0008 — Fila de mensagens mutável, sem append-only nem CDC

- **Status:** aceita
- **Data:** 2026-10-21

## Contexto

Padrões comuns do time incluem imutabilidade (append-only, sem DELETE), outbox e CDC via Kafka. Num mensageiro, isso criaria um histórico permanente de quem falou com quem.

## Decisão

A `message_queue` é apagada no ACK (TTL de 30 dias). Sem outbox, sem CDC, sem Debezium. Kafka só com eventos sem par remetente/destinatário e retenção de 24h. Append-only restrito a `identity_keys_log` e `admin_audit_log`.

## Consequências

- Minimização de metadados verificável no schema.
- Depuração de entrega depende de métricas agregadas, não de histórico.
- Revisões de PR rejeitam qualquer tabela ou tópico que registre pares remetente/destinatário.
