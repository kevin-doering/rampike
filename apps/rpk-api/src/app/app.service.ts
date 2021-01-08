import { Injectable } from '@nestjs/common';
import { Message } from '@rampike/shared/interfaces';

@Injectable()
export class AppService {
  getIndex(): Message {
    return { message: 'hot welcome in rampike grove!' };
  }
}
