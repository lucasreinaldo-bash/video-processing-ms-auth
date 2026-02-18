import {
  Controller,
  Post,
  Body,
  Get,
  UseGuards,
  HttpCode,
  HttpStatus,
  ClassSerializerInterceptor,
  UseInterceptors,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiBody,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterDto, LoginDto, TokensDto, RefreshTokenDto } from './dto';
import { JwtAuthGuard } from './guards';
import { CurrentUser, Public } from './decorators';
import { User } from '@prisma/client';
import { UserResponseDto } from '../users/dto/user-response.dto';

@ApiTags('Authentication')
@Controller('auth')
@UseInterceptors(ClassSerializerInterceptor)
export class AuthController {
  constructor(private authService: AuthService) {}

  @Public()
  @Post('register')
  @ApiOperation({ summary: 'Registrar novo usuário' })
  @ApiResponse({
    status: 201,
    description: 'Usuário registrado com sucesso',
    type: TokensDto,
  })
  @ApiResponse({ status: 409, description: 'Email já cadastrado' })
  async register(@Body() registerDto: RegisterDto): Promise<TokensDto> {
    return this.authService.register(registerDto);
  }

  @Public()
  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Fazer login' })
  @ApiResponse({
    status: 200,
    description: 'Login realizado com sucesso',
    type: TokensDto,
  })
  @ApiResponse({ status: 401, description: 'Credenciais inválidas' })
  async login(@Body() loginDto: LoginDto): Promise<TokensDto> {
    return this.authService.login(loginDto);
  }

  @Public()
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Renovar access token' })
  @ApiBody({ type: RefreshTokenDto })
  @ApiResponse({
    status: 200,
    description: 'Tokens renovados com sucesso',
    type: TokensDto,
  })
  @ApiResponse({ status: 401, description: 'Refresh token inválido' })
  async refresh(@Body() body: RefreshTokenDto): Promise<TokensDto> {
    return this.authService.refreshTokens(body.refreshToken);
  }

  @UseGuards(JwtAuthGuard)
  @Post('logout')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Fazer logout' })
  @ApiBody({ type: RefreshTokenDto })
  @ApiResponse({ status: 204, description: 'Logout realizado com sucesso' })
  @ApiResponse({ status: 401, description: 'Não autorizado' })
  async logout(
    @CurrentUser() user: User,
    @Body() body: RefreshTokenDto,
  ): Promise<void> {
    await this.authService.logout(user.id, body.refreshToken);
  }

  @UseGuards(JwtAuthGuard)
  @Get('profile')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obter perfil do usuário autenticado' })
  @ApiResponse({
    status: 200,
    description: 'Perfil do usuário',
    type: UserResponseDto,
  })
  @ApiResponse({ status: 401, description: 'Não autorizado' })
  async getProfile(@CurrentUser() user: User): Promise<UserResponseDto> {
    return new UserResponseDto(user);
  }

  @Public()
  @Get('health')
  @ApiOperation({ summary: 'Health check do serviço de autenticação' })
  @ApiResponse({ status: 200, description: 'Serviço funcionando' })
  health() {
    return { status: 'ok', service: 'ms-auth' };
  }
}
