import { Injectable } from '@nestjs/common';
import { Message } from '@rampike/shared/interfaces';
import { environment } from '@rampike/shared/environments';

@Injectable()
export class AppService {
  getIndex(): Message {
    return { message: 'warm welcome in rampike grove!' };
  }

  isProduction(): boolean {
    return environment.production;
  }
}
