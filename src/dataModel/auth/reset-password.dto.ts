import { IsString, IsNotEmpty, IsBoolean, IsOptional, MinLength, Matches } from 'class-validator';

export class ResetPasswordDto {
  @IsString()
  @IsOptional()
  user_id: string;

  @IsString()
  @IsNotEmpty()
  token: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(12, { message: 'Password must be at least 12 characters long' })
  // @Matches(/^(?=.*[a-zA-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{12,}$/, {
  //   message: 'Password must contain at least one letter, one number, and one special character (@$!%*?&)',
  // })
  new_password: string;

  @IsString()
  @IsNotEmpty()
  confirm_password: string;
}