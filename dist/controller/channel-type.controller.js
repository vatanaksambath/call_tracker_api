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
exports.ChannelTypeController = void 0;
const common_1 = require("@nestjs/common");
const channel_type_service_1 = require("../service/channel-type.service");
const auth_guard_1 = require("../auth/auth.guard");
const error_handler_util_1 = require("../common/error-handler.util");
const channel_type_dto_1 = require("../dataModel/channel-type.dto");
const common_dto_1 = require("../dataModel/common.dto");
const permission_guard_1 = require("../auth/decorator/permission.guard");
const permission_decorator_1 = require("../auth/decorator/permission.decorator");
let ChannelTypeController = class ChannelTypeController {
    channelTypeService;
    constructor(channelTypeService) {
        this.channelTypeService = channelTypeService;
    }
    async get(commonDto, req) {
        const userId = req.user?.user_id;
        try {
            const result = this.channelTypeService.ChannelTypePagination(commonDto, userId);
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
    async create(ChannelTypeDTO, req) {
        const userId = req.user?.user_id;
        try {
            const result = this.channelTypeService.createChannelType(ChannelTypeDTO, userId);
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
    async update(ChannelTypeDTO, req) {
        const userId = req.user?.user_id;
        try {
            const result = this.channelTypeService.updateChannelType(ChannelTypeDTO, userId);
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
    async delete(id, req) {
        const userId = req.user?.user_id;
        try {
            const result = this.channelTypeService.deleteChannelType(id);
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
    async getCustomerType(req) {
        try {
            const result = await this.channelTypeService.getChannelType();
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
};
exports.ChannelTypeController = ChannelTypeController;
__decorate([
    (0, common_1.UseGuards)(permission_guard_1.PermissionGuard),
    (0, permission_decorator_1.RequirePermission)('MU_16', 'PM_02'),
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    (0, common_1.Post)('pagination'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [common_dto_1.CommonDTO, Object]),
    __metadata("design:returntype", Promise)
], ChannelTypeController.prototype, "get", null);
__decorate([
    (0, common_1.UseGuards)(permission_guard_1.PermissionGuard),
    (0, permission_decorator_1.RequirePermission)('MU_16', 'PM_01'),
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    (0, common_1.Post)('create'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [channel_type_dto_1.ChannelTypeDTO, Object]),
    __metadata("design:returntype", Promise)
], ChannelTypeController.prototype, "create", null);
__decorate([
    (0, common_1.UseGuards)(permission_guard_1.PermissionGuard),
    (0, permission_decorator_1.RequirePermission)('MU_16', 'PM_03'),
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    (0, common_1.Put)('update'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [channel_type_dto_1.ChannelTypeDTO, Object]),
    __metadata("design:returntype", Promise)
], ChannelTypeController.prototype, "update", null);
__decorate([
    (0, common_1.UseGuards)(permission_guard_1.PermissionGuard),
    (0, permission_decorator_1.RequirePermission)('MU_16', 'PM_04'),
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    (0, common_1.Delete)(":id"),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], ChannelTypeController.prototype, "delete", null);
__decorate([
    (0, common_1.Get)("/channel-type"),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], ChannelTypeController.prototype, "getCustomerType", null);
exports.ChannelTypeController = ChannelTypeController = __decorate([
    (0, common_1.Controller)('channel-type'),
    __metadata("design:paramtypes", [channel_type_service_1.ChannelTypeService])
], ChannelTypeController);
//# sourceMappingURL=channel-type.controller.js.map