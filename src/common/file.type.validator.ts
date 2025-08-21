import { FileValidator } from '@nestjs/common';

export class CsvFileTypeValidator extends FileValidator<{}> {
  constructor() {
    super({});
  }

  isValid(file?: Express.Multer.File): boolean | Promise<boolean> {
    if (!file || !file.mimetype) {
      return false;
    }
    return (
      file.mimetype === 'text/csv' ||
      file.mimetype === 'application/octet-stream'
    );
  }

  buildErrorMessage(file: any): string {
    return 'Validation failed: Invalid file type. Only CSV files are allowed.';
  }
}