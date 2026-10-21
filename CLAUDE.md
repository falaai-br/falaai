# falaai — instruções para agentes

Repositório de **documentação** do FalaAí: blueprint, ADRs, jurídico e scripts de bootstrap. Não contém código de produto.

**Este NÃO é um repositório Nova.** Não aplicar `ai-core-basic-decisions` nem NERDs da Nova.

## Regras
- Escrever em português do Brasil, frases curtas, sem marketing.
- Fatos externos (leis, versões de bibliotecas, preços) marcados com **[V]** (verificado, com fonte) ou **[S]** (suposição/recomendação).
- Mudança de decisão de arquitetura = nova ADR em `docs/adr/` (ou ADR existente marcada como substituída). Nunca reescrever uma ADR aceita.
- Epics de fase vivem nesta rig (prefixo de beads `flh`); tarefas de código vivem nas rigs de cada repositório.
- Trunk-based em `main`, squash merge, Conventional Commits.
