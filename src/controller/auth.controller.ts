import { Controller, Post, Body, Get, Req, UsePipes, ValidationPipe, UseGuards, Request as NestRequest, UnauthorizedException } from '@nestjs/common';
import { AuthService } from '../service/auth.service';
import { AuthGuard } from '../auth/auth.guard';
import { LoginDto } from '../dataModel/login.dto';
import { ResetPasswordDto } from '../dataModel/reset-password.dto';
import { Request } from 'express';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  @UsePipes(new ValidationPipe())
  async login(@Body() loginDto: LoginDto, @Req() req: Request) {
    const ip = (req.headers['x-forwarded-for'] as string) || req.socket.remoteAddress;
    return this.authService.login(loginDto, ip || 'unknown');
  }

  @Post('reset-password')
  @UsePipes(new ValidationPipe())
  async resetPassword(@Body() resetPasswordDto: ResetPasswordDto) {
    return this.authService.resetPassword(resetPasswordDto);
  }

  // @Get('refresh-token')
  // async getRefreshToken(@Req() req: Request) {
  //   const token = req.headers.authorization?.split(' ')?.[1];
  //   if (!token) throw new UnauthorizedException('Authorization token not found.');
  //   return this.authService.getRefreshToken(token);
  // }

  @UseGuards(AuthGuard)
  @Get('profile')
  getProfile(@NestRequest() req) {
    return this.authService.getProfile(req.user);
  }
}