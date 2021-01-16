import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get('')
  getVersion(): string {
    return this.appService.getVersion();
  }

  @Get('production')
  isProduction(): boolean {
    return this.appService.isProduction();
  }

  @Get('healthz')
  isHealthy(): boolean {
    return this.appService.isHealthy();
  }

  @Get('readyz')
  isReady(): boolean {
    return this.appService.isReady();
  }
}
