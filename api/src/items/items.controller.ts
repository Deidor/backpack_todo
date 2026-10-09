import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseIntPipe,
  Patch,
  Post,
} from '@nestjs/common';

import { Item } from './item.entity';
import { ItemsService } from './items.service';
import { CreateItemDto } from './dto/create-item.dto';
import { UpdateItemDto } from './dto/update-item.dto';
import { DeleteItemsDto } from './dto/delete-items.dto';

@Controller('items')
export class ItemsController {
  constructor(private readonly itemsService: ItemsService) {}

  @Get()
  findAll(): Promise<Item[]> {
    return this.itemsService.findAll();
  }

  @Post()
  create(@Body() dto: CreateItemDto): Promise<Item> {
    return this.itemsService.create(dto);
  }

  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateItemDto,
  ): Promise<Item> {
    return this.itemsService.update(id, dto);
  }

  @Post('bulk-delete')
  @HttpCode(HttpStatus.NO_CONTENT)
  removeMany(@Body() dto: DeleteItemsDto): Promise<void> {
    return this.itemsService.removeMany(dto.ids);
  }
}
