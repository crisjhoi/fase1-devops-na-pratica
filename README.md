# Fase 1 — DevOps na Prática

Projeto da primeira fase da disciplina **DevOps na Prática**.
A proposta aqui é montar a base de automação: um pipeline de Integração Contínua (CI)
e os scripts de Infraestrutura como Código (IaC).

Pra ter algo concreto pra automatizar, eu construí uma **API de Tarefas** bem simples
em Node.js. Ela não é o foco da disciplina — o foco é todo o processo de DevOps
em volta dela (testes automáticos, pipeline e provisionamento da infra).

---

## O que tem nesse repositório

```
fase1-devops-na-pratica/
├── .github/workflows/ci.yml   -> o pipeline de CI (GitHub Actions)
├── src/
│   ├── app.js                 -> as rotas da API
│   └── server.js              -> sobe a API numa porta
├── tests/
│   └── tarefas.test.js        -> os testes automatizados
├── infra/
│   ├── main.tf                -> a infra na AWS (máquina EC2 + firewall)
│   ├── variables.tf           -> as configurações
│   ├── outputs.tf             -> o que o Terraform me devolve no final
│   └── scripts/user-data.sh   -> instala e sobe a API quando a máquina liga
├── docs/
│   └── documentacao-planejamento.md
└── package.json
```

---

## A API de Tarefas

É uma API REST pra gerenciar uma lista de tarefas. As rotas são:

| Método | Rota            | O que faz                        |
|--------|-----------------|----------------------------------|
| GET    | `/health`       | Diz se a API está no ar          |
| GET    | `/tarefas`      | Lista todas as tarefas           |
| GET    | `/tarefas/:id`  | Pega uma tarefa específica       |
| POST   | `/tarefas`      | Cria uma tarefa nova             |
| DELETE | `/tarefas/:id`  | Apaga uma tarefa                 |

Pra criar uma tarefa, mando um JSON assim:

```json
{ "titulo": "Estudar" }
```

---

## Como rodar na máquina

Precisa ter o [Node.js](https://nodejs.org) instalado (versão 18 ou mais nova).

```bash
# instala as dependências
npm install

# sobe a API (fica em http://localhost:3000)
npm start
```

Pra testar se está funcionando, abre no navegador: `http://localhost:3000/health`

---

## Como rodar os testes

```bash
npm test
```

Os testes usam **Jest** + **Supertest** e cobrem todas as rotas da API
(criar, listar, buscar, apagar e os casos de erro).

---

## Integração Contínua (CI)

Toda vez que der `push` ou abrir um Pull Request pra branch `main`, o
**GitHub Actions** roda o pipeline automaticamente (olha o arquivo
[`.github/workflows/ci.yml`](.github/workflows/ci.yml)). Ele faz duas coisas:

1. **Testes da aplicação** — instala o Node (nas versões 18 e 20), instala as
   dependências e roda `npm test`.
2. **Validar Terraform** — confere a formatação e valida os scripts de infra.

Se qualquer coisa falhar, o pipeline fica vermelho e já descubre na hora,
antes de subir qualquer coisa pra produção.

---

## Infraestrutura como Código (Terraform)

Os scripts da pasta `infra/` provisionam a infra na **AWS** (pensei no ambiente
do AWS Academy). Em resumo, eles sobem uma máquina EC2 com um grupo de segurança
(firewall) e, quando a máquina liga, ela mesma instala o Node e sobe a API.

```bash
cd infra

# copia o arquivo de exemplo e ajusta os valores
cp terraform.tfvars.example terraform.tfvars

terraform init      # prepara o terraform
terraform plan      # mostra o que vai ser criado
terraform apply     # cria a infra de verdade
```

No final, o Terraform mostra a URL da API já pronta pra abrir no navegador.
