import { AuthService } from '../service/auth.service';
import { LoginDto } from '../dataModel/auth/login.dto';
import { ResetPasswordDto } from '../dataModel/auth/reset-password.dto';
import { Request } from 'express';
import { CreateUserDto } from 'src/dataModel/auth/create-user.dto';
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    login(loginDto: LoginDto, req: Request): Promise<void | {
        token: string;
        res_status: number;
    } | {
        res_status: number;
        res_message: string;
    }>;
    resetPassword(resetPasswordDto: ResetPasswordDto): Promise<{
        res_status: number;
        res_message: string;
    }>;
    createUser(createUserDto: CreateUserDto): Promise<{
        message: string;
        user: any;
    }>;
    getProfile(req: any): Promise<{
        message: string;
        user: any;
    }>;
}
