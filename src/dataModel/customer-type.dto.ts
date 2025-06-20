import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsIn } from 'class-validator';

export class CustomerTypeDTO {
    @IsString()
    @IsOptional()
    customer_type_id: string;

    @IsString()
    @IsNotEmpty()
    customer_type_name: string;

    @IsString()
    @IsOptional()
    customer_type_description: string;

    @IsBoolean()
    @IsOptional()
    is_active: string;
  }
