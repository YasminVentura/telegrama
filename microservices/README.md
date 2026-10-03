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
Responsável pela **Segurança, Autenticação (JWT) e Gestão de Usuários**.
- Banco de Dados: PostgreSQL
- Domínios: Usuários, Perfis, Permissões (Roles: USER, ADMIN), Sistema de Seguidores.

### Serviços Futuros (Em Planejamento)
- **`post-service`**: Para gestão de publicações, mídias, salvamentos e curtidas.
- **`feed-service`**: Para orquestração da linha do tempo baseada em quem o usuário segue.

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
