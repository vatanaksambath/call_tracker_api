import { Type } from 'class-transformer';
import { IsString, IsNotEmpty, IsOptional, IsBoolean } from 'class-validator';

export class ContactValueDTO {
  @IsString()
  @IsNotEmpty()
  user_name: string;

  @IsString()
  @IsNotEmpty()
  contact_number: string;

  @IsString()
  @IsOptional()
  remark: string | null;

  @IsBoolean()
  @IsOptional() // Set to optional based on your Postman, but can be IsNotEmpty if always present
  @Type(() => Boolean) // Important: Converts "true"/"false" strings or 0/1 to boolean
  is_primary: boolean;
}