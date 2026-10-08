import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Item } from './item.entity';
import { CreateItemDto } from './dto/create-item.dto';
import { UpdateItemDto } from './dto/update-item.dto';

@Injectable()
export class ItemsService {
  constructor(
    @InjectRepository(Item)
    private readonly items: Repository<Item>,
  ) {}

  findAll(): Promise<Item[]> {
    return this.items.find({ order: { id: 'ASC' } });
  }

  create(dto: CreateItemDto): Promise<Item> {
    return this.items.save(this.items.create({ name: dto.name }));
  }

  async update(id: number, dto: UpdateItemDto): Promise<Item> {
    const item = await this.items.findOneBy({ id });
    if (!item) {
      throw new NotFoundException(`Item ${id} not found`);
    }
    if (dto.packed !== undefined) item.packed = dto.packed;
    if (dto.toBuy !== undefined) item.toBuy = dto.toBuy;
    return this.items.save(item);
  }

  async removeMany(ids: number[]): Promise<void> {
    await this.items.delete(ids);
  }
}