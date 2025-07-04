import { DataSource } from 'typeorm';
import { CallLogDTO } from 'src/dataModel/call-log.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class CallLogService {
    private call_tracker;
    constructor(call_tracker: DataSource);
    CallLogPagination(commonDTO: CommonDTO, userId: number): Promise<any>;
    createCallLog(callLogDTO: CallLogDTO, userId: number, menuId: string): Promise<any>;
    updateCallLog(callLogDTO: CallLogDTO, userId: number, menuId: string): Promise<any>;
    deleteCallLog(id: number | string): Promise<any>;
}
