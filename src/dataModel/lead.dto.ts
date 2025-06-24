import { Type } from 'class-transformer';
import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsIn, IsArray, ValidateNested } from 'class-validator';
import { ContactChannelDTO } from './contact-channel.dto';

export class LeadDTO {
    @IsString()
    @IsOptional()
    lead_id: string;

    @IsString()
    @IsNotEmpty()
    gender_id: string;

    @IsString()
    @IsNotEmpty()
    customer_type_id: string;

    @IsString()
    @IsNotEmpty()
    lead_source_id: string;

    @IsString()
    @IsNotEmpty()
    village_id: string;

    @IsString()
    @IsNotEmpty()
    business_id: string;

    @IsString()
    @IsNotEmpty()
    initial_staff_id: string;

    @IsString()
    @IsNotEmpty()
    current_staff_id: string;

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
    @IsOptional()
    email: string;

    @IsString()
    @IsOptional()
    occupation: string;

    @IsString()
    @IsOptional()
    home_address: string;

    @IsString()
    @IsOptional()
    street_address: string;

    @IsString()
    @IsOptional()
    biz_description: string;

    @IsString()
    @IsNotEmpty()
    relationship_date: string;

    @IsString()
    @IsOptional()
    remark: string;

    @IsString()
    @IsOptional()
    photo_url: string;

    @IsArray()
    @ValidateNested({ each: true })
    @Type(() => ContactChannelDTO)
    contact_data: ContactChannelDTO[];

    @IsBoolean()
    @IsOptional()
    is_active: boolean;
}