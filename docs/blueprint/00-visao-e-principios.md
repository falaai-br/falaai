# 00 — Visão e princípios

## O que é o FalaAí

Um aplicativo de mensagens e chamadas **brasileiro**, para o público brasileiro, em que **só você e quem recebe podem ler, ouvir ou ver** o que é trocado. Nem a empresa, nem um invasor do servidor, nem uma ordem judicial conseguem extrair o conteúdo, porque a empresa nunca tem as chaves.

## Para quem

- Qualquer pessoa que use WhatsApp/Telegram e queira uma alternativa nacional, sem precisar entender criptografia.
- Jornalistas, advogados, profissionais de saúde, ativistas e empresas que precisam de sigilo demonstrável.

## Princípios (inegociáveis)

1. **Criptografia ponta a ponta em tudo, sempre.** Mensagens 1:1, grupos, mídia, chamadas, backups. Não existe "modo inseguro" nem "chat em nuvem".
2. **Protocolo comprovado, nunca caseiro.** Usamos o Signal Protocol via `libsignal`, a implementação de referência auditada. Não escrevemos primitivas criptográficas.
3. **Mínimo de metadados.** O servidor guarda apenas o que é tecnicamente necessário para entregar mensagens, ou o que a lei brasileira obriga. Tudo tem prazo de retenção público.
4. **Auditável.** O cliente (app e núcleo criptográfico) é código aberto sob AGPLv3, com builds reproduzíveis no Android. Auditoria independente publicada antes do lançamento público.
5. **Honestidade sobre limites.** Publicamos o que protegemos e o que não protegemos (ver [modelo de ameaças](01-modelo-de-ameacas.md)). Nada de marketing de "100% inviolável".
6. **Brasileiro de verdade.** Empresa, sede, dados e equipe no Brasil; português como primeira língua; pensado para Android de entrada e redes móveis instáveis.
7. **Sem telemetria por padrão.** Relatórios de falha só com consentimento explícito e sem conteúdo.

## O que o FalaAí NÃO é

- Não é rede social nem canal de broadcast em massa no MVP.
- Não é anônimo: o registro usa número de telefone (o número fica oculto para os outros por padrão; username opcional).
- Não protege contra um aparelho já comprometido por spyware.

## Escopo do MVP

| Incluído | Fora do MVP |
|---|---|
| Texto 1:1 | Múltiplos dispositivos vinculados (desktop/tablet) |
| Grupos até 256 pessoas | Descoberta de contatos pela agenda |
| Fotos, vídeos e arquivos cifrados | Key transparency (verificação automática de chaves) |
| Chamadas de voz e vídeo 1:1 | Grupos zero-knowledge (zkgroup) |
| Chamadas em grupo via SFU com frame encryption | Canais/comunidades |
| Recibos, digitação, mensagens efêmeras | Pagamentos |
| Safety numbers, PIN de registro, backup cifrado | Registro sem número de telefone |

## Mapa dos documentos

- [01 — Modelo de ameaças](01-modelo-de-ameacas.md)
- [02 — Segurança e criptografia](02-seguranca-e-criptografia.md)
- [03 — Backend e infraestrutura](03-backend-e-infra.md)
- [04 — Cliente (app + núcleo)](04-cliente.md)
- [05 — Roadmap](05-roadmap.md)
- [06 — Custos](06-custos.md)
- [07 — Qualidade e pipeline](07-qualidade-e-pipeline.md)
- [Jurídico: LGPD e Marco Civil](../legal/lgpd-e-marco-civil.md)
- [Jurídico: retenção e resposta a ordens](../legal/retencao-e-resposta-a-ordens.md)
- [Jurídico: licenciamento AGPL](../legal/licenciamento-agpl.md)
- [Decisões de arquitetura (ADRs)](../adr/)
