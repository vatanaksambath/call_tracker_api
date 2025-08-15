import { IsIn, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { Transform } from 'class-transformer';

export class CommonDTO {

     @IsOptional()
    page_number: number;

     @IsOptional()
    page_size: number;

    @Transform(({ value }) => (value === '' ? null : value))
    @IsOptional()
    // @IsIn(['customerID', 'customerName'], {
    //     message: 'searchType must be either "customerID" or "customerName"',
    // })
    search_type: string;

    @IsOptional()
    @Transform(({ value }) => (value === '' ? null : value))
    query_search: string;

    @IsString()
    @IsOptional()
    menu_id: string;

    
    @IsString()
    @IsOptional()
    call_log_id: string;

}
