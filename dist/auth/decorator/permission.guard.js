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
Object.defineProperty(exports, "__esModule", { value: true });
exports.PermissionGuard = void 0;
const common_1 = require("@nestjs/common");
const core_1 = require("@nestjs/core");
const permission_decorator_1 = require("./permission.decorator");
const user_permission_service_1 = require("./user-permission.service");
let PermissionGuard = class PermissionGuard {
    reflector;
    userPermissionService;
    constructor(reflector, userPermissionService) {
        this.reflector = reflector;
        this.userPermissionService = userPermissionService;
    }
    async canActivate(context) {
        const required = this.reflector.getAllAndOverride(permission_decorator_1.PERMISSION_CHECK_KEY, [context.getHandler(), context.getClass()]);
        if (!required)
            return true;
        const request = context.switchToHttp().getRequest();
        const user = request.user;
        const has = await this.userPermissionService.checkUserHasPermission(user.user_id, required.menu_id, required.permission_id);
        if (!has) {
            throw new common_1.ForbiddenException('Access denied: you do not have permission to access this!!!');
        }
        return true;
    }
};
exports.PermissionGuard = PermissionGuard;
exports.PermissionGuard = PermissionGuard = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [core_1.Reflector,
        user_permission_service_1.UserPermissionService])
], PermissionGuard);
//# sourceMappingURL=permission.guard.js.map