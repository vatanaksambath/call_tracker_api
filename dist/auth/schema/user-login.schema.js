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
exports.UserLoginSchema = exports.UserLogin = void 0;
const mongoose_1 = require("@nestjs/mongoose");
const mongoose_2 = require("mongoose");
let UserLogin = class UserLogin extends mongoose_2.Document {
    user_id;
    user_name;
    password;
    gender;
    email;
    is_active;
    is_reset_password;
    last_password_change_date;
    is_lock_out;
    fail_password_attemp_count;
    phone_number;
    position;
    created_by;
    last_update_by;
    is_email;
    email_sent_date;
};
exports.UserLogin = UserLogin;
__decorate([
    (0, mongoose_1.Prop)({ type: String, unique: true, required: true }),
    __metadata("design:type", String)
], UserLogin.prototype, "user_id", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: String }),
    __metadata("design:type", String)
], UserLogin.prototype, "user_name", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: String, required: true }),
    __metadata("design:type", String)
], UserLogin.prototype, "password", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: String }),
    __metadata("design:type", String)
], UserLogin.prototype, "gender", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: String }),
    __metadata("design:type", String)
], UserLogin.prototype, "email", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: String, default: 'yes' }),
    __metadata("design:type", String)
], UserLogin.prototype, "is_active", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: String, default: 'yes' }),
    __metadata("design:type", String)
], UserLogin.prototype, "is_reset_password", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: String }),
    __metadata("design:type", String)
], UserLogin.prototype, "last_password_change_date", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: String, default: 'no' }),
    __metadata("design:type", String)
], UserLogin.prototype, "is_lock_out", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: String, default: '0' }),
    __metadata("design:type", String)
], UserLogin.prototype, "fail_password_attemp_count", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: String }),
    __metadata("design:type", String)
], UserLogin.prototype, "phone_number", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: String }),
    __metadata("design:type", String)
], UserLogin.prototype, "position", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: String, required: true }),
    __metadata("design:type", String)
], UserLogin.prototype, "created_by", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: String, required: true }),
    __metadata("design:type", String)
], UserLogin.prototype, "last_update_by", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: Boolean, default: false }),
    __metadata("design:type", Boolean)
], UserLogin.prototype, "is_email", void 0);
__decorate([
    (0, mongoose_1.Prop)({ type: Date, default: null }),
    __metadata("design:type", Date)
], UserLogin.prototype, "email_sent_date", void 0);
exports.UserLogin = UserLogin = __decorate([
    (0, mongoose_1.Schema)({ timestamps: { createdAt: 'created_date', updatedAt: 'last_updated' } })
], UserLogin);
exports.UserLoginSchema = mongoose_1.SchemaFactory.createForClass(UserLogin);
exports.UserLoginSchema.pre('save', function (next) {
    if (!this.last_password_change_date) {
        this.last_password_change_date = new Date().toLocaleString();
    }
    if (this.gender === 'm')
        this.gender = 'Male';
    if (this.gender === 'f')
        this.gender = 'Female';
    next();
});
//# sourceMappingURL=user-login.schema.js.map