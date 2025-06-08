import { IsString, IsNotEmpty, IsBoolean, IsOptional } from 'class-validator';

export class ResetPasswordDto {
  @IsString()
  @IsNotEmpty()
  user_id: string;

  @IsString()
  @IsNotEmpty()
  new_password: string;

  @IsString()
  @IsNotEmpty()
  confirm_password: string;

  @IsBoolean()
  @IsOptional()
  is_forget_password?: boolean;
}