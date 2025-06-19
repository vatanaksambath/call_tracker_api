import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsIn } from 'class-validator';

export class ProjectDTO {
    @IsString()
    @IsOptional()
    project_id: string;

    @IsString()
    @IsNotEmpty()
    developer_id: string;

    @IsString()
    @IsNotEmpty()
    village_id: string;

    @IsString()
    @IsNotEmpty()
    project_name: string;

    @IsString()
    @IsOptional()
    project_description: string;

    @IsBoolean()
    @IsOptional()
    is_active: string;
  }
