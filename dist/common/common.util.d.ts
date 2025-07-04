export declare function convertValuesToNull(value: string | number | null | undefined): string | number | null | undefined;
export type ConvertOptions = {
    fields: string[];
};
export declare function convertEmptyToNull<T extends object>(data: T[], options: ConvertOptions): T[];
export declare function formatDate(date: Date): string;
export declare function getUserDisplay(user?: any): string;
export declare function arrayToCommaSeparatedString(names: any): string;
export declare function formatDateExcel(dateString: string | null): string;
export declare function formatPercentage(value: number | null): string;
export declare function formatCurrency(amount: number | null): string;
export declare function getYesNo(value: boolean | null): string;
export declare function formatCoBorrower(coBorrowers: any): string;
export declare function yesNoToBoolean(value: string): boolean | {
    message: string;
    error: string | null;
    statusCode: number;
}[];
export declare function formatAccountNumber(accountNumber: string): string;
