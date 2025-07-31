import { IsEmail, IsIn, IsNumberString, IsOptional, IsString } from "class-validator";

export class UpdateUserDto {
    @IsString()
    @IsOptional()
    user_name?: string;

    @IsString()
    @IsOptional()
    gender?: string;

    @IsString()
    @IsOptional()
    phone_number?: string;

    @IsString()
    @IsOptional() // Password is optional on update
    password?: string;

    @IsEmail()
    @IsOptional()
    email?: string;

    @IsString()
    @IsOptional()
    @IsIn(['yes', 'no'])
    is_active?: string;

    @IsString()
    @IsOptional()
    @IsIn(['yes', 'no'])
    is_reset_password?: string;

    @IsString()
    @IsOptional()
    @IsIn(['yes', 'no'])
    is_lock_out?: string;

    @IsNumberString()
    @IsOptional()
    fail_password_attemp_count?: string;

    @IsString()
    @IsOptional() // The user performing the update
    updated_by?: string;
}