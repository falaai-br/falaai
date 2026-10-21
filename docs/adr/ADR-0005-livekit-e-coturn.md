# ADR-0005 — coturn para 1:1 e LiveKit para chamadas em grupo

- **Status:** aceita
- **Data:** 2026-10-21

## Contexto

Chamadas fazem parte do MVP. 1:1 funciona P2P com fallback TURN. Grupo exige SFU, e o SFU não pode ver mídia.

## Decisão

coturn self-hosted com credenciais efêmeras para 1:1. **LiveKit self-hosted** como SFU, com frame encryption obrigatória e chave distribuída por mensagem de grupo E2EE.

## Consequências

- Egress de mídia vira a maior linha variável de custo (ver [custos](../blueprint/06-custos.md)).
- O SFU vê quem participa e quando; declarado como risco residual.
- mediasoup e ion-sfu descartados.
