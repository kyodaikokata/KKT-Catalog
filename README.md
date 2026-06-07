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
> **Do not** keep legacy per-plugin repo URLs alongside this catalog, or the same plugin may appear twice.

---

## 当前插件 · Plugins in this catalog

| 插件 Plugin | 版本 Version | CN | Global | 源码 Source |
|-------------|--------------|:--:|:------:|-------------|
| Heels Design Linker | **1.2.1.3** | ✅ | ✅ | [HeelsDesignLinker](https://github.com/kyodaikokata/HeelsDesignLinker) |
| SoundMixer | **0.2.0.0** | ✅ | ✅ | [SoundMixer](https://github.com/kyodaikokata/SoundMixer) |

---

### Heels Design Linker

| | |
|---|---|
| **游戏内命令** | `/hdl` · `/heelsdesign` |

**本版更新 · This release (1.2.1.3)**  
- 中文：界面本地化补全；Penumbra 临时应用、SoundMixer 联动与稳定性修复（详见游戏内更新日志）；开发者文档。  
- English: UI localization complete; Penumbra temp apply, SoundMixer integration, and stability fixes (see in-game changelog); developer docs.

**中文**  
根据 **SimpleHeels** 的实时高度，自动联动 **Glamourer** 设计或 **Penumbra** mod 选项；每条规则还可选用 **Moodles** 状态/预设与 **Honorific** 称号。  
**强烈推荐：** SimpleHeels、Glamourer、Penumbra。

**English**  
Automatically applies **Glamourer** designs or **Penumbra** mod options when your **SimpleHeels** height matches a rule. Optional **Honorific** titles and **Moodles** statuses/presets per rule.  
**Strongly recommended:** SimpleHeels, Glamourer, and Penumbra.

[HeelsDesignLinker README](https://github.com/kyodaikokata/HeelsDesignLinker#readme)

---

### SoundMixer

| | |
|---|---|
| **游戏内命令** | `/soundmixer` · `/smix` |

**本版更新 · This release (0.2.0.0)**  
- 中文：外部插件 **IPC 临时音量覆盖**；可折叠监听/IPC 面板；发行包附带 `DotNet.Glob.dll`；实时监听防崩溃；中英界面与游戏内更新日志。  
- English: **IPC temporary volume overrides** for external plugins; collapsible monitor/IPC panels; ships `DotNet.Glob.dll`; live monitor crash guards; CN/EN UI and in-game changelog.

**中文**  
按 **SCD 路径** 精细控制 FF14 音效音量。支持 **Glob** 分组、嵌套分组、**预设** 与 **实时监听**；可调节 BGM 与环境音（专家模式最高约 350% 听感上限）。

**English**  
Fine-grained FFXIV audio mixing by **SCD path**. **Glob** groups, nested groups, **presets**, and a **live monitor**; BGM and ambient support (Expert Mode up to ~350% audible cap).

[SoundMixer README](https://github.com/kyodaikokata/SoundMixer#readme)

---

## 反馈与支持 · Feedback & support

| 需求 Need | 去哪里 Where |
|-----------|--------------|
| 插件功能、Bug、建议 Feature, bugs, suggestions | 对应插件的 **源码仓库 Issues**（见上表） |
| 合集源无法安装、URL 失效 Catalog install / URL issues | [KKT-Catalog Issues](https://github.com/kyodaikokata/KKT-Catalog/issues) |

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
