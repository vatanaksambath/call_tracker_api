import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { CallLogDTO } from 'src/dataModel/call-log.dto';
import { CommonDTO } from 'src/dataModel/common.dto';

@Injectable()
export class CallLogService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async CallLogPagination(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search, userId];
        try {
            const result = await this.call_tracker.query(SQL.callLogPagination, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

    async CallLogSummary(userId: number) {
        try {
            const result = await this.call_tracker.query(SQL.callLogSummary, [userId]);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }
    
     async createCallLog(callLogDTO: CallLogDTO, userId: number, menuId: string) {
        const parameters = [
            callLogDTO.lead_id,
            callLogDTO.property_profile_id,
            callLogDTO.status_id,
            callLogDTO.purpose,
            callLogDTO.fail_reason,
            callLogDTO.follow_up_date,
            callLogDTO.is_follow_up,
            JSON.stringify(callLogDTO.p_call_log_detail),
            userId
        ];
        try {
            const result = await this.call_tracker.query(SQL.callLogInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updateCallLog(callLogDTO: CallLogDTO, userId: number, menuId: string) {
        const parameters = [
            callLogDTO.call_log_id,
            callLogDTO.lead_id,
            callLogDTO.property_profile_id,
            callLogDTO.status_id,
            callLogDTO.purpose,
            callLogDTO.fail_reason,
            callLogDTO.follow_up_date,
            callLogDTO.is_follow_up,
            callLogDTO.is_active,
            JSON.stringify(callLogDTO.p_call_log_detail),
            userId
        ];
        try {
            const result = await this.call_tracker.query(SQL.callLogUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updateCallLogInfo(callLogDTO: CallLogDTO, userId: number, menuId: string) {
        const parameters = [
            callLogDTO.call_log_id,
            callLogDTO.lead_id,
            callLogDTO.property_profile_id,
            callLogDTO.status_id,
            callLogDTO.purpose,
            callLogDTO.fail_reason,
            callLogDTO.follow_up_date,
            callLogDTO.is_follow_up,
            callLogDTO.is_active,
            userId
        ];
        try {
            const result = await this.call_tracker.query(SQL.callLogUpdateInfo, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async deleteCallLog(id: number | string) {
        try {
            const result = await this.call_tracker.query(SQL.callLogDelete, [id]);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async CallLogExport(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.search_type, commonDTO.query_search, userId];
        try {
            const result = await this.call_tracker.query(SQL.callLogExport, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }

}

