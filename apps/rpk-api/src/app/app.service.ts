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
    // TODO: check if db connection is established
    return true;
  }

  isReady(): boolean {
    // TODO: add proper readiness check
    return true;
  }
}
