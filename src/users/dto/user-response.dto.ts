import { ApiProperty } from '@nestjs/swagger';
import { Exclude } from 'class-transformer';

export class UserResponseDto {
  @ApiProperty({ example: 'clxxxxx' })
  id: string;

  @ApiProperty({ example: 'john.doe@example.com' })
  email: string;

  @ApiProperty({ example: 'John Doe' })
  name: string;

  @ApiProperty({ example: 'https://example.com/avatar.jpg', required: false })
  avatarUrl?: string;

  @ApiProperty({ example: true })
  isActive: boolean;

  @ApiProperty({ example: false })
  emailVerified: boolean;

  @ApiProperty({ example: '2026-02-17T21:00:00.000Z' })
  createdAt: Date;

  @ApiProperty({ example: '2026-02-17T21:00:00.000Z' })
  updatedAt: Date;

  @Exclude()
  passwordHash: string;

  constructor(partial: Partial<UserResponseDto>) {
    Object.assign(this, partial);
  }
}
