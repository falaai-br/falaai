# 07 — Qualidade e pipeline

O FalaAí **não usa CI remoto** (nada de GitHub Actions). O pipeline completo de boas práticas roda **localmente nos git hooks** versionados em cada repositório e, de novo, no **Refinery do Gas Town** antes de qualquer merge. Ver [ADR-0009](../adr/ADR-0009-qualidade-em-git-hooks-sem-ci-remoto.md).

## Um comando, três lugares

Todo repositório tem um `Makefile` com a mesma interface. Os comandos vivem só no Makefile; hooks e Gas Town apenas o chamam.

| Alvo | O que faz |
|---|---|
| `make tools` | Instala as ferramentas pinadas e ativa os hooks (`core.hooksPath=.githooks`) |
| `make fmt` | Formata |
| `make lint` | Formatação em modo verificação e lint estático |
| `make test` | Testes unitários (com race e cobertura onde se aplica) |
| `make test-integration` | Testes de integração |
| `make security` | Vulnerabilidades em dependências, análise estática de segurança, segredos |
| `make build` | Build de verificação |
| `make check-fast` | Subconjunto rápido para o pre-commit |
| `make check` | `lint` + `test` + `test-integration` + `security` + `build` |

## Onde o pipeline roda

| Momento | Quem | Comando | Bloqueia? |
|---|---|---|---|
| `git commit` | hook `pre-commit` | `make check-fast` | Sim |
| `git commit` | hook `commit-msg` | Conventional Commits | Sim |
| `git push` | hook `pre-push` | `make check` | Sim |
| Antes de `gt done` | polecat (etapa *pre-verify*, após rebase) | `make lint`, `make check`, `make build` | Sim |
| Antes do merge | Refinery, gate `check` (pre-merge) | `make check` | Sim |
| Depois do squash, antes do push | Refinery, gate `build-merged` (post-squash) | `make build` | Sim; reseta o merge se falhar |
| Revisão | Refinery com `judgment_enabled` | Revisão de qualidade por agente | Sim |

Hooks são bloqueantes. `FALAAI_SKIP_HOOKS=1` existe para emergência humana; agentes não podem usar. O Refinery repete o gate, então pular o hook não pula a verificação.

## Pipeline por repositório

| Repositório | Lint | Testes unitários | Integração | Segurança | Build |
|---|---|---|---|---|---|
| `falaai-core` (Rust) | `cargo fmt --check`, `clippy -D warnings`, lints de crate (`unsafe_code`, `unwrap_used`) | `cargo test --lib` | `cargo test --test '*'`: dois cores trocando mensagens, SQLCipher real | `cargo deny` (licenças, advisories, fontes git permitidas), `cargo audit`, gitleaks | `cargo build --release`; `make build-mobile` nas beads de build |
| `falaai-app` (Flutter) | `dart format`, `flutter analyze` estrito | `flutter test --coverage` | `test_integration/` sem aparelho; `make test-device` em aparelho, como critério de saída | `osv-scanner` no `pubspec.lock`, gitleaks | `flutter build apk --debug` |
| `falaai-proto` | `buf format`, `buf lint` | `buf breaking` contra a `main` | — | gitleaks | `buf generate` e verificação de código gerado desatualizado |
| `falaai-server` (Go) | `gofmt`, `go vet`, `golangci-lint` estrito (proíbe `fmt.Print` e import de libsignal), `sqlc vet` | `go test -race` + cobertura mínima de 85% nos pacotes `domain` | `go test -tags integration` com testcontainers (Postgres, Redis) e testes de contrato com vetores do core | `gosec`, `govulncheck`, gitleaks | `go build`, `sqlc diff` |
| `falaai-infra` (Pulumi Go) | `gofmt`, `go vet`, `golangci-lint`, `shellcheck` | `go test` com mocks do Pulumi | `docker compose config` | `gosec`, `govulncheck`, gitleaks | `go build` |
| `falaai` (docs) | `markdownlint-cli2`, `shellcheck` | links internos | `make -n check` em cada template | gitleaks | — |

Todas as versões de ferramentas são pinadas no Makefile de cada repositório.

## Por que não CI remoto

- O trabalho é feito por agentes no Gas Town; o Refinery já é o ponto único de merge e roda os gates.
- Feedback em segundos no commit e em minutos no push, sem fila de runners.
- Sem segredos em plataforma de CI e menos superfície de ataque na cadeia de build.
- Custo: dois lugares rodam o mesmo comando; a máquina que roda o Refinery precisa ter todas as ferramentas.

## Quando o pipeline mudar

1. Mude o alvo no Makefile do repositório (e no template em `scripts/bootstrap/templates/`).
2. Atualize a tabela deste documento.
3. O Refinery pega a mudança automaticamente, porque chama `make check`.
