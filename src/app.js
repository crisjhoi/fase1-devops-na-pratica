// Aqui é onde eu monto a aplicação em si (o Express).
// Separei a "app" do "server" de propósito: assim nos testes eu consigo
// importar só a app e testar as rotas sem precisar subir uma porta de verdade.

const express = require("express");

function criarApp() {
  const app = express();

  // deixo o express entender JSON no corpo das requisições
  app.use(express.json());

  // vou guardar as tarefas aqui na memória mesmo.
  // é só um projeto da faculdade, então não precisa de banco de dados ainda.
  let tarefas = [];
  let proximoId = 1;

  // rota de saúde -> uso ela depois pra checar se a API tá de pé lá na AWS
  app.get("/health", (req, res) => {
    res.json({ status: "ok", horario: new Date().toISOString() });
  });

  // lista todas as tarefas
  app.get("/tarefas", (req, res) => {
    res.json(tarefas);
  });

  // pega uma tarefa específica pelo id
  app.get("/tarefas/:id", (req, res) => {
    const tarefa = tarefas.find((t) => t.id === Number(req.params.id));
    if (!tarefa) {
      // se não achou, devolvo 404 pra deixar claro que esse id não existe
      return res.status(404).json({ erro: "tarefa não encontrada" });
    }
    res.json(tarefa);
  });

  // cria uma tarefa nova
  app.post("/tarefas", (req, res) => {
    const { titulo } = req.body || {};

    // não deixo criar tarefa sem título, senão fica sem sentido
    if (!titulo || titulo.trim() === "") {
      return res.status(400).json({ erro: "o campo 'titulo' é obrigatório" });
    }

    const novaTarefa = {
      id: proximoId++,
      titulo: titulo.trim(),
      concluida: false,
    };

    tarefas.push(novaTarefa);
    // 201 = criado com sucesso
    res.status(201).json(novaTarefa);
  });

  // remove uma tarefa
  app.delete("/tarefas/:id", (req, res) => {
    const id = Number(req.params.id);
    const existia = tarefas.some((t) => t.id === id);

    if (!existia) {
      return res.status(404).json({ erro: "tarefa não encontrada" });
    }

    tarefas = tarefas.filter((t) => t.id !== id);
    // 204 = deu certo e não tenho nada pra devolver no corpo
    res.status(204).send();
  });

  return app;
}

module.exports = { criarApp };
