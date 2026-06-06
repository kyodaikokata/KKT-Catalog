# KKT-Catalog

**KKT 插件合集源 · Unified Dalamud custom plugin repository**

**Repository:** https://github.com/kyodaikokata/KKT-Catalog

本仓库集中分发 KKT 开发的 Dalamud 插件。在 Dalamud 设置中添加 **一个** 自定义源 URL，即可安装与更新合集内的全部插件。  
This repository hosts KKT’s Dalamud plugins in one place. Add **one** custom repo URL in Dalamud settings to install and update every plugin listed below.

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
> **Do not** keep legacy per-plugin repo URLs (e.g. `HeelsDesignLinker/main/pluginmaster.cn.json`) alongside this catalog, or the same plugin may appear twice.

---

## 当前插件 · Plugins in this catalog

### Heels Design Linker

| | |
|---|---|
| **版本 Version** | **1.2.1.1** |
| **源码 Source** | https://github.com/kyodaikokata/HeelsDesignLinker |
| **游戏内命令** | `/hdl` · `/heelsdesign` |

**本版更新 · This release (1.2.1.1)**  
- 中文：规则与基准使用相同参数时跳过基准回退；设置界面 HelpMarker 提示；本地化更新。  
- English: Skip baseline revert when a rule uses the same parameter; HelpMarker hints in settings; localization updates.

**中文**  
根据 **SimpleHeels** 的实时高度，自动联动 **Glamourer** 设计或 **Penumbra** mod 选项；每条规则还可选用 **Moodles** 状态/预设与 **Honorific** 称号。  
**强烈推荐：** SimpleHeels、Glamourer、Penumbra（本插件的价值依赖这些插件配合使用）。

**English**  
Automatically applies **Glamourer** designs or **Penumbra** mod options when your **SimpleHeels** height matches a rule. Optional **Honorific** titles and **Moodles** statuses/presets per rule.  
**Strongly recommended:** SimpleHeels, Glamourer, and Penumbra.

功能说明、快速上手与完整更新日志见源码仓库 README：  
Full documentation, quick start, and changelog: [HeelsDesignLinker README](https://github.com/kyodaikokata/HeelsDesignLinker#readme)

### SoundMixer

| | |
|---|---|
| **版本 Version** | **0.1.0.0** |
| **源码 Source** | https://github.com/kyodaikokata/SoundMixer |
| **游戏内命令** | `/soundmixer` · `/smix` |
| **国服 CN** | ✅ |
| **国际服 Global** | ✅ |

**本版更新 · This release (0.1.0.0)**  
- 中文：首发版本——按 SCD 路径调节音量、自定义分组与 Glob 规则、预设、实时监听、BGM/环境音支持，中英界面。  
- English: Initial release — per-SCD-path volume mixing, custom groups, Glob patterns, presets, live monitor, BGM/ambient support, CN/EN UI.

**中文**  
按 **SCD 路径** 精细控制 FF14 音效音量。支持 **Glob** 分组、嵌套分组、**预设** 与 **实时监听**；可调节 BGM 与环境音，线性增益 0–200%（专家模式最高 350%）。

**English**  
Fine-grained FFXIV audio mixing by **SCD path**. **Glob** groups, nested groups, **presets**, and a **live monitor**; BGM and ambient support with 0–200% linear gain (Expert Mode up to 350%).

功能说明与反馈指引见源码仓库 README：  
Full documentation: [SoundMixer README](https://github.com/kyodaikokata/SoundMixer#readme)

---

## 反馈与支持 · Feedback & support

| 需求 Need | 去哪里 Where |
|-----------|--------------|
| 插件功能、Bug、建议 Feature, bugs, suggestions | 对应插件的 **源码仓库 Issues**（见上表 Source 链接） |
| 合集源无法安装、URL 失效 Catalog install / URL issues | [KKT-Catalog Issues](https://github.com/kyodaikokata/KKT-Catalog/issues) |

---

## 许可证 · License

本仓库中的分发文件（manifest、发行 zip、图标等）采用 [MIT License](LICENSE)。  
各插件源码仓库可能有相同或补充说明，以源码仓为准。  
Distribution artifacts in this repo (manifests, release zips, icons) are under the [MIT License](LICENSE). See each source repository for additional terms if any.

---

## 维护者 · Maintainers

仓库目录约定、发版脚本与 `catalog.json.example` 说明见 [REPOSITORY.md](REPOSITORY.md)（面向开发者，非安装必需）。  
For directory layout, release scripts, and `catalog.json.example`, see [REPOSITORY.md](REPOSITORY.md) (maintainer documentation).
