import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { RoleDTO } from 'src/dataModel/role.dto';
import { UserRoleDTO } from 'src/dataModel/user-role.dto';

@Injectable()
export class RBACService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async getRole() {
        try {
            const result = await this.call_tracker.query(SQL.getRole);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async createRole(roleDto: RoleDTO, userId: number) {
        const parameters = [roleDto.role_id, roleDto.role_name, userId]
        try {
            const result = await this.call_tracker.query(SQL.roleInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updateRole(roleDto: RoleDTO, userId: number) {
        const parameters = [roleDto.role_id, roleDto.role_name, roleDto.role_description, roleDto.is_active, userId];
        try {
            const result = await this.call_tracker.query(SQL.roleUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async deleteRole(roleDto: RoleDTO, userId: number) {
        const parameters = [roleDto.role_id, userId];
        try {
            const result = await this.call_tracker.query(SQL.roleDelete, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async getUserRole() {
        try {
            const result = await this.call_tracker.query(SQL.getUserRole);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async getUserPermission(userId: number) {
        try {
            const result = await this.call_tracker.query(SQL.getUserPermission, [userId]);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async createUserRole(userRoleDto: UserRoleDTO, userId: number) {
        const parameters = [userRoleDto.role_id, userRoleDto.staff_id, userRoleDto.user_role_description, userRoleDto.is_active, userId]
        try {
            const result = await this.call_tracker.query(SQL.userRoleInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updateUserRole(userRoleDto: UserRoleDTO, userId: number) {
        const parameters = [userRoleDto.role_id, userRoleDto.staff_id, userRoleDto.user_role_description, userRoleDto.is_active, userId];
        try {
            const result = await this.call_tracker.query(SQL.userRoleUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async deleteUserRole(userRoleDto: UserRoleDTO, userId: number) {
        const parameters = [userRoleDto.role_id, userId];
        try {
            const result = await this.call_tracker.query(SQL.userRoleDelete, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }
}

