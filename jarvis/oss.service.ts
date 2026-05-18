import OSS from 'ali-oss'
import { Injectable } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'

/**
 * 阿里云 OSS 服务
 * 提供 STS 临时凭证和直接上传功能
 */
@Injectable()
export class OssService {
  private client: OSS

  constructor(private readonly configService: ConfigService) {
    // 初始化 OSS 客户端（用于生成 STS 凭证）
    this.client = new OSS({
      region: this.configService.get('OSS_REGION') || 'oss-cn-beijing',
      accessKeyId: this.configService.get('OSS_ACCESS_KEY_ID'),
      accessKeySecret: this.configService.get('OSS_ACCESS_KEY_SECRET'),
      bucket: this.configService.get('OSS_BUCKET') || 'chatbotbinary',
    })
  }

  /**
   * 生成 STS 临时凭证
   * 前端使用此凭证直传 OSS
   */
  async generateStsToken(userId: string, tenantId: string) {
    // STS 权限策略
    const policy = {
      Statement: [
        {
          Action: ['oss:PutObject', 'oss:GetObject'],
          Effect: 'Allow',
          Resource: [
            `acs:oss:*:*:${this.configService.get('OSS_BUCKET') || 'chatbotbinary'}/uploads/${tenantId}/*`,
          ],
        },
      ],
      Version: '1',
    }

    try {
      // 生成临时凭证（1小时有效）
      const result = await this.client.assumeRole(
        this.configService.get('OSS_ROLE_ARN'), // RAM Role ARN
        JSON.stringify(policy),
        3600, // 有效期1小时
        userId // 会话名称
      )

      return {
        accessKeyId: result.credentials.AccessKeyId,
        accessKeySecret: result.credentials.AccessKeySecret,
        stsToken: result.credentials.SecurityToken,
        region: this.configService.get('OSS_REGION') || 'oss-cn-beijing',
        bucket: this.configService.get('OSS_BUCKET') || 'chatbotbinary',
        // 上传路径前缀
        uploadPath: `uploads/${tenantId}/${Date.now()}`,
      }
    } catch (error) {
      console.error('生成 STS 凭证失败:', error)
      throw new Error('生成上传凭证失败')
    }
  }

  /**
   * 生成上传后的文件访问 URL
   */
  getFileUrl(objectKey: string): string {
    const bucket = this.configService.get('OSS_BUCKET') || 'chatbotbinary'
    const region = this.configService.get('OSS_REGION') || 'oss-cn-beijing'
    const domain = this.configService.get('OSS_CUSTOM_DOMAIN')
    
    if (domain) {
      return `https://${domain}/${objectKey}`
    }
    return `https://${bucket}.${region}.aliyuncs.com/${objectKey}`
  }
}
