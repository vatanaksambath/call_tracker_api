import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsIn } from 'class-validator';

export class ProjectOwnerDTO {
    @IsString()
    @IsOptional()
    project_owner_id: string;

    @IsString()
    @IsNotEmpty()
    gender_id: string;

    @IsString()
    @IsNotEmpty()
    village_id: string;

    @IsString()
    @IsNotEmpty()
    first_name: string;

    @IsString()
    @IsNotEmpty()
    last_name: string;

    @IsString()
    @IsOptional()
    date_of_birth: string;

    @IsString()
    @IsOptional()
    remark: string;

    @IsBoolean()
    @IsOptional()
    is_active: string;
  }
