import { BadRequestException } from "@nestjs/common";

export function convertValuesToNull(value: string | number | null | undefined): string | number | null | undefined {
  if (typeof value === 'string' && value.trim().toLowerCase() === 'all') {
    return null;
  }
  return value;
}
export type ConvertOptions = {
  fields: string[];
};

export function convertEmptyToNull<T extends object>(
  data: T[],
  options: ConvertOptions
): T[] {
  const { fields } = options;

  return data.map(item => {
    const newItem = { ...item } as Record<string, any>;

    fields.forEach(field => {
      if (newItem[field] === '' || newItem[field] === undefined) {
        newItem[field] = null;
      }
    });

    return newItem as T;
  });
}

export function formatDate(date: Date): string {
  return date.toLocaleString('en-GB', { hour12: false });
}

// Static utility for user display string
export function getUserDisplay(user?: any): string {
  const userId = user?.user_id ?? 'Anonymous';
  const userName = user?.user_name ?? 'Anonymous';
  return `${userName} [${userId}]`;
}

export function arrayToCommaSeparatedString(names: any): string {
  if (!Array.isArray(names)) return '';
  return names.join(',');
}

export function formatDateExcel(dateString: string | null): string {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleDateString('en-CA');
};

export function formatPercentage(value: number | null): string {
  if (value === null || value === undefined) return '';
  return `${value.toLocaleString('en-US', {
    minimumFractionDigits: 0,
    maximumFractionDigits: 2
  })}%`;
};


export function formatCurrency(amount: number | null): string {
  if (!amount) return '';
  return new Intl.NumberFormat('en-US', {
    minimumFractionDigits: 0,
    maximumFractionDigits: 2
  }).format(amount);
};


export function getYesNo(value: boolean | null): string {
  if (value === null || value === undefined) return '';
  return value ? 'Y' : 'N';
};

export function formatCoBorrower(coBorrowers: any): string {
  if (!coBorrowers) return '';

  // Handle string input
  if (typeof coBorrowers === 'string') {
    try {
      const parsed = JSON.parse(coBorrowers);
      if (Array.isArray(parsed)) {
        return formatCoBorrower(parsed);
      }
      return parsed.customerName || parsed.name || coBorrowers;
    } catch {
      return coBorrowers;
    }
  }

  // Ensure array
  if (!Array.isArray(coBorrowers)) {
    coBorrowers = [coBorrowers];
  }

  return coBorrowers
    .map((b: any) => {
      // Handle null/undefined
      if (!b) return '';

      // Handle string items
      if (typeof b === 'string') {
        try {
          const parsed = JSON.parse(b);
          return parsed.customerName || parsed.name || b;
        } catch {
          return b; // Return as is if not JSON
        }
      }

      // Handle object items
      if (typeof b === 'object') {
        return b.customerName || b.name || '';
      }

      return String(b);
    })
    .filter(Boolean)
    .join(', ');
}

export function yesNoToBoolean(value: string): boolean | {
  message   : string;
  error     : string | null;
  statusCode: number;
}[] {
  const lower = value?.toLowerCase();

  if (lower === 'yes') return true;
  if (lower === 'no') return false;

  return [{
    message: 'Invalid input: expected "yes" or "no".',
    error: 'InvalidQueryParameter',
    statusCode: 400,
  }];
}

export function formatAccountNumber(accountNumber: string): string {
  const length = accountNumber.length;

  if (length < 9 || length > 14) {
    throw new Error("Account number must be between 9 and 14 characters long");
  }

  if (accountNumber.includes("-") || length === 9) {
    return accountNumber;
  }

  return `${accountNumber.slice(0, 3)}-${accountNumber.slice(3)}`;
}

export function getPrefix(menu) {
  const prefixMap = {
    'lead': 'LD',
    'staff': '',
    'site_visit': 'ST',
    'property_profile': 'PT',
  };

  return prefixMap[menu.toLowerCase()] ?? 'UNKNOWN';
}