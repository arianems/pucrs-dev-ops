[![CI - Build and test solution](https://github.com/arianems/pucrs-dev-ops/actions/workflows/build-and-test.yml/badge.svg?branch=main)](https://github.com/arianems/pucrs-dev-ops/actions/workflows/build-and-test.yml)

[![CD - Deploy Application](https://github.com/arianems/pucrs-dev-ops/actions/workflows/deploy.yml/badge.svg)](https://github.com/arianems/pucrs-dev-ops/actions/workflows/deploy.yml)


# Projeto DevOps - Na Prática

Projeto desenvolvido de acordo com os requisitos das fases 01 e 02 da disciplina "DevOps na Prática", do curso de Análise e Desenvolvimento de Sistemas (PUCRS).


### Sobre a aplicação

Ferramenta web para codificar e decodificar strings em Base64, implementada utilizando o Blazor. O deployment será realizado em AWS ECS via Docker. Nosso objetivo é demonstrar um pipeline completo de CI/CD de uma aplicação conteinerizada por meio de workflows do GitHub Actions e com infraestrutura gerenciada por Terraform, considerando os requisitos das fases 01 e 02 da disciplina.

Para rodar a aplicação, após clonar o repositório, execute o comando abaixo no diretório `src/DevOps.App/DevOps.App`:

`dotnet run`

