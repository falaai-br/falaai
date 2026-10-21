# falaai-server — instruções para agentes

Este repositório faz parte do **FalaAí**, mensageiro brasileiro com criptografia ponta a ponta. O blueprint completo está em https://github.com/__ORG__/falaai (pasta `docs/`). Leia o blueprint antes de decisões de arquitetura.

**Este NÃO é um repositório Nova.** Não aplicar `ai-core-basic-decisions` nem NERDs da Nova.

## Stack
Go 1.24+, gin, PostgreSQL (sqlc + pgx/v5 + goose), Redis, RedPanda (Kafka), WebSocket (`coder/websocket`). Um binário modular com os módulos accounts, keys, gateway, delivery, groups, media e o worker push (ADR-0004). Deploy em AWS sa-east-1 / EKS.

## Licença
Proprietária, repositório privado. **Nunca** importar libsignal, zkgroup ou qualquer código AGPL: isso obrigaria a publicar o servidor.

## Convenções
- Trunk-based em `main`, squash merge, mensagens em Conventional Commits.
- Tarefas vivem como beads no Gas Town e são espelhadas em GitHub Issues (`bd github sync`). Todo PR referencia uma bead/issue.
- Documentação, issues e mensagens de commit em português; identificadores de código em inglês.

## Regras de segurança (inegociáveis)
- Nunca escrever primitivas criptográficas. Toda cripto vem da libsignal (só no `falaai-core`).
- Nunca registrar em log: telefone, par remetente/destinatário, IP completo, conteúdo, chaves, ACI em claro.
- Nenhuma tabela, tópico ou log pode guardar quem falou com quem (ADR-0008).

## Específico deste repo
- Clean Architecture por módulo: `domain` não importa `handlers` nem `adapters`.
- `message_queue` é apagada no ACK; sem outbox, sem CDC (ADR-0008). Kafka só com eventos sem par remetente/destinatário.
- Testes table-driven com testify; `go test ./...`, `golangci-lint run`, `govulncheck ./...` antes de `gt done`.
- Testes de contrato usam vetores de envelope gerados pelo falaai-core.
