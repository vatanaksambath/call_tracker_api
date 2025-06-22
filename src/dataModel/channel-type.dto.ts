import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsIn } from 'class-validator';

export class ChannelTypeDTO {
    @IsString()
    @IsOptional()
    channel_type_id: string;

    @IsString()
    @IsNotEmpty()
    channel_type_name: string;

    @IsString()
    @IsOptional()
    channel_type_description: string;

    @IsBoolean()
    @IsOptional()
    is_active: string;
  }
