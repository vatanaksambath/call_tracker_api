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
import { UserLogin, UserLoginSchema } from './auth/schema/user-login.schema';
import { UserActivityLog, UserActivityLogSchema } from './auth/schema/user-activity-log.schema';
import { ForgetPasswordLog, ForgetPasswordLogSchema } from './auth/schema/forget-password-log.schema';
import { RBACService } from './service/rbac.service';
import { RBACController } from './controller/rbac.controller';
import { PermissionGuard } from './auth/decorator/permission.guard';
import { UserPermissionService } from './auth/decorator/user-permission.service';
import { DeveloperController } from './controller/developer.controller';
import { DeveloperService } from './service/developer.service';
import { ProjectOwnerController } from './controller/project-owner.controller';
import { ProjectOwnerService } from './service/project-owner.service';
import { ProjectService } from './service/project.service';
import { ProjectController } from './controller/project.controller';
import { BusinessController } from './controller/business.controller';
import { BusinessService } from './service/business.service';
import { LeadSourceController } from './controller/lead-source.controller';
import { CustomerTypeController } from './controller/customer-type.controller';
import { LeadSourceService } from './service/lead-source.service';
import { CustomerTypeService } from './service/customer-type.service';
import { PropertyTypeController } from './controller/property-type.controller';
import { PropertyTypeService } from './service/property-type.service';
import { PropertyProfileController } from './controller/property-profile.controller';
import { PropertyProfileService } from './service/property-profile.service';
import { StaffController } from './controller/staff.controller';
import { StaffService } from './service/staff.service';
import { ChannelTypeController } from './controller/channel-type.controller';
import { ChannelTypeService } from './service/channel-type.service';

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
    DeveloperController,
    ProjectOwnerController,
    ProjectController,
    BusinessController,
    LeadSourceController,
    CustomerTypeController,
    PropertyTypeController,
    PropertyProfileController,
    StaffController,
    ChannelTypeController,
    ],
  providers: [
    AuthGuard,
    PermissionGuard,
    UserPermissionService,
    CommonService,
    LoggingInterceptor,
    LoggingFormate,
    AuthService,
    RBACService,
    DeveloperService,
    ProjectOwnerService,
    ProjectService,
    BusinessService,
    LeadSourceService,
    CustomerTypeService,
    PropertyTypeService,
    PropertyProfileService,
    StaffService,
    ChannelTypeService,
  ],
})

export class AppModule {}
// implements NestModule {
//   configure(consumer: MiddlewareConsumer) {
//     consumer.apply(LoggerMiddleware).forRoutes('*');
//   }
// }
