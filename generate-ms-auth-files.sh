#!/bin/bash

# Script para gerar todos os arquivos do MS-Auth

echo "Gerando arquivos do MS-Auth..."

# app.module.ts
cat > src/app.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { DatabaseModule } from './database/database.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    DatabaseModule,
    AuthModule,
    UsersModule,
  ],
})
export class AppModule {}
EOF

# Prisma schema
mkdir -p prisma
cat > prisma/schema.prisma << 'EOF'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id            String         @id @default(uuid())
  email         String         @unique
  passwordHash  String         @map("password_hash")
  name          String
  avatarUrl     String?        @map("avatar_url")
  isActive      Boolean        @default(true) @map("is_active")
  emailVerified Boolean        @default(false) @map("email_verified")
  createdAt     DateTime       @default(now()) @map("created_at")
  updatedAt     DateTime       @updatedAt @map("updated_at")
  refreshTokens RefreshToken[]

  @@map("users")
}

model RefreshToken {
  id        String   @id @default(uuid())
  userId    String   @map("user_id")
  token     String   @unique
  expiresAt DateTime @map("expires_at")
  createdAt DateTime @default(now()) @map("created_at")
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("refresh_tokens")
}
EOF

# .env.example atualizado
cat > .env.example << 'EOF'
# Database
DATABASE_URL=postgresql://postgres:postgres123@localhost:5432/video_processing_auth

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRATION=1d
JWT_REFRESH_SECRET=your-refresh-secret-key-change-in-production
JWT_REFRESH_EXPIRATION=7d

# Server
PORT=3001
NODE_ENV=development
CORS_ORIGIN=*

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=redis123
EOF

# Dockerfile
cat > Dockerfile << 'EOF'
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
COPY prisma ./prisma/

RUN npm ci

COPY . .

RUN npm run prisma:generate
RUN npm run build

FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/prisma ./prisma
COPY package*.json ./

EXPOSE 3001

CMD ["npm", "run", "start:prod"]
EOF

# docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  ms-auth:
    build: .
    container_name: video-processing-ms-auth
    ports:
      - "3001:3001"
    environment:
      - DATABASE_URL=postgresql://postgres:postgres123@postgres:5432/video_processing_auth
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - REDIS_PASSWORD=redis123
    depends_on:
      - postgres
      - redis
    networks:
      - video-processing-network

networks:
  video-processing-network:
    external: true
EOF

# README.md
cat > README.md << 'EOF'
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
EOF

echo "✅ Arquivos principais criados!"
echo ""
echo "Próximos passos:"
echo "1. npm install"
echo "2. Configurar .env"
echo "3. npm run prisma:generate"
echo "4. npm run start:dev"

