import { IsNotEmpty, IsEmail, IsOptional, IsString, IsBoolean } from "class-validator";


export class CreateUserDto {
    @IsString() @IsNotEmpty()
    user_id: string;

    @IsString() @IsNotEmpty()
    user_name: string;

    @IsString() @IsNotEmpty()
    gender?: string;

    @IsString() @IsNotEmpty()
    phone_number?: string;

    @IsString() @IsNotEmpty()
    password: string;

    @IsEmail() @IsNotEmpty()
    email?: boolean;

    @IsString() @IsOptional()
    email_sent_date: string;

    @IsBoolean() @IsOptional()
    is_active?: boolean;

    @IsBoolean() @IsOptional()
    is_reset_password?: boolean;

    @IsBoolean() @IsOptional()
    is_lock_out?: boolean;

    @IsBoolean() @IsOptional()
    fail_password_attemp_count?: boolean;

    @IsString() @IsNotEmpty()
    created_by: string;

    @IsString() @IsOptional()
    created_date: string;

    @IsString() @IsOptional()
    last_updated_by: string;

    @IsString() @IsOptional()
    last_updated_date: string;

    @IsString() @IsOptional()
    last_password_change_date: string;

}