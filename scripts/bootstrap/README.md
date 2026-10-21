# Bootstrap do FalaAí

Recria do zero a estrutura do projeto: repositórios no GitHub, labels, rigs do Gas Town, beads das fases espelhadas em GitHub Issues e o convoy da Fase 0. O script é idempotente.

## Pré-requisitos

1. Organização no GitHub criada manualmente em https://github.com/organizations/plan (plano Free). O nome `falaai` pertence a outro usuário; o padrão é `falaai-br`.
2. `gh` autenticado com escopo `repo` e acesso de owner na organização.
3. Chave SSH cadastrada no GitHub (os rigs usam `git@github.com:...`).
4. Gas Town (`gt`) e beads (`bd`) instalados, com workspace em `~/gt`.
5. Este diretório já é um repositório git com o commit inicial do blueprint.

## Uso

```bash
ORG=falaai-br scripts/bootstrap/bootstrap.sh            # todas as etapas
ORG=falaai-br scripts/bootstrap/bootstrap.sh seed sync  # só algumas
```

Etapas, nesta ordem: `repos`, `labels`, `rigs`, `github`, `seed`, `sync`, `convoy`.

## O que é criado

| Repositório | Rig | Prefixo | Visibilidade |
|---|---|---|---|
| `falaai` | `falaai` | `flh` | público |
| `falaai-core` | `falaai_core` | `flc` | público |
| `falaai-app` | `falaai_app` | `fla` | público |
| `falaai-proto` | `falaai_proto` | `flp` | público |
| `falaai-server` | `falaai_server` | `fls` | privado |
| `falaai-infra` | `falaai_infra` | `fli` | privado |

- Rig `falaai`: 5 epics (Fases 0 a 4, encadeados) e 3 tarefas jurídicas.
- Demais rigs: as tarefas da Fase 0, com dependências internas.
- Convoy "FalaAí Fase 0" rastreando o epic e todas as tarefas da Fase 0.

## Depois do bootstrap

O script não inicia agentes. Para começar a Fase 0:

```bash
cd ~/gt
gt rig start falaai_core falaai_proto falaai_server falaai_app falaai_infra
gt ready                       # o que está desbloqueado
gt sling <bead> <rig>          # despacha para um polecat
gt convoy list                 # acompanha a fase
```

As issues no GitHub são espelho das beads. Para trazer comentários e mudanças feitas no GitHub, rode `bd github sync` dentro da rig.
