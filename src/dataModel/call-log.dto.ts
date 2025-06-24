import { Type } from 'class-transformer';
import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsIn, IsArray, ValidateNested } from 'class-validator';
import { ContactChannelDTO } from './contact-channel.dto';

export class CallLogDTO {

    @IsString()
    @IsOptional()
    call_log_id: string;

    @IsString()
    @IsNotEmpty()
    lead_id: string;

    @IsString()
    @IsNotEmpty()
    property_profile_id: string;

    @IsString()
    @IsNotEmpty()
    status_id: string;

    @IsString()
    @IsOptional()
    purpose: string;

    @IsString()
    @IsOptional()
    fail_reason: string;

    // CALL DETAIL

    @IsString()
    @IsNotEmpty()
    contact_result_id: string;

    @IsString()
    @IsNotEmpty()
    call_start_datetime: string;

    @IsString()
    @IsNotEmpty()
    call_end_datetime: string;

    @IsString()
    @IsOptional()
    remark: string;

    @IsArray()
    @ValidateNested({ each: true })
    @Type(() => ContactChannelDTO)
    contact_data: ContactChannelDTO[];

    @IsBoolean()
    @IsOptional()
    is_active: boolean;
}