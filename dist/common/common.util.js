"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.convertValuesToNull = convertValuesToNull;
exports.convertEmptyToNull = convertEmptyToNull;
exports.formatDate = formatDate;
exports.getUserDisplay = getUserDisplay;
exports.arrayToCommaSeparatedString = arrayToCommaSeparatedString;
exports.formatDateExcel = formatDateExcel;
exports.formatPercentage = formatPercentage;
exports.formatCurrency = formatCurrency;
exports.getYesNo = getYesNo;
exports.formatCoBorrower = formatCoBorrower;
exports.yesNoToBoolean = yesNoToBoolean;
exports.formatAccountNumber = formatAccountNumber;
function convertValuesToNull(value) {
    if (typeof value === 'string' && value.trim().toLowerCase() === 'all') {
        return null;
    }
    return value;
}
function convertEmptyToNull(data, options) {
    const { fields } = options;
    return data.map(item => {
        const newItem = { ...item };
        fields.forEach(field => {
            if (newItem[field] === '' || newItem[field] === undefined) {
                newItem[field] = null;
            }
        });
        return newItem;
    });
}
function formatDate(date) {
    return date.toLocaleString('en-GB', { hour12: false });
}
function getUserDisplay(user) {
    const userId = user?.user_id ?? 'Anonymous';
    const userName = user?.user_name ?? 'Anonymous';
    return `${userName} [${userId}]`;
}
function arrayToCommaSeparatedString(names) {
    if (!Array.isArray(names))
        return '';
    return names.join(',');
}
function formatDateExcel(dateString) {
    if (!dateString)
        return '';
    const date = new Date(dateString);
    return date.toLocaleDateString('en-CA');
}
;
function formatPercentage(value) {
    if (value === null || value === undefined)
        return '';
    return `${value.toLocaleString('en-US', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 2
    })}%`;
}
;
function formatCurrency(amount) {
    if (!amount)
        return '';
    return new Intl.NumberFormat('en-US', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 2
    }).format(amount);
}
;
function getYesNo(value) {
    if (value === null || value === undefined)
        return '';
    return value ? 'Y' : 'N';
}
;
function formatCoBorrower(coBorrowers) {
    if (!coBorrowers)
        return '';
    if (typeof coBorrowers === 'string') {
        try {
            const parsed = JSON.parse(coBorrowers);
            if (Array.isArray(parsed)) {
                return formatCoBorrower(parsed);
            }
            return parsed.customerName || parsed.name || coBorrowers;
        }
        catch {
            return coBorrowers;
        }
    }
    if (!Array.isArray(coBorrowers)) {
        coBorrowers = [coBorrowers];
    }
    return coBorrowers
        .map((b) => {
        if (!b)
            return '';
        if (typeof b === 'string') {
            try {
                const parsed = JSON.parse(b);
                return parsed.customerName || parsed.name || b;
            }
            catch {
                return b;
            }
        }
        if (typeof b === 'object') {
            return b.customerName || b.name || '';
        }
        return String(b);
    })
        .filter(Boolean)
        .join(', ');
}
function yesNoToBoolean(value) {
    const lower = value?.toLowerCase();
    if (lower === 'yes')
        return true;
    if (lower === 'no')
        return false;
    return [{
            message: 'Invalid input: expected "yes" or "no".',
            error: 'InvalidQueryParameter',
            statusCode: 400,
        }];
}
function formatAccountNumber(accountNumber) {
    const length = accountNumber.length;
    if (length < 9 || length > 14) {
        throw new Error("Account number must be between 9 and 14 characters long");
    }
    if (accountNumber.includes("-") || length === 9) {
        return accountNumber;
    }
    return `${accountNumber.slice(0, 3)}-${accountNumber.slice(3)}`;
}
//# sourceMappingURL=common.util.js.map