import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsIn } from 'class-validator';

export class BusinessDTO {
    @IsString()
    @IsOptional()
    business_id: string;

    @IsString()
    @IsNotEmpty()
    business_name: string;

    @IsString()
    @IsOptional()
    business_description: string;

    @IsBoolean()
    @IsOptional()
    is_active: string;
  }
