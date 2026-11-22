import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CommissionService } from '../payments/commission.service';
import { CreateOrderDto } from './dto/create-order.dto';

@Injectable()
export class OrdersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly commission: CommissionService,
  ) {}

  async create(buyerId: string, dto: CreateOrderDto) {
    const listing = await this.prisma.listing.findUnique({ where: { id: dto.listingId } });
    if (!listing || listing.status !== 'ACTIVE') throw new NotFoundException('Active product not found');
    if (listing.sellerId === buyerId) throw new BadRequestException('You cannot order your own product');

    const subtotal = listing.price.mul(dto.quantity);
    const fee = this.commission.calculate(subtotal, listing.currency);
    const order = await this.prisma.order.create({
      data: {
        buyerId, sellerId: listing.sellerId, listingId: listing.id,
        quantity: dto.quantity, countryCode: listing.countryCode,
        currency: listing.currency, subtotal,
      },
      include: { listing: { select: { id: true, title: true, price: true, currency: true } } },
    });
    return {
      ...order,
      commission: { rateBps: fee.commissionBps, platformFee: fee.platformFee, sellerNet: fee.sellerNet, currency: fee.currency },
      paymentStatus: 'NOT_STARTED',
      message: 'Order created. Online payment is not enabled yet.',
    };
  }

  async mine(buyerId: string) {
    return this.prisma.order.findMany({
      where: { buyerId }, orderBy: { createdAt: 'desc' },
      include: { listing: { select: { id: true, title: true, price: true, currency: true } } },
    });
  }

  async sellerOrders(sellerId: string) {
    return this.prisma.order.findMany({
      where: { sellerId }, orderBy: { createdAt: 'desc' },
      include: { listing: { select: { id: true, title: true } } },
    });
  }
}
