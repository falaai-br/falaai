# falaai-infra — instruções para agentes

Este repositório faz parte do **FalaAí**, mensageiro brasileiro com criptografia ponta a ponta. O blueprint completo está em https://github.com/__ORG__/falaai (pasta `docs/`). Leia o blueprint antes de decisões de arquitetura.

**Este NÃO é um repositório Nova.** Não aplicar `ai-core-basic-decisions` nem NERDs da Nova.

## Stack
Pulumi (Go) em AWS sa-east-1: VPC, EKS, RDS Postgres, ElastiCache Redis, RedPanda, S3 + CloudFront, coturn, LiveKit. GitOps com ArgoCD. docker-compose para desenvolvimento local.

## Licença
Proprietária, repositório privado.

## Convenções
- Trunk-based em `main`, squash merge, mensagens em Conventional Commits.
- Tarefas vivem como beads no Gas Town e são espelhadas em GitHub Issues (`bd github sync`). Todo PR referencia uma bead/issue.
- Documentação, issues e mensagens de commit em português; identificadores de código em inglês.

## Regras de segurança (inegociáveis)
- Nunca escrever primitivas criptográficas. Toda cripto vem da libsignal (só no `falaai-core`).
- Nunca registrar em log: telefone, par remetente/destinatário, IP completo, conteúdo, chaves, ACI em claro.
- Nenhuma tabela, tópico ou log pode guardar quem falou com quem (ADR-0008).

## Específico deste repo
- Nada de mudança manual em console; tudo via Pulumi.
- Logs com retenção de 7 dias e sem identificadores de usuário; S3 de mídia com lifecycle de 30 dias.
- Segredos só no gerenciador de segredos; nunca no repositório.
- `pulumi preview` anexado ao PR.
