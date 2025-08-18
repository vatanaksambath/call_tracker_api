import { Injectable, UnauthorizedException, BadRequestException, ConflictException, NotFoundException, Inject, InternalServerErrorException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, now } from 'mongoose';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { SupabaseClient } from '@supabase/supabase-js';
import { ConfigService } from '@nestjs/config';
import { LoginDto } from '../dataModel/auth/login.dto';
import { ResetPasswordDto } from '../dataModel/auth/reset-password.dto';
import { UserLogin } from '../auth/schema/user-login.schema';
import { UserActivityLog } from '../auth/schema//user-activity-log.schema';
import { ForgetPasswordLog } from '../auth/schema//forget-password-log.schema';
import { CreateUserDto } from 'src/dataModel/auth/create-user.dto';
import { UpdateUserDto } from 'src/dataModel/update-user.dto';
import { SUPABASE_CLIENT } from 'src/supabase/supabase.provider';
import { ForgotPasswordDto } from 'src/dataModel/auth/forgot-password.dto';
import { ChangePasswordDto } from 'src/dataModel/auth/change-password.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    @Inject(SUPABASE_CLIENT) private readonly supabase: SupabaseClient,
    @InjectModel(UserLogin.name) private readonly loginModel: Model<UserLogin>,
    @InjectModel(UserActivityLog.name) private readonly userActivityLogModel: Model<UserActivityLog>,
    @InjectModel(ForgetPasswordLog.name) private readonly forgetPasswordLogModel: Model<ForgetPasswordLog>,
  ) {}

  async login(loginDto: LoginDto, ip: string) {
    const password = loginDto.password;
    const user_id = loginDto.user_id.trim();
    const user = await this.loginModel.findOne({ user_id }).exec();

    if (!user) {
        console.log(`Login attempt for non-existent user_id: ${user_id}`);
        throw new UnauthorizedException('Please make sure the staff ID and password are correct.');
    }
    
    if (user.is_active !== 'yes') throw new UnauthorizedException('Account is locked. Please contact admin.');
    if (user.is_lock_out !== 'no') throw new UnauthorizedException('Account has been locked due to too many attempts. Please contact admin.');

    if (user.is_reset_password === 'yes') {
        if (user.password?.trimEnd() === password?.trimEnd()) {
            await this.loginModel.updateOne({ user_id }, { fail_password_attemp_count: '0' });
            return { res_status: 201, res_message: 'User must reset password.' };
        } else {
            return this.handleFailedLoginAttempt(user);
        }
    } else {
        const isMatch = await bcrypt.compare(password, user.password);
        if (isMatch) return this.handleSuccessfulLogin(user, ip);
        else return this.handleFailedLoginAttempt(user);
    }
  }

  private async handleSuccessfulLogin(user: UserLogin, ip: string) {
      await this.loginModel.updateOne({ user_id: user.user_id }, { fail_password_attemp_count: '0' });
      const payload = { user_id: user.user_id, user_name: user.user_name, user_email: user.email };
      const accessToken = this.jwtService.sign(payload);
      
      const logData = new this.userActivityLogModel({
          log_datetime: new Date().toLocaleString(),
          user_id: user.user_id,
          user_name: user.user_name,
          is_active: user.is_active,
          action: 'User login successful',
          ip,
      });
      await logData.save();

      return { token: accessToken, res_status: 200 };
  }

  private async handleFailedLoginAttempt(user: UserLogin) {
    const newAttemptCount = parseInt(user.fail_password_attemp_count || '0') + 1;
    if (newAttemptCount >= 5) {
        await this.loginModel.updateOne({ user_id: user.user_id }, { is_lock_out: 'yes', fail_password_attemp_count: newAttemptCount.toString() });
        throw new UnauthorizedException('Your account has been locked due to too many failed attempts.');
    } else {
        await this.loginModel.updateOne({ user_id: user.user_id }, { fail_password_attemp_count: newAttemptCount.toString() });
        throw new UnauthorizedException('Please make sure the staff ID and password are correct.');
    }
  }

  async changePassword(userId: string, changePasswordDto: ChangePasswordDto) {
    const { old_password, new_password, confirm_password } = changePasswordDto;

    if (new_password !== confirm_password) {
      throw new BadRequestException('New passwords do not match.');
    }

    const user = await this.loginModel.findOne({ user_id: userId, is_active: 'yes' }).exec();
    if (!user) {
      throw new NotFoundException('User not found or is inactive.');
    }

    const isPasswordMatching = await bcrypt.compare(old_password, user.password);
    if (!isPasswordMatching) {
      throw new UnauthorizedException('Incorrect old password.');
    }

    // Step 1: Update the password in Supabase Auth
    const { error: supabaseUpdateError } = await this.supabase.auth.admin.updateUserById(
      user.supabase_user_id,
      { password: new_password },
    );

    if (supabaseUpdateError) {
      throw new InternalServerErrorException(`Failed to update password in Supabase: ${supabaseUpdateError.message}`);
    }

    // Step 2: Hash the new password for MongoDB
    const hashedPassword = await bcrypt.hash(new_password, 10);

    // Step 3: Update the password in MongoDB
    await this.loginModel.updateOne(
      { user_id: userId },
      {
        password: hashedPassword,
        last_password_change_date: new Date(),
      },
    );

    return { res_status: 200, res_message: 'Password changed successfully.' };
  }

  async forgotPassword(forgotPasswordDto: ForgotPasswordDto) {
    const { user_id, email } = forgotPasswordDto;

    const user = await this.loginModel.findOne({ user_id, email, is_active: 'yes' });
    if (!user) {
      throw new BadRequestException('User with the provided User ID and Email does not exist or is inactive.');
    }

    const { error } = await this.supabase.auth.resetPasswordForEmail(email, {
      redirectTo: this.configService.get<string>('FRONTEND_URL') + '/update-password',
    });

    if (error) {
      console.error('Supabase password reset link generation error:', error.message);
      throw new InternalServerErrorException('Could not initiate password reset.');
    }

    return {
      res_status: 200,
      res_message: 'A password reset link has been sent to the provided email.',
    };
  }

  async resetPassword(resetDto: ResetPasswordDto) {
    if (resetDto.new_password !== resetDto.confirm_password) {
      throw new BadRequestException('Passwords do not match.');
    }

    const {
      data: { user },
      error: tokenError,
    } = await this.supabase.auth.getUser(resetDto.token);

    if (tokenError || !user) {
      throw new BadRequestException('Invalid or expired password reset token.');
    }
    
    // Step 1: Update the password in Supabase Auth
    const { error: supabaseUpdateError } = await this.supabase.auth.admin.updateUserById(
        user.id,
        { password: resetDto.new_password }
    );

    if (supabaseUpdateError) {
        throw new InternalServerErrorException(`Failed to update password in Supabase: ${supabaseUpdateError.message}`);
    }

    // Step 2: Hash the password for MongoDB
    const hashedPassword = await bcrypt.hash(resetDto.new_password, 10);

    // Step 3: Update the password in MongoDB
    const result = await this.loginModel.updateOne(
      { email: user.email, is_active: 'yes' },
      {
        password: hashedPassword,
        is_reset_password: 'no',
        last_password_change_date: new Date(),
      },
    );

    if (result.modifiedCount === 0) {
      // Note: This might indicate a sync issue if the Supabase update succeeded but Mongo failed
      throw new BadRequestException(
        'Password reset failed. User not found in local DB or password could not be updated.',
      );
    }

    return { res_status: 200, res_message: 'Password has been reset successfully.' };
  }

  async createUser(createUserDto: CreateUserDto): Promise<UserLogin> {
    const { user_id, email, password } = createUserDto;

    if (!email || !password) {
      throw new BadRequestException('Email and password are required.');
    }

    const existingUser = await this.loginModel.findOne({ user_id }).exec();
    if (existingUser) {
      throw new ConflictException('User with this ID already exists.');
    }

    const { data: supabaseUser, error: supabaseError } =
      await this.supabase.auth.admin.createUser({
        email,
        password,
        email_confirm: true
      });

    if (supabaseError) {
      throw new InternalServerErrorException(
        `Failed to create user in Supabase: ${supabaseError.message}`,
      );
    }
    if (!supabaseUser.user) {
        throw new InternalServerErrorException('Supabase user was not created.');
    }

    // Step 2: If Supabase user is created, save to MongoDB
    const hashedPassword = await bcrypt.hash(password, 10);
    const localString: string = new Date().toLocaleString();

    const newUser = new this.loginModel({
      ...createUserDto,
      password: hashedPassword,
      supabase_user_id: supabaseUser.user.id, // Store the Supabase ID
      last_update_by: createUserDto.created_by,
      last_updated: localString,
      created_date: localString,
    });

    return newUser.save();
  }

  async updateUser(userId: string, updateUserDto: UpdateUserDto): Promise<UserLogin> {
    const currentUser = await this.loginModel.findOne({ user_id: userId }).exec();
    if (!currentUser) {
        throw new NotFoundException(`User with ID "${userId}" not found.`);
    }

    // Check if email is being updated and is different from the current one
    if (updateUserDto.email && updateUserDto.email !== currentUser.email) {
        const { error: supabaseUpdateError } = await this.supabase.auth.admin.updateUserById(
            currentUser.supabase_user_id, // Use the stored Supabase ID
            { email: updateUserDto.email }
        );

        if (supabaseUpdateError) {
            throw new InternalServerErrorException(`Failed to update user email in Supabase: ${supabaseUpdateError.message}`);
        }
    }

    const updateData: any = { ...updateUserDto };
    if (updateUserDto.password) {
      updateData.password = await bcrypt.hash(updateUserDto.password, 10);
    }

    updateData.last_updated = new Date().toLocaleString();
    if (updateUserDto.updated_by) {
      updateData.last_update_by = updateUserDto.updated_by;
    }

    const updatedUser = await this.loginModel.findOneAndUpdate(
      { user_id: userId },
      { $set: updateData },
      { new: true },
    ).exec();

    if (!updatedUser) {
      throw new NotFoundException(`User with ID "${userId}" not found during update.`);
    }

    return updatedUser;
  }
  
  async getProfileById(userId: string): Promise<UserLogin> {
    const user = await this.loginModel.findOne({ user_id: userId }).exec();
    if (!user) {
        throw new NotFoundException(`User with ID "${userId}" not found.`);
    }
    return user;
  }

  async getAllProfile(): Promise<UserLogin[]> {
    return this.loginModel.find().exec();
  }
}