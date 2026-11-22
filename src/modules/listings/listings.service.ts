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

  async publicSearch(query?: string, category?: string, countryCode?: string, currency?: string) {
    return this.prisma.listing.findMany({
      where: {
        status: 'ACTIVE',
        ...(category ? { category: { equals: category, mode: 'insensitive' as const } } : {}),
        ...(countryCode ? { countryCode } : {}),
        ...(currency ? { currency: currency.toUpperCase() } : {}),
        ...(query ? {
          OR: [
            { title: { contains: query, mode: 'insensitive' as const } },
            { description: { contains: query, mode: 'insensitive' as const } },
          ],
        } : {}),
      },
      // Prices are only comparable when the currency is identical.
      orderBy: currency ? [{ price: 'asc' }, { createdAt: 'desc' }] : [{ createdAt: 'desc' }],
      take: 50,
      include: { store: { select: { id: true, name: true, countryCode: true } } },
    });
  }

  async publish(sellerId: string, listingId: string) {
    const listing = await this.prisma.listing.findUnique({ where: { id: listingId } });
    if (!listing) throw new NotFoundException('Product not found');
    if (listing.sellerId !== sellerId) throw new ForbiddenException('You cannot publish another seller product');
    if (listing.status === 'ARCHIVED' || listing.status === 'SOLD') {
      throw new ForbiddenException('This product cannot be published in its current status');
    }
    return this.prisma.listing.update({
      where: { id: listingId },
      data: { status: 'ACTIVE' },
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
