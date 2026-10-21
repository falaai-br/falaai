# 06 — Custos de infraestrutura

Ordem de grandeza para **100 mil usuários ativos por mês**, em dólares, em AWS sa-east-1.

| Item | US$/mês |
|---|---|
| EKS (control plane + ~12 nós) | 2.500 |
| RDS Postgres Multi-AZ | 900 |
| ElastiCache Redis + RedPanda (3 brokers) | 700 |
| S3 (~5 TB) + CloudFront (~10 TB) | 900 |
| coturn (3 instâncias + ~2 TB de egress) | 500 |
| LiveKit (3 nós + ~8–10 TB de egress) | 2.000 |
| Load balancers, NAT, discos, diversos | 500 |
| SMS de verificação (~40 mil/mês) | 1.600 |
| Observabilidade | 1.500 |
| **Total** | **~11.000 (± 4.000)** |

## Premissas

- 10 mil chamadas 1:1 por dia, 30% passando por TURN, ~20 MB de relay cada.
- 1 mil chamadas em grupo por dia, 4 participantes, 10 minutos, ~1 Mbps por fluxo de descida.
- Egress representa cerca de 30% do total e cresce linearmente com o uso de vídeo.

## Alavancas de economia

1. Mover coturn e LiveKit para OCI São Paulo quando o egress passar de ~20 TB/mês.
2. Rodar os seis serviços Go como um binário só no início (menos nós).
3. Negociar SMS com provedor nacional; usar verificação por chamada ou e-mail como alternativa.
4. Observabilidade com retenção curta (já exigida pela política de metadados).

## Fora desta conta

Pessoas, auditoria externa (tipicamente dezenas a centenas de milhares de dólares), jurídico, contas de desenvolvedor das lojas e bug bounty.
