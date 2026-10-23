# ADR-0010 — Sealed sender por canal não autenticado, desde a Fase 0

- **Status:** aceita
- **Data:** 2026-10-22
- **Origem:** achados de revisão nas beads flp-gdq (falaai-proto) e flc-8u3 (falaai-core)

## Contexto

O blueprint promete que o servidor não sabe quem enviou cada mensagem ([modelo de ameaças](../blueprint/01-modelo-de-ameacas.md), [segurança](../blueprint/02-seguranca-e-criptografia.md)), e a [ADR-0008](ADR-0008-fila-mutavel-sem-append-only.md) proíbe guardar quem falou com quem. Durante a Fase 0, dois problemas apareceram:

1. **Canal de envio.** Se o envelope sealed sender vai pelo WebSocket autenticado como `aci + device`, o gateway vê em memória o par remetente/destinatário a cada envio.
2. **Formato do envelope.** Na libsignal, toda `PreKeySignalMessage` leva em claro a identidade e o endereço do remetente e do destinatário. Sem sealed sender, a fila do servidor guardaria esse par até o ACK, e o destinatário não teria no envelope o tipo do ciphertext nem o remetente para decifrar.

## Decisão

1. **Sealed sender desde a Fase 0**, inclusive na demo. `Envelope.content` é sempre um `UnidentifiedSenderMessage` produzido por `sealed_sender_encrypt` da libsignal. Nenhum envelope com remetente em claro chega ao servidor.
2. **Certificado de remetente:** o `accounts` emite `SenderCertificate` de curta duração (24h), assinado por um server certificate que deriva de um trust root. O trust root público vai embutido na build do app. O servidor valida em Go, sem linkar libsignal.
3. **Canal de envio não autenticado**, como no Signal. O sealed sender é enviado por uma conexão TLS separada, sem credencial (`/v1/ws/unidentified`). O direito de enviar é provado pela *unidentified access key* de 16 bytes, derivada pela libsignal da profile key do destinatário e comparada em tempo constante. O socket responde `UNAUTHORIZED` também para destinatário inexistente, para não virar oráculo de enumeração de contas.

## Consequências

- A Fase 0 cresce de 1 a 2 semanas, e a Fase 1 de 2 a 3 semanas, com profile key, registro da access key, segundo socket no gateway e fallback no app.
- **Riscos residuais**, a declarar no modelo de ameaças:
  - Primeiro contato sem profile key do destinatário usa o socket autenticado, e o par fica exposto nesse envio.
  - Mesmo IP e horário nos dois sockets permitem correlação por rede. O gateway não registra o IP do socket não autenticado junto de nada que identifique conta.
  - Anti-abuso no caminho anônimo depende de rate limit por IP e por destinatário.
- **Jurídico:** o socket sem conta não gera registro de acesso por conta para mensagens enviadas. Conexões autenticadas continuam registradas. Precisa de confirmação no parecer sobre o art. 15 do Marco Civil ([LGPD e Marco Civil](../legal/lgpd-e-marco-civil.md)).
- **Grupos (Fase 2):** o fan-out com sealed sender exige access key por membro.
