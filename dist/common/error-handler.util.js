"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ArrayBadRequestException = void 0;
exports.dispatchBadRequestException = dispatchBadRequestException;
const common_1 = require("@nestjs/common");
class ArrayBadRequestException extends common_1.InternalServerErrorException {
    constructor(nativeError) {
        super([
            {
                message: 'Something went wrong, please try again.',
                error: nativeError,
                statusCode: 500,
            },
        ]);
    }
}
exports.ArrayBadRequestException = ArrayBadRequestException;
function dispatchBadRequestException(error) {
    const nativeError = error?.response?.message || error.message || 'Unknown error';
    throw new ArrayBadRequestException(nativeError);
}
//# sourceMappingURL=error-handler.util.js.map