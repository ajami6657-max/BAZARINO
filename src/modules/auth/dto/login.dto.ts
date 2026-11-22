import { IsString, Length, MaxLength } from 'class-validator';

export class LoginDto {
  @IsString()
  @Length(3, 254)
  @MaxLength(254)
  identifier!: string;

  @IsString()
  @Length(8, 72)
  password!: string;
}
