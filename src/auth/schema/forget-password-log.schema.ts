import { Prop, Schema as MongooseForgetPwSchema, SchemaFactory as MongooseForgetPwSchemaFactory } from '@nestjs/mongoose';
import { Document as MongooseForgetPwDocument } from 'mongoose';

@MongooseForgetPwSchema()
export class ForgetPasswordLog extends MongooseForgetPwDocument {
    @Prop() log_datetime: string;
    @Prop() user_id: string;
    @Prop() user_name: string;
    @Prop() branch: string;
    @Prop() division: string;
    @Prop() department: string;
    @Prop() is_active: string;
    @Prop() is_reset_password: string;
    @Prop() last_password_change_date: string;
    @Prop() is_lock_out: string;
    @Prop() fail_password_attemp_count: string;
    @Prop() ip: string;
    @Prop({ type: Boolean, default: true }) is_email: boolean;
    @Prop({ type: Boolean, default: false }) is_success: boolean;
    @Prop({ type: String, default: null }) success_datetime: string;
}
export const ForgetPasswordLogSchema = MongooseForgetPwSchemaFactory.createForClass(ForgetPasswordLog);

ForgetPasswordLogSchema.pre('save', function (next) {
    if (!this.log_datetime) {
        const offset = new Date().getTimezoneOffset();
        this.log_datetime = new Date(Date.now() - offset * 60 * 1000).toISOString();
    }
    next();
});