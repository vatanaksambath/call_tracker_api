import { CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { UserPermissionService } from './user-permission.service';
export declare class PermissionGuard implements CanActivate {
    private reflector;
    private readonly userPermissionService;
    constructor(reflector: Reflector, userPermissionService: UserPermissionService);
    canActivate(context: ExecutionContext): Promise<boolean>;
}
