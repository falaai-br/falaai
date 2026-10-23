# Licenciamento: libsignal e AGPLv3

> Validar com advogado especializado em licenças de software. Legenda: **[V]** verificado em 2026-10-21; **[S]** nossa interpretação.

## Fatos

- **[V]** A `libsignal` (Rust) é licenciada sob **AGPL-3.0**, sem exceções adicionais.
- **[V]** A Signal informa que uso externo não é suportado e que a API pode mudar sem aviso.
- **[V]** Não há permissão adicional (§7) para distribuição via Apple App Store na libsignal Rust atual. A issue [signalapp/libsignal#684](https://github.com/signalapp/libsignal/issues/684) segue aberta. A antiga `libsignal-protocol-c` tinha essa exceção.

## Consequências

| Componente | Linka libsignal? | Licença | Visibilidade |
|---|---|---|---|
| `falaai-core` | Sim | AGPL-3.0 | Público |
| `falaai-app` | Sim (via core) | AGPL-3.0 | Público |
| `falaai-proto` | Não | Apache-2.0 | Público |
| `falaai-server` | **Não** | Proprietária | Privado |
| `falaai-signer` | Sim | AGPL-3.0 | Público |
| `falaai-infra` | Não | Proprietária | Privado |
| `falaai` (docs) | Não | CC-BY-SA 4.0 | Público |

- **[S] Servidor:** pode ser fechado **enquanto não linkar** libsignal, zkgroup ou outro código AGPL. O servidor não verifica assinaturas criptográficas; quem verifica é a libsignal no cliente. Se no futuro adotarmos zkgroup ou SVR no servidor, essas partes ficam sob AGPL (cláusula de rede) e precisam ser publicadas.
- **[S] Recomendação:** publicar o servidor também, mesmo sem obrigação. Reforça a tese "100% auditável". A decisão atual é mantê-lo privado; revisável.

## Risco App Store

A distribuição de software AGPL pela App Store tem conflito conhecido entre os termos da Apple e a liberdade de redistribuição da GPL/AGPL. Sem exceção §7 da Signal:

1. **[S]** Pedir confirmação formal à Signal Foundation (comentar na issue #684 e escrever diretamente).
2. **[S]** Obter parecer jurídico antes de publicar na App Store.
3. **[S]** Como somos os titulares do código do FalaAí, podemos adicionar exceção §7 ao **nosso** código. Isso não cobre o binário da libsignal.
4. Risco percebido: baixo a médio (não há histórico conhecido de ação judicial), mas precisa estar resolvido antes da Fase 4.

## Obrigações práticas da AGPL no cliente

- Publicar o código-fonte correspondente de cada versão distribuída (tags no GitHub batendo com as versões das lojas).
- Incluir a licença e os avisos de copyright no app (tela "Sobre").
- Builds reproduzíveis no Android para que qualquer pessoa confira que o APK corresponde ao código.
