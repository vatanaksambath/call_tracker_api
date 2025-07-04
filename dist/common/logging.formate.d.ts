export declare class LoggingFormate {
    static COLORS: {
        RESET: string;
        FG_GREEN: string;
        FG_CYAN: string;
        FG_YELLOW: string;
        FG_MAGENTA: string;
        FG_RED: string;
        BRIGHT: string;
    };
    logRequest({ method, originalUrl, user, ip, time, userAgent }: any): void;
    logResponse({ user, statusCode, message, duration, time, userAgent, originalUrl, method }: any): void;
    logError({ user, statusCode, message, duration, time, error, userAgent, originalUrl, method }: any): void;
}
