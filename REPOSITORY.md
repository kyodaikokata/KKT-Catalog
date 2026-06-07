# KKT-Catalog 仓库管理规范

本文档定义 **KKT-Catalog**（Dalamud 自定义插件合集源）的目录约定、元数据格式与发版流程，供后续编写 `build` / `release` 脚本时作为单一事实来源（Single Source of Truth）。

---

## 1. 仓库定位

| 仓库 | 职责 |
|------|------|
| **KKT-Catalog**（本仓库） | 聚合多款插件的 manifest 与发行 zip；用户只需添加一个 Repo URL |
| **各插件独立仓库**（如 `HeelsDesignLinker`、`SoundMixer`） | 存放源码、开发历史；**插件 Bug / 功能建议的 Issue 提交到对应源码仓**，非 KKT-Catalog |

**原则：**

- 本仓库 **不存放插件源码**（`*.cs`、`*.csproj` 等）。
- 本仓库 **必须** 存放可安装的 zip 与对外 manifest。
- 每个插件条目的 `RepoUrl` 指向该插件的源码仓库，而非本仓库。

**GitHub 仓库：** `kyodaikokata/KKT-Catalog`  
**默认分支：** `main`

---

## 2. 三层目录与文件归属

维护者本地通常同时存在三个层级。**源码、构建、分发必须分开**，避免把 build 脚本或 `bin/` 产物混进 Catalog。

### 2.1 总览

```
WorkInProgress/<Plugin>/          本地开发（日常编码、编译、调试）
        │
        │  build 脚本（build-dual.ps1）
        ▼
   dist/cn|global/latest.zip      本地中间产物，不提交 Git
        │
        │  publish 脚本（publish-plugin.ps1）
        ▼
KKT-Catalog/                      合集分发仓（用户 Repo URL 指向这里）
        │
插件独立仓库（如 HeelsDesignLinker）  源码 + Issue + 版本历史（RepoUrl 指向这里）
```

| 层级 | 路径示例 | 是否上 GitHub | 用户是否直接接触 |
|------|----------|---------------|------------------|
| 本地开发 | `DalamudProject/WorkInProgress/HeelsToggle/` | 否 | 否 |
| 插件源码仓 | `github.com/kyodaikokata/HeelsDesignLinker` | 是（每插件一仓） | 仅通过 `RepoUrl` 链接 |
| 合集分发仓 | `github.com/kyodaikokata/KKT-Catalog` | 是（仅此一个 URL） | 是（安装/更新插件） |

### 2.2 文件归属对照表

| 文件 / 目录 | WorkInProgress | 插件独立仓库 | KKT-Catalog |
|-------------|:--------------:|:------------:|:-----------:|
| `*.cs`、`*.csproj`、`packages.lock.json` | ✅ | ✅ | ❌ |
| 插件内 `{AssemblyName}.json`（manifest 模板） | ✅ | ✅ | ❌ |
| `images/<InternalName>/icon.png`（源图） | ✅ | ✅ | ✅ 分发副本 |
| `scripts/build-dual.ps1` | ✅ | ✅ 可选同步 | ❌ |
| `scripts/lib/PublishHelpers.ps1`（zip 校验） | ✅ | ✅ 可选同步 | ❌ |
| `scripts/publish-release.ps1`（插件级：build → 调 Catalog） | ✅ | ✅ 可选同步 | ❌ |
| `scripts/publish-plugin.ps1`（合集级：写入 manifest + zip） | ❌ | ❌ | ✅ |
| `scripts/lib/CatalogHelpers.ps1` | ❌ | ❌ | ✅ |
| `dist/`（`cn/global/latest.zip`） | ✅ 临时 | ❌ | ❌ |
| `bin/`、`obj/` | ✅ 本地 | ❌ gitignore | ❌ |
| `pluginmaster.*.json`（单插件草稿/模板） | ✅ | 迁移期可 deprecated | ❌ |
| `catalog.json` | ❌ | ❌ | ✅ |
| `pluginmaster.cn.json` / `pluginmaster.global.json`（合集） | ❌ | ❌ | ✅ |
| `plugins/<InternalName>/latest-cn.zip` | ❌ | ❌ 迁入后 | ✅ |
| `plugins/<InternalName>/latest-global.zip` | ❌ | ❌ 迁入后 | ✅ |
| `README`（功能说明） | ✅ | ✅ | ✅（安装 URL + 插件列表） |
| `LICENSE` | 可选 | ✅ | ✅ |

**记忆口诀：**

- **能编译的** → WorkInProgress / 插件源码仓  
- **能安装的**（zip + 合集 manifest + 图标副本）→ KKT-Catalog  
- **中间产物**（`dist/`、`bin/`、`obj/`）→ 只在本地，不进任何 Git 仓库

### 2.3 各层推荐目录结构

#### WorkInProgress（仅本机，不推送）

```
DalamudProject/WorkInProgress/<PluginSlug>/
├── <ProjectDir>/                 # 含 .csproj 的目录，如 HeelsToggle/
│   ├── *.cs
│   ├── <ProjectDir>.csproj
│   └── <AssemblyName>.json       # 随构建写入 bin/，亦作为模板保留
├── images/
│   └── icon.png
├── dist/                         # .gitignore；build-dual 输出
│   ├── cn/latest.zip
│   └── global/latest.zip
├── scripts/
│   ├── build-dual.ps1            # ← build 入口
│   ├── publish-release.ps1       # build-dual → 调 Catalog 的 publish-plugin
│   └── lib/
│       └── PublishHelpers.ps1      # zip 校验、版本读取
└── pluginmaster.cn.json          # 可选：该插件条目元数据草稿（Description 等）
    pluginmaster.global.json        # 脚本合并进 Catalog 时读取，非最终分发文件
```

#### 插件独立仓库（GitHub 源码仓）

```
<SourceRepo>/                     # 如 HeelsDesignLinker/
├── LICENSE
├── README.md                     # 功能文档；底部注明 Catalog 安装 URL
├── <ProjectDir>/                 # 与 WIP 同步的源码（不含 bin/obj）
│   ├── *.cs
│   ├── *.csproj
│   └── <AssemblyName>.json
├── images/
│   └── icon.png
└── scripts/                      # 建议与 WIP 保持一致，便于他人 clone 后 build
    ├── build-dual.ps1
    ├── publish-release.ps1
    └── lib/PublishHelpers.ps1
```

**迁入 Catalog 后，不应再出现在插件源码仓：**

- `plugins/**/latest-*.zip`（改由 Catalog 托管）
- 作为用户安装入口的 `pluginmaster.cn.json` / `pluginmaster.global.json`（改指向 Catalog URL）

可保留 deprecated 的 `pluginmaster.json` 一段时间，标注「请改用 KKT-Catalog」。

#### KKT-Catalog（GitHub 分发仓）

```
KKT-Catalog/
├── LICENSE
├── README.md
├── REPOSITORY.md
├── catalog.json                  # 插件注册表；release 脚本主配置
├── pluginmaster.cn.json          # 用户安装的国服 manifest
├── pluginmaster.global.json      # 用户安装的国际服 manifest
├── plugins/
│   └── <InternalName>/
│       ├── latest-cn.zip
│       └── latest-global.zip
├── images/
│   └── <InternalName>/icon.png
└── scripts/
    ├── publish-plugin.ps1        # ← release 入口（按 InternalName）
    ├── publish-all.ps1           # 可选：全量
    └── lib/
        └── CatalogHelpers.ps1    # 读 catalog、合并 manifest、写 URL
```

**本仓库不应出现：** `*.cs`、`*.csproj`、`bin/`、`obj/`、`dist/`、各插件的 build-dual 脚本。

### 2.4 Build / Release 脚本放置规范

| 脚本 | 放置位置 | 阶段 | 职责 |
|------|----------|------|------|
| `build-dual.ps1` | WorkInProgress / 插件源码仓 `scripts/` | **Build** | `dotnet build -c Release`（CN + Global），收集 zip 到 `dist/` |
| `PublishHelpers.ps1` | 同上 `scripts/lib/` | **Build** | 查找 `bin/Release/.../latest.zip`、`Assert-ValidPluginZip` |
| `publish-release.ps1` | 同上 `scripts/` | **编排** | 依次调用 `build-dual` → `KKT-Catalog/scripts/publish-plugin.ps1` |
| `publish-plugin.ps1` | **仅** `KKT-Catalog/scripts/` | **Release** | 校验 dist zip → 复制到 `plugins/` → 更新 `pluginmaster.*.json` |
| `CatalogHelpers.ps1` | **仅** `KKT-Catalog/scripts/lib/` | **Release** | 读 `catalog.json`、拼 raw URL、按 `InternalName` 合并 manifest |

**调用关系（目标态）：**

```powershell
# 在 WorkInProgress/<Plugin>/ 执行
.\scripts\publish-release.ps1
    → .\scripts\build-dual.ps1              # 产出 dist/cn|global/latest.zip
    → <CatalogRoot>\scripts\publish-plugin.ps1 `
         -InternalName <Name> `
         -WorkInProgressRoot <WIP根目录> `
         -DistDir <WIP根目录>\dist
```

`publish-release.ps1` 可通过 `catalog.json` 中的 `catalogRoot` 或环境变量 `KKT_CATALOG_ROOT` 定位 Catalog 路径。**不要**在插件源码仓（GitHub 镜像）内复制 `publish-plugin.ps1`；`PublishHelpers.ps1` 仅存在于 WIP 的 `scripts/lib/`。

`publish-plugin.ps1` 解析 WIP 根目录的优先级：

1. 参数 `-WorkInProgressRoot`（`publish-release.ps1` 传入）
2. `-DistDir` 的父目录（当路径以 `\dist` 结尾）
3. `DalamudProject/WorkInProgress/<PluginFolder>`（由 Catalog 路径向上推导，**非** `Release/WorkInProgress`）
4. `catalog.json` 的 `workInProgressPath` 或环境变量 `KKT_WIP_<InternalName>`

### 2.5 与旧模式（单插件 Release 文件夹）的差异

`HeelsDesignLinker` 曾使用 `sync-to-release.ps1`，将 **源码 + zip + manifest** 一并写入 `Release/HeelsDesignLinker` 并 push 到同一 GitHub 仓库。

| 旧行为（单插件仓自分发） | 新行为（Catalog 合集分发） |
|--------------------------|----------------------------|
| zip 在 `HeelsDesignLinker/plugins/` | zip 在 `KKT-Catalog/plugins/` |
| 用户 URL 指向插件仓的 `pluginmaster.cn.json` | 用户 URL 只指向 `KKT-Catalog/pluginmaster.cn.json` |
| `sync-to-release` 用 robocopy 同步源码到 Release 文件夹 | 源码 **仅** 留在插件源码仓 / WIP，**不**复制到 Catalog |
| 插件仓内同时承担源码 + 分发 | 插件仓 = 源码；Catalog = 分发 |

---

## 3. 用户安装 URL

用户在 Dalamud → 设置 → 自定义插件库 中添加：

| 环境 | URL |
|------|-----|
| 国服 CN | `https://raw.githubusercontent.com/kyodaikokata/KKT-Catalog/main/pluginmaster.cn.json` |
| 国际服 Global | `https://raw.githubusercontent.com/kyodaikokata/KKT-Catalog/main/pluginmaster.global.json` |

> 用户迁移到本合集源后，应 **删除** 各插件旧的单插件源 URL，避免同一 `InternalName` 重复出现。

---

## 4. KKT-Catalog 目录结构

> 完整三层结构见 **§2.3**；本节仅强调 Catalog 仓内的命名与 zip 规则。

### 4.1 命名约定（强制）

以下三个标识 **必须相同**，且仅使用 ASCII 字母与数字（PascalCase 推荐）：

| 字段 | 示例 | 说明 |
|------|------|------|
| `InternalName` | `HeelsDesignLinker` | Dalamud 唯一插件 ID，对应 DLL 主文件名 |
| `AssemblyName` | `HeelsDesignLinker` | csproj 中 `<AssemblyName>` |
| `PluginFolder` | `HeelsDesignLinker` | `plugins/` 与 `images/` 下的子目录名 |

**禁止：** 空格、中文、与已收录插件重复的 `InternalName`。

### 4.2 Zip 文件命名（固定）

| 文件 | 用途 |
|------|------|
| `latest-cn.zip` | 国服构建（`Use_Dalamud_CN=true`） |
| `latest-global.zip` | 国际服构建（`Use_Dalamud_CN=false`） |

不使用 `latest.zip` 作为 Catalog 最终文件名；各插件开发仓可在本地 build 产出 `latest.zip`，同步脚本负责重命名并复制到本仓库。

---

## 5. 插件注册表 `catalog.json`

脚本应以 `catalog.json` 为配置入口，再生成或更新 `pluginmaster.*.json`。  
避免在脚本中硬编码插件列表。

### 5.1 格式

```json
{
  "catalogRepo": "kyodaikokata/KKT-Catalog",
  "defaultBranch": "main",
  "catalogRoot": "E:/work/DalamudProject/Release/KKT-Catalog",
  "plugins": [
    {
      "internalName": "HeelsDesignLinker",
      "assemblyName": "HeelsDesignLinker",
      "pluginFolder": "HeelsDesignLinker",
      "sourceRepo": "kyodaikokata/HeelsDesignLinker",
      "sourceRepoUrl": "https://github.com/kyodaikokata/HeelsDesignLinker",
      "workInProgressPath": "E:/work/DalamudProject/WorkInProgress/HeelsToggle",
      "projectSubPath": "HeelsToggle",
      "publishGlobal": true,
      "enabled": true
    }
  ]
}
```

### 5.2 字段说明

| 字段 | 必填 | 说明 |
|------|------|------|
| `internalName` | 是 | 与 manifest `InternalName` 一致 |
| `assemblyName` | 是 | 与 zip 内 DLL 名一致 |
| `pluginFolder` | 是 | `plugins/`、`images/` 子目录名 |
| `sourceRepo` | 是 | `owner/repo`，用于 `RepoUrl` 与文档 |
| `sourceRepoUrl` | 是 | 完整 GitHub URL |
| `catalogRoot` | 否 | 本机 KKT-Catalog 路径；`publish-release.ps1` 用于定位 `publish-plugin.ps1` |
| `workInProgressPath` | 否 | 本地开发根目录，供 build 脚本定位源码（仅维护者机器） |
| `sourceRepoLocalPath` | 否 | 本地 GitHub 源码仓克隆路径（如 `Release/SoundMixer`），供 `sync-source-repo.ps1` |
| `syncRequiredFiles` | 否 | 同步后必须存在的相对路径列表（如黑名单相关源码） |
| `projectSubPath` | 否 | 相对 `workInProgressPath` 的 csproj 目录 |
| `publishGlobal` | 否 | 默认 `true`；仅国服时设为 `false`，只发布 `latest-cn.zip` |
| `enabled` | 否 | 默认 `true`；`false` 时从 manifest 中排除（下架保留目录） |

新增插件时：**先改 `catalog.json`，再跑 release 脚本**，不要手写 manifest 数组。

---

## 6. Manifest 规范（`pluginmaster.*.json`）

### 6.1 文件职责

| 文件 | 受众 |
|------|------|
| `pluginmaster.cn.json` | XIVLauncher 国服 / Dalamud CN |
| `pluginmaster.global.json` | XIVLauncher 国际服 |

每个文件是一个 **JSON 数组**，数组中每个对象对应一款插件。  
**不要** 在本仓库维护已弃用的单文件 `pluginmaster.json`（单插件源兼容由旧仓库自行处理）。

### 6.2 必填字段

脚本生成条目时必须包含：

| 字段 | 规则 |
|------|------|
| `Author` | 固定 `"KKT"`（除非另有约定） |
| `Name` | 显示名称 |
| `InternalName` | 见 §4.1 |
| `Punchline` | 简短一句话 |
| `Description` | CN/Global 两份可不同（在模板或插件元数据中区分） |
| `ApplicableVersion` | 通常 `"any"` |
| `DalamudApiLevel` | 与构建时 SDK/API 一致（当前为 `15`） |
| `AssemblyVersion` | **必须与 zip 内 `{AssemblyName}.json` 一致** |
| `Changelog` | 本版本更新说明 |
| `LastUpdate` | Unix 时间戳（UTC），**每次该插件发版必须更新** |
| `RepoUrl` | 插件 **源码** 仓库 URL，非 Catalog URL |
| `DownloadLinkInstall` | 指向本仓库 raw zip |
| `DownloadLinkUpdate` | 同 Install |
| `DownloadLinkTesting` | 无测试通道时与 Install 相同 |
| `IconUrl` | 指向本仓库 `images/<InternalName>/icon.png` |

### 6.3 Download / Icon URL 模板

设 `BASE = https://raw.githubusercontent.com/kyodaikokata/KKT-Catalog/main`：

```
DownloadLink* (CN)     = {BASE}/plugins/{PluginFolder}/latest-cn.zip
DownloadLink* (Global) = {BASE}/plugins/{PluginFolder}/latest-global.zip
IconUrl                = {BASE}/images/{PluginFolder}/icon.png
```

### 6.4 条目合并规则（脚本必须遵守）

1. 按 `InternalName` 定位数组中的条目；存在则 **更新**，不存在则 **追加**。
2. 更新单个插件时，**不得** 修改其他插件的 `AssemblyVersion` / `LastUpdate`。
3. 发版插件的 `LastUpdate` 必须刷新为当前 UTC 时间戳。
4. `AssemblyVersion` 从对应 zip 内的 manifest 读取，**禁止** 手写后与 zip 不一致。
5. 输出 JSON 为 UTF-8 **无 BOM**；整体为数组，缩进风格与现有 `HeelsDesignLinker` 条目保持一致即可。

### 6.5 CN 与 Global 差异

允许不同的字段：

- `Description`（语言/构建说明）
- `DownloadLink*`（`latest-cn.zip` vs `latest-global.zip`）

以下字段 **应保持一致**（除非刻意区分版本）：

- `AssemblyVersion`
- `DalamudApiLevel`
- `InternalName`
- `RepoUrl`

---

## 7. 插件 Zip 规范

与 `HeelsDesignLinker` 发布脚本校验逻辑对齐，release 脚本 **必须** 在复制前校验。

### 7.1 内容

每个 zip **恰好 3 个文件**，根目录扁平、无子路径：

```
{AssemblyName}.dll
{AssemblyName}.pdb
{AssemblyName}.json
```

### 7.2 禁止项

- 嵌套目录或路径分隔符（`/`、`\`）
- `*.deps.json`
- 嵌套的 `latest.zip`
- 除上述 3 个文件外的任何条目

### 7.3 Zip 内 manifest（`{AssemblyName}.json`）

- 必须包含非空 `IconUrl`
- 必须包含 `AssemblyVersion`
- `InternalName` 与 `AssemblyName` 与目录约定一致

### 7.4 构建环境

| 构建 | MSBuild 属性 | Dalamud dev DLL 路径（需本机已启动过对应启动器） |
|------|----------------|--------------------------------------------------|
| CN | `Use_Dalamud_CN=true` | `%APPDATA%\XIVLauncherCN\addon\Hooks\dev\Dalamud.dll` |
| Global | `Use_Dalamud_CN=false` | `%APPDATA%\XIVLauncher\addon\Hooks\dev\Dalamud.dll` |

本地 build 产出路径（供脚本查找）优先级：

1. `bin/Release/{AssemblyName}/latest.zip`
2. `bin/Release/net10.0-windows/{AssemblyName}/latest.zip`
3. `bin/Release/net10.0-windows/latest.zip`

---

## 8. 发版流程

### 8.1 单插件发版（目标流程）

详见 **§2.4** 脚本分工；流程如下：

```
WorkInProgress/<Plugin>/scripts/publish-release.ps1
    → build-dual.ps1（本机 build，产出 dist/cn|global/latest.zip）
    → Assert-ValidPluginZip
    → KKT-Catalog/scripts/publish-plugin.ps1 -InternalName <Name>
        → 复制 zip → plugins/<PluginFolder>/
        → 复制 icon → images/<PluginFolder>/icon.png
        → 合并 pluginmaster.cn.json / pluginmaster.global.json
    → KKT-Catalog/scripts/sync-source-repo.ps1 -InternalName <Name>
        → 将 WIP 源码同步到本地源码仓克隆（Release/<PluginFolder>/）
        → 打印源码仓 git add / commit / push 提示
    → git commit & push（Catalog；源码仓按提示另推）
```

### 8.2 发版前检查清单

- [ ] `catalog.json` 已登记该插件且 `enabled: true`
- [ ] CN zip 通过校验；若 `publishGlobal: true`，Global zip 亦通过
- [ ] `AssemblyVersion` 已递增（相对上一版 Catalog 中的记录）
- [ ] `Changelog` 已填写
- [ ] `images/<PluginFolder>/icon.png` 存在且可访问
- [ ] manifest 中 `DownloadLink*` / `IconUrl` 指向本仓库 raw URL
- [ ] `RepoUrl` 指向插件源码仓，非 Catalog
- [ ] 未误改其他插件条目

### 8.3 Git 提交范围（单插件发版）

建议每次 commit 仅包含该插件相关变更：

```
catalog.json                                    # 若新增插件
pluginmaster.cn.json
pluginmaster.global.json
plugins/<PluginFolder>/latest-cn.zip
plugins/<PluginFolder>/latest-global.zip        # 若发布 Global
images/<PluginFolder>/icon.png                  # 若有更新
```

Commit message 建议：

```
Release <InternalName> <AssemblyVersion>
```

示例：`Release HeelsDesignLinker 1.2.1.0`

---

## 9. Git 与 `.gitignore`

### 9.1 纳入版本控制

- 所有 `pluginmaster.*.json`
- `catalog.json`
- `plugins/**/latest-cn.zip`、`plugins/**/latest-global.zip`
- `images/**/icon.png`
- `scripts/`、`LICENSE`、`README.md`、`REPOSITORY.md`

### 9.2 忽略项（建议）

```gitignore
# 构建产物（插件源码不在本仓，但脚本临时目录可忽略）
dist/
*.user
.vs/
.idea/

# 默认忽略 zip，再按插件白名单放行
plugins/**
!plugins/**/
!plugins/**/latest-cn.zip
!plugins/**/latest-global.zip
```

### 9.3 分支策略

- 发行始终落在 `main`（与 raw URL 一致）。
- 不在本仓库用分支名区分 CN/Global；双环境由 **两个 manifest 文件** 区分。

---

## 10. 脚本接口约定（供后续实现）

以下为建议的脚本划分，实现时可直接引用本节作为契约。

### 10.1 `scripts/lib/CatalogHelpers.ps1`

共享函数，建议从 `HeelsDesignLinker` 的 `PublishHelpers.ps1` 复用或抽取：

| 函数 | 职责 |
|------|------|
| `Assert-ValidPluginZip` | §7 校验（或复用插件仓 `PublishHelpers.ps1`） |
| `Update-PluginMasterLastUpdate` | 刷新单条 `LastUpdate` |
| `Read-CatalogConfig` | 读取并校验 `catalog.json` |
| `Get-RawBaseUrl` | 返回 `https://raw.githubusercontent.com/{catalogRepo}/{branch}` |
| `Merge-PluginMasterEntry` | 按 `InternalName` 合并单条到数组 |
| `Write-PluginMasterArray` | UTF-8 无 BOM 写回 manifest |

### 10.2 `scripts/publish-plugin.ps1`

参数建议：

```powershell
param(
    [Parameter(Mandatory)]
    [string]$InternalName,
    [string]$CatalogRoot = "$PSScriptRoot\..",
    [string]$DistDir,              # 默认从 WIP 的 dist/ 读取
    [switch]$SkipGlobal,
    [switch]$WhatIf
)
```

行为：

1. 从 `catalog.json` 解析插件配置
2. 校验 `dist/cn/latest.zip`（及可选 `dist/global/latest.zip`）
3. 复制到 `plugins/<PluginFolder>/`
4. 合并 manifest 两条（cn / global）
5. 打印 `git add` / `git commit` 建议命令

### 10.3 `scripts/publish-all.ps1`

遍历 `catalog.json` 中 `enabled: true` 的插件；对每个插件调用其 WIP 的 build + `publish-plugin`。  
**注意：** 全量发版应少见，日常以单插件发版为主。

### 10.4 退出码

| 码 | 含义 |
|----|------|
| 0 | 成功 |
| 1 | 配置错误（catalog.json、路径不存在） |
| 2 | zip 校验失败 |
| 3 | manifest 合并/写入失败 |

---

## 11. 新增插件流程

1. 在 **WorkInProgress** 完成开发与本地测试（§2.3）。
2. 确认 `AssemblyName` / `InternalName` 最终命名（§4.1）。
3. 在 **KKT-Catalog** 的 `catalog.json` 追加条目。
4. 在 WIP / 插件源码仓准备 `images/icon.png`；首次发版时由 release 脚本复制到 Catalog。
5. 在 **WIP / 插件源码仓** `scripts/` 放置 `build-dual.ps1`、`PublishHelpers.ps1`（§2.4）；**不要**把 build 脚本放进 Catalog。
6. 在 WIP 运行 `publish-release.ps1`（内部调用 Catalog 的 `publish-plugin.ps1`，待实现）。
7. 验证 Catalog raw URL 可下载 zip 与 manifest。
8. 更新 Catalog `README.md` 插件列表；插件源码仓 `README` 注明 Catalog 安装 URL。

---

## 12. 从单插件源迁移

以 `HeelsDesignLinker` 为例：

| 项目 | 迁移前 | 迁移后 |
|------|--------|--------|
| 用户 Repo URL | `.../HeelsDesignLinker/main/pluginmaster.cn.json` | `.../KKT-Catalog/main/pluginmaster.cn.json` |
| zip 托管 | `HeelsDesignLinker/plugins/...` | `KKT-Catalog/plugins/HeelsDesignLinker/...` |
| 源码 / Issue | 不变，仍在 `HeelsDesignLinker` | 不变 |

迁移后可在原仓库 README 注明新 URL；原 manifest 可保留一段时间并标记 deprecated，但用户侧应只保留 Catalog 一个源。

---

## 13. 已知插件（维护表）

| InternalName | 源码仓库 | CN | Global | 状态 |
|--------------|----------|----|--------|------|
| `HeelsDesignLinker` | [kyodaikokata/HeelsDesignLinker](https://github.com/kyodaikokata/HeelsDesignLinker) | 是 | 是 | 已迁入 Catalog |
| `SoundMixer` | [kyodaikokata/SoundMixer](https://github.com/kyodaikokata/SoundMixer) | 是 | 是 | 已迁入 Catalog |
| `TerrainIK` | TBD | 是 | 待定 | 开发中 |

> 脚本与 manifest 以 `catalog.json` 为准；上表仅供人类阅读，发版时同步更新。

---

## 14. 参考

- [Dalamud — Publishing to a Custom Repository](https://dalamud.dev/plugin-publishing/custom-repositories)
- 现有实现参考：`HeelsDesignLinker` 仓库中的 `pluginmaster.cn.json`、`scripts/sync-to-release.ps1`、`scripts/lib/PublishHelpers.ps1`

---

*文档版本：与仓库初始化同步。后续若目录或脚本契约变更，请同步更新本节与 `catalog.json` 示例。*
