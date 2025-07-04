import { Document as MongooseForgetPwDocument } from 'mongoose';
export declare class ForgetPasswordLog extends MongooseForgetPwDocument {
    log_datetime: string;
    user_id: string;
    user_name: string;
    branch: string;
    division: string;
    department: string;
    is_active: string;
    is_reset_password: string;
    last_password_change_date: string;
    is_lock_out: string;
    fail_password_attemp_count: string;
    ip: string;
    is_email: boolean;
    is_success: boolean;
    success_datetime: string;
}
export declare const ForgetPasswordLogSchema: import("mongoose").Schema<ForgetPasswordLog, import("mongoose").Model<ForgetPasswordLog, any, any, any, MongooseForgetPwDocument<unknown, any, ForgetPasswordLog, any> & ForgetPasswordLog & Required<{
    _id: unknown;
}> & {
    __v: number;
}, any>, {}, {}, {}, {}, import("mongoose").DefaultSchemaOptions, ForgetPasswordLog, MongooseForgetPwDocument<unknown, {}, import("mongoose").FlatRecord<ForgetPasswordLog>, {}> & import("mongoose").FlatRecord<ForgetPasswordLog> & Required<{
    _id: unknown;
}> & {
    __v: number;
}>;
