import { CallLogDetailDTO } from './call-log-detail.dto';
export declare class CallLogDTO {
    call_log_id: string;
    lead_id: string;
    property_profile_id: string;
    status_id: string;
    purpose: string;
    fail_reason: string;
    p_call_log_detail: CallLogDetailDTO[];
    is_active: boolean;
}
