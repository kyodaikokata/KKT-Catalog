# KKT-Catalog

**KKT 插件合集源 · Unified Dalamud custom plugin repository**

**Repository:** https://github.com/kyodaikokata/KKT-Catalog

本仓库集中分发 KKT 开发的 Dalamud 插件——涵盖 **外观自动化**（按 SimpleHeels 高度或当前渲染装备匹配规则，联动 Glamourer / Penumbra 等）与 **音效调节** 等工具。在 Dalamud 设置中添加 **一个** 自定义源 URL，即可安装与更新合集内的全部插件。  
This repository hosts KKT’s Dalamud plugins in one place: **appearance automation** (match rules by SimpleHeels height or rendered equipment, then drive Glamourer / Penumbra and more) and **audio tools**, among others. Add **one** custom repo URL in Dalamud settings to install and update every plugin listed below.

---

## 安装 · Installation

在游戏中打开 Dalamud 插件安装器（`/xlplugins`），进入 **设置 → 自定义插件库 / Settings → Custom Plugin Repositories**，粘贴与你启动器对应的 URL：

| 启动器 Launcher | 自定义源 URL |
|-----------------|--------------|
| XIVLauncher **国服 (CN)** | `https://raw.githubusercontent.com/kyodaikokata/KKT-Catalog/main/pluginmaster.cn.json` |
| XIVLauncher **国际 (Global)** | `https://raw.githubusercontent.com/kyodaikokata/KKT-Catalog/main/pluginmaster.global.json` |

添加后回到插件列表，搜索插件名称即可安装或更新。  
After adding the URL, return to the plugin list and search by name to install or update.

> **请勿同时添加各插件旧的单插件源 URL**（例如 `HeelsDesignLinker/main/pluginmaster.cn.json`），否则会在列表中出现重复条目。  
> **Do not** keep legacy per-plugin repo URLs alongside this catalog, or the same plugin may appear twice.

---

## 当前插件 · Plugins in this catalog

| 插件 Plugin | 版本 Version | CN | Global | 源码 Source |
|-------------|--------------|:--:|:------:|-------------|
| Heels Design Linker | **1.4.2.7** | ✅ | ✅ | [HeelsDesignLinker](https://github.com/kyodaikokata/HeelsDesignLinker) |
| SoundMixer | **0.2.3.2** | ✅ | ✅ | [SoundMixer](https://github.com/kyodaikokata/SoundMixer) |

---

### Heels Design Linker

| | |
|---|---|
| **游戏内命令** | `/hdl` · `/heelsdesign` |

> **不仅限于高跟鞋！** 除 SimpleHeels 高度外，还可根据 **当前渲染装备外观**（DrawObject）匹配规则；可组合高度与装备条件，自动执行 Glamourer、Penumbra、Moodles、Honorific、SoundMixer 等行动。  
> **Not just for heels!** Match rules by **SimpleHeels height** and/or **rendered equipment** (DrawObject), then auto-apply Glamourer, Penumbra, Moodles, Honorific, or SoundMixer actions.

**本版更新 · This release (1.4.2.7)**  
- 中文：**全局 SFW 模式**（独立标签页，Penumbra 临时层 -1210）；主界面与 DTR 一键切换；`/hdl sfw` / `/hdl nsfw`。规则现在支持分组。详见游戏内「更新履历」。  
- English: **Global SFW mode** (dedicated tab, Penumbra temp layer -1210); main panel and DTR toggle; `/hdl sfw` / `/hdl nsfw`. Rules now can be grouped See in-app changelog.

**中文**  
在 **SimpleHeels 高度** 之外，还可按 **当前渲染装备**（如脚部是否为空、头部 ModelId、身体是否有装备等）触发规则，并自动应用 **Glamourer** 设计、**Penumbra** mod 选项，以及可选的 **Moodles**、**Honorific**、**SoundMixer**。  
**强烈推荐：** SimpleHeels、Glamourer、Penumbra。

**English**  
Beyond **SimpleHeels height**, rules can match **rendered equipment** (e.g. empty feet, specific head ModelId, body gear) and auto-apply **Glamourer**, **Penumbra**, and optional **Moodles**, **Honorific**, or **SoundMixer**.  
**Strongly recommended:** SimpleHeels, Glamourer, and Penumbra.

**反馈 / Feedback：** [HeelsDesignLinker Issues](https://github.com/kyodaikokata/HeelsDesignLinker/issues)

[HeelsDesignLinker README](https://github.com/kyodaikokata/HeelsDesignLinker#readme)

---

### SoundMixer

| | |
|---|---|
| **游戏内命令** | `/soundmixer` · `/smix` |

**本版更新 · This release (0.2.3.2)**  
- 中文：修复 **mod 音乐** 短/长路径分裂（自动路径别名）；修复 >100% 音量放大基准污染；强制刷新与调试页极限音量优化。详见游戏内更新日志。  
- English: Fix **mod music** short/full path split (auto alias); fix >100% volume boost baseline; enforcement refresh and extreme volume debug. See in-app changelog.

**中文**  
按 **SCD 路径** 精细调节音效：分组与 Glob、预设、实时监听、黑名单、BGM/环境音、**IPC 临时覆盖**、调试页、可拖动 UI（0–200% 增益，专家模式 350%）。PlaySound 默认关闭；路径解析始终安全（不调用 GetFileName）。

**English**  
Per-**SCD-path** volume mixing with groups, Glob, presets, live monitor, blacklist, BGM/ambient, **IPC overrides**, debug hooks, resizable UI (0–350% gain). PlaySound off by default; always safe path resolve (no GetFileName).

**反馈 / Feedback：** 功能、Bug、建议请提交至 **[SoundMixer Issues](https://github.com/kyodaikokata/SoundMixer/issues)**（勿在本 Catalog 仓库开 Issue）。  
Report features, bugs, or suggestions at **[SoundMixer Issues](https://github.com/kyodaikokata/SoundMixer/issues)** — **not** in this catalog repo.

[SoundMixer README](https://github.com/kyodaikokata/SoundMixer#readme)

---

## 反馈与支持 · Feedback & support

**插件相关问题请到各插件源码仓提 Issue，不要在本仓库（KKT-Catalog）提交。**  
**For plugin bugs or feature requests, use each plugin’s source repo — not KKT-Catalog.**

| 插件 Plugin | Issues |
|-------------|--------|
| Heels Design Linker | [kyodaikokata/HeelsDesignLinker/issues](https://github.com/kyodaikokata/HeelsDesignLinker/issues) |
| SoundMixer | [kyodaikokata/SoundMixer/issues](https://github.com/kyodaikokata/SoundMixer/issues) |

仅在以下情况使用 **本仓库** [KKT-Catalog Issues](https://github.com/kyodaikokata/KKT-Catalog/issues)：

- 自定义源 URL 无法添加或 manifest / zip 下载失败  
- 合集源配置、分发文件错误（与插件逻辑无关）

Use **KKT-Catalog Issues** only for catalog distribution problems (repo URL, manifest, zip download) — not plugin behavior.

---

## 许可证 · License

本仓库中的分发文件（manifest、发行 zip、图标等）采用 [MIT License](LICENSE)。  
Distribution artifacts in this repo are under the [MIT License](LICENSE). See each source repository for additional terms if any.

---

## 维护者 · Maintainers

| 文档 | 用途 |
|------|------|
| [REPOSITORY.md](REPOSITORY.md) | 目录约定、发版流程、`catalog.json.example` |
| [catalog.json.example](catalog.json.example) | 插件注册表模板（复制为本地 `catalog.json`，**不提交 Git**） |

本地首次配置：

```powershell
Copy-Item catalog.json.example catalog.json
# 可选：在 catalog.json 中填写 catalogRoot、workInProgressPath
```

发版后提交本仓库时 **不要** `git add catalog.json`（含本机路径）。若远程仍有旧的 `catalog.json`，执行 `git rm --cached catalog.json` 后推送。
