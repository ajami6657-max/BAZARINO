import { ArrayMaxSize, IsArray, IsBoolean, IsIn, IsNumber, IsOptional, IsString, Length, Matches, MaxLength, Min, IsUrl } from 'class-validator';

const TYPES = ['GOODS', 'VEHICLE', 'REAL_ESTATE', 'SERVICES', 'JOBS'];
const PLAN_CODES = ['P1', 'P2', 'P3', 'P4', 'P5'];
const CURRENCIES = ['IRR', 'USD', 'EUR', 'GBP', 'TRY', 'AED', 'SAR'];

export class CreateClassifiedAdDto {
  @IsString() @IsIn(PLAN_CODES)
  planCode!: string;

  @IsString() @Length(3, 120)
  title!: string;

  @IsString() @MaxLength(5000)
  description!: string;

  @IsString() @Length(2, 60)
  category!: string;

  @IsOptional() @IsString() @IsIn(TYPES)
  adType?: string;

  @IsOptional() @IsString() @MaxLength(40)
  condition?: string;

  @IsOptional() @IsNumber({ maxDecimalPlaces: 4 }) @Min(0)
  price?: number;

  @IsOptional() @IsString() @IsIn(CURRENCIES)
  currency?: string;

  @IsOptional() @IsBoolean()
  isNegotiable?: boolean;

  @IsOptional() @IsBoolean()
  isFree?: boolean;

  @IsOptional() @IsString() @Matches(/^[A-Z]{2}$/)
  countryCode?: string;

  @IsString() @Length(2, 80)
  city!: string;

  @IsOptional() @IsString() @MaxLength(100)
  area?: string;

  @IsOptional() @IsArray() @ArrayMaxSize(10) @IsUrl({}, { each: true })
  images?: string[];
}
