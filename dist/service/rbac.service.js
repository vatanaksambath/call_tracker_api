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
exports.RBACService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const query_common_1 = require("../common/query.common");
let RBACService = class RBACService {
    call_tracker;
    constructor(call_tracker) {
        this.call_tracker = call_tracker;
    }
    async getRole() {
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.getRole);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async createRole(roleDto, userId) {
        const parameters = [roleDto.role_id, roleDto.role_name, userId];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.roleInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async updateRole(roleDto, userId) {
        const parameters = [roleDto.role_id, roleDto.role_name, roleDto.role_description, roleDto.is_active, userId];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.roleUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async deleteRole(roleDto, userId) {
        const parameters = [roleDto.role_id, userId];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.roleDelete, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async getUserRole() {
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.getUserRole);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async createUserRole(userRoleDto, userId) {
        const parameters = [userRoleDto.role_id, userRoleDto.staff_id, userRoleDto.user_role_description, userRoleDto.is_active, userId];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.userRoleInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async updateUserRole(userRoleDto, userId) {
        const parameters = [userRoleDto.role_id, userRoleDto.staff_id, userRoleDto.user_role_description, userRoleDto.is_active, userId];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.userRoleUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
    async deleteUserRole(userRoleDto, userId) {
        const parameters = [userRoleDto.role_id, userId];
        try {
            const result = await this.call_tracker.query(query_common_1.SQL.userRoleDelete, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
};
exports.RBACService = RBACService;
exports.RBACService = RBACService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectDataSource)()),
    __metadata("design:paramtypes", [typeorm_2.DataSource])
], RBACService);
//# sourceMappingURL=rbac.service.js.map