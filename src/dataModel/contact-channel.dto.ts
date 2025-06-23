import { Type } from 'class-transformer';
import { IsString, IsNotEmpty, IsOptional, IsBoolean, ValidateNested, IsArray, IsInt } from 'class-validator';
import { ContactValueDTO } from './contact-value.dto';

export class ContactChannelDTO {
  @IsString()
  @IsNotEmpty()
  channel_type_id: string;

  @IsArray()
  @ValidateNested({ each: true }) 
  @Type(() => ContactValueDTO)
  contact_values: ContactValueDTO[];
}