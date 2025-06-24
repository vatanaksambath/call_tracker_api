import { Type } from 'class-transformer';
import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsIn, IsArray, ValidateNested, IsDate } from 'class-validator';

export class SiteVisitDTO {
    @IsString()
    @IsOptional()
    site_visit_id: string;

    @IsString()
    @IsNotEmpty()
    call_id: string;

    @IsString()
    @IsNotEmpty()
    property_profile_id: string;

    @IsString()
    @IsNotEmpty()
    staff_id: string;

    @IsString()
    @IsNotEmpty()
    lead_id: string;

    @IsString()
    @IsNotEmpty()
    contact_result_id: string;

    @IsString()
    @IsNotEmpty()
    purpose: string;

    @IsString()
    @IsNotEmpty()
    start_datetime: string;

    @IsString()
    @IsOptional()
    end_datetime: string;

    @IsArray()
    @IsOptional()
    photo_url: string;

    @IsString()
    @IsOptional()
    remark: string;

    @IsBoolean()
    @IsOptional()
    is_active: string;
}