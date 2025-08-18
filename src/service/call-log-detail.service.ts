import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { SQL } from '../common/query.common';
import { CallLogDetailDTO } from 'src/dataModel/call-log-detail.dto';
import { CommonDTO } from 'src/dataModel/common.dto';

@Injectable()
export class CallLogDetailService {
    constructor(
        // @InjectDataSource() private readonly call_tracker: DataSource,private readonly permissionService: PermissionService,
        @InjectDataSource() private call_tracker: DataSource
    ) { }

    async CallLogDetailPagination(commonDTO: CommonDTO, userId: number) {
        const parameters = [commonDTO.page_number, commonDTO.page_size, commonDTO.search_type, commonDTO.query_search, userId];
        try {
            const result = await this.call_tracker.query(SQL.callLogDetailPagination, parameters);
            return result;
        } catch (error) {
            throw new Error(error);
        }
    }


    async createCallLogDetail(callLogDetailDTO: CallLogDetailDTO, userId: number, menuId: string) {
        const parameters = [
            callLogDetailDTO.call_log_id,
            callLogDetailDTO.contact_result_id,
            callLogDetailDTO.call_start_datetime,
            callLogDetailDTO.call_end_datetime,
            callLogDetailDTO.remark,
            menuId,
            JSON.stringify(callLogDetailDTO.contact_data),
            userId
        ]
        try {
            const result = await this.call_tracker.query(SQL.callLogDetailLogInsert, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async updateCallLogDetail(callLogDetailDTO: CallLogDetailDTO, userId: number, menuId: string) {
        const parameters = [
            callLogDetailDTO.call_log_id,
            callLogDetailDTO.call_log_detail_id,
            callLogDetailDTO.contact_result_id,
            callLogDetailDTO.call_start_datetime,
            callLogDetailDTO.call_end_datetime,
            callLogDetailDTO.remark,
            callLogDetailDTO.is_active,
            menuId,
            JSON.stringify(callLogDetailDTO.contact_data),
            userId
        ]
        try {
            const result = await this.call_tracker.query(SQL.callLogDetailLogUpdate, parameters);
            return result;
        }
        catch (error) {
            throw new Error(error);
        }
    }

    async callLogDetailExport(commonDTO: CommonDTO) {
            const parameters = [commonDTO.call_log_id];
            try {
                const result = await this.call_tracker.query(SQL.callLogDetailExport, parameters);
                return result;
            } catch (error) {
                throw new Error(error);
            }
        }
}