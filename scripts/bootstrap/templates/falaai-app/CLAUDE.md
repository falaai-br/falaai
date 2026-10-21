# falaai-app — instruções para agentes

Este repositório faz parte do **FalaAí**, mensageiro brasileiro com criptografia ponta a ponta. O blueprint completo está em https://github.com/__ORG__/falaai (pasta `docs/`). Leia o blueprint antes de decisões de arquitetura.

**Este NÃO é um repositório Nova.** Não aplicar `ai-core-basic-decisions` nem NERDs da Nova.

## Stack
Flutter (Dart 3.9+), estado em **Async Redux**, navegação `go_router`, chamadas com `flutter_webrtc` e SDK LiveKit. Núcleo em Rust (`falaai-core`) via flutter_rust_bridge (ADR-0003). Partes nativas: Notification Service Extension (Swift), CallKit/PushKit, ConnectionService.

## Licença
AGPL-3.0 (o app linka a libsignal via falaai-core).

## Convenções
- Trunk-based em `main`, squash merge, mensagens em Conventional Commits.
- Tarefas vivem como beads no Gas Town e são espelhadas em GitHub Issues (`bd github sync`). Todo PR referencia uma bead/issue.
- Documentação, issues e mensagens de commit em português; identificadores de código em inglês.

## Regras de segurança (inegociáveis)
- Nunca escrever primitivas criptográficas. Toda cripto vem da libsignal (só no `falaai-core`).
- Nunca registrar em log: telefone, par remetente/destinatário, IP completo, conteúdo, chaves, ACI em claro.
- Nenhuma tabela, tópico ou log pode guardar quem falou com quem (ADR-0008).

## Específico deste repo
- Não adicionar outro gerenciador de estado sem ADR.
- O Dart nunca manipula chaves; toda cripto passa pelo falaai-core.
- pt-BR é o idioma único no MVP; strings em ARB, nunca hardcoded.
- Alvo: Android de entrada (APK < 40 MB por ABI, cold start < 2s).
- Rodar em aparelho físico iOS e Android antes de `gt done`.
