# PreciseSearch

PreciseSearch 是一个本地 macOS 搜索工具，用来替代 Finder / 文件打开面板里默认偏模糊的文件名搜索体验。它默认使用精准搜索，也可以一键切换为模糊搜索。

## 下载使用

打开 GitHub Releases，下载 `PreciseSearch-macOS.zip`，解压后运行 `PreciseSearch.app`。

如果 macOS 提示应用来自未认证开发者，可以右键点击应用并选择“打开”，或者从源码本地构建。

## 功能

- 默认精准搜索：完整匹配文件名。
- 可选忽略扩展名：搜索 `报告` 时可以匹配 `报告.pdf`。
- 可切换模糊搜索：按文件名包含关系搜索。
- 可限定范围：这台 Mac、用户目录、桌面、下载、文稿。
- 支持打开文件、在 Finder 显示、复制路径。

## 构建

要求：

- macOS 14.0 或更新版本
- Swift 6.0 或更新版本

构建并启动本地 app bundle：

```bash
./script/build_and_run.sh
```

运行测试：

```bash
swift test
```

运行脚本会构建名为 `PreciseSearch` 的 Swift package target，生成 `dist/PreciseSearch.app`，并启动这个应用。

## 说明

PreciseSearch 使用 macOS 自带的 Spotlight 命令行工具 `mdfind` 做文件名查询，不修改 Finder 或系统文件选择器本身的行为。

## License

MIT
