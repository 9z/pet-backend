# 빌드 스테이지 - TypeScript 컴파일용
FROM node:22-alpine AS builder

# 작업 디렉토리 설정
WORKDIR /app

# package.json과 package-lock.json 복사
COPY package*.json ./

# 모든 의존성 설치 (빌드에 필요한 개발 의존성 포함)
RUN npm ci

# 소스 코드 복사
COPY . .

# TypeScript 빌드
RUN npm run build

# 프로덕션 스테이지 - 실행용
FROM node:22-alpine AS production

# 작업 디렉토리 설정
WORKDIR /app

# package.json과 package-lock.json 복사
COPY package*.json ./

# 프로덕션 의존성만 설치
RUN npm ci --only=production && npm cache clean --force

# 빌드된 파일만 복사 (빌드 스테이지에서)
COPY --from=builder /app/dist ./dist

# 포트 노출
EXPOSE 3000

# 애플리케이션 시작
CMD ["node", "dist/main"]