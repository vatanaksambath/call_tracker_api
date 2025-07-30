import { Type } from 'class-transformer';
import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsIn, IsArray, ValidateNested } from 'class-validator';
import { CallLogDetailDTO } from './call-log-detail.dto';

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

    @IsBoolean()
    @IsNotEmpty()
    is_follow_up: boolean;

    @IsArray()
    @ValidateNested({ each: true })
    @Type(() => CallLogDetailDTO)
    p_call_log_detail: CallLogDetailDTO[];

    @IsBoolean()
    @IsOptional()
    is_active: boolean;
}