---
name: network-search
description: 综合网络搜索技能 - 集成多种搜索工具，提供可靠的信息检索能力
homepage: https://docs.openclaw.ai/agent-skills
metadata:
  {
    "openclaw":
      {
        "emoji": "🔍",
        "tags": ["search", "web", "api", "mcp", "curl", "strategy"]
      }
  }
---

# 🔍 综合网络搜索技能 v2.0

这是一个综合性的网络搜索技能，整合了所有可用的搜索工具和策略，确保在任何情况下都能提供可靠的信息检索能力。

**版本更新：v2.0 (2026-03-09)**
- ✅ 验证 Brave Search API 网页搜索功能完全正常
- ✅ 整合多源搜索策略（非学术领域首选）
- ✅ 建立优先级和兜底机制

---

## 📊 当前可用的搜索工具

### 1. **Brave Search API** (curl 直接调用) ⭐ **非学术领域首选**
- **状态**: ✅ 完全正常（已验证网页搜索和新闻搜索）
- **API Key**: ``
- **主要功能**:
  - `brave_web_search` - 网页搜索
  - `brave_news_search` - 新闻搜索
  - `brave_video_search` - 视频搜索
  - `brave_image_search` - 图片搜索
  - `brave_local_search` - 本地搜索（需 Pro 计划）
  - `brave_summarizer` - 摘要功能
- **优势**:
  - ✅ 支持多种内容类型（网页、新闻、视频、图片）
  - ✅ curl 直接调用，无需 MCP 中间层
  - ✅ 返回完整 JSON 格式
  - ✅ 支持时间过滤、结果过滤
  - ✅ 已验证可用（2026-03-09 测试通过）
- **适用场景**: 英文内容、全球信息、多类型搜索
- **curl 模板**: 
  ```bash
  # 网页搜索
  curl -s "https://api.search.brave.com/res/v1/web/search?q=QUERY&count=10" \
    -H "X-Subscription-Token: "
  
  # 新闻搜索
  curl -s "https://api.search.brave.com/res/v1/news/search?q=QUERY&count=10" \
    -H "X-Subscription-Token: "
  ```

### 2. **智谱搜索 MCP** (`zhipu-web-search-sse`) ✅ **中文内容首选**
- **状态**: 完全正常
- **工具数**: 4 个搜索工具
- **特点**:
  - `webSearchSogou` - 搜狗搜索
  - `webSearchQuark` - 夸克搜索  
  - `webSearchPro` - 专业版搜索
  - `webSearchStd` - 标准搜索
- **优势**:
  - ✅ 中文搜索能力强
  - ✅ 支持多种搜索引擎
  - ✅ 响应速度快
  - ✅ 不依赖外部网络（通过智谱 API）
- **适用场景**: 中文内容、新闻、百科信息、中英文混合搜索

### 3. **PubMed 文献搜索 MCP** (`mcp-pubmed-llm-server`) ✅
- **状态**: 完全正常
- **工具数**: 13 个工具
- **主要功能**:
  - `pubmed_search` - PubMed 文献搜索
  - `pubmed_fulltext` - 全文获取
  - 自动导出 EndNote (RIS/BibTeX) 格式
- **适用场景**: 医学文献、学术论文、生命科学研究
- **API Key**: 已配置 `FULLTEXT_MODE=enabled`

### 4. **OpenAlex 学术搜索 MCP** (`openalex-mcp-server`) ✅
- **状态**: 完全正常
- **工具数**: 8 个工具
- **主要功能**:
  - `openalex_search` - 跨学科学术搜索
  - 提供详细的引用信息和概念标签
  - 支持按年份、开放获取等过滤
- **适用场景**: 跨学科研究、学术论文、引用分析

### 5. **Metaso 搜索 MCP** (`metaso-search-mcp`) ⚠️
- **状态**: 配置但连接失败（重定向问题）
- **工具数**: 2 个工具
- **主要功能**:
  - `metaso_search` - 多维度搜索
  - `metaso_reader` - 网页内容抓取
- **适用场景**: 需要时使用（智谱优先）

### 6. **Brave 搜索 MCP** (`brave-search`) ⚠️
- **状态**: 配置并健康（但通过 mcporter 调用时 fetch 失败）
- **工具数**: 6 个工具
- **适用场景**: 作为 MCP 备用（curl 版本优先）

---

## 🎯 智能搜索策略和优先级

### 非学术领域搜索（通用搜索）

**优先级 1: Brave Search API (curl 直接调用)** ⭐
- **选择原因**:
  - ✅ 已验证网页搜索、新闻搜索完全正常
  - ✅ 支持 6 种搜索类型
  - ✅ curl 直接调用，无需 MCP 中间层
  - ✅ 返回完整 JSON 格式，易于解析
  - ✅ 支持高级过滤（时间、结果类型）
- **使用条件**: 任何非学术搜索任务
- **不适用**: 需要中文内容的场景

**优先级 2: 智谱搜索 MCP** 🇨🇳
- **选择原因**:
  - ✅ 中文搜索能力强
  - ✅ 响应速度快
  - ✅ 支持多种搜索引擎（搜狗、夸克、Pro、Std）
- **使用条件**: 
  - 查询语言为中文
  - 内容主要面向中文用户
  - 用户明确要求中文搜索
- **不适用**: 英文专用内容

**优先级 3: Metaso 搜索 MCP**
- **使用条件**: 智谱搜索结果不理想时
- **注意**: 连接不稳定，需要监控

### 学术领域搜索

**优先级 4: PubMed 搜索 MCP** ⭐
- **使用条件**: 医学、生命科学相关搜索
- **优势**: 专注医学文献，自动导出引用格式

**优先级 5: OpenAlex 搜索 MCP**
- **使用条件**: 跨学科、非医学的学术搜索
- **优势**: 提供详细引用和概念标签

---

## 🔄 兜底和降级策略

### 工具选择决策树

```
搜索任务启动
    │
    ├─ 内容类型判断
    │   ├─ 通用信息 → 使用优先级 1 (Brave Search API)
    │   ├─ 中文内容 → 使用优先级 2 (智谱搜索)
    │   └─ 学术/医学 → 使用优先级 4 或 5
    │
    └─ 失败重试
        ├─ 首选工具失败 → 尝试次优先级工具
        ├─ 所有工具失败 → 尝试其他可用的搜索方式
        └─ 完全失败 → 明确告知用户，建议替代方案
```

### 错误处理和重试逻辑

1. **Brave Search API (curl) 失败**
   - 尝试：智谱搜索 MCP
   - 次要：Metaso 搜索 MCP
   - 记录失败原因到日志

2. **智谱搜索 MCP 失败**
   - 尝试：Metaso 搜索 MCP
   - 记录失败原因到日志

3. **Metaso 搜索 MCP 失败**
   - 明确告知用户：所有搜索工具遇到问题
   - 建议：手动搜索或稍后重试

4. **所有工具完全失败**
   - 使用已知信息/缓存内容回复
   - 明确告知限制

---

## 🔧 技术细节

### Brave Search API 参数说明

#### 网页搜索 (`/res/v1/web/search`)
```bash
curl -s "https://api.search.brave.com/res/v1/web/search?q=QUERY&count=10" \
  -H "X-Subscription-Token: "
```

**主要参数**:
- `q` - 搜索查询（必需）
- `count` - 返回结果数量（1-20，默认 10）
- `country` - 国家代码（如 "US", "CN", "JP"）
- `search_lang` - 搜索语言（如 "en", "zh-hans"）
- `safesearch` - 安全搜索（"off", "moderate", "strict"）
- `freshness` - 时间过滤（"pd"=1天, "pw"=1周, "pm"=1月, "py"=1年）
- `result_filter` - 结果类型过滤（["web", "news", "images", "videos", "discussions", "faq", "infobox"]）

#### 新闻搜索 (`/res/v1/news/search`)
```bash
curl -s "https://api.search.brave.com/res/v1/news/search?q=QUERY&count=10" \
  -H "X-Subscription-Token: "
```

**额外参数**:
- `freshness` - 默认 "pd"（过去 24 小时）

#### 视频搜索 (`/res/v1/videos/search`)
```bash
curl -s "https://api.search.brave.com/res/v1/videos/search?q=QUERY&count=10" \
  -H "X-Subscription-Token: "
```

**额外参数**:
- `count` - 1-50，默认 20

#### 图片搜索 (`/res/v1/images/search`)
```bash
curl -s "https://api.search.brave.com/res/v1/images/search?q=QUERY&count=10" \
  -H "X-Subscription-Token: "
```

**额外参数**:
- `count` - 1-200，默认 50

### 其他搜索引擎说明

**Bing 搜索 API**：
- 需要 API Key，类似于 Google
- 如果有密钥，可以通过 curl 调用
- 暂无可用密钥，不推荐作为首选

**Google 搜索 API**：
- 需要 API Key 和项目设置
- Google Programmable Search Engine 有严格的配额和限制
- 不推荐用于自动化搜索

**百度搜索**：
- 已测试：返回验证码页面，反爬虫机制强
- 不适合程序化访问
- 推荐用于手动搜索

---

## 📝 使用说明

### 触发条件
- 用户询问任何需要搜索的问题
- 需要查找特定信息
- 需要验证某个事实
- 需要获取最新资讯

### 自动决策流程

1. **判断搜索类型**：
   - 通用信息 → Brave Search API
   - 中文内容 → 智谱搜索
   - 学术/医学 → PubMed / OpenAlex

2. **执行搜索**：
   - 根据优先级选择工具
   - 传递合适的参数
   - 解析返回结果

3. **结果整理**：
   - 提取关键信息（标题、链接、摘要）
   - 按相关性排序
   - 简洁呈现（3-5 条主要结果）

### 返回格式

**简洁模式**（默认）：
- 标题（加粗）
- 链接
- 简短摘要（1-2 句）

**详细模式**（用户要求）：
- 完整标题
- 完整摘要
- 时间戳
- 结果数量

### 错误处理

1. **MCP 连接失败** → 自动降级到下一个优先级工具
2. **所有 MCP 失败** → 自动切换到 curl 兜底方案（Brave Search API）
3. **curl 也失败** → 明确告知用户网络问题，建议其他方案

---

## 🎓 最佳实践

1. **工具测试**: 定期测试所有 MCP 服务器的可用性
2. **缓存策略**: 对于重复查询，优先使用响应最快的工具
3. **结果验证**: 从多个来源获取信息时，交叉验证关键数据
4. **用户反馈**: 如果工具失败，告知用户具体原因和后续计划
5. **优先级调整**: 根据实际使用情况调整优先级

---

## 📚 维护和更新

### 需要监控的服务
- Brave Search API - 响应时间和成功率
- 智谱搜索 - 响应时间和成功率
- Metaso 搜索 - 连接稳定性

### 需要更新时
- 添加新的搜索 MCP 工具
- 更新 API 密钥
- 修改搜索策略
- 添加新的兜底方案

### 版本历史
- **v2.0** (2026-03-09):
  - ✅ 验证 Brave Search API 网页搜索完全正常
  - ✅ 整合多源搜索策略
  - ✅ 建立优先级和兜底机制
  - 🎯 非学术领域配置为 Brave Search API 首选
- **v1.0** (2026-03-09 初始版本):
  - 整合 5 个 MCP 工具
  - 配置 curl 兜底方案
  - 建立优先级策略

---

## 🔗 相关链接和文档

- **OpenClaw 文档**: https://docs.openclaw.ai/
- **MCP 协议**: https://modelcontextprotocol.io/
- **Brave API 文档**: https://api-dashboard.search.brave.com/documentation/services/web-search
- **GitHub 仓库**: https://github.com/brave/brave-search-mcp-server
