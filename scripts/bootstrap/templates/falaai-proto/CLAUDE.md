# falaai-proto — instruções para agentes

Este repositório faz parte do **FalaAí**, mensageiro brasileiro com criptografia ponta a ponta. O blueprint completo está em https://github.com/__ORG__/falaai (pasta `docs/`). Leia o blueprint antes de decisões de arquitetura.

**Este NÃO é um repositório Nova.** Não aplicar `ai-core-basic-decisions` nem NERDs da Nova.

## Stack
Protocol Buffers (proto3) gerenciados com `buf`. Geração para Go (servidor) e Rust (`prost`, no falaai-core).

## Licença
Apache-2.0.

## Convenções
- Trunk-based em `main`, squash merge, mensagens em Conventional Commits.
- Tarefas vivem como beads no Gas Town e são espelhadas em GitHub Issues (`bd github sync`). Todo PR referencia uma bead/issue.
- Documentação, issues e mensagens de commit em português; identificadores de código em inglês.

## Regras de segurança (inegociáveis)
- Nunca escrever primitivas criptográficas. Toda cripto vem da libsignal (só no `falaai-core`).
- Nunca registrar em log: telefone, par remetente/destinatário, IP completo, conteúdo, chaves, ACI em claro.
- Nenhuma tabela, tópico ou log pode guardar quem falou com quem (ADR-0008).

## Específico deste repo
- Contrato público entre cliente e servidor: Envelope, mensagens do WebSocket, ACK, bundles de prekeys.
- Mudanças só retrocompatíveis (`buf breaking` no CI). Nunca reutilizar número de campo.
- Nenhum campo pode carregar remetente em claro no envelope (sealed sender).
