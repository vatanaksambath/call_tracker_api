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
exports.CallLogDetailController = void 0;
const common_1 = require("@nestjs/common");
const call_log_detail_service_1 = require("../service/call-log-detail.service");
const auth_guard_1 = require("../auth/auth.guard");
const error_handler_util_1 = require("../common/error-handler.util");
const call_log_detail_dto_1 = require("../dataModel/call-log-detail.dto");
const permission_guard_1 = require("../auth/decorator/permission.guard");
const permission_decorator_1 = require("../auth/decorator/permission.decorator");
let CallLogDetailController = class CallLogDetailController {
    callLogDetailService;
    constructor(callLogDetailService) {
        this.callLogDetailService = callLogDetailService;
    }
    async create(callLogDetailDTO, req) {
        const userId = req.user?.user_id;
        try {
            const result = this.callLogDetailService.createCallLogDetail(callLogDetailDTO, userId, "MU_02");
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
    async update(callLogDetailDTO, req) {
        const userId = req.user?.user_id;
        try {
            const result = this.callLogDetailService.updateCallLogDetail(callLogDetailDTO, userId, "MU_02");
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
};
exports.CallLogDetailController = CallLogDetailController;
__decorate([
    (0, common_1.UseGuards)(permission_guard_1.PermissionGuard),
    (0, permission_decorator_1.RequirePermission)('MU_02', 'PM_01'),
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    (0, common_1.Post)('create'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [call_log_detail_dto_1.CallLogDetailDTO, Object]),
    __metadata("design:returntype", Promise)
], CallLogDetailController.prototype, "create", null);
__decorate([
    (0, common_1.UseGuards)(permission_guard_1.PermissionGuard),
    (0, permission_decorator_1.RequirePermission)('MU_02', 'PM_03'),
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    (0, common_1.Put)('update'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [call_log_detail_dto_1.CallLogDetailDTO, Object]),
    __metadata("design:returntype", Promise)
], CallLogDetailController.prototype, "update", null);
exports.CallLogDetailController = CallLogDetailController = __decorate([
    (0, common_1.Controller)('call-log-detail'),
    __metadata("design:paramtypes", [call_log_detail_service_1.CallLogDetailService])
], CallLogDetailController);
//# sourceMappingURL=call-log-detail.controller.js.map