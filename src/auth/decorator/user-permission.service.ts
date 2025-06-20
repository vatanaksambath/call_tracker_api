// user-permission.service.ts
import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { SQL } from 'src/common/query.common';
import { DataSource } from 'typeorm';

@Injectable()
export class UserPermissionService {
  constructor(
    // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
    @InjectDataSource() private call_tracker: DataSource
  ) { }
  private readonly ADMIN_ROLE_ID = 'RG_01';

  async checkUserHasPermission(
    staffId: number,
    menuId: string,
    permissionId: string,
  ): Promise<boolean> {
    const role = await this.call_tracker.query(SQL.getUserRoleByID, [staffId]);
    
    const userRoleId = role?.[0]?.role_id;
    if (userRoleId === this.ADMIN_ROLE_ID) {
      return true;
    }

    const permissions = await this.call_tracker.query(SQL.getUserRolePermissionByID, [userRoleId]);
    console.log(permissions);
    return permissions.some(
      (perm) =>
        perm.menu_id?.trim() === menuId.trim() &&
        perm.permission_id?.trim() === permissionId.trim()
    );
  }
}
