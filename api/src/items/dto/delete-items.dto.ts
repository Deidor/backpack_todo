import { ArrayNotEmpty, ArrayUnique, IsArray, IsInt } from 'class-validator';

export class DeleteItemsDto {
  @IsArray()
  @ArrayNotEmpty()
  @ArrayUnique()
  @IsInt({ each: true })
  ids: number[];
}
