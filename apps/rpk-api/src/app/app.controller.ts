import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get('')
  getIndex(): boolean {
    return this.appService.isHealthy();
  }

  @Get('production')
  isProduction(): boolean {
    return this.appService.isProduction();
  }

  @Get('version')
  getVersion(): string {
    return this.appService.getVersion();
  }
}
