import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateClassifiedAdDto } from './dto/create-classified-ad.dto';

@Injectable()
export class ClassifiedsService {
  constructor(private readonly prisma: PrismaService) {}

  async search(q?: string, city?: string, category?: string, adType?: string, countryCode?: string) {
    return this.prisma.classifiedAd.findMany({
      where: {
        status: 'ACTIVE',
        ...(city ? { city: { contains: city, mode: 'insensitive' as const } } : {}),
        ...(category ? { category: { equals: category, mode: 'insensitive' as const } } : {}),
        ...(adType ? { adType: adType as any } : {}),
        ...(countryCode ? { countryCode: countryCode.toUpperCase() } : {}),
        ...(q ? { OR: [
          { title: { contains: q, mode: 'insensitive' as const } },
          { description: { contains: q, mode: 'insensitive' as const } },
        ] } : {}),
      },
      orderBy: { createdAt: 'desc' },
      take: 100,
      include: { owner: { select: { id: true, displayName: true } } },
    });
  }

  async create(ownerId: string, dto: CreateClassifiedAdDto) {
    const isFree = dto.isFree ?? false;
    if (!isFree && dto.price === undefined) {
      throw new ForbiddenException('Enter a price or mark this ad as free');
    }
    return this.prisma.classifiedAd.create({
      data: {
        ownerId,
        title: dto.title.trim(),
        description: dto.description.trim(),
        category: dto.category.trim(),
        adType: (dto.adType ?? 'GOODS') as any,
        condition: dto.condition?.trim(),
        price: isFree ? null : dto.price,
        currency: dto.currency ?? 'IRR',
        isNegotiable: dto.isNegotiable ?? false,
        isFree,
        countryCode: dto.countryCode ?? 'IR',
        city: dto.city.trim(),
        area: dto.area?.trim(),
        images: dto.images ?? [],
        status: 'ACTIVE',
      },
      include: { owner: { select: { id: true, displayName: true } } },
    });
  }

  mine(ownerId: string) {
    return this.prisma.classifiedAd.findMany({
      where: { ownerId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async setStatus(ownerId: string, id: string, status: 'SOLD' | 'ARCHIVED') {
    const ad = await this.prisma.classifiedAd.findUnique({ where: { id } });
    if (!ad) throw new NotFoundException('Classified ad not found');
    if (ad.ownerId !== ownerId) throw new ForbiddenException('You cannot edit another user ad');
    return this.prisma.classifiedAd.update({ where: { id }, data: { status } });
  }
}
