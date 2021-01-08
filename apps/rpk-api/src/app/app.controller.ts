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
}
