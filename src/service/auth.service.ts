import { Injectable, UnauthorizedException, BadRequestException, ConflictException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, now } from 'mongoose';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { ConfigService } from '@nestjs/config';
import { LoginDto } from '../dataModel/auth/login.dto';
import { ResetPasswordDto } from '../dataModel/auth/reset-password.dto';
import { UserLogin } from '../auth/schema/user-login.schema';
import { UserActivityLog } from '../auth/schema//user-activity-log.schema';
import { ForgetPasswordLog } from '../auth/schema//forget-password-log.schema';
import { CreateUserDto } from 'src/dataModel/auth/create-user.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    @InjectModel(UserLogin.name) private readonly loginModel: Model<UserLogin>,
    @InjectModel(UserActivityLog.name) private readonly userActivityLogModel: Model<UserActivityLog>,
    @InjectModel(ForgetPasswordLog.name) private readonly forgetPasswordLogModel: Model<ForgetPasswordLog>,
  ) {}

  // private decryptPassword(encryptedPass: string): string {
  //   try {
  //       const secret = this.configService.get<string>('CRYPTO_SECRET') || '356181248f0e77e95c382df2e5abd86108a7c7abccca340ef1f1118a15235255';
  //       const decipher = crypto.createDecipher('aes-256-cbc', secret);
  //       let decrypted = decipher.update(encryptedPass, 'hex', 'utf8');
  //       decrypted += decipher.final('utf8');
  //       return decrypted;
  //   } catch (error) {
  //       throw new BadRequestException('Invalid password format.');
  //   }
  // }

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

  async resetPassword(resetDto: ResetPasswordDto) {
    if (resetDto.new_password !== resetDto.confirm_password) throw new BadRequestException('Passwords do not match.');
    // const newPassword = this.decryptPassword(resetDto.new_password);
    const newPassword = resetDto.new_password;
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    const userId = resetDto.user_id.trim();
    const result = await this.loginModel.findOneAndUpdate(
        { user_id: userId, is_reset_password: 'no', is_active: 'yes', is_lock_out: 'no' },
        { password: hashedPassword, is_reset_password: 'yes', last_password_change_date: new Date().toLocaleString() }
    );
    if (!result) throw new BadRequestException('Password reset failed.');
  
    return { res_status: 200, res_message: 'Password reset successful.' };
  }

  async createUser(createUserDto: CreateUserDto): Promise<UserLogin> {
    const { user_id, password } = createUserDto;

    const existingUser = await this.loginModel.findOne({ user_id }).exec();
    if (existingUser) {
      throw new ConflictException('User with this ID already exists.');
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const localString: string = new Date().toLocaleString();
    const newUser = new this.loginModel({
      ...createUserDto,
      password: hashedPassword,
      last_update_by: createUserDto.created_by,
      last_updated: localString, 
      created_date: localString,
    });
    
    return newUser.save();
  }
  
  async getProfile(user: any) {
    return { message: 'Successfully accessed protected profile data.', user };
  }
}