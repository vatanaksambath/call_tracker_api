import { ContactChannelDTO } from './contact-channel.dto';
export declare class LeadDTO {
    lead_id: string;
    gender_id: string;
    customer_type_id: string;
    lead_source_id: string;
    village_id: string;
    business_id: string;
    initial_staff_id: string;
    current_staff_id: string;
    first_name: string;
    last_name: string;
    date_of_birth: string;
    email: string;
    occupation: string;
    home_address: string;
    street_address: string;
    biz_description: string;
    relationship_date: string;
    remark: string;
    photo_url: string;
    contact_data: ContactChannelDTO[];
    is_active: boolean;
}
