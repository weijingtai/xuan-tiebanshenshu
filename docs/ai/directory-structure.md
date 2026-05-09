# xuan-tiebanshenshu 目录结构

> **TODO（占位）**：本文件覆盖上游 `weijingtai/docs/ai/directory-structure.md` 中的 `lib/` 通用示例。
> 维护者：以下结构基于代码扫描结果，请补充每个目录的"用途"说明，并清理冗余。

---

## lib/ 实际结构

```
lib/
├── application/                 ← 应用服务层
│   ├── services/
│   └── usecases/
├── domain/                      ← 领域模型
│   ├── models/
│   └── exceptions/
├── infrastructure/              ← 基础设施
│   └── di/
├── presentation/                ← 表现层（推荐使用）
│   ├── home/
│   ├── pages/
│   ├── components/
│   ├── widgets/
│   ├── viewmodels/
│   ├── models/
│   ├── styles/
│   └── theme/
├── features/                    ← 功能模块
│   ├── kao_ding_liu_qin/
│   ├── six_yao_gua/
│   ├── yuan_tang_gua/
│   ├── kao_ke/
│   ├── liuqinkaoke/
│   └── huang_ji/
├── service/                     ← TODO: 与 application/services 关系待澄清
│   ├── unified/
│   └── strategy/
├── repository/
│   └── datamodels/
├── providers/                   ← TODO: 是否合并入 presentation/viewmodels
├── usecases/                    ← TODO: 是否合并入 application/usecases
├── ui/                          ← TODO: 是否迁移入 presentation/
│   ├── pages/
│   └── utils/
├── utils/
├── extensions/
└── constant/
```

## 命名约定

TODO：补充。例如：
- 文件名 snake_case
- 类名 PascalCase
- ViewModel 后缀：`*ViewModel`
- Page 后缀：`*Page`
- Strategy 后缀：`*Strategy`

## 常见 import 模式

TODO：补充。

## 已知冗余（待清理）

- `lib/ui/` ↔ `lib/presentation/`：职责重叠，目标是统一到 `lib/presentation/`
- `lib/usecases/` ↔ `lib/application/usecases/`：同上
- `lib/service/` ↔ `lib/application/services/`：同上

> 完整迁移计划见 `docs/Plans.md`。
