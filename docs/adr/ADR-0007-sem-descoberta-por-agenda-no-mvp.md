# ADR-0007 — Sem descoberta de contatos pela agenda no MVP

- **Status:** aceita
- **Data:** 2026-10-21

## Contexto

Descobrir quais contatos usam o app é a maior fonte de metadados de um mensageiro. Hash de telefone brasileiro é reversível por força bruta. Enclaves (SGX) têm histórico de side-channels e custo operacional alto.

## Decisão

No MVP, contatos são adicionados por **link de convite, QR code ou username**. Número oculto por padrão. PSI (private set intersection) avaliado na fase 2.

## Consequências

- Adoção inicial mais lenta; mitigada com convite fácil por link no WhatsApp/SMS.
- Elimina tratamento de dados de não-usuários (LGPD).
- Diferencial de privacidade claro para comunicar.
