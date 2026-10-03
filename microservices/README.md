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

## 🚀 Como rodar o projeto localmente

Para garantir que os serviços se enxerguem corretamente, é **extremamente importante respeitar a ordem de inicialização**.

### Passo 1: Infraestrutura (Bancos de Dados)
Na raiz do projeto (uma pasta acima desta), existe um arquivo `docker-compose.yml`. Inicie os bancos de dados executando:
```bash
docker-compose up -d
```

### Passo 2: Service Discovery (Eureka)
O Eureka deve ser o **primeiro** serviço Java a ser ligado.
- Abra o projeto `service-discovery` na sua IDE.
- Execute a classe principal `ServerApplication.java`.
- Acesse `http://localhost:8761` no navegador para garantir que o painel do Eureka está no ar.

### Passo 3: Serviços de Negócio
Com o Eureka rodando, você já pode ligar os serviços de negócio. 
- Abra o projeto `auth-service` e execute a classe `AutheticationApplication.java`.
- Olhando o painel do Eureka, você verá o `AUTH-SERVICE` registrado.

### Passo 4: API Gateway
Por fim, ligue o roteador.
- Abra o projeto `api-gateway` e execute a classe `GatewayApplication.java`.
- Ele também se registrará no painel do Eureka.

> **Teste Prático**: A partir desse momento, todas as requisições devem ser feitas para `http://localhost:8080`. Se você mandar um `POST http://localhost:8080/auth/registro`, o Gateway repassará a requisição automaticamente para o `auth-service`!
