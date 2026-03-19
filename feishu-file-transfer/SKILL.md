---
name: feishu-file-transfer
description: 飞书文件传输任意门 - 通过 MCP 工具将 workspace 中的任意文件发送到飞书聊天
homepage: https://docs.openclaw.ai/agent-skills
metadata:
  { "openclaw": { "emoji": "🚪", "tags": ["feishu", "file", "transfer", "mcp", "upload", "send"] } }
---

# 🚪 飞书文件传输任意门 v1.0

通过飞书 MCP 工具将 workspace 中的任意文件发送到飞书聊天，实现稳定的文件传输。

---

## 📋 功能特性

### 核心功能

- ✅ 发送任意文件（PDF、DOCX、XLSX、PPTX、图片、视频、音频等）
- ✅ 支持相对路径和绝对路径
- ✅ 自动检测文件类型
- ✅ 文件大小验证（最大 30MB）
- ✅ 支持回复消息
- ✅ 支持在话题中回复
- ✅ 可自定义文件名

### 支持的文件类型

- **文档**: PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX
- **图片**: JPG, PNG, GIF, WEBP, BMP, ICO, TIFF
- **视频**: MP4, MOV, AVI
- **音频**: OPUS, OGG
- **其他**: 任何文件（作为通用文件类型发送）

---

## 🎯 使用场景

### 典型使用场景

1. **发送报告文件**
   - 生成的调研报告、分析报告
   - Markdown 文档转换为 PDF 后发送

2. **发送代码文件**
   - 源代码文件
   - 配置文件
   - 脚本文件

3. **发送图片**
   - 生成的图表
   - 截图
   - 素材图片

4. **发送数据文件**
   - CSV/JSON 数据文件
   - Excel 表格

---

## 🔧 MCP 工具

### feishu_send_file

**描述**: Upload and send any file to Feishu through the built-in OpenClaw Feishu plugin tool.

**参数**:

```json
{
  "action": "upload_and_send",
  "file_path": "相对路径或绝对路径",
  "to": "chat_id 或 user/open_id (可选，留空时默认私发给当前飞书请求者)",
  "reply_to_message_id": "回复的消息 ID (可选)",
  "reply_in_thread": "是否在话题中回复 (可选，默认 false)",
  "file_name": "覆盖文件名 (可选)",
  "account_id": "飞书账户 ID (可选)"
}
```

**返回值**:

```json
{
  "success": true,
  "message_id": "消息 ID",
  "chat_id": "聊天 ID",
  "file_name": "文件名",
  "file_size": "文件大小（字节）",
  "file_type": "文件类型",
  "msg_type": "消息类型",
  "file_key": "文件 key"
}
```

---

## 📝 使用说明

### 触发条件

当用户要求：

- "把这个文件发给我"
- "发送 [文件名]"
- "把 [文件路径] 发到飞书"
- "传输文件"
- "任意门：[文件路径]"

### 执行流程

1. **验证文件存在**
   - 检查文件路径是否有效
   - 如果是相对路径，相对于 workspace 目录解析

2. **检查文件大小**
   - 确保文件不超过 30MB

3. **检测文件类型**
   - 根据文件扩展名自动检测
   - 确定正确的 msg_type

4. **上传文件到飞书**
   - 调用飞书 API 上传文件
   - 获取 file_key

5. **发送文件到聊天**
   - 使用 file_key 发送文件消息
   - 支持回复和话题回复

### 路径解析规则

- **相对路径**: 相对于 workspace 目录 (`/home/node/.openclaw/workspace`)，找不到时再尝试当前 agent 目录
- **绝对路径**: 允许，但必须仍然位于 workspace 或 agent 目录内

示例：

- `report/2026-03-14-report.pdf` → `/home/node/.openclaw/workspace/report/2026-03-14-report.pdf`
- `/tmp/file.pdf` → `/tmp/file.pdf`
- `images/photo.png` → `/home/node/.openclaw/workspace/images/photo.png`

---

## 🎨 最佳实践

### 文件命名

- 使用有意义的文件名
- 避免特殊字符（中文使用 URL 编码）
- 添加时间戳区分版本

### 文件大小

- 尽量控制在 10MB 以内
- 大文件建议压缩后发送
- 超过 30MB 的文件无法发送

### 文件类型

- 文档推荐 PDF 格式（兼容性好）
- 图片推荐 PNG/JPG 格式
- 代码推荐使用压缩包

---

## ⚠️ 注意事项

### 限制

1. **文件大小**: 最大 30MB
2. **文件类型**: 部分特殊格式可能无法正确识别
3. **发送频率**: 避免频繁发送大文件，可能被限流

### 错误处理

- **文件不存在**: 明确提示文件路径
- **文件过大**: 提示文件大小和限制
- **上传失败**: 记录错误日志，建议稍后重试
- **发送失败**: 检查飞书连接和权限

---

## 🔗 相关技能

- **feishu-doc**: 飞书文档操作
- **feishu-drive**: 飞书云盘操作
- **feishu-perm**: 飞书权限管理

---

## 📚 版本历史

- **v1.0** (2026-03-14):
  - ✅ 创建飞书文件传输任意门
  - ✅ 集成 feishu_send_file MCP 工具
  - ✅ 支持任意文件类型
  - ✅ 自动路径解析和类型检测

---

## 🛠️ 技术细节

### 工具集成

- **工具名称**: `feishu_send_file`
- **来源**: 飞书扩展 (`/app/extensions/feishu/src/send-file.ts`)
- **依赖**: 飞书 API SDK (`@larksuiteoapi/node-sdk`)
- **认证**: 使用配置的飞书账户
- **不是外部 mcporter 服务**: 不需要在 `mcporter.json` 里额外配置一个 MCP 服务器；它是 gateway 启动时注册的内置工具

### 文件上传流程

1. 读取文件到 Buffer
2. 调用 `uploadFileFeishu()` 上传文件
3. 获取 `file_key`
4. 调用 `sendMediaFeishu()` 发送文件消息
5. 返回消息 ID 和文件信息

### 生效方式

如果你修改的是本地 checkout 中的飞书扩展代码，必须重建或重启 gateway 才会注册新工具：

```bash
cd /mnt/500G-1/clawdata/repo
docker compose up -d --build --force-recreate openclaw-gateway
```

### 错误处理

所有错误都会被捕获并返回给用户，包括：

- 文件不存在
- 文件不可读
- 文件过大
- 上传失败
- 发送失败
