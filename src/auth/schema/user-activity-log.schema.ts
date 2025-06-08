import { Prop, Schema as MongooseActivitySchema, SchemaFactory as MongooseActivitySchemaFactory } from '@nestjs/mongoose';
import { Document as MongooseActivityDocument } from 'mongoose';

@MongooseActivitySchema()
export class UserActivityLog extends MongooseActivityDocument {
    @Prop() log_datetime: string;
    @Prop() user_id: string;
    @Prop() user_name: string;
    @Prop() is_active: string;
    @Prop() action: string;
    @Prop() ip: string;
}
export const UserActivityLogSchema = MongooseActivitySchemaFactory.createForClass(UserActivityLog);
