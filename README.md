# Tech Interview RD Station - Carrinho de Compras

API de gerenciamento de carrinhos de compra. Este projeto é um teste técnico para o processo seletivo da RD Station.

## Requisitos basicos
- Ruby 3.3.1
- Rails 7.1.3.2
- PostgreSQL 16
- Redis 7.0.15

Nota: O arquivo que era o README anterior foi renomeado para [README_REQUISITOS.md](README_REQUISITOS.md).

## Variaveis de ambiente
Crie um arquivo `.env` na raíz da aplicação com as URLs de banco e Redis:

```
DATABASE_URL=postgres://postgres:password@127.0.0.1:5432/store
REDIS_URL=redis://127.0.0.1:6379/0
```

Para testes, ajuste `.env.test` caso necessario. Ele já existe com valores default.

## Execução local (sem Docker)
1. Tenha PostgreSQL e Redis rodando em seu ambiente local.
    - Dica para facilitar: execute via docker o redis e o postgres `docker compose up db redis`
2. Instale as dependencias Ruby:
   - `bundle install`
3. Prepare o banco:
   - `bundle exec rails db:prepare`
4. Suba o Sidekiq:
   - `bundle exec sidekiq`   
5. Inicie o servidor web:
   - `bundle exec rails server`
6. Agora `http://localhost:3000` está acessível. Essas são formas de acessar <a href="#Swagger">Swagger</a>, <a href="#arquivos-http">api/main.rubymine.http</a> ou <a href="#arquivos-http">api/main.vscode.http</a>.

### Tarefas úteis local
- Executar testes: `COVERAGE=true bundle exec rspec`
- RuboCop: `bundle exec rubocop`
- Annotate: `bundle exec annotate`

## Docker Compose
1. Suba aplicação e workers (PostgreSQL e Redis sobem automaticamente):
   - `docker compose up web jobs`
4. A API ficará acessível em `http://localhost:3000` e você pode usar o <a href="#Swagger">Swagger</a>, <a href="#arquivos-http">api/main.rubymine.http</a> ou <a href="#arquivos-http">api/main.vscode.http</a>.

Nota: Para <span style="color:#ff5a00"><strong>testar o funcionamento do job</strong></span> no sidekiq, você pode executar o comando `bundle exec rails dev:carts` que ele irá adicionar carrinhos.

## Testes
### Testes locais sem Docker
- Executar testes: `COVERAGE=true bundle exec rspec`
### Executar testes com Docker Compose
- Executar testes: `docker compose up test`

### Cobertura de testes
Após executar os testes com `COVERAGE=true`, o relatório de cobertura estará disponível em `coverage/index.html`. 

Nota: Atualmente a <span style="color:#ff5a00"><strong>cobertura está em 100%</strong></span>. Com exclusão dos arquivos irrelevantes.

## Documentação da API

### Swagger
1. Execute o docker compose com o serviço web:
   - `docker compose up swagger`
2. Acesse `http://localhost:3000/api-docs` para visualizar a documentação.

![Swagger UI](api/swagger.gif)

### Arquivos http

Arquivos estão localizado em `api/`:  
- `main.rubymine.http` - para RubyMine/IntelliJ
- `main.vscode.http` - para REST Client do VSCode

Nota: instruções de uso e exemplos para testar a API estão incluídos dentro dos arquivos `api/main.rubymine.http` e `api/main.vscode.http`.
