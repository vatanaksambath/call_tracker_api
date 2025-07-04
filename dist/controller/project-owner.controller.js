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
exports.ProjectOwnerController = void 0;
const common_1 = require("@nestjs/common");
const project_owner_service_1 = require("../service/project-owner.service");
const auth_guard_1 = require("../auth/auth.guard");
const error_handler_util_1 = require("../common/error-handler.util");
const project_owner_dto_1 = require("../dataModel/project-owner.dto");
const common_dto_1 = require("../dataModel/common.dto");
const permission_guard_1 = require("../auth/decorator/permission.guard");
const permission_decorator_1 = require("../auth/decorator/permission.decorator");
let ProjectOwnerController = class ProjectOwnerController {
    projectOwnerService;
    constructor(projectOwnerService) {
        this.projectOwnerService = projectOwnerService;
    }
    async get(commonDto, req) {
        const userId = req.user?.user_id;
        try {
            const result = this.projectOwnerService.projectOwnerPagination(commonDto, userId);
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
    async create(projectOwnerDto, req) {
        const userId = req.user?.user_id;
        try {
            const result = this.projectOwnerService.createProjectOwner(projectOwnerDto, userId);
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
    async update(projectOwnerDto, req) {
        const userId = req.user?.user_id;
        try {
            const result = this.projectOwnerService.updateProjectOwner(projectOwnerDto, userId);
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
    async delete(id, req) {
        const userId = req.user?.user_id;
        try {
            const result = this.projectOwnerService.deleteProjectOwner(id);
            return result;
        }
        catch (error) {
            (0, error_handler_util_1.dispatchBadRequestException)(error);
        }
    }
};
exports.ProjectOwnerController = ProjectOwnerController;
__decorate([
    (0, common_1.UseGuards)(permission_guard_1.PermissionGuard),
    (0, permission_decorator_1.RequirePermission)('MU_11', 'PM_02'),
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    (0, common_1.Post)('pagination'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [common_dto_1.CommonDTO, Object]),
    __metadata("design:returntype", Promise)
], ProjectOwnerController.prototype, "get", null);
__decorate([
    (0, common_1.UseGuards)(permission_guard_1.PermissionGuard),
    (0, permission_decorator_1.RequirePermission)('MU_11', 'PM_01'),
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    (0, common_1.Post)('create'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [project_owner_dto_1.ProjectOwnerDTO, Object]),
    __metadata("design:returntype", Promise)
], ProjectOwnerController.prototype, "create", null);
__decorate([
    (0, common_1.UseGuards)(permission_guard_1.PermissionGuard),
    (0, permission_decorator_1.RequirePermission)('MU_11', 'PM_03'),
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    (0, common_1.Put)('update'),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [project_owner_dto_1.ProjectOwnerDTO, Object]),
    __metadata("design:returntype", Promise)
], ProjectOwnerController.prototype, "update", null);
__decorate([
    (0, common_1.UseGuards)(permission_guard_1.PermissionGuard),
    (0, permission_decorator_1.RequirePermission)('MU_11', 'PM_04'),
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    (0, common_1.Delete)(":id"),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], ProjectOwnerController.prototype, "delete", null);
exports.ProjectOwnerController = ProjectOwnerController = __decorate([
    (0, common_1.Controller)('project-owner'),
    __metadata("design:paramtypes", [project_owner_service_1.ProjectOwnerService])
], ProjectOwnerController);
//# sourceMappingURL=project-owner.controller.js.map