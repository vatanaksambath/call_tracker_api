import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
  ParseFilePipe,
  MaxFileSizeValidator,
  Req,
  UseGuards,
  UnauthorizedException,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { LeadImportService } from '../service/lead-import.service';
import { CsvFileTypeValidator } from '../common/file.type.validator';
import { PermissionGuard } from 'src/auth/decorator/permission.guard';
import { AuthGuard } from 'src/auth/auth.guard';

@Controller('import-data')
export class LeadImportController {
  constructor(private readonly leadImportService: LeadImportService) {}

  @UseGuards(PermissionGuard, AuthGuard)
  @Post('lead')
  @UseInterceptors(FileInterceptor('file'))
  async importLeadsFromFile(
    @UploadedFile(
      new ParseFilePipe({
        validators: [
          new MaxFileSizeValidator({ maxSize: 5 * 1024 * 1024 }),
          new CsvFileTypeValidator(),
        ],
      }),
    )
    file: Express.Multer.File,
    @Req() req: any,
  ) {
    const userIdString = req.user?.user_id;

    if (!userIdString) {
      throw new UnauthorizedException('User identifier not found in token.');
    }
    
    const userId = parseInt(userIdString, 10);

    if (isNaN(userId)) {
      throw new BadRequestException('User ID is not a valid number.');
    }
    
    return this.leadImportService.importLeads(file, userId);
  }
}