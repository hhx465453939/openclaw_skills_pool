# OpenClaw Skills Pool

OpenClaw Agent Skills 技能库，收录适配 OpenClaw 的高质量技能集合，覆盖开发、调研、办公与垂直领域任务。

> 本仓库重点支持 **OpenClaw 优化版多 Agent 架构**：`superpowers` 与 `deep-research` 在并发模式下可显著提升执行速度和 Token 效率。

---

## 目录

- [快速开始](#快速开始)
- [OpenClaw 接入方式](#openclaw-接入方式)
- [技能列表](#技能列表)
- [多 Agent 运行建议](#多-agent-运行建议)
- [重点技能：superpowers 与 deep-research](#重点技能superpowers-与-deep-research)
- [典型组合用法](#典型组合用法)
- [目录结构](#目录结构)
- [技能索引维护](#技能索引维护)
- [贡献指南](#贡献指南)

---

## 快速开始

每个技能是一个独立目录，最少包含一个 `SKILL.md`。

```text
openclaw_skills_pool/
├── <skill-name>/
│   ├── SKILL.md
│   ├── references/   # 可选
│   ├── scripts/      # 可选
│   └── templates/    # 可选
└── index.json        # 自动维护
```

---

## OpenClaw 接入方式

1. 将本仓库挂载到 OpenClaw Workspace 的技能目录（建议映射到 `workspace/skills/`）。
2. 确保每个技能目录中存在 `SKILL.md`，并包含 `name` / `description` / `version`（可选）元信息。
3. 对复杂任务优先使用 task session（而非裸跑），以获得更稳的并发和更低的上下文成本。

---

## 技能列表

当前扫描到 `SKILL.md`：**28** 个（其中 `frontend-slides/references/SKILL.md` 为内嵌参考技能）；主技能目录清单为 **27** 个（与下方列表对齐）。

### 核心开发与方法论

- [superpowers](./superpowers/SKILL.md)（v2.0.0）
- [code-debugger](./code-debugger/SKILL.md)
- [ai-spec](./ai-spec/SKILL.md)
- [debug-ui](./debug-ui/SKILL.md)
- [ralph](./ralph/SKILL.md)

### 深度研究与分析

- [deep-research](./deep-research/SKILL.md)（v2.3.0）
- [paper-reader](./paper-reader/SKILL.md)
- [network-search](./network-search/SKILL.md)
- [market-alpha-orchestrator](./market-alpha-orchestrator/SKILL.md)
- [scrna-celltype-annotation](./scrna-celltype-annotation/SKILL.md)

### 办公与效率工具

- [office-docs](./office-docs/SKILL.md)
- [executive-secretary](./executive-secretary/SKILL.md)
- [executive-consultant](./executive-consultant/SKILL.md)
- [feishu-file-transfer](./feishu-file-transfer/SKILL.md)
- [image-recognition](./image-recognition/SKILL.md)
- [frontend-slides](./frontend-slides/SKILL.md)
- [drawio-xml-roadmap](./drawio-xml-roadmap/SKILL.md)

### 垂直领域技能（命理/医疗等）

- [medical-advisory](./medical-advisory/SKILL.md)
- [metaphysics-generalist](./metaphysics-generalist/SKILL.md)
- [eight-characters-analysis](./eight-characters-analysis/SKILL.md)
- [bazi-marriage-matchmaker](./bazi-marriage-matchmaker/SKILL.md)
- [senior-numerology-master](./senior-numerology-master/SKILL.md)
- [iching-divination](./iching-divination/SKILL.md)
- [meihua-ease-number-analysis](./meihua-ease-number-analysis/SKILL.md)
- [six-divines-expert](./six-divines-expert/SKILL.md)
- [qi-dun-jia-yijing-master](./qi-dun-jia-yijing-master/SKILL.md)
- [fengshui-gardening-geography](./fengshui-gardening-geography/SKILL.md)

---

## 多 Agent 运行建议

- **推荐环境**：OpenClaw + 支持并发子 Agent 的运行器。
- **复杂任务优先并发**：规划、收集、执行、复核分工给不同 agent。
- **capsule 优先**：并发 agent 读取 capsule 和自身 brief，避免重放完整历史。
- **产物分层**：中间稿放 task 目录，正式报告再归档。

---

## 重点技能：superpowers 与 deep-research

### superpowers（规划 + 执行中枢）

适合复杂任务的统一入口，核心能力：

- 复杂度评估与任务拆解
- 任务会话对接与 capsule 管理
- 子 Agent 并发协作（在支持环境下）

在 OpenClaw Workspace 中推荐通过 bootstrap 进入：

```bash
bash workspace/scripts/superpowers-bootstrap.sh "<task-slug>" "<reason>" \
  --objective "<goal>" \
  --deliverable "<deliverable>" \
  --scope "<scope>"
```

### deep-research（并行调研引擎）

适合多源信息收集、交叉验证、量化核算和报告交付，核心能力：

- 2-8 个角色化 agent 并发执行
- 学术风格引用管理（正文 `[n]` + References）
- 轻量量化验证（描述统计/公式核算/简单回归）

在 OpenClaw Workspace 中推荐通过 bootstrap 进入：

```bash
bash workspace/scripts/deep-research-bootstrap.sh "<task-slug>" "<reason>" \
  --objective "<goal>" \
  --deliverable "<deliverable>" \
  --scope "<scope>"
```

---

## 典型组合用法

### 组合 A：`superpowers` -> `deep-research`

用于“先定义问题，再深挖证据”的任务：

1. `superpowers` 明确目标、范围、成功标准
2. 输出调研任务拆解和执行边界
3. `deep-research` 并行执行收集、分析、验证
4. 输出可交付报告并发送文件

### 组合 B：`superpowers` -> `code-debugger`

用于工程执行闭环：

1. `superpowers` 产出计划与质量门禁
2. `code-debugger` 做实现、Checkfix、调试文档维护

---

## 目录结构

```text
openclaw_skills_pool/
├── index.json
├── SKILL_INDEXING.md
├── SHOWCASE.md
├── superpowers/
├── deep-research/
├── code-debugger/
└── <other-skills>/
```

---

## 技能索引维护

`index.json` 必须通过脚本维护，禁止手改。

```bash
# 重建索引
node workspace/scripts/rebuild-skills-index.js

# 检查漂移
node workspace/scripts/check-skills-index.js

# 启动监听（长会话推荐）
bash workspace/scripts/start-skills-index-watcher.sh

# 停止监听
bash workspace/scripts/stop-skills-index-watcher.sh
```

详细规则见 [`SKILL_INDEXING.md`](./SKILL_INDEXING.md)。

---

## 贡献指南

1. 新建技能目录（kebab-case）。
2. 编写 `SKILL.md`（含 `name` 与清晰的 `description`）。
3. 按需添加 `scripts/` / `references/` / `templates/`。
4. 运行索引脚本并确认无漂移。

建议：`description` 直接写“适用场景 + 核心能力”，便于触发器精准匹配。

---

## 相关资源

- [OpenClaw Agent Skills 文档](https://docs.openclaw.ai/agent-skills)
- [superpowers 原始项目](https://github.com/obra/superpowers)
