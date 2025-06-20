// permission.guard.ts
import {
  CanActivate,
  ExecutionContext,
  Injectable,
  ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PERMISSION_CHECK_KEY } from './permission.decorator';
import { UserPermissionService } from './user-permission.service';

@Injectable()
export class PermissionGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    private readonly userPermissionService: UserPermissionService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const required = this.reflector.getAllAndOverride<{ menu_id: string; permission_id: string }>(
      PERMISSION_CHECK_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!required) return true;

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    const has = await this.userPermissionService.checkUserHasPermission(
      user.user_id,
      required.menu_id,
      required.permission_id,
    );

    if (!has) {
      throw new ForbiddenException('Access denied: you do not have permission to access this!!!');
    }

    return true;
  }
}
