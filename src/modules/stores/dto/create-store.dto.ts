import { IsIn, IsOptional, IsString, Length, Matches, MaxLength } from 'class-validator';

const CURRENCIES = ['USD', 'EUR', 'GBP', 'IRR', 'TRY', 'AED', 'SAR', 'JPY', 'KRW', 'KWD', 'BHD'];

export class CreateStoreDto {
  @IsString()
  @Length(2, 80)
  name!: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;

  @IsString()
  @Matches(/^[A-Z]{2}$/)
  countryCode!: string;

  @IsOptional()
  @IsString()
  @IsIn(CURRENCIES)
  defaultCurrency?: string;
}
