import { Controller, Get } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { AppService } from './app.service';

@ApiTags('기본')
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  @ApiOperation({ summary: '기본 인사 메시지', description: '서버 상태를 확인하는 기본 엔드포인트입니다.' })
  @ApiResponse({ status: 200, description: '성공적으로 인사 메시지를 반환합니다.', type: String })
  getHello(): string {
    return this.appService.getHello();
  }
}
