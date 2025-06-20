import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsIn } from 'class-validator';

export class PropertyTypeDTO {
    @IsString()
    @IsOptional()
    property_type_id: string;

    @IsString()
    @IsNotEmpty()
    property_type_name: string;

    @IsString()
    @IsOptional()
    property_type_description: string;

    @IsBoolean()
    @IsOptional()
    is_active: string;
  }
