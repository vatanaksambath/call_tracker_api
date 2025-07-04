import { CallLogService } from '../service/call-log.service';
import { CallLogDTO } from 'src/dataModel/call-log.dto';
import { CommonDTO } from 'src/dataModel/common.dto';
export declare class CallLogController {
    private readonly CallLogService;
    constructor(CallLogService: CallLogService);
    get(commonDto: CommonDTO, req: any): Promise<any>;
    create(CallLogDTO: CallLogDTO, req: any): Promise<any>;
    update(CallLogDTO: CallLogDTO, req: any): Promise<any>;
    delete(id: number | string, req: any): Promise<any>;
}
