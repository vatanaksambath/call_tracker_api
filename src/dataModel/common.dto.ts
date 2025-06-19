import { IsIn, IsNotEmpty, IsOptional } from 'class-validator';
import { Transform } from 'class-transformer';

export class CommonDTO {

    @IsNotEmpty({ message: 'page is required' })
    page_number: number;

    @IsNotEmpty({ message: 'page Size is required' })
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

}
