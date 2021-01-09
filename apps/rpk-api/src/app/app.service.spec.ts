import { Test } from '@nestjs/testing';

import { AppService } from './app.service';

describe('AppService', () => {
  let service: AppService;

  beforeAll(async () => {
    const app = await Test.createTestingModule({
      providers: [AppService],
    }).compile();

    service = app.get<AppService>(AppService);
  });

  describe('getIndex', () => {
    it('should return "hot welcome in rampike grove!"', () => {
      expect(service.getIndex()).toEqual({ message: 'hot welcome in rampike grove!' });
    });
  });
});
