"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RequirePermission = exports.PERMISSION_CHECK_KEY = void 0;
const common_1 = require("@nestjs/common");
exports.PERMISSION_CHECK_KEY = 'required_permission';
const RequirePermission = (menu_id, permission_id) => (0, common_1.SetMetadata)(exports.PERMISSION_CHECK_KEY, { menu_id, permission_id });
exports.RequirePermission = RequirePermission;
//# sourceMappingURL=permission.decorator.js.map