// sobe a API numa porta. as rotas estão no app.js.

const { criarApp } = require("./app");

// porta vem da variável de ambiente; sem ela, usa 3000
const PORTA = process.env.PORT || 3000;

const app = criarApp();

app.listen(PORTA, () => {
  console.log(`API de Tarefas rodando na porta ${PORTA}`);
});
