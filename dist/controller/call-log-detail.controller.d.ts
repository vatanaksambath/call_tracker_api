import { CallLogDetailService } from '../service/call-log-detail.service';
import { CallLogDetailDTO } from 'src/dataModel/call-log-detail.dto';
export declare class CallLogDetailController {
    private readonly callLogDetailService;
    constructor(callLogDetailService: CallLogDetailService);
    create(callLogDetailDTO: CallLogDetailDTO, req: any): Promise<any>;
    update(callLogDetailDTO: CallLogDetailDTO, req: any): Promise<any>;
}
