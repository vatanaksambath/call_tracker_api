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
exports.RBACController = void 0;
const common_1 = require("@nestjs/common");
const rbac_service_1 = require("../service/rbac.service");
const auth_guard_1 = require("../auth/auth.guard");
const role_dto_1 = require("../dataModel/role.dto");
const error_handler_util_1 = require("../common/error-handler.util");
const user_role_dto_1 = require("../dataModel/user-role.dto");
let RBACController = class RBACController {
    rbacService;
    constructor(rbacService) {
        this.rbacService = rbacService;
    }
    async getRole() {
        try {
            const result = this.rbacService.getRole();
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
    async create(roleDto, req) {
        const userId = req.user?.user_id;
        try {
            const result = this.rbacService.createRole(roleDto, userId);
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
    async update(roleDto, req) {
        const userId = req.user?.user_id;
        try {
            const result = this.rbacService.updateRole(roleDto, userId);
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
    async delete(roleDto, req) {
        const userId = req.user?.user_id;
        try {
            const result = this.rbacService.deleteRole(roleDto, userId);
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
    async getUserRole() {
        try {
            const result = this.rbacService.getUserRole();
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
    async createUserRole(userRoleDto, req) {
        const userId = req.user?.user_id;
        try {
            const result = this.rbacService.createUserRole(userRoleDto, userId);
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
    async updateUserRole(userRoleDto, req) {
        const userId = req.user?.user_id;
        try {
            const result = this.rbacService.updateUserRole(userRoleDto, userId);
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
    async deleteUserRole(userRoleDto, req) {
        const userId = req.user?.user_id;
        try {
            const result = this.rbacService.deleteUserRole(userRoleDto, userId);
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
};
exports.RBACController = RBACController;
__decorate([
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    (0, common_1.Get)('get-role'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    (0, common_1.HttpCode)(200),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], RBACController.prototype, "getRole", null);
__decorate([
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    (0, common_1.Post)('create-role'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [role_dto_1.RoleDTO, Object]),
    __metadata("design:returntype", Promise)
], RBACController.prototype, "create", null);
__decorate([
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    (0, common_1.Post)('update-role'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [role_dto_1.RoleDTO, Object]),
    __metadata("design:returntype", Promise)
], RBACController.prototype, "update", null);
__decorate([
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    (0, common_1.Post)('delete-role'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [role_dto_1.RoleDTO, Object]),
    __metadata("design:returntype", Promise)
], RBACController.prototype, "delete", null);
__decorate([
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    (0, common_1.Get)('get-user-role'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    (0, common_1.HttpCode)(200),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], RBACController.prototype, "getUserRole", null);
__decorate([
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    (0, common_1.Post)('create-user-role'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [user_role_dto_1.UserRoleDTO, Object]),
    __metadata("design:returntype", Promise)
], RBACController.prototype, "createUserRole", null);
__decorate([
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    (0, common_1.Post)('update-user-role'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [user_role_dto_1.UserRoleDTO, Object]),
    __metadata("design:returntype", Promise)
], RBACController.prototype, "updateUserRole", null);
__decorate([
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    (0, common_1.Post)('delete-user-role'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [user_role_dto_1.UserRoleDTO, Object]),
    __metadata("design:returntype", Promise)
], RBACController.prototype, "deleteUserRole", null);
exports.RBACController = RBACController = __decorate([
    (0, common_1.Controller)('rbac'),
    __metadata("design:paramtypes", [rbac_service_1.RBACService])
], RBACController);
//# sourceMappingURL=rbac.controller.js.map