import { Model } from 'mongoose';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { LoginDto } from '../dataModel/auth/login.dto';
import { ResetPasswordDto } from '../dataModel/auth/reset-password.dto';
import { UserLogin } from '../auth/schema/user-login.schema';
import { UserActivityLog } from '../auth/schema//user-activity-log.schema';
import { ForgetPasswordLog } from '../auth/schema//forget-password-log.schema';
import { CreateUserDto } from 'src/dataModel/auth/create-user.dto';
export declare class AuthService {
    private readonly jwtService;
    private readonly configService;
    private readonly loginModel;
    private readonly userActivityLogModel;
    private readonly forgetPasswordLogModel;
    constructor(jwtService: JwtService, configService: ConfigService, loginModel: Model<UserLogin>, userActivityLogModel: Model<UserActivityLog>, forgetPasswordLogModel: Model<ForgetPasswordLog>);
    login(loginDto: LoginDto, ip: string): Promise<void | {
        token: string;
        res_status: number;
    } | {
        res_status: number;
        res_message: string;
    }>;
    private handleSuccessfulLogin;
    private handleFailedLoginAttempt;
    resetPassword(resetDto: ResetPasswordDto): Promise<{
        res_status: number;
        res_message: string;
    }>;
    createUser(createUserDto: CreateUserDto): Promise<UserLogin>;
    getProfile(user: any): Promise<{
        message: string;
        user: any;
    }>;
}
