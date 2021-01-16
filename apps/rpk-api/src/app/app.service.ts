import { Injectable } from '@nestjs/common';
import { environment } from '@rampike/shared/environments';

@Injectable()
export class AppService {
  isProduction(): boolean {
    return environment.production;
  }

  getVersion(): string {
    return process.env.VERSION;
  }

  isHealthy(): boolean {
    return true;
  }

  isReady(): boolean {
    return true;
  }
}
