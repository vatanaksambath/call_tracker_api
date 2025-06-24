import { Type } from 'class-transformer';
import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsIn, IsArray, ValidateNested } from 'class-validator';
import { ContactChannelDTO } from './contact-channel.dto';

export class CallLogDetailDTO {

    @IsString()
    @IsNotEmpty()
    call_log_id: string;

    @IsString()
    @IsOptional()
    call_log_detail_id: string;

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