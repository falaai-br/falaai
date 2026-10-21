# falaai-core — instruções para agentes

Este repositório faz parte do **FalaAí**, mensageiro brasileiro com criptografia ponta a ponta. O blueprint completo está em https://github.com/__ORG__/falaai (pasta `docs/`). Leia o blueprint antes de decisões de arquitetura.

**Este NÃO é um repositório Nova.** Não aplicar `ai-core-basic-decisions` nem NERDs da Nova.

## Stack
Rust (edição 2021, toolchain pinada em rust-toolchain.toml). libsignal como dependência git **pinada por commit** (ADR-0001). SQLCipher via rusqlite. Bindings para Flutter via flutter_rust_bridge 2.x.

## Licença
AGPL-3.0 (exigência da libsignal).

## Convenções
- Trunk-based em `main`, squash merge, mensagens em Conventional Commits.
- Tarefas vivem como beads no Gas Town e são espelhadas em GitHub Issues (`bd github sync`). Todo PR referencia uma bead/issue.
- Documentação, issues e mensagens de commit em português; identificadores de código em inglês.

## Regras de segurança (inegociáveis)
- Nunca escrever primitivas criptográficas. Toda cripto vem da libsignal (só no `falaai-core`).
- Nunca registrar em log: telefone, par remetente/destinatário, IP completo, conteúdo, chaves, ACI em claro.
- Nenhuma tabela, tópico ou log pode guardar quem falou com quem (ADR-0008).

## Específico deste repo
- Rust só existe aqui (ADR-0002). Mantenha o crate pequeno: wrapper de protocolo, stores, storage, messaging, transport, media, api.
- Material de chave nunca atravessa o FFI para o Dart.
- Use `zeroize` em todo buffer com segredo.
- `cargo fmt`, `cargo clippy -D warnings`, `cargo deny check`, `cargo test` antes de `gt done`.
