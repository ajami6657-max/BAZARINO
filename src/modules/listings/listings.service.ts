import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateListingDto } from './dto/create-listing.dto';

@Injectable()
export class ListingsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(sellerId: string, dto: CreateListingDto) {
    const store = await this.prisma.store.findUnique({ where: { ownerId: sellerId } });
    if (!store) throw new ForbiddenException('Create your free seller store before adding products');

    return this.prisma.listing.create({
      data: {
        sellerId,
        storeId: store.id,
        title: dto.title.trim(),
        description: dto.description.trim(),
        price: dto.price,
        currency: dto.currency ?? store.defaultCurrency,
        countryCode: dto.countryCode ?? store.countryCode,
        locale: dto.locale ?? 'fa-IR',
        category: dto.category.trim(),
        status: 'DRAFT',
      },
    });
  }

  async mine(sellerId: string) {
    return this.prisma.listing.findMany({
      where: { sellerId },
      orderBy: { createdAt: 'desc' },
      include: { store: { select: { id: true, name: true } } },
    });
  }

  async publicSearch(query?: string, category?: string, countryCode?: string) {
    return this.prisma.listing.findMany({
      where: {
        status: 'ACTIVE',
        ...(category ? { category: { equals: category, mode: 'insensitive' as const } } : {}),
        ...(countryCode ? { countryCode } : {}),
        ...(query ? {
          OR: [
            { title: { contains: query, mode: 'insensitive' as const } },
            { description: { contains: query, mode: 'insensitive' as const } },
          ],
        } : {}),
      },
      orderBy: [{ price: 'asc' }, { createdAt: 'desc' }],
      take: 50,
      include: { store: { select: { id: true, name: true, countryCode: true } } },
    });
  }

  async archive(sellerId: string, listingId: string) {
    const listing = await this.prisma.listing.findUnique({ where: { id: listingId } });
    if (!listing) throw new NotFoundException('Product not found');
    if (listing.sellerId !== sellerId) throw new ForbiddenException('You cannot change another seller product');
    return this.prisma.listing.update({
      where: { id: listingId },
      data: { status: 'ARCHIVED' },
    });
  }
}
