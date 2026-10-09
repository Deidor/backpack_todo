import { NotFoundException } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Item } from './item.entity';
import { ItemsService } from './items.service';

describe('ItemsService', () => {
  let service: ItemsService;
  const repository = {
    find: jest.fn(),
    findOneBy: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    delete: jest.fn(),
  };

  beforeEach(async () => {
    jest.resetAllMocks();
    const moduleRef = await Test.createTestingModule({
      providers: [
        ItemsService,
        { provide: getRepositoryToken(Item), useValue: repository },
      ],
    }).compile();
    service = moduleRef.get(ItemsService);
  });

  it('lists items ordered by id', async () => {
    const items = [{ id: 1 }, { id: 2 }];
    repository.find.mockResolvedValue(items);

    await expect(service.findAll()).resolves.toBe(items);
    expect(repository.find).toHaveBeenCalledWith({ order: { id: 'ASC' } });
  });

  it('creates an item with the given name', async () => {
    const created = { name: 'Botas' };
    repository.create.mockReturnValue(created);
    repository.save.mockResolvedValue({ id: 7, ...created });

    await expect(service.create({ name: 'Botas' })).resolves.toMatchObject({
      id: 7,
      name: 'Botas',
    });
    expect(repository.create).toHaveBeenCalledWith({ name: 'Botas' });
  });

  it('updates only the provided checkbox', async () => {
    const item = { id: 1, name: 'Palos', packed: false, toBuy: true };
    repository.findOneBy.mockResolvedValue(item);
    repository.save.mockImplementation((value: unknown) =>
      Promise.resolve(value),
    );

    await expect(service.update(1, { packed: true })).resolves.toEqual({
      id: 1,
      name: 'Palos',
      packed: true,
      toBuy: true,
    });
  });

  it('throws NotFoundException when the item does not exist', async () => {
    repository.findOneBy.mockResolvedValue(null);

    await expect(service.update(99, { packed: true })).rejects.toThrow(
      NotFoundException,
    );
    expect(repository.save).not.toHaveBeenCalled();
  });

  it('deletes several items in one call', async () => {
    await service.removeMany([1, 2, 3]);

    expect(repository.delete).toHaveBeenCalledWith([1, 2, 3]);
  });
});
