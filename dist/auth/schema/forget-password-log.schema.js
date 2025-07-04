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
Object.defineProperty(exports, "__esModule", { value: true });
exports.ForgetPasswordLogSchema = exports.ForgetPasswordLog = void 0;
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
let ForgetPasswordLog = class ForgetPasswordLog extends mongoose_2.Document {
    log_datetime;
    user_id;
    user_name;
    branch;
    division;
    department;
    is_active;
    is_reset_password;
    last_password_change_date;
    is_lock_out;
    fail_password_attemp_count;
    ip;
    is_email;
    is_success;
    success_datetime;
};
exports.ForgetPasswordLog = ForgetPasswordLog;
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], ForgetPasswordLog.prototype, "log_datetime", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], ForgetPasswordLog.prototype, "user_id", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], ForgetPasswordLog.prototype, "user_name", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], ForgetPasswordLog.prototype, "branch", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], ForgetPasswordLog.prototype, "division", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], ForgetPasswordLog.prototype, "department", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], ForgetPasswordLog.prototype, "is_active", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], ForgetPasswordLog.prototype, "is_reset_password", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], ForgetPasswordLog.prototype, "last_password_change_date", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], ForgetPasswordLog.prototype, "is_lock_out", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], ForgetPasswordLog.prototype, "fail_password_attemp_count", void 0);
__decorate([
    (0, mongoose_1.Prop)(),
    __metadata("design:type", String)
], ForgetPasswordLog.prototype, "ip", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: Boolean, default: true }),
    __metadata("design:type", Boolean)
], ForgetPasswordLog.prototype, "is_email", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: Boolean, default: false }),
    __metadata("design:type", Boolean)
], ForgetPasswordLog.prototype, "is_success", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: String, default: null }),
    __metadata("design:type", String)
], ForgetPasswordLog.prototype, "success_datetime", void 0);
exports.ForgetPasswordLog = ForgetPasswordLog = __decorate([
    (0, mongoose_1.Schema)()
], ForgetPasswordLog);
exports.ForgetPasswordLogSchema = mongoose_1.SchemaFactory.createForClass(ForgetPasswordLog);
exports.ForgetPasswordLogSchema.pre('save', function (next) {
    if (!this.log_datetime) {
        const offset = new Date().getTimezoneOffset();
        this.log_datetime = new Date(Date.now() - offset * 60 * 1000).toISOString();
    }
    next();
});
//# sourceMappingURL=forget-password-log.schema.js.map