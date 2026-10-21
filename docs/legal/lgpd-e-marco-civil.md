# LGPD e Marco Civil da Internet

> Documento técnico de orientação. **Não substitui parecer jurídico.** Legenda: **[V]** verificado em fonte pública em 2026-10-21; **[S]** suposição ou recomendação nossa, a validar com advogado.

## LGPD (Lei 13.709/2018)

- **[V] Encarregado (art. 41):** nomear e publicar o contato do encarregado pelo tratamento de dados.
- **Bases legais por tratamento:**

| Tratamento | Base legal | Artigo |
|---|---|---|
| Criar conta, entregar mensagens, chamadas | Execução de contrato | art. 7º, V **[V]** |
| Guardar registros de acesso por 6 meses | Cumprimento de obrigação legal | art. 7º, II **[V]** |
| Antifraude, anti-spam, rate limit | Legítimo interesse, com teste de balanceamento documentado | art. 7º, IX e art. 10 **[V]** |
| Crash reports | Consentimento (opt-in) | art. 7º, I **[V]** |

- **[S] RIPD** (relatório de impacto à proteção de dados): elaborar antes do beta e publicar uma versão resumida.
- **[S] Direitos do titular:** exclusão de conta pelo app em até 24h; exportação dos poucos dados que existem no servidor (conta, dispositivos, username).
- **[S] Dados de terceiros:** sem descoberta pela agenda no MVP, não tratamos números de pessoas que não são usuárias. Isso elimina a maior dor de LGPD dos mensageiros.

## Marco Civil da Internet (Lei 12.965/2014)

- **[V] Art. 15:** provedor de aplicação constituído como pessoa jurídica com fins econômicos deve guardar os **registros de acesso a aplicações** por **6 meses**, sob sigilo, em ambiente controlado e seguro.
- **[V] Art. 5º, VIII:** registro de acesso a aplicações é o conjunto de informações sobre **data e hora de uso** de uma aplicação **a partir de um endereço IP**.
- **[V] Art. 15, §2º:** autoridade pode requerer cautelarmente a guarda por prazo maior.
- **[V] Art. 15, §3º:** disponibilização depende de **ordem judicial**.
- **[V]** Regulamentação: Decreto 8.771/2016.

### Implicação para o FalaAí

Guardar IP + data/hora de acesso é **compatível** com E2EE. Não guardamos conteúdo, destinatários nem o grafo de contatos. A tabela `access_log` (ver [backend](../blueprint/03-backend-e-infra.md)) guarda só `(data/hora, IP, porta, ACI)`, cifrada em repouso, com acesso auditado e purga automática após 6 meses.

## Histórico: bloqueios do WhatsApp

- **[V]** Entre 2015 e 2016 houve quatro ordens judiciais de suspensão do WhatsApp no Brasil (Teresina em fevereiro de 2015, não executada; São Bernardo do Campo em dezembro de 2015, por 48h, derrubada em cerca de 12h; Lagarto/SE em maio de 2016; Rio de Janeiro em julho de 2016).
- **[V]** Motivo comum: descumprimento de ordens de interceptação de conteúdo que a empresa afirmava não ter como cumprir, por causa da criptografia.
- **[V] ADPF 403 e ADI 5527 (STF):** os relatores (Fachin e Rosa Weber) votaram no sentido de que o Marco Civil não autoriza exigir acesso a mensagens com E2EE nem impor enfraquecimento de criptografia, e de que a suspensão só cabe quando o provedor viola a privacidade dos usuários.
- **[S]** Não encontramos confirmação de conclusão do julgamento até esta data. Tratar como **pendente** e acompanhar.

## Postura recomendada

1. **Entidade jurídica brasileira** com representante legal identificado.
2. Documento público **"O que o FalaAí pode e não pode entregar"**, com fundamento técnico, publicado antes do lançamento.
3. **Relatório de transparência** semestral: ordens recebidas, atendidas e contestadas.
4. Procedimento interno de resposta a ordens (ver [retenção e resposta a ordens](retencao-e-resposta-a-ordens.md)).
5. Nunca manter "porta dos fundos". A melhor defesa contra bloqueio é a **impossibilidade técnica demonstrável**: código aberto, builds reproduzíveis e auditoria publicada.
