import { IsIn, IsNumber, IsOptional, IsString, Length, MaxLength, Min, Matches } from 'class-validator';

const CURRENCIES = ['USD', 'EUR', 'GBP', 'IRR', 'TRY', 'AED', 'SAR', 'JPY', 'KRW', 'KWD', 'BHD'];

export class CreateListingDto {
  @IsString()
  @Length(2, 160)
  title!: string;

  @IsString()
  @MaxLength(4000)
  description!: string;

  @IsNumber({ maxDecimalPlaces: 4 })
  @Min(0.0001)
  price!: number;

  @IsOptional()
  @IsString()
  @IsIn(CURRENCIES)
  currency?: string;

  @IsOptional()
  @IsString()
  @Matches(/^[A-Z]{2}$/)
  countryCode?: string;

  @IsOptional()
  @IsString()
  @Length(2, 12)
  locale?: string;

  @IsString()
  @Length(2, 80)
  category!: string;
}
