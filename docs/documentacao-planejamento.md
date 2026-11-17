# Documentação de Planejamento — Fase 1

**Disciplina:** DevOps na Prática
**Fase:** 1 — Configuração e Automação Inicial
**Estudante:** Joyce Cristina do Nascimento Souza

> **Repositório do projeto:** https://github.com/crisjhoi/fase1-devops-na-pratica

---

## a) Descrição do projeto, seus objetivos e requisitos

### Descrição

O projeto é uma **API de Tarefas** em Node.js, usada como base para aplicar na
prática os conceitos de DevOps desta fase. A aplicação é simples de propósito
(criar, listar, buscar e apagar tarefas), porque o foco não é a complexidade do
software, e sim **todo o processo de automação em volta dele**: testes
automatizados, integração contínua e provisionamento de infraestrutura como
código.

A ideia é reproduzir, em escala pequena, o fluxo que uma equipe usaria: o código
fica versionado no GitHub, cada alteração passa por um pipeline que roda os testes
automaticamente, e a infraestrutura onde a aplicação roda é descrita em código.

### Objetivos

- Implementar um pipeline de **Integração Contínua (CI)** que rode os testes de
  forma automática a cada alteração no código.
- Garantir a qualidade do código com **testes automatizados** integrados ao
  pipeline.
- Descrever a infraestrutura em **código (IaC)** com Terraform, de forma repetível.
- Versionar o projeto com Git/GitHub.

### Requisitos

**Funcionais (da aplicação):**
- Criar uma tarefa informando um título.
- Listar todas as tarefas cadastradas.
- Consultar uma tarefa específica pelo identificador.
- Remover uma tarefa.
- Disponibilizar uma rota de verificação de saúde (`/health`).

**Não funcionais / técnicos:**
- O código versionado em um repositório no GitHub.
- Cada `push` ou Pull Request dispara o pipeline de CI.
- Os testes automatizados rodam dentro do pipeline.
- A infraestrutura é provisionada por scripts (Terraform), sem configuração manual.
- A solução roda no ambiente da AWS (AWS Academy).

**Ferramentas utilizadas:**
- **Node.js + Express** — aplicação.
- **Jest + Supertest** — testes automatizados.
- **Git + GitHub** — versionamento.
- **GitHub Actions** — pipeline de CI.
- **Terraform** — infraestrutura como código.
- **AWS (EC2)** — ambiente onde a aplicação roda.

---

## b) Plano de Integração Contínua

A Integração Contínua é a prática de integrar as alterações de código com
frequência, validando cada uma automaticamente. A cada integração o pipeline roda
sozinho e avisa se algo quebrou — os problemas aparecem cedo, e não só na entrega.

### Organização do pipeline

O pipeline foi implementado com **GitHub Actions** e fica no arquivo
`.github/workflows/ci.yml`.

**Quando dispara:**
- A cada `push` na branch `main`.
- A cada **Pull Request** aberto para a `main`.

**O que executa (em dois jobs paralelos):**

1. **Testes da aplicação**
   - Baixa o código do repositório.
   - Instala o Node.js (versões **18** e **20** ao mesmo tempo, via *matrix*, para
     garantir compatibilidade).
   - Instala as dependências com `npm ci`.
   - Roda os testes automatizados com `npm test`.

2. **Validação da Infraestrutura**
   - Baixa o código.
   - Instala o Terraform.
   - Confere a formatação dos arquivos (`terraform fmt -check`).
   - Inicializa e valida os scripts (`terraform init` + `terraform validate`).

### Critério de sucesso

O pipeline só fica **verde** se todos os testes passarem e se os scripts de
infraestrutura forem válidos. Se qualquer etapa falhar, o GitHub marca o commit
com um ❌ e envia um aviso, impedindo que um código quebrado passe despercebido.

### Fluxo de trabalho

1. A alteração é feita em uma branch.
2. Abre-se um Pull Request para a `main`.
3. O pipeline roda automaticamente os testes e a validação.
4. O merge só acontece depois que o pipeline fica verde.

---

## c) Especificação detalhada da infraestrutura necessária

A infraestrutura foi descrita como código com **Terraform**, na pasta `infra/`.
Foi pensada para o ambiente do **AWS Academy (Learner Lab)**, que tem limitações
(região fixa, tipos de máquina restritos e uso de um perfil pré-criado).

### Recursos provisionados

| Recurso | Descrição |
|---|---|
| **VPC padrão** (data source) | A VPC padrão da conta é reutilizada — mais simples e evita problemas de permissão no Academy. |
| **AMI Amazon Linux 2023** (data source) | A imagem mais recente é buscada dinamicamente, sem deixar um ID fixo que envelhece. |
| **Security Group** | Funciona como firewall. Libera a porta da aplicação (3000) e a porta 22 (SSH), e libera a saída de internet (para a máquina baixar o Node e as dependências). |
| **Instância EC2** (`t3.micro`) | A máquina virtual onde a API roda. Ao ligar, executa o script de *user-data*. |
| **Script de user-data** | Instala o Node, baixa o código do repositório, instala as dependências e sobe a API como um serviço do systemd (que reinicia sozinho se cair). |

### Parâmetros (variáveis)

Nada fica chumbado no código: tudo que pode mudar é variável em `variables.tf` —
região da AWS, tipo da instância, porta da aplicação, URL do repositório, perfil
IAM (o `LabInstanceProfile` do Academy) e a faixa de IP liberada para SSH.

### Saídas (outputs)

Depois do `terraform apply`, o Terraform devolve o IP público, o DNS público e a
URL pronta da API, já apontando para a rota `/health`.

### Considerações de segurança e custo

- **Segurança:** o acesso SSH é liberado por uma variável; o ideal, num cenário
  real, é restringir essa faixa apenas ao IP necessário. Os arquivos de estado do
  Terraform (`*.tfstate`) e as variáveis locais (`*.tfvars`) ficam fora do Git,
  porque podem conter informações sensíveis.
- **Custo:** a instância é `t3.micro` (dentro da faixa permitida no Academy) e, ao
  terminar os testes, tudo é destruído com `terraform destroy` para não gastar
  crédito à toa.

---

### Conteúdo das próximas seções

O código completo do **pipeline de CI** (Seção 2) e dos **scripts de IaC**
(Seção 3) está no repositório do GitHub indicado no início deste documento.
