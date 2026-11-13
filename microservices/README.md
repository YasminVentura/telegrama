# Telegrama - Arquitetura de Microserviços (Backend)

Este diretório contém todos os microsserviços do backend do projeto **Telegrama**, estruturados usando a stack do **Spring Cloud** e **Spring Boot**. A arquitetura foi pensada para ser escalável, permitindo que cada domínio da aplicação evolua e seja implantado de forma independente.

## 🏗️ Padrão de Arquitetura

O frontend (desenvolvido em Flutter) não se comunica diretamente com os serviços finais. A comunicação segue o seguinte fluxo:
1. **Frontend** envia a requisição.
2. **API Gateway** recebe a requisição, consulta a "lista telefônica" para saber onde o serviço desejado está hospedado.
3. **Service Discovery (Eureka)** responde ao Gateway com o endereço exato do serviço.
4. **API Gateway** repassa (faz o proxy) da requisição para o serviço correto.

---

## 🧩 Serviços Disponíveis

### 1. `service-discovery` (Porta `8761`)
Atua como o servidor do Netflix Eureka. Ele é a "lista telefônica" do projeto. Todos os outros microsserviços, assim que são iniciados, se registram nele. 

### 2. `api-gateway` (Porta `8080`)
Ponto de entrada único para o front-end. Ele expõe rotas (como `/auth/**` ou `/usuarios/**`) e usa o `service-discovery` para redirecionar o tráfego para os serviços de destino corretos.

### 3. `auth-service` (Porta `8081`)
Responsável pela **Segurança, Autenticação e Credenciais**.
- Banco de Dados: PostgreSQL (`telegrama_auth`)
- Domínios: Credenciais de Acesso, Permissões (`Role`: `USER`, `ADMIN`), Sessões e Emissão de JWT.
- **Autenticação (BFF / Token Handler Pattern com Redis)**: O front-end recebe apenas um `idSessao` opaco (UUID) em cookie `HttpOnly` e no header `X-Session-Id`. A sessão fica armazenada em memória no **Redis** (TTL de 24h). O `api-gateway` intercepta as requisições, busca reativamente a sessão no Redis (< 1ms) e repassa o JWT interno no cabeçalho `Authorization: Bearer <jwt>` (incluindo a claim `role`) para os microsserviços.
- **Bootstrap de Admin/Moderador**: Cria/garante automaticamente a conta padrão `@admin` (`admin@telegrama.zone` / `Admin@123`) com papel `ADMIN`.

### 4. `user-profile-service` (Porta `8083`)
Responsável pelo **Perfil Social, Preferências e Seguidores**.
- Banco de Dados: PostgreSQL (`telegrama_profile`)
- Domínios: Perfis públicos (`/usuarios/**`), Busca de usuários, Consultas em lote (`/usuarios/batch`), Preferências de tema/avatar (`/usuarios/me/preferences`) e Sistema de Seguidores (`/seguir`).
- **Exclusão em Cascata e Moderação**: Permite que o próprio dono ou um `ADMIN` exclua uma conta (`DELETE /usuarios/{nodeId}`), acionando via Feign a limpeza de postagens no `post-service` e de credenciais no `auth-service`.

### 5. `post-service` (Porta `8082`)
Responsável pela **Criação, Leitura, Feed e Interação com Postagens**.
- Banco de Dados: MongoDB (`telegrama_posts`)
- Domínios: Postagens de texto, Geração e Paginação de Feed (Fan-out on Read), Sistema de Curtidas (toggle curtir/descurtir), Contagem de comentários/reposts, Auditoria de datas.
- **Integração**: Consulta o `user-profile-service` via Feign (`POST /usuarios/batch`) para enriquecer postagens e feed com nome e avatar atualizados.
- **Segurança e Moderação**: Validação de JWT injetado pelo API Gateway. Tanto o autor da publicação quanto usuários com papel `ADMIN` podem excluir postagens.
- **Consolidação de Feed**: A geração da timeline de postagens e agregação de dados é realizada diretamente no `post-service`, eliminando a necessidade de um microsserviço intermediário de feed e reduzindo a latência de rede.

---

## 🐳 Como rodar usando Docker (Recomendado)

Todos os serviços foram containerizados! Isso significa que você não precisa iniciar serviço por serviço na IDE. O `docker-compose` fará todo o trabalho de orquestração (respeitando a ordem de subida e a conexão com o banco).

1. Abra o terminal na **raiz do projeto** (`c:\Users\yasmi\workspace\telegrama`).
2. Execute o comando para buildar e subir tudo em background:
   ```bash
   docker-compose up --build -d
   ```
3. Acompanhe os logs se quiser:
   ```bash
   docker-compose logs -f
   ```

Quando subir, você terá acesso:
- **API Gateway**: `http://localhost:8080` (use essa para testar no Postman ou Front)
- **Painel Eureka**: `http://localhost:8761`

> **Nota**: Sempre que você alterar o código-fonte de algum microsserviço (como o `auth-service`), você deve rodar o comando `docker-compose up --build -d` novamente. A flag `--build` forçará o Docker a recompilar os arquivos `.jar` e gerar a nova versão da imagem.

---

## 🚀 Como rodar localmente via IDE (Sem Docker)

Caso queira debugar código e rodar na IDE (VS Code, IntelliJ, etc.):
1. Suba apenas o banco de dados via docker: `docker-compose up -d postgres`
2. Inicie os serviços nas classes `main` nesta exata ordem:
   - `ServerApplication` (Eureka)
   - `AutheticationApplication` (Auth Service)
   - `GatewayApplication` (API Gateway)
