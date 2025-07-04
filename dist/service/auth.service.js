"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
const jwt_1 = require("@nestjs/jwt");
const bcrypt = require("bcryptjs");
const config_1 = require("@nestjs/config");
const user_login_schema_1 = require("../auth/schema/user-login.schema");
const user_activity_log_schema_1 = require("../auth/schema//user-activity-log.schema");
const forget_password_log_schema_1 = require("../auth/schema//forget-password-log.schema");
let AuthService = class AuthService {
    jwtService;
    configService;
    loginModel;
    userActivityLogModel;
    forgetPasswordLogModel;
    constructor(jwtService, configService, loginModel, userActivityLogModel, forgetPasswordLogModel) {
        this.jwtService = jwtService;
        this.configService = configService;
        this.loginModel = loginModel;
        this.userActivityLogModel = userActivityLogModel;
        this.forgetPasswordLogModel = forgetPasswordLogModel;
    }
    async login(loginDto, ip) {
        const password = loginDto.password;
        const user_id = loginDto.user_id.trim();
        const user = await this.loginModel.findOne({ user_id }).exec();
        if (!user) {
            console.log(`Login attempt for non-existent user_id: ${user_id}`);
            throw new common_1.UnauthorizedException('Please make sure the staff ID and password are correct.');
        }
        if (user.is_active !== 'yes')
            throw new common_1.UnauthorizedException('Account is locked. Please contact admin.');
        if (user.is_lock_out !== 'no')
            throw new common_1.UnauthorizedException('Account has been locked due to too many attempts. Please contact admin.');
        if (user.is_reset_password === 'yes') {
            if (user.password?.trimEnd() === password?.trimEnd()) {
                await this.loginModel.updateOne({ user_id }, { fail_password_attemp_count: '0' });
                return { res_status: 201, res_message: 'User must reset password.' };
            }
            else {
                return this.handleFailedLoginAttempt(user);
            }
        }
        else {
            const isMatch = await bcrypt.compare(password, user.password);
            if (isMatch)
                return this.handleSuccessfulLogin(user, ip);
            else
                return this.handleFailedLoginAttempt(user);
        }
    }
    async handleSuccessfulLogin(user, ip) {
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
    async handleFailedLoginAttempt(user) {
        const newAttemptCount = parseInt(user.fail_password_attemp_count || '0') + 1;
        if (newAttemptCount >= 5) {
            await this.loginModel.updateOne({ user_id: user.user_id }, { is_lock_out: 'yes', fail_password_attemp_count: newAttemptCount.toString() });
            throw new common_1.UnauthorizedException('Your account has been locked due to too many failed attempts.');
        }
        else {
            await this.loginModel.updateOne({ user_id: user.user_id }, { fail_password_attemp_count: newAttemptCount.toString() });
            throw new common_1.UnauthorizedException('Please make sure the staff ID and password are correct.');
        }
    }
    async resetPassword(resetDto) {
        if (resetDto.new_password !== resetDto.confirm_password)
            throw new common_1.BadRequestException('Passwords do not match.');
        const newPassword = resetDto.new_password;
        const hashedPassword = await bcrypt.hash(newPassword, 10);
        const userId = resetDto.user_id.trim();
        const result = await this.loginModel.findOneAndUpdate({ user_id: userId, is_reset_password: 'no', is_active: 'yes', is_lock_out: 'no' }, { password: hashedPassword, is_reset_password: 'yes', last_password_change_date: new Date().toLocaleString() });
        if (!result)
            throw new common_1.BadRequestException('Password reset failed.');
        return { res_status: 200, res_message: 'Password reset successful.' };
    }
    async createUser(createUserDto) {
        const { user_id, password } = createUserDto;
        const existingUser = await this.loginModel.findOne({ user_id }).exec();
        if (existingUser) {
            throw new common_1.ConflictException('User with this ID already exists.');
        }
        const hashedPassword = await bcrypt.hash(password, 10);
        const localString = new Date().toLocaleString();
        const newUser = new this.loginModel({
            ...createUserDto,
            password: hashedPassword,
            last_update_by: createUserDto.created_by,
            last_updated: localString,
            created_date: localString,
        });
        return newUser.save();
    }
    async getProfile(user) {
        return { message: 'Successfully accessed protected profile data.', user };
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __param(2, (0, mongoose_1.InjectModel)(user_login_schema_1.UserLogin.name)),
    __param(3, (0, mongoose_1.InjectModel)(user_activity_log_schema_1.UserActivityLog.name)),
    __param(4, (0, mongoose_1.InjectModel)(forget_password_log_schema_1.ForgetPasswordLog.name)),
    __metadata("design:paramtypes", [jwt_1.JwtService,
        config_1.ConfigService,
        mongoose_2.Model,
        mongoose_2.Model,
        mongoose_2.Model])
], AuthService);
//# sourceMappingURL=auth.service.js.map