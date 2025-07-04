export declare class CreateUserDto {
    user_id: string;
    user_name: string;
    gender?: string;
    phone_number?: string;
    password: string;
    email?: boolean;
    email_sent_date: string;
    is_active?: boolean;
    is_reset_password?: boolean;
    is_lock_out?: boolean;
    fail_password_attemp_count?: boolean;
    created_by: string;
    created_date: string;
    last_updated_by: string;
    last_updated_date: string;
    last_password_change_date: string;
}
