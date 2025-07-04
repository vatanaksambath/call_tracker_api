import { DataSource } from 'typeorm';
import { CallLogDetailDTO } from 'src/dataModel/call-log-detail.dto';
export declare class CallLogDetailService {
    private call_tracker;
    constructor(call_tracker: DataSource);
    createCallLogDetail(callLogDetailDTO: CallLogDetailDTO, userId: number, menuId: string): Promise<any>;
    updateCallLogDetail(callLogDetailDTO: CallLogDetailDTO, userId: number, menuId: string): Promise<any>;
}
