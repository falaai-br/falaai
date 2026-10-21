# FalaAí

**Mensageiro brasileiro em que só você e quem recebe podem ler, ouvir ou ver o que é trocado.**

Mensagens, grupos, fotos, arquivos e chamadas de voz e vídeo com criptografia ponta a ponta em tudo, usando o Signal Protocol (PQXDH + Triple Ratchet, resistente a computação quântica). Empresa, dados e equipe no Brasil. Cliente de código aberto e auditável.

> Status: **planejamento**. Este repositório contém o blueprint do produto. Nada foi lançado.

## Princípios

1. Criptografia ponta a ponta em tudo, sempre.
2. Protocolo comprovado (libsignal), nunca caseiro.
3. Mínimo de metadados, com prazos de retenção públicos.
4. Código do cliente aberto, builds reproduzíveis e auditoria independente publicada.
5. Honestidade sobre o que protegemos e o que não protegemos.

## Blueprint

| Documento | Assunto |
|---|---|
| [Visão e princípios](docs/blueprint/00-visao-e-principios.md) | O que é, para quem, escopo do MVP |
| [Modelo de ameaças](docs/blueprint/01-modelo-de-ameacas.md) | Contra quem protegemos e contra quem não |
| [Segurança e criptografia](docs/blueprint/02-seguranca-e-criptografia.md) | PQXDH, Triple Ratchet, grupos, mídia, chamadas, PIN, backup |
| [Backend e infraestrutura](docs/blueprint/03-backend-e-infra.md) | Servidor Go, dados mínimos, escala, hospedagem, diagrama C4 |
| [Cliente](docs/blueprint/04-cliente.md) | Flutter + núcleo Rust, push, chamadas, segurança no aparelho |
| [Roadmap](docs/blueprint/05-roadmap.md) | Fases 0 a 4, critérios de saída, riscos |
| [Custos](docs/blueprint/06-custos.md) | Infraestrutura para 100 mil usuários |
| [LGPD e Marco Civil](docs/legal/lgpd-e-marco-civil.md) | Bases legais, art. 15, histórico de bloqueios |
| [Retenção e resposta a ordens](docs/legal/retencao-e-resposta-a-ordens.md) | O que existe no servidor e o que pode ser entregue |
| [Licenciamento](docs/legal/licenciamento-agpl.md) | libsignal, AGPL e App Store |
| [ADRs](docs/adr/) | Decisões de arquitetura |

## Repositórios

| Repositório | Conteúdo | Licença |
|---|---|---|
| `falaai` | Blueprint, ADRs, jurídico | CC-BY-SA 4.0 |
| `falaai-core` | Núcleo Rust sobre a libsignal | AGPL-3.0 |
| `falaai-app` | App Flutter (Android e iOS) | AGPL-3.0 |
| `falaai-proto` | Contratos protobuf cliente/servidor | Apache-2.0 |
| `falaai-server` | Servidor Go | Privado |
| `falaai-infra` | Infraestrutura (Pulumi) | Privado |

## Como o trabalho é organizado

A construção é orquestrada por agentes no [Gas Town](https://github.com/steveyegge/gastown), com uma rig por repositório. As tarefas vivem como beads e são espelhadas em GitHub Issues. Para recriar o ambiente, veja [scripts/bootstrap](scripts/bootstrap/README.md).

## Segurança

Encontrou uma vulnerabilidade? Veja [SECURITY.md](SECURITY.md).
