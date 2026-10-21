# ADR-0006 — AWS sa-east-1 no MVP

- **Status:** aceita
- **Data:** 2026-10-21

## Contexto

"100% brasileiro" sugere nuvem nacional, mas construir o produto e trocar de nuvem ao mesmo tempo dobra o risco. O time opera AWS, EKS, Pulumi e ArgoCD.

## Decisão

Hospedar tudo em AWS sa-east-1 no MVP. Declarar publicamente o risco CLOUD Act (afeta só metadados). Migrar coturn/LiveKit para OCI São Paulo quando o egress passar de ~20 TB/mês. Reavaliar Magalu Cloud em 2027.

## Consequências

- Dados no Brasil desde o início.
- Narrativa de soberania depende da E2EE, não do provedor.
- Infra como código (Pulumi) mantém a migração viável.
