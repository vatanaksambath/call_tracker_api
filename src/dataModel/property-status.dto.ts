import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsIn } from 'class-validator';

export class PropertyStatusDTO {
    @IsString()
    @IsOptional()
    property_status_id: string;

    @IsString()
    @IsNotEmpty()
    property_status_name: string;

    @IsString()
    @IsOptional()
    property_status_description: string;

    @IsBoolean()
    @IsOptional()
    is_active: string;
  }
