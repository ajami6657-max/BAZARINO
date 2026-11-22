import { BadRequestException, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Prisma } from '@prisma/client';

const CURRENCY_MINOR_UNITS: Record<string, number> = {
  IRR: 0, USD: 2, EUR: 2, GBP: 2, TRY: 2, AED: 2, SAR: 2,
  JPY: 0, KRW: 0, KWD: 3, BHD: 3,
};

@Injectable()
export class CommissionService {
  constructor(private readonly config: ConfigService) {}

  calculate(grossAmount: Prisma.Decimal | string | number, currency: string) {
    const code = currency.trim().toUpperCase();
    const minorUnits = CURRENCY_MINOR_UNITS[code];
    if (minorUnits === undefined) {
      throw new BadRequestException(`Unsupported currency for settlement: ${code}`);
    }

    const commissionBps = Number(this.config.get<string>('PLATFORM_COMMISSION_BPS') ?? '50');
    if (!Number.isInteger(commissionBps) || commissionBps < 0 || commissionBps > 10000) {
      throw new Error('PLATFORM_COMMISSION_BPS must be an integer from 0 to 10000');
    }

    const gross = new Prisma.Decimal(grossAmount);
    if (!gross.isFinite() || gross.lte(0)) {
      throw new BadRequestException('Payment amount must be greater than zero');
    }

    const platformFee = gross
      .mul(commissionBps)
      .div(10000)
      .toDecimalPlaces(minorUnits, Prisma.Decimal.ROUND_HALF_UP);
    const sellerNet = gross.minus(platformFee);

    return {
      currency: code,
      grossAmount: gross.toFixed(minorUnits),
      commissionBps,
      platformFee: platformFee.toFixed(minorUnits),
      sellerNet: sellerNet.toFixed(minorUnits),
    };
  }
}
