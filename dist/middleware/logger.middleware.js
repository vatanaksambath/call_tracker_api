"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.LoggingInterceptor = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const operators_1 = require("rxjs/operators");
const common_util_1 = require("../common/common.util");
const logging_formate_1 = require("../common/logging.formate");
const typeorm_2 = require("typeorm");
const query_common_1 = require("../common/query.common");
let LoggingInterceptor = class LoggingInterceptor {
    logger;
    call_tracker;
    constructor(logger, call_tracker) {
        this.logger = logger;
        this.call_tracker = call_tracker;
    }
    async intercept(context, next) {
        const req = context.switchToHttp().getRequest();
        const { method, originalUrl, user, ip, headers, body } = req;
        const userAgent = headers['user-agent'] || 'unknown';
        const start = Date.now();
        const requestTime = (0, common_util_1.formatDate)(new Date());
        this.logger.logRequest({ method, originalUrl, user, ip, userAgent, time: requestTime, body });
        try {
            await this.call_tracker.query(query_common_1.SQL.auditLogInsert, [
                method,
                originalUrl,
                user,
                ip,
                userAgent,
                null,
                null,
                null,
                null,
                'REQUEST',
                new Date(),
                body
            ]);
        }
        catch (err) {
            this.logger.logError({
                user,
                statusCode: 500,
                message: 'Failed to insert request log',
                duration: 0,
                time: requestTime,
                error: err?.message,
                userAgent,
                originalUrl,
                method,
            });
        }
        return next.handle().pipe((0, operators_1.tap)(async (response) => {
            const duration = Date.now() - start;
            const res = Array.isArray(response) ? response[0] : response;
            const statusCode = res?.statusCode ?? 200;
            const message = res?.message ?? 'Success';
            const errorMsg = res?.error ?? null;
            const now = (0, common_util_1.formatDate)(new Date());
            if (statusCode === 500 || errorMsg) {
                this.logger.logError({ user, statusCode, message, duration, time: now, error: errorMsg ?? 'Unknown', userAgent, originalUrl, method, body });
            }
            else {
                this.logger.logResponse({ user, statusCode, message, duration, time: now, userAgent, originalUrl, method, body });
            }
            try {
                await this.call_tracker.query(query_common_1.SQL.auditLogInsert, [
                    method,
                    originalUrl,
                    user,
                    ip,
                    userAgent,
                    statusCode,
                    message,
                    errorMsg,
                    duration,
                    'RESPONSE',
                    new Date(),
                    null
                ]);
            }
            catch (err) {
                this.logger.logError({
                    user,
                    statusCode: 500,
                    message: 'Failed to insert response log',
                    duration,
                    time: now,
                    error: err?.message,
                    userAgent,
                    originalUrl,
                    method,
                });
            }
        }), (0, operators_1.catchError)(async (err) => {
            const duration = Date.now() - start;
            const now = (0, common_util_1.formatDate)(new Date());
            const statusCode = err?.status ?? 500;
            const errorMsg = err?.message ?? 'Internal server error';
            this.logger.logError({ user, statusCode, message: errorMsg, duration, time: now, userAgent, originalUrl, method });
            try {
                await this.call_tracker.query(query_common_1.SQL.auditLogInsert, [
                    method,
                    originalUrl,
                    user,
                    ip,
                    userAgent,
                    statusCode,
                    errorMsg,
                    errorMsg,
                    duration,
                    'ERROR',
                    new Date(),
                    null
                ]);
            }
            catch (dbErr) {
                this.logger.logError({
                    user,
                    statusCode: 500,
                    message: 'Failed to insert error log',
                    duration,
                    time: now,
                    error: dbErr?.message,
                    userAgent,
                    originalUrl,
                    method,
                });
            }
            throw err;
        }));
    }
};
exports.LoggingInterceptor = LoggingInterceptor;
exports.LoggingInterceptor = LoggingInterceptor = __decorate([
    (0, common_1.Injectable)(),
    __param(1, (0, typeorm_1.InjectDataSource)()),
    __metadata("design:paramtypes", [logging_formate_1.LoggingFormate,
        typeorm_2.DataSource])
], LoggingInterceptor);
//# sourceMappingURL=logger.middleware.js.map