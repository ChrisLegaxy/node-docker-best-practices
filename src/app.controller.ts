import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getGreetingMessage(): object {
    return this.appService.getGreetingMessage();
  }
}
