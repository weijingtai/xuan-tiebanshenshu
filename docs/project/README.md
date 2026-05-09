# project/ — xuan-tiebanshenshu 项目内容

> **TODO（占位）**：本文件覆盖上游 `weijingtai/docs/project/README.md` 中的命名示例。
> 维护者：按下面的骨架补全本项目实际命名规范。

---

## 本目录用途

存放 xuan-tiebanshenshu 项目专属内容（区别于 `docs/ai/` 的方法论）：

- PRD（Product Requirement Document）
- ADR（Architecture Decision Record）
- Changelog
- 模块设计文档（如分册的算法说明）

## 命名约定

TODO：补充。建议示例：

| 类型 | 命名格式 | 例子 |
|------|----------|------|
| PRD | `prd-<feature>.md` | `prd-yuan_tang_gua.md` |
| ADR | `adr-<NNN>-<short-title>.md` | `adr-001-clean-architecture-migration.md` |
| Changelog | `CHANGELOG.md`（顶层） | — |
| 模块设计 | `design-<module>.md` | `design-strategy-pattern.md` |

## 子目录建议

TODO：根据需要建立。例如：

- `prds/` — 所有 PRD
- `adrs/` — 所有 ADR
- `designs/` — 模块设计文档
- `changelogs/` — 历史变更日志

## 与 `docs/superpowers/specs/` 的区别

- `docs/superpowers/specs/` — SPEC Coding 流程产物（AI 与人之间的开发合同），日期前缀 `YYYY-MM-DD-<topic>-design.md`
- `docs/project/` — 项目稳定文档（PRD / ADR / changelog），不带日期前缀，按主题归档

> 详见 `docs/ai/doc-standards.md`。
