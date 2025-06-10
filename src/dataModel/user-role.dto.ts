import { IsString, IsNotEmpty, IsOptional, IsBoolean } from 'class-validator';

export class UserRoleDTO {
    @IsString()
    @IsNotEmpty()
    role_id: string;

    @IsString()
    @IsOptional()
    staff_id: string;

    @IsString()
    @IsOptional()
    user_role_description: string;

    @IsBoolean()
    @IsOptional()
    is_active: string;
  }
