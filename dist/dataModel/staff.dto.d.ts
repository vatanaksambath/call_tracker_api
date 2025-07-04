import { ContactChannelDTO } from './contact-channel.dto';
export declare class StaffDTO {
    staff_id: string;
    staff_code: string;
    gender_id: string;
    village_id: string;
    manager_id: string;
    first_name: string;
    last_name: string;
    date_of_birth: string;
    position: string;
    department: string;
    employment_type: string;
    employment_start_date: string;
    employment_end_date: string;
    employment_level: string;
    current_address: string;
    photo_url: string;
    contact_data: ContactChannelDTO[];
    is_active: boolean;
}
