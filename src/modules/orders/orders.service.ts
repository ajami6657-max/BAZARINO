import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CommissionService } from '../payments/commission.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { AddCartItemDto } from './dto/add-cart-item.dto';

@Injectable()
export class OrdersService {
  constructor(private readonly prisma: PrismaService, private readonly commission: CommissionService) {}

  async cart(buyerId: string) {
    const cart = await this.prisma.cart.findUnique({
      where: { buyerId },
      include: { items: { include: { listing: { include: { store: { select: { id: true, name: true } } } } } } },
    });
    if (!cart) return { items: [], itemCount: 0, subtotalByCurrency: {} };
    const active = cart.items.filter((item) => item.listing.status === 'ACTIVE');
    const totals: Record<string, string> = {};
    for (const item of active) {
      const code = item.listing.currency;
      totals[code] = (Number(totals[code] ?? 0) + Number(item.listing.price) * item.quantity).toFixed(4);
    }
    return { ...cart, items: active, itemCount: active.reduce((sum, item) => sum + item.quantity, 0), subtotalByCurrency: totals };
  }

  async addToCart(buyerId: string, dto: AddCartItemDto) {
    const listing = await this.prisma.listing.findUnique({ where: { id: dto.listingId } });
    if (!listing || listing.status !== 'ACTIVE') throw new NotFoundException('Active product not found');
    if (listing.sellerId === buyerId) throw new BadRequestException('You cannot add your own product');
    const cart = await this.prisma.cart.upsert({ where: { buyerId }, create: { buyerId }, update: {} });
    await this.prisma.cartItem.upsert({
      where: { cartId_listingId: { cartId: cart.id, listingId: listing.id } },
      create: { cartId: cart.id, listingId: listing.id, quantity: dto.quantity },
      update: { quantity: { increment: dto.quantity } },
    });
    return this.cart(buyerId);
  }

  async removeFromCart(buyerId: string, listingId: string) {
    const cart = await this.prisma.cart.findUnique({ where: { buyerId } });
    if (cart) await this.prisma.cartItem.deleteMany({ where: { cartId: cart.id, listingId } });
    return this.cart(buyerId);
  }

  async checkoutCart(buyerId: string) {
    const cart = await this.prisma.cart.findUnique({ where: { buyerId }, include: { items: { include: { listing: true } } } });
    if (!cart || cart.items.length === 0) throw new BadRequestException('Your cart is empty');
    if (cart.items.some((item) => item.listing.status !== 'ACTIVE' || item.listing.sellerId === buyerId)) {
      throw new BadRequestException('Cart contains an unavailable product. Remove it and try again.');
    }
    const orders = await this.prisma.$transaction(async (tx) => {
      const created: Array<Record<string, unknown>> = [];
      for (const item of cart.items) {
        const subtotal = item.listing.price.mul(item.quantity);
        const fee = this.commission.calculate(subtotal, item.listing.currency);
        const order = await tx.order.create({ data: {
          buyerId, sellerId: item.listing.sellerId, listingId: item.listing.id, quantity: item.quantity,
          countryCode: item.listing.countryCode, currency: item.listing.currency, subtotal,
        } });
        created.push({ ...order, commission: { rateBps: fee.commissionBps, platformFee: fee.platformFee, sellerNet: fee.sellerNet, currency: fee.currency }, paymentStatus: 'NOT_STARTED' });
      }
      await tx.cartItem.deleteMany({ where: { cartId: cart.id } });
      return created;
    });
    return { orders, paymentStatus: 'NOT_STARTED', message: 'Orders created. Online payment is not enabled yet.' };
  }

  async create(buyerId: string, dto: CreateOrderDto) {
    const listing = await this.prisma.listing.findUnique({ where: { id: dto.listingId } });
    if (!listing || listing.status !== 'ACTIVE') throw new NotFoundException('Active product not found');
    if (listing.sellerId === buyerId) throw new BadRequestException('You cannot order your own product');
    const subtotal = listing.price.mul(dto.quantity);
    const fee = this.commission.calculate(subtotal, listing.currency);
    const order = await this.prisma.order.create({
      data: { buyerId, sellerId: listing.sellerId, listingId: listing.id, quantity: dto.quantity, countryCode: listing.countryCode, currency: listing.currency, subtotal },
      include: { listing: { select: { id: true, title: true, price: true, currency: true } } },
    });
    return { ...order, commission: { rateBps: fee.commissionBps, platformFee: fee.platformFee, sellerNet: fee.sellerNet, currency: fee.currency }, paymentStatus: 'NOT_STARTED', message: 'Order created. Online payment is not enabled yet.' };
  }

  async mine(buyerId: string) {
    return this.prisma.order.findMany({ where: { buyerId }, orderBy: { createdAt: 'desc' }, include: { listing: { select: { id: true, title: true, price: true, currency: true } } } });
  }

  async sellerOrders(sellerId: string) {
    return this.prisma.order.findMany({ where: { sellerId }, orderBy: { createdAt: 'desc' }, include: { listing: { select: { id: true, title: true } } } });
  }

  async cancel(buyerId: string, orderId: string) {
    const order = await this.prisma.order.findUnique({ where: { id: orderId } });
    if (!order) throw new NotFoundException('Order not found');
    if (order.buyerId !== buyerId) throw new ForbiddenException('This order does not belong to you');
    if (order.status !== 'PENDING') throw new BadRequestException('Only pending unpaid orders can be cancelled');
    return this.prisma.order.update({ where: { id: orderId }, data: { status: 'CANCELLED' } });
  }

  async fulfill(sellerId: string, orderId: string) {
    const order = await this.prisma.order.findUnique({ where: { id: orderId } });
    if (!order) throw new NotFoundException('Order not found');
    if (order.sellerId !== sellerId) throw new ForbiddenException('This order does not belong to your store');
    if (order.status !== 'PAID') throw new BadRequestException('Only paid orders can be fulfilled');
    return this.prisma.order.update({ where: { id: orderId }, data: { status: 'FULFILLED' } });
  }
}
