import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { PaymentDTO } from 'src/dataModel/payment.dto';

@Injectable()
export class PaymentService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async createPayment(paymentDTO: PaymentDTO, userId: number) {
        const parameters = [
            paymentDTO.call_log_id,
            paymentDTO.amount_in_usd,
            paymentDTO.start_payment_date,
            paymentDTO.tenor,
            paymentDTO.interest_rate,
            paymentDTO.payment_frequency,
            paymentDTO.remark,
            userId
        ]
        try {
            const result = await this.call_tracker.query(SQL.paymentInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updatePayment(paymentDTO: PaymentDTO, userId: number) {
       const parameters = [
            paymentDTO.call_log_id,
            paymentDTO.amount_in_usd,
            paymentDTO.start_payment_date,
            paymentDTO.tenor,
            paymentDTO.interest_rate,
            paymentDTO.payment_frequency,
            paymentDTO.is_active,
            paymentDTO.remark,
            userId
        ]
        try {
            const result = await this.call_tracker.query(SQL.paymentUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async deletePayment(id: string | string) {
        try {
            const result = await this.call_tracker.query(SQL.paymentDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async generate_loan_schedule(call_log_id: string) {
        try {
            const result = await this.call_tracker.query( SQL.generate_loan_schedule, [call_log_id]);
            if (result.length === 0) {
                throw new Error('No loan schedule generated');
            }
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async paymentSummary(call_log_id: string) {
        try {
            const result = await this.call_tracker.query(SQL.paymentSummary, [call_log_id]);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }
}

