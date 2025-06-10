import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { PGConnection } from './config/pg.connection';
import { JwtModule } from '@nestjs/jwt';
import { MongooseModule } from '@nestjs/mongoose';
import { AuthGuard } from './auth/auth.guard';
import { CommonController } from './controller/common.controller';
import { CommonService } from './service/common.service';
import { LoggingInterceptor } from './middleware/logger.middleware';
import { LoggingFormate } from './common/logging.formate';
import { AuthController } from './controller/auth.controller';
import { AuthService } from './service/auth.service';
// import { AuthModule } from './auth/auth.module';

import { UserLogin, UserLoginSchema } from './auth/schema/user-login.schema';
import { UserActivityLog, UserActivityLogSchema } from './auth/schema/user-activity-log.schema';
import { ForgetPasswordLog, ForgetPasswordLogSchema } from './auth/schema/forget-password-log.schema';
import { RBACService } from './service/rbac.service';
import { RBACController } from './controller/rbac.controller';


@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    MongooseModule.forRoot('mongodb://localhost:27017/user_management'),
    MongooseModule.forFeature([
          { name: UserLogin.name, schema: UserLoginSchema },
          { name: UserActivityLog.name, schema: UserActivityLogSchema },
          { name: ForgetPasswordLog.name, schema: ForgetPasswordLogSchema },
        ]),
    JwtModule.registerAsync({
      imports: [],
      useFactory: async () => ({
        // secret: configService.get<string>('JWT_SECRET'),
        secret: '356181248f0e77e95c382df2e5abd86108a7c7abccca340ef1f1118a15235255',
        signOptions: { expiresIn: '1h' },
      }),
      inject: [ConfigService],
    }),
    PGConnection
  ],

  controllers:[
    CommonController,
    AuthController,
    RBACController,
    ],
  providers: [
    AuthGuard,
    CommonService,
    LoggingInterceptor,
    LoggingFormate,
    AuthService,
    RBACService,
  ],
})

export class AppModule {}
// implements NestModule {
//   configure(consumer: MiddlewareConsumer) {
//     consumer.apply(LoggerMiddleware).forRoutes('*');
//   }
// }
