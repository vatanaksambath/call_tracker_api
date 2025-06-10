import { IsString, IsNotEmpty, IsOptional, IsBoolean } from 'class-validator';

export class RoleDTO {
    @IsString()
    @IsNotEmpty()
    role_id: string;

    @IsString()
    @IsNotEmpty()
    role_name: string;

    @IsString()
    @IsOptional()
    role_description: string;

    @IsBoolean()
    @IsOptional()
    is_active: string;
  }
