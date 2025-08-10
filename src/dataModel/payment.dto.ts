import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsIn } from 'class-validator';

export class PaymentDTO {
    @IsString()
    @IsOptional()
    payment_id: string;

    @IsString()
    @IsNotEmpty()
    call_log_id: string;

    @IsString()
    @IsNotEmpty()
    amount_in_usd: string;

    @IsString()
    @IsNotEmpty()
    start_payment_date: string;

    @IsString()
    @IsNotEmpty()
    tenor: string;

    @IsString()
    @IsNotEmpty()
    interest_rate: string;

    @IsString()
    @IsNotEmpty()
    payment_frequency: string;

    @IsString()
    @IsOptional()
    remark: string;

    @IsBoolean()
    @IsOptional()
    is_active: string;
  }
