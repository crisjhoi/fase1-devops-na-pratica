# Documentação de Planejamento — Fase 1

**Disciplina:** DevOps na Prática
**Fase:** 1 — Configuração e Automação Inicial
**Estudante:** Joyce Cristina do Nascimento Souza

> **Repositório do projeto:** https://github.com/crisjhoi/fase1-devops-na-pratica

---

## a) Descrição do projeto, seus objetivos e requisitos

### Descrição

O projeto consiste em uma **API de Tarefas** desenvolvida em Node.js, usada como
base para aplicar na prática os conceitos de DevOps estudados nesta fase. A
aplicação em si é propositalmente simples (criar, listar, buscar e apagar
tarefas), porque o objetivo da disciplina não é a complexidade do software, e sim
**todo o processo de automação em volta dele**: testes automatizados, integração
contínua e provisionamento de infraestrutura como código.

A ideia é reproduzir, em escala pequena, o fluxo que uma equipe de verdade usaria:
o código fica versionado no GitHub, cada alteração passa por um pipeline que roda
os testes automaticamente, e a infraestrutura onde a aplicação roda é descrita em
código (e não configurada na mão).

### Objetivos

- Implementar um pipeline de **Integração Contínua (CI)** que rode os testes de
  forma automática a cada alteração no código.
- Garantir a qualidade do código por meio de **testes automatizados** integrados
  ao pipeline.
- Descrever a infraestrutura em **código (IaC)** usando Terraform, de forma que ela
  possa ser criada e destruída de maneira repetível.
- Praticar o versionamento do projeto com Git/GitHub.

### Requisitos

**Funcionais (da aplicação):**
- Permitir criar uma tarefa informando um título.
- Listar todas as tarefas cadastradas.
- Consultar uma tarefa específica pelo seu identificador.
- Remover uma tarefa.
- Disponibilizar uma rota de verificação de saúde (`/health`).

**Não funcionais / técnicos:**
- O código deve ficar versionado em um repositório no GitHub.
- Cada `push` ou Pull Request deve disparar o pipeline de CI.
- Os testes automatizados devem rodar dentro do pipeline.
- A infraestrutura deve ser provisionada por scripts (Terraform), sem configuração
  manual.
- A solução deve rodar no ambiente da AWS (AWS Academy).

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
frequência, validando cada uma delas automaticamente. A cada integração, o
pipeline roda sozinho e avisa se algo quebrou — assim os problemas aparecem cedo,
e não só na hora de entregar.

### Como o pipeline está organizado

O pipeline foi implementado com **GitHub Actions** e fica descrito no arquivo
`.github/workflows/ci.yml`.

**Quando ele dispara:**
- A cada `push` na branch `main`.
- A cada **Pull Request** aberto para a `main`.

**O que ele executa (em dois jobs paralelos):**

1. **Testes da aplicação**
   - Baixa o código do repositório.
   - Instala o Node.js (testa nas versões **18** e **20** ao mesmo tempo, usando
     uma *matrix*, pra garantir compatibilidade).
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

### Fluxo de trabalho pensado

1. Faço a alteração em uma branch.
2. Abro um Pull Request para a `main`.
3. O pipeline roda automaticamente os testes e a validação.
4. Só faço o *merge* depois que o pipeline fica verde.

---

## c) Especificação detalhada da infraestrutura necessária

A infraestrutura foi descrita como código com **Terraform**, na pasta `infra/`.
Ela foi pensada para o ambiente do **AWS Academy (Learner Lab)**, que tem algumas
limitações (região fixa, tipos de máquina restritos e uso de um perfil pré-criado).

### Recursos provisionados

| Recurso | Descrição |
|---|---|
| **VPC padrão** (data source) | Em vez de criar uma rede do zero, reutilizo a VPC padrão da conta — mais simples e evita problemas de permissão no Academy. |
| **AMI Amazon Linux 2023** (data source) | Busco dinamicamente a imagem mais recente, pra não deixar um ID de imagem fixo que envelhece. |
| **Security Group** | Funciona como firewall. Libera a porta da aplicação (3000) e a porta 22 (SSH) para acesso, e libera a saída de internet (pra máquina baixar o Node e as dependências). |
| **Instância EC2** (`t3.micro`) | A máquina virtual onde a API roda. Quando ela liga, executa o script de *user-data*. |
| **Script de user-data** | Instala o Node, baixa o código do repositório, instala as dependências e sobe a API como um serviço do systemd (que reinicia sozinho se cair). |

### Parâmetros (variáveis)

Nada fica chumbado no código: tudo que pode mudar virou variável em
`variables.tf` — região da AWS, tipo da instância, porta da aplicação, URL do
repositório, perfil IAM (o `LabInstanceProfile` do Academy) e a faixa de IP
liberada para SSH.

### Saídas (outputs)

Depois do `terraform apply`, o Terraform devolve o IP público, o DNS público e a
URL pronta da API, já apontando para a rota `/health`.

### Considerações de segurança e custo

- **Segurança:** o acesso SSH está liberado por uma variável; o ideal, num cenário
  real, é restringir essa faixa apenas ao meu IP. Os arquivos de estado do
  Terraform (`*.tfstate`) e as variáveis locais (`*.tfvars`) ficam fora do Git,
  porque podem conter informações sensíveis.
- **Custo:** uso a instância `t3.micro` (dentro da faixa permitida no Academy) e,
  ao terminar os testes, destruo tudo com `terraform destroy` pra não gastar
  crédito à toa.

---

### Conteúdo das próximas seções

O código completo do **pipeline de CI** (Seção 2) e dos **scripts de IaC**
(Seção 3) está no repositório do GitHub indicado no início deste documento.
