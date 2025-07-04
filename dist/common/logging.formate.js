"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.LoggingFormate = void 0;
const common_util_1 = require("./common.util");
class LoggingFormate {
    static COLORS = {
        RESET: '\x1b[0m',
        FG_GREEN: '\x1b[32m',
        FG_CYAN: '\x1b[36m',
        FG_YELLOW: '\x1b[33m',
        FG_MAGENTA: '\x1b[35m',
        FG_RED: '\x1b[31m',
        BRIGHT: '\x1b[1m',
    };
    logRequest({ method, originalUrl, user, ip, time, userAgent }) {
        const COLORS = LoggingFormate.COLORS;
        const userDisplay = (0, common_util_1.getUserDisplay)(user);
        console.log(`\n${COLORS.FG_CYAN}───────────────────────────────${COLORS.RESET}\n` +
            `🌈  ${COLORS.BRIGHT}${COLORS.FG_MAGENTA}Request  ${userDisplay}${COLORS.RESET}\n` +
            `${COLORS.FG_CYAN}───────────────────────────────${COLORS.RESET}\n` +
            `• ${COLORS.FG_YELLOW}Time${COLORS.RESET}      : ${time}\n` +
            `• ${COLORS.FG_YELLOW}Method${COLORS.RESET}    : ${method}\n` +
            `• ${COLORS.FG_YELLOW}URL${COLORS.RESET}       : ${originalUrl}\n` +
            `• ${COLORS.FG_YELLOW}User${COLORS.RESET}      : ${userDisplay}\n` +
            `• ${COLORS.FG_YELLOW}Agent${COLORS.RESET}     : ${userAgent}\n` +
            `• ${COLORS.FG_YELLOW}IP${COLORS.RESET}        : ${ip}\n` +
            `${COLORS.FG_CYAN}───────────────────────────────${COLORS.RESET}`);
    }
    logResponse({ user, statusCode, message, duration, time, userAgent, originalUrl, method }) {
        const COLORS = LoggingFormate.COLORS;
        const userDisplay = (0, common_util_1.getUserDisplay)(user);
        console.log(`\n${COLORS.FG_GREEN}🟢  Response  ${userDisplay}${COLORS.RESET}\n` +
            `${COLORS.FG_CYAN}───────────────────────────────${COLORS.RESET}\n` +
            `• ${COLORS.FG_YELLOW}Time${COLORS.RESET}     : ${time}\n` +
            `• ${COLORS.FG_YELLOW}Method${COLORS.RESET}   : ${method}\n` +
            `• ${COLORS.FG_YELLOW}URL${COLORS.RESET}      : ${originalUrl}\n` +
            `• ${COLORS.FG_YELLOW}Status${COLORS.RESET}   : ${statusCode}\n` +
            `• ${COLORS.FG_YELLOW}Duration${COLORS.RESET} : ${duration}ms\n` +
            `• ${COLORS.FG_YELLOW}User${COLORS.RESET}     : ${userDisplay}\n` +
            `• ${COLORS.FG_YELLOW}Agent${COLORS.RESET}    : ${userAgent}\n` +
            `• ${COLORS.FG_YELLOW}Message${COLORS.RESET}  : ${message}\n` +
            `${COLORS.FG_CYAN}───────────────────────────────${COLORS.RESET}`);
    }
    logError({ user, statusCode, message, duration, time, error, userAgent, originalUrl, method }) {
        const COLORS = LoggingFormate.COLORS;
        const userDisplay = (0, common_util_1.getUserDisplay)(user);
        console.error(`\n${COLORS.FG_RED}🔴  Error  ${userDisplay}${COLORS.RESET}\n` +
            `${COLORS.FG_RED}───────────────────────────────\n` +
            `• Time     : ${time}\n` +
            `• Method   : ${method}\n` +
            `• URL      : ${originalUrl}\n` +
            `• Status   : ${statusCode}\n` +
            `• Duration : ${duration}ms\n` +
            `• User     : ${userDisplay}\n` +
            `• Agent    : ${userAgent}\n` +
            `• Message  : ${message}\n` +
            (error ? `• Error    : ${error}\n` : '') +
            `───────────────────────────────${COLORS.RESET}`);
    }
}
exports.LoggingFormate = LoggingFormate;
//# sourceMappingURL=logging.formate.js.map