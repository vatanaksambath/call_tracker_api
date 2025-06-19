// permission.decorator.ts
import { SetMetadata } from '@nestjs/common';

export const PERMISSION_CHECK_KEY = 'required_permission';
export const RequirePermission = (menu_id: string, permission_id: string) =>
  SetMetadata(PERMISSION_CHECK_KEY, { menu_id, permission_id });
