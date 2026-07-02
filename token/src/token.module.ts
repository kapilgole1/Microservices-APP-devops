import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { MongooseModule } from '@nestjs/mongoose';
import { TokenController } from './token.controller';
import { TokenService } from './services/token.service';
import { JwtConfigService } from './services/config/jwt-config.service';
import { MongoConfigService } from './services/config/mongo-config.service';
import { TokenSchema } from './schemas/token.schema';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    JwtModule.registerAsync({
      useClass: JwtConfigService,
    }),
    MongooseModule.forRootAsync({
      useClass: MongoConfigService,
    }),
    MongooseModule.forFeature([
      {
        name: 'Token',
        schema: TokenSchema,
      },
    ]),
  ],
  controllers: [TokenController],
  providers: [TokenService],
})
export class TokenModule {}
