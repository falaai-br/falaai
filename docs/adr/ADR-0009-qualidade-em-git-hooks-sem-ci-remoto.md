# ADR-0009 — Pipeline de qualidade em git hooks, sem CI remoto

- **Status:** aceita
- **Data:** 2026-10-21

## Contexto

O projeto é construído por agentes orquestrados pelo Gas Town, e o merge para a `main` passa pelo Refinery. A decisão do projeto é não usar GitHub Actions nem outro CI remoto. Mesmo assim, o pipeline completo de boas práticas (formatação, lint, testes unitários, testes de integração, segurança e build) precisa rodar sempre.

## Decisão

1. Cada repositório tem um `Makefile` com interface única (`tools`, `fmt`, `lint`, `test`, `test-integration`, `security`, `build`, `check-fast`, `check`).
2. Os git hooks versionados em `.githooks/` são **bloqueantes**: `pre-commit` roda `make check-fast`, `commit-msg` exige Conventional Commits e `pre-push` roda `make check`. `make tools` ativa os hooks no clone.
3. As rigs do Gas Town configuram `merge_queue` para chamar o mesmo Makefile (`setup_command=make tools`, `lint_command=make lint`, `test_command=make check`, `build_command=make build`), com revisão por agente (`judgment_enabled`) e merge via PR no GitHub. Gates nomeados pós-squash ficam para quando o Gas Town suportá-los.
4. Nenhum arquivo em `.github/workflows/`.

## Consequências

- O mesmo comando roda no commit, no push, no polecat e no Refinery; não há divergência entre "local" e "CI".
- A máquina que roda o Gas Town precisa ter todas as ferramentas instaladas (`make tools` em cada rig).
- Testes que exigem aparelho físico (`make test-device`) não cabem em hook; são critério de saída das beads de UI.
- Se no futuro houver contribuidores externos, um CI remoto pode ser reavaliado em nova ADR.
