import { Injectable } from '@nestjs/common';
import { Message } from '@rampike/shared/interfaces';
import { environment } from '@rampike/shared/environments';

@Injectable()
export class AppService {
  getIndex(): Message {
    return { message: 'hot welcome in rampike grove!' };
  }

  getEnv(): boolean {
    return environment.production;
  }
}
