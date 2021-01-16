import { Injectable } from '@nestjs/common';
import { environment } from '@rampike/shared/environments';

@Injectable()
export class AppService {
  isHealthy(): boolean {
    // TODO: add proper readiness and health check
    // TODO: check if db connection is established..
    return true;
  }

  isProduction(): boolean {
    return environment.production;
  }

  getVersion(): string {
    return process.env.VERSION;
  }
}
