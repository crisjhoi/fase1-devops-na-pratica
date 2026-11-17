// testes das rotas da API com supertest (sem subir servidor de verdade).

const request = require("supertest");
const { criarApp } = require("../src/app");

describe("API de Tarefas", () => {
  let app;

  // app nova a cada teste (as tarefas ficam em memória)
  beforeEach(() => {
    app = criarApp();
  });

  test("GET /health deve responder que está ok", async () => {
    const resposta = await request(app).get("/health");

    expect(resposta.status).toBe(200);
    expect(resposta.body.status).toBe("ok");
  });

  test("GET /tarefas deve começar com uma lista vazia", async () => {
    const resposta = await request(app).get("/tarefas");

    expect(resposta.status).toBe(200);
    expect(resposta.body).toEqual([]);
  });

  test("POST /tarefas deve criar uma tarefa quando mando um título", async () => {
    const resposta = await request(app)
      .post("/tarefas")
      .send({ titulo: "Estudar pra prova de DevOps" });

    expect(resposta.status).toBe(201);
    expect(resposta.body.id).toBe(1);
    expect(resposta.body.titulo).toBe("Estudar pra prova de DevOps");
    expect(resposta.body.concluida).toBe(false);
  });

  test("POST /tarefas sem título deve dar erro 400", async () => {
    const resposta = await request(app).post("/tarefas").send({});

    expect(resposta.status).toBe(400);
    expect(resposta.body.erro).toBeDefined();
  });

  test("GET /tarefas/:id deve devolver a tarefa que eu criei", async () => {
    await request(app).post("/tarefas").send({ titulo: "Comprar café" });

    const resposta = await request(app).get("/tarefas/1");

    expect(resposta.status).toBe(200);
    expect(resposta.body.titulo).toBe("Comprar café");
  });

  test("GET /tarefas/:id de um id que não existe deve dar 404", async () => {
    const resposta = await request(app).get("/tarefas/999");

    expect(resposta.status).toBe(404);
  });

  test("DELETE /tarefas/:id deve apagar a tarefa", async () => {
    await request(app).post("/tarefas").send({ titulo: "Tarefa pra apagar" });

    const delecao = await request(app).delete("/tarefas/1");
    expect(delecao.status).toBe(204);

    const busca = await request(app).get("/tarefas/1");
    expect(busca.status).toBe(404);
  });
});
