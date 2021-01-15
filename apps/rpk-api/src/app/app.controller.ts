import { Controller, Get } from '@nestjs/common';

import { Message } from '@rampike/shared/interfaces';

import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get('')
  getIndex(): Message {
    return this.appService.getIndex();
  }

  @Get('production')
  isProduction(): boolean {
    return this.appService.isProduction();
  }

  @Get('version')
  getVersion(): string {
    return this.appService.getVersion();
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
