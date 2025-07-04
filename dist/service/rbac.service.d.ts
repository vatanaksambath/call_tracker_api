import { DataSource } from 'typeorm';
import { RoleDTO } from 'src/dataModel/role.dto';
import { UserRoleDTO } from 'src/dataModel/user-role.dto';
export declare class RBACService {
    private call_tracker;
    constructor(call_tracker: DataSource);
    getRole(): Promise<any>;
    createRole(roleDto: RoleDTO, userId: number): Promise<any>;
    updateRole(roleDto: RoleDTO, userId: number): Promise<any>;
    deleteRole(roleDto: RoleDTO, userId: number): Promise<any>;
    getUserRole(): Promise<any>;
    createUserRole(userRoleDto: UserRoleDTO, userId: number): Promise<any>;
    updateUserRole(userRoleDto: UserRoleDTO, userId: number): Promise<any>;
    deleteUserRole(userRoleDto: UserRoleDTO, userId: number): Promise<any>;
}
