// Esse arquivo é só o "liga a API numa porta e deixa escutando".
// Quem tem a lógica das rotas é o app.js.

const { criarApp } = require("./app");

// uso variável de ambiente pra porta porque lá na nuvem pode ser outra.
// se não vier nada, cai no 3000 mesmo.
const PORTA = process.env.PORT || 3000;

const app = criarApp();

app.listen(PORTA, () => {
  console.log(`API de Tarefas rodando na porta ${PORTA}`);
});
