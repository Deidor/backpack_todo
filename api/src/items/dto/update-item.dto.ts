import { IsBoolean, IsOptional } from 'class-validator';

export class UpdateItemDto {
  @IsOptional()
  @IsBoolean()
  packed?: boolean;

  @IsOptional()
  @IsBoolean()
  toBuy?: boolean;
}
