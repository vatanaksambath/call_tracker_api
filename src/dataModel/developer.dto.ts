import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsIn } from 'class-validator';

export class DeveloperDTO {
    @IsString()
    @IsOptional()
    developer_id: string;

    @IsString()
    @IsNotEmpty()
    developer_name: string;

    @IsString()
    @IsOptional()
    developer_description: string;

    @IsBoolean()
    @IsOptional()
    is_active: string;
  }
