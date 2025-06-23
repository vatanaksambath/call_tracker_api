import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsIn, IsDate, IsArray, ValidateNested } from 'class-validator';
import { ContactChannelDTO } from './contact-channel.dto';
import { Type } from 'class-transformer';

export class StaffDTO {
    @IsString()
    @IsNotEmpty()
    staff_id: string;

    @IsString()
    @IsNotEmpty()
    staff_code: string;

    @IsString()
    @IsNotEmpty()
    gender_id: string;

    @IsString()
    @IsNotEmpty()
    village_id: string;

    @IsString()
    @IsOptional()
    manager_id: string;

    @IsString()
    @IsNotEmpty()
    first_name: string;

    @IsString()
    @IsNotEmpty()
    last_name: string;

    @IsString()
    @IsNotEmpty()
    date_of_birth: string;

    @IsString()
    @IsNotEmpty()
    position: string;

    @IsString()
    @IsOptional()
    department: string;

    @IsString()
    @IsNotEmpty()
    employment_type: string;

    @IsString()
    @IsNotEmpty()
    employment_start_date: string;

    @IsString()
    @IsOptional()
    employment_end_date: string;

    @IsString()
    @IsOptional()
    employment_level: string;

    @IsString()
    @IsOptional()
    current_address: string;

    @IsString()
    @IsOptional()
    photo_url: string;

    @IsArray()
    @ValidateNested({ each: true }) // Ensures each element in the array is validated
    @Type(() => ContactChannelDTO) // Crucial: Tells class-transformer to instantiate ContactChannelDTOs
    contact_data: ContactChannelDTO[];

    @IsBoolean()
    @IsOptional()
    is_active: boolean;
  }
