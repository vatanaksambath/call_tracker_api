import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsIn, IsArray } from 'class-validator';

export class PropertyProfileDTO {
    @IsString()
    @IsOptional()
    property_profile_id: string;

    @IsString()
    @IsNotEmpty()
    property_type_id: string;

    @IsString()
    @IsNotEmpty()
    project_id: string;

    @IsString()
    @IsNotEmpty()
    project_owner_id: string;

    @IsString()
    @IsNotEmpty()
    property_status_id: string;

    @IsString()
    @IsNotEmpty()
    village_id: string;

    @IsString()
    @IsNotEmpty()
    property_profile_name: string;

    @IsString()
    @IsOptional()
    home_number: string;

    @IsString()
    @IsOptional()
    room_number: string;

    @IsString()
    @IsOptional()
    address: string;

    @IsString()
    @IsNotEmpty()
    width: string;

    @IsString()
    @IsNotEmpty()
    length: string;

    @IsString()
    @IsNotEmpty()
    price: number;

    @IsString()
    @IsNotEmpty()
    bedroom: number;

    @IsString()
    @IsNotEmpty()
    bathroom: number;

    @IsString()
    @IsNotEmpty()
    year_built: string;

    @IsString()
    @IsOptional()
    description: string;

    @IsString()
    @IsNotEmpty()
    feature: string;

    @IsArray()
    @IsString({ each: true })
    @IsOptional()
    photo_url: string;

    @IsBoolean()
    @IsOptional()
    is_active: string;
  }
