import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateStoreDto } from './dto/create-store.dto';

@Injectable()
export class StoresService {
  constructor(private readonly prisma: PrismaService) {}

  async create(ownerId: string, dto: CreateStoreDto) {
    const existing = await this.prisma.store.findUnique({ where: { ownerId } });
    if (existing) throw new ConflictException('You already have a store');
    return this.prisma.$transaction(async (tx) => {
      const store = await tx.store.create({
        data: {
          ownerId,
          name: dto.name.trim(),
          description: dto.description?.trim(),
          countryCode: dto.countryCode,
          defaultCurrency: dto.defaultCurrency ?? 'USD',
        },
      });
      await tx.user.update({ where: { id: ownerId }, data: { role: 'SELLER' } });
      return store;
    });
  }

  async mine(ownerId: string) {
    const store = await this.prisma.store.findUnique({
      where: { ownerId },
      include: { _count: { select: { listings: true } } },
    });
    if (!store) throw new NotFoundException('Store not found');
    return store;
  }
}
