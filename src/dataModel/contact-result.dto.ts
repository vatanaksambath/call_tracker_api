import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsIn } from 'class-validator';

export class ContactResultDTO {
    @IsString()
    @IsOptional()
    contact_result_id: string;

    @IsString()
    @IsNotEmpty()
    menu_id: string;

    @IsString()
    @IsNotEmpty()
    contact_result_name: string;

    @IsString()
    @IsOptional()
    contact_result_description: string;

    @IsBoolean()
    @IsOptional()
    is_active: string;
  }
