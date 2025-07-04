import { DataSource } from 'typeorm';
export declare class UserPermissionService {
    private call_tracker;
    constructor(call_tracker: DataSource);
    private readonly ADMIN_ROLE_ID;
    checkUserHasPermission(staffId: number, menuId: string, permissionId: string): Promise<boolean>;
}
