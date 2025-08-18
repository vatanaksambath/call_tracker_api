import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema({ timestamps: { createdAt: 'created_date', updatedAt: 'last_updated' } })
export class UserLogin extends Document {
  @Prop({ type: String, unique: true, required: true })
  user_id: string;

  @Prop({ type: String })
  user_name: string;

  @Prop({ type: String, required: true })
  password: string;

  @Prop({ type: String })
  gender: string;

  @Prop({ type: String })
  email: string;

  @Prop({ type: String, default: 'yes' })
  is_active: string;

  @Prop({ type: String, default: 'yes' })
  is_reset_password: string;

  @Prop({ type: String })
  last_password_change_date: string;

  @Prop({ type: String, default: 'no' })
  is_lock_out: string;

  @Prop({ type: String, default: '0' })
  fail_password_attemp_count: string;

  @Prop({ type: String })
  phone_number: string;

  @Prop({ type: String })
  position: string;

  @Prop({ type: String, required: true })
  created_by: string;

  @Prop({ type: String, required: true })
  last_update_by: string;

  @Prop({ type: Boolean, default: false })
  is_email: boolean;

  @Prop({ type: Date, default: null })
  email_sent_date: Date;

  @Prop({ type: String, required: true })
  supabase_user_id: string;
}

export const UserLoginSchema = SchemaFactory.createForClass(UserLogin);

UserLoginSchema.pre('save', function (next) {
  if (!this.last_password_change_date) {
    this.last_password_change_date = new Date().toLocaleString();
  }
  if (this.gender === 'm') this.gender = 'Male';
  if (this.gender === 'f') this.gender = 'Female';
  next();
});