# Retenção de dados e resposta a ordens

> Política técnica. Validar com o jurídico antes do lançamento.

## O que existe no servidor e por quanto tempo

| Dado | Existe? | Retenção | Pode ser entregue com ordem judicial? |
|---|---|---|---|
| Conteúdo de mensagens, mídia, chamadas | Só como ciphertext, temporariamente | Até o ACK (máx. 30 dias) | Não há como decifrar |
| Chaves privadas | **Não** | — | Não existem no servidor |
| Lista de contatos / agenda | **Não** | — | Não existe |
| Quem falou com quem | **Não** (sealed sender, fila sem remetente) | — | Não existe |
| Registros de acesso (IP, data/hora, conta) | Sim | 6 meses | Sim, com ordem judicial (Marco Civil art. 15) |
| Data de criação da conta, último dia de uso | Sim | Enquanto a conta existir | Sim, com ordem judicial |
| Número de telefone | Sim (HMAC + cifrado) | Enquanto a conta existir | Sim, com ordem judicial |
| Username | Sim, se o usuário criou | Enquanto existir | Sim, com ordem judicial |
| Membros de grupos (UUIDs) | Sim (MVP) | Enquanto o grupo existir | Sim, com ordem judicial. Risco residual a eliminar com zkgroup |
| Nome, foto, descrição do grupo | Só cifrado | — | Não há como decifrar |
| Logs de aplicação | Sim, sem identificadores | 7 dias | Não contêm dados de usuário |

## Procedimento para ordens

1. Toda ordem chega por canal único (`juridico@`) e é registrada.
2. O jurídico valida autenticidade, competência e escopo.
3. Ordens que pedem **conteúdo** ou **interceptação**: resposta técnica fundamentada explicando a impossibilidade; contestação com base nos votos da ADPF 403 / ADI 5527 quando cabível.
4. Ordens que pedem **dados existentes**: extração por duas pessoas (princípio dos quatro olhos), registrada em `admin_audit_log`, entregue apenas no escopo pedido.
5. **Guarda cautelar** (art. 15, §2º): congelar apenas os registros da conta indicada, pelo prazo indicado.
6. Notificar o usuário quando a lei permitir.
7. Contabilizar no relatório de transparência semestral.

## Exclusão

- Exclusão de conta pelo app: apagamento em até 24h, exceto registros de acesso (obrigação legal, 6 meses) e `phone_hmac` como tombstone anti-abuso por 30 dias.
- Purgas automáticas rodam diariamente e são **testadas em CI**.
