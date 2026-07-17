import re

with open("lib/presentation/pages/tai_xuan_interactive_page.dart", "r") as f:
    content = f.read()

# Add import
content = content.replace("import 'package:xuan_common_ui/xuan_common_ui.dart';", "import 'package:xuan_common_ui/xuan_common_ui.dart';\nimport '../../l10n/generated/app_localizations.dart';")

# Add l10n to build
content = content.replace("Widget build(BuildContext context) {", "Widget build(BuildContext context) {\n    final l10n = AppLocalizations.of(context)!;")

content = content.replace("const Text('太玄四柱交互式计算')", "Text(l10n.taiXuanInteractive)")
content = content.replace("Text('撤销')", "Text(l10n.undo)")
content = content.replace("Text('重新开始')", "Text(l10n.restart)")
content = content.replace("Text('帮助')", "Text(l10n.help)")
content = content.replace("const Text('等待用户操作...')", "Text(l10n.waitingForUserAction)")
content = content.replace("const Text('取消')", "Text(l10n.cancel)")
content = content.replace("const Text('确定')", "Text(l10n.confirm)")
content = content.replace("const Text('交互式计算帮助')", "Text(l10n.interactiveHelp)")

with open("lib/presentation/pages/tai_xuan_interactive_page.dart", "w") as f:
    f.write(content)
