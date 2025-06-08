import { IsIn, IsNotEmpty, IsOptional } from 'class-validator';
import { Transform } from 'class-transformer';

export class CustomerPaginationDTO {

    @IsNotEmpty({ message: 'page is required' })
    page: number;

    @IsNotEmpty({ message: 'page Size is required' })
    pageSize: number;

    @Transform(({ value }) => (value === '' ? null : value))
    @IsOptional()
    @IsIn(['customerID', 'customerName'], {
        message: 'searchType must be either "customerID" or "customerName"',
    })
    searchType: string;

    @IsOptional()
    @Transform(({ value }) => (value === '' ? null : value))
    querySearch: string;

}
