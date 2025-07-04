import { RBACService } from '../service/rbac.service';
import { RoleDTO } from 'src/dataModel/role.dto';
import { UserRoleDTO } from 'src/dataModel/user-role.dto';
export declare class RBACController {
    private readonly rbacService;
    constructor(rbacService: RBACService);
    getRole(): Promise<any>;
    create(roleDto: RoleDTO, req: any): Promise<any>;
    update(roleDto: RoleDTO, req: any): Promise<any>;
    delete(roleDto: RoleDTO, req: any): Promise<any>;
    getUserRole(): Promise<any>;
    createUserRole(userRoleDto: UserRoleDTO, req: any): Promise<any>;
    updateUserRole(userRoleDto: UserRoleDTO, req: any): Promise<any>;
    deleteUserRole(userRoleDto: UserRoleDTO, req: any): Promise<any>;
}
