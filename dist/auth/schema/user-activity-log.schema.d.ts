import { Document as MongooseActivityDocument } from 'mongoose';
export declare class UserActivityLog extends MongooseActivityDocument {
    log_datetime: string;
    user_id: string;
    user_name: string;
    is_active: string;
    action: string;
    ip: string;
}
export declare const UserActivityLogSchema: import("mongoose").Schema<UserActivityLog, import("mongoose").Model<UserActivityLog, any, any, any, MongooseActivityDocument<unknown, any, UserActivityLog, any> & UserActivityLog & Required<{
    _id: unknown;
}> & {
    __v: number;
}, any>, {}, {}, {}, {}, import("mongoose").DefaultSchemaOptions, UserActivityLog, MongooseActivityDocument<unknown, {}, import("mongoose").FlatRecord<UserActivityLog>, {}> & import("mongoose").FlatRecord<UserActivityLog> & Required<{
    _id: unknown;
}> & {
    __v: number;
}>;
