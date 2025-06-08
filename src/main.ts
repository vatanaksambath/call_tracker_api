import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { LoggingInterceptor } from './middleware/logger.middleware'
import { ValidationPipe } from '@nestjs/common';
import { HttpExceptionFilter } from './common/http-exception.filter';
async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
      whitelist: true,
      forbidNonWhitelisted: false,
    })
  );

  app.enableCors();
  app.useGlobalPipes(new ValidationPipe());
  app.useGlobalInterceptors(app.get(LoggingInterceptor));
  app.useGlobalFilters(new HttpExceptionFilter());
  app.setGlobalPrefix('call_tracker_api')
  await app.listen(3000);
  // console.log('server is running on port ' + process.env.PORT )
  console.log(`Application is running on: ${await app.getUrl()}`);
}
bootstrap();
