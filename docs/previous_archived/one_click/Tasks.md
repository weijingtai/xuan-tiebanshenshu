# 统一排盘系统开发任务清单 (Unified Divination System Tasks)

## Phase 1: 核心架构 (Core Architecture)

### 1.1 数据模型 (Data Models)

- [x] 定义 `DivinationContext` (排盘上下文)
  - [x] 包含基本输入 (`EightChars`, `Gender`, 等)
  - [x] 支持不可变更新 (`copyWith` / `fork`)
- [x] 定义 `DivinationSession` (全局会话)
  - [x] 管理 `List<DivinationContext>` (分支历史)
  - [x] 实现 `switchBranch(Context)`
- [x] 定义 `DivinationResult` (统一结果接口)
  - [x] 标准化输出结构 (`title`, `items`, `tags`)

### 1.2 协调器 (Orchestrator)

- [x] 实现 `DivinationOrchestrator`
  - [x] 依赖注入所有 16+ 策略
  - [x] 实现 `analyzeDependencies()` (计算执行顺序)
  - [x] 实现 `execute()` (异步执行流)

## Phase 2: 策略适配 (Strategy Adapters)

### 2.1 Level 1: 基础层 (Direct)

- [x] Adapter: `DayGanZhiGua`
- [x] Adapter: `FourZhuTianGan`
- [ ] Adapter: `ShengMingGuaCalculation`
- [ ] Adapter: `BaGuaJiaZe` & `BaGuaGun`
- [ ] Adapter: `SiMenFa`
- [ ] Adapter: `QianHouGua`
- [x] Adapter: `TaiXuanFourZhu` (Standard)

### 2.2 Level 2: 进阶层 (Dependent)

- [ ] Adapter: `YuanTang` (处理大运/条文分组)
- [ ] Adapter: `XianHoutianQuShu` (重构: 使用 Context 结果)
- [ ] Adapter: `LiuYaoGanZhiHe` (重构: 使用 Context 结果)
- [ ] Adapter: `GuaYaoGanZhiHe` & `XianHoutianJiaZe`
- [ ] Adapter: `GuaZhong` (处理多方案)

### 2.3 Level 3: 交互层 (Interactive)

- [ ] Adapter: `TaiXuanFourZhuInteractive`
  - [ ] 实现 `InteractiveSession` 到 `DivinationResult` 的映射

## Phase 3: UI 功能原型 (Functional UI Prototype)

*注: 优先确保程序功能可用，暂不追求高保真视觉效果。*

### 3.1 页面框架

- [ ] 创建 `UnifiedDivinationPage`
- [ ] 实现 `StreamBuilder` 监听排盘进度

### 3.2 核心组件 (原型)

- [ ] `ResultItemWidget`: 简单的文本/列表展示
- [ ] `StripListWidget`:带有简单时间轴标记的条文列表
- [ ] `InteractiveDialog`: 弹出式或嵌入式输入框 (用于皇极/刻分选择)

## Phase 4: 优化与验证

- [ ] 验证 "皇极经世" 1111 vs 2222 分支对比功能
- [ ] 性能测试: 确保 16+ 算法并发不卡顿 (Isolate)
