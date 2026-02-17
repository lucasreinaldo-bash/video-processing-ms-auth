# 🔐 MS-Auth - Microsserviço de Autenticação

Microsserviço de autenticação com JWT para o Sistema de Processamento de Vídeos.

## 🚀 Tecnologias

- NestJS 11
- Prisma ORM
- PostgreSQL
- Redis
- JWT
- Swagger

## 📦 Instalação

```bash
npm install
```

## 🔧 Configuração

```bash
cp .env.example .env
```

Edite `.env` com suas configurações.

## 🗄️ Banco de Dados

```bash
# Gerar Prisma Client
npm run prisma:generate

# Rodar migrations
npm run prisma:migrate

# Abrir Prisma Studio
npm run prisma:studio
```

## 🏃 Executar

```bash
# Desenvolvimento
npm run start:dev

# Produção
npm run build
npm run start:prod
```

## 📚 API Docs

http://localhost:3001/api/docs

## 🧪 Testes

```bash
# Unit tests
npm test

# E2E tests
npm run test:e2e

# Coverage
npm run test:cov
```

## 📡 Endpoints

### POST /api/v1/auth/register
Registrar novo usuário

### POST /api/v1/auth/login
Login

### POST /api/v1/auth/refresh
Renovar token

### GET /api/v1/users/me
Perfil do usuário autenticado

## 🐳 Docker

```bash
docker-compose up -d
```
