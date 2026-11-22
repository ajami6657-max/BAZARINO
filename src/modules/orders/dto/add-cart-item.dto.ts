import { IsInt, IsString, IsUUID, Min } from 'class-validator';

export class AddCartItemDto {
  @IsString()
  @IsUUID()
  listingId!: string;

  @IsInt()
  @Min(1)
  quantity!: number;
}
