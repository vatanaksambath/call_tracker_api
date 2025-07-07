"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const pg_connection_1 = require("./config/pg.connection");
const jwt_1 = require("@nestjs/jwt");
const mongoose_1 = require("@nestjs/mongoose");
const auth_guard_1 = require("./auth/auth.guard");
const common_controller_1 = require("./controller/common.controller");
const common_service_1 = require("./service/common.service");
const logger_middleware_1 = require("./middleware/logger.middleware");
const logging_formate_1 = require("./common/logging.formate");
const auth_controller_1 = require("./controller/auth.controller");
const auth_service_1 = require("./service/auth.service");
const user_login_schema_1 = require("./auth/schema/user-login.schema");
const user_activity_log_schema_1 = require("./auth/schema/user-activity-log.schema");
const forget_password_log_schema_1 = require("./auth/schema/forget-password-log.schema");
const rbac_service_1 = require("./service/rbac.service");
const rbac_controller_1 = require("./controller/rbac.controller");
const permission_guard_1 = require("./auth/decorator/permission.guard");
const user_permission_service_1 = require("./auth/decorator/user-permission.service");
const developer_controller_1 = require("./controller/developer.controller");
const developer_service_1 = require("./service/developer.service");
const project_owner_controller_1 = require("./controller/project-owner.controller");
const project_owner_service_1 = require("./service/project-owner.service");
const project_service_1 = require("./service/project.service");
const project_controller_1 = require("./controller/project.controller");
const business_controller_1 = require("./controller/business.controller");
const business_service_1 = require("./service/business.service");
const lead_source_controller_1 = require("./controller/lead-source.controller");
const customer_type_controller_1 = require("./controller/customer-type.controller");
const lead_source_service_1 = require("./service/lead-source.service");
const customer_type_service_1 = require("./service/customer-type.service");
const property_type_controller_1 = require("./controller/property-type.controller");
const property_type_service_1 = require("./service/property-type.service");
const property_profile_controller_1 = require("./controller/property-profile.controller");
const property_profile_service_1 = require("./service/property-profile.service");
const staff_controller_1 = require("./controller/staff.controller");
const staff_service_1 = require("./service/staff.service");
const channel_type_controller_1 = require("./controller/channel-type.controller");
const channel_type_service_1 = require("./service/channel-type.service");
const lead_controller_1 = require("./controller/lead.controller");
const lead_service_1 = require("./service/lead.service");
const site_visit_controller_1 = require("./controller/site-visit.controller");
const site_visit_service_1 = require("./service/site-visit.service");
const call_log_controller_1 = require("./controller/call-log.controller");
const call_log_service_1 = require("./service/call-log.service");
const call_log_detail_service_1 = require("./service/call-log-detail.service");
const call_log_detail_controller_1 = require("./controller/call-log-detail.controller");
const photo_upload_service_1 = require("./service/photo-upload.service");
const photo_upload_controller_1 = require("./controller/photo-upload.controller");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({
                isGlobal: true,
                envFilePath: '.env',
            }),
            mongoose_1.MongooseModule.forRoot('mongodb+srv://manan242536:aMK3C8Hwed9CNzBu@cluster0.kkiije8.mongodb.net/user_management'),
            mongoose_1.MongooseModule.forFeature([
                { name: user_login_schema_1.UserLogin.name, schema: user_login_schema_1.UserLoginSchema },
                { name: user_activity_log_schema_1.UserActivityLog.name, schema: user_activity_log_schema_1.UserActivityLogSchema },
                { name: forget_password_log_schema_1.ForgetPasswordLog.name, schema: forget_password_log_schema_1.ForgetPasswordLogSchema },
            ]),
            jwt_1.JwtModule.registerAsync({
                imports: [],
                useFactory: async () => ({
                    secret: '356181248f0e77e95c382df2e5abd86108a7c7abccca340ef1f1118a15235255',
                    signOptions: { expiresIn: '8h' },
                }),
                inject: [config_1.ConfigService],
            }),
            pg_connection_1.PGConnection
        ],
        controllers: [
            common_controller_1.CommonController,
            auth_controller_1.AuthController,
            rbac_controller_1.RBACController,
            developer_controller_1.DeveloperController,
            project_owner_controller_1.ProjectOwnerController,
            project_controller_1.ProjectController,
            business_controller_1.BusinessController,
            lead_source_controller_1.LeadSourceController,
            customer_type_controller_1.CustomerTypeController,
            property_type_controller_1.PropertyTypeController,
            property_profile_controller_1.PropertyProfileController,
            staff_controller_1.StaffController,
            channel_type_controller_1.ChannelTypeController,
            lead_controller_1.LeadController,
            site_visit_controller_1.SiteVisitController,
            call_log_controller_1.CallLogController,
            call_log_detail_controller_1.CallLogDetailController,
            photo_upload_controller_1.PhotoUploadController,
        ],
        providers: [
            auth_guard_1.AuthGuard,
            permission_guard_1.PermissionGuard,
            user_permission_service_1.UserPermissionService,
            common_service_1.CommonService,
            logger_middleware_1.LoggingInterceptor,
            logging_formate_1.LoggingFormate,
            auth_service_1.AuthService,
            rbac_service_1.RBACService,
            developer_service_1.DeveloperService,
            project_owner_service_1.ProjectOwnerService,
            project_service_1.ProjectService,
            business_service_1.BusinessService,
            lead_source_service_1.LeadSourceService,
            customer_type_service_1.CustomerTypeService,
            property_type_service_1.PropertyTypeService,
            property_profile_service_1.PropertyProfileService,
            staff_service_1.StaffService,
            channel_type_service_1.ChannelTypeService,
            lead_service_1.LeadService,
            site_visit_service_1.SiteVisitService,
            call_log_service_1.CallLogService,
            call_log_detail_service_1.CallLogDetailService,
            photo_upload_service_1.PhotoUploadService,
        ],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map