import { Document } from 'mongoose';
export declare class UserLogin extends Document {
    user_id: string;
    user_name: string;
    password: string;
    gender: string;
    email: string;
    is_active: string;
    is_reset_password: string;
    last_password_change_date: string;
    is_lock_out: string;
    fail_password_attemp_count: string;
    phone_number: string;
    position: string;
    created_by: string;
    last_update_by: string;
    is_email: boolean;
    email_sent_date: Date;
}
export declare const UserLoginSchema: import("mongoose").Schema<UserLogin, import("mongoose").Model<UserLogin, any, any, any, Document<unknown, any, UserLogin, any> & UserLogin & Required<{
    _id: unknown;
}> & {
    __v: number;
}, any>, {}, {}, {}, {}, import("mongoose").DefaultSchemaOptions, UserLogin, Document<unknown, {}, import("mongoose").FlatRecord<UserLogin>, {}> & import("mongoose").FlatRecord<UserLogin> & Required<{
    _id: unknown;
}> & {
    __v: number;
}>;
