// aplicação Express com as rotas da API.
// separo app e server pra conseguir testar as rotas sem subir uma porta.

const express = require("express");

function criarApp() {
  const app = express();

  // lê JSON do corpo das requisições
  app.use(express.json());

  // tarefas guardadas em memória
  let tarefas = [];
  let proximoId = 1;

  // checa se a API está no ar
  app.get("/health", (req, res) => {
    res.json({ status: "ok", horario: new Date().toISOString() });
  });

  // lista as tarefas
  app.get("/tarefas", (req, res) => {
    res.json(tarefas);
  });

  // busca uma tarefa pelo id
  app.get("/tarefas/:id", (req, res) => {
    const tarefa = tarefas.find((t) => t.id === Number(req.params.id));
    if (!tarefa) {
      return res.status(404).json({ erro: "tarefa não encontrada" });
    }
    res.json(tarefa);
  });

  // cria uma tarefa
  app.post("/tarefas", (req, res) => {
    const { titulo } = req.body || {};

    // título é obrigatório
    if (!titulo || titulo.trim() === "") {
      return res.status(400).json({ erro: "o campo 'titulo' é obrigatório" });
    }

    const novaTarefa = {
      id: proximoId++,
      titulo: titulo.trim(),
      concluida: false,
    };

    tarefas.push(novaTarefa);
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
    res.status(204).send();
  });

  return app;
}

module.exports = { criarApp };
