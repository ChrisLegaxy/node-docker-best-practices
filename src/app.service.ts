import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getGreetingMessage() {
    return {
      success: true,
      message:
        'Welcome to Node with Docker Best Practices By Chris Van/Chris Legaxy',
      github: 'https://github.com/ChrisLegaxy',
      status: 200,
    };
  }
}
