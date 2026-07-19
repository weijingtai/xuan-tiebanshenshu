# PLAN

- [x] 确认 TiaoWenLocalDataSource 属于 persistence/assets 层边界，而不是 tieban 业务层契约。
- [x] 用测试锁定 StrategyProviders 只依赖外部 TiaoWenRepository，不注册 TiaoWenLocalDataSource/TiaoWenRemoteDataSource/TiaoWenRepositoryImpl。
- [x] 将 lib/main.dart 与 example/lib/main.dart 改为从 persistence_assets 创建 AssetsTiaoWenRepository 并传入 StrategyProviders。
- [x] 删除 tieban 主模块中的半迁移本地/远程数据源实现文件。
- [x] 更新依赖与架构说明文档。
- [x] 运行目标测试、全量测试、GitNexus detect_changes。

后续可选：
- [ ] 在 persistence_assets 内恢复/实现 TXT 数据源变体，并提供统一 factory/provider。
- [ ] 决定是否废弃或迁移 lib/shaozishu/repository/shaozi_tiao_wen_repository.dart。
