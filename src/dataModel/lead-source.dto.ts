import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsIn } from 'class-validator';

export class LeadSourceDTO {
    @IsString()
    @IsOptional()
    lead_source_id: string;

    @IsString()
    @IsNotEmpty()
    lead_source_name: string;

    @IsString()
    @IsOptional()
    lead_source_description: string;

    @IsBoolean()
    @IsOptional()
    is_active: string;
  }
