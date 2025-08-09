import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Swagger 설정
  const config = new DocumentBuilder()
    .setTitle('Pet Backend API')
    .setDescription('반려동물 관리 백엔드 API 문서')
    .setVersion('1.0')
    .addTag('pets', '반려동물 관련 API')
    .build();
  
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document);

  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  
  console.log('\n🚀 서버가 성공적으로 시작되었습니다!');
  console.log(`📍 메인 API: http://localhost:${port}`);
  console.log(`📚 Swagger 문서: http://localhost:${port}/api`);
  console.log(`📖 API 문서 JSON: http://localhost:${port}/api-json\n`);
}
bootstrap();
