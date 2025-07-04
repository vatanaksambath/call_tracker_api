"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PGConnection = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const config_1 = require("@nestjs/config");
let PGConnection = class PGConnection {
};
exports.PGConnection = PGConnection;
exports.PGConnection = PGConnection = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({
                isGlobal: true,
                envFilePath: '.env',
            }),
            typeorm_1.TypeOrmModule.forRootAsync({
                imports: [config_1.ConfigModule],
                useFactory: async (configService) => ({
                    type: 'postgres',
                    host: configService.get('POSTGRES_HOST_IP'),
                    port: configService.get('POSTGRES_PORT'),
                    username: configService.get('POSTGRES_USER'),
                    password: String(configService.get('POSTGRES_PASSWORD')),
                    database: configService.get('POSTGRES_DATABASE'),
                    entities: [__dirname + '/**/*.entity{.ts,.js}'],
                    ssl: {
                        rejectUnauthorized: false,
                    },
                    synchronize: false,
                }),
                inject: [config_1.ConfigService],
            }),
        ],
    })
], PGConnection);
//# sourceMappingURL=pg.connection.js.map