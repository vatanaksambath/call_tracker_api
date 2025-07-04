import { ContactChannelDTO } from './contact-channel.dto';
export declare class CallLogDetailDTO {
    call_log_id: string;
    call_log_detail_id: string;
    contact_result_id: string;
    call_start_datetime: string;
    call_end_datetime: string;
    remark: string;
    menu_id: string;
    contact_data: ContactChannelDTO[];
    is_active: boolean;
}
