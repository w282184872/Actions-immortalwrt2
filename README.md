# Actions-immortalwrt 使用说明

基于 GitHub Actions 的在线云编译方案，一键自动编译 ImmortalWrt 固件，无需本地 Linux 编译环境。

项目地址：<https://github.com/w282184872/Actions-immortalwrt>

---

## 1. 项目简介

本仓库基于 [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt) 模板改造，面向 hanwckf 维护的 `immortalwrt-mt798x` 源码仓库，为以下两台 MT798x 机型提供开箱即用的固件云编译：

| 设备 | 厂商 | Workflow 名称 | 默认后台地址 | 默认主机名 |
|------|------|--------------|-------------|-----------|
| 小米 AX3000T | Xiaomi | 编译 AX3000T OpenWrt 固件 | `192.168.3.1` | Xiaomi-AX3000T |
| ABT ASR3000 | ABT | 编译 ASR3000 OpenWrt 固件 | `192.168.6.1` | ASR3000 |

两台设备共用同一套源码与编译流程，通过不同的 `.config` 配置文件和 workflow 变量实现差异化编译。

## 2. 目录结构

```
Actions-immortalwrt/
├── .github/workflows/
│   ├── build-AX3000T.yml        # 小米 AX3000T 固件编译工作流
│   ├── build-ASR3000.yml        # ABT ASR3000 固件编译工作流
│   └── update-checker.yml       # 源码更新检查工作流
├── ax3000t.config               # AX3000T 固件编译配置（make menuconfig 导出）
├── asr3000.config               # ASR3000 固件编译配置
├── diy-part1.sh                 # DIY 脚本（更新 feeds 前执行）
├── diy-part2.sh                 # DIY 脚本（更新 feeds 后执行）
├── README.md                    # 仓库说明
└── LICENSE                      # MIT 许可证
```

## 3. 快速开始

### 3.1 创建自己的仓库

1. 点击本仓库页面右上角 **Use this template**，创建你自己的新仓库（建议设为私有）。
2. 在仓库 **Settings → Actions → General** 中确保 Actions 处于启用状态。

### 3.2 触发编译

- 打开仓库 **Actions** 页面，选择「编译 AX3000T OpenWrt 固件」或「编译 ASR3000 OpenWrt 固件」。
- 点击 **Run workflow** 按钮，即可开始编译。

> 说明：两个 workflow 默认无手动输入参数，直接点击运行即可。触发方式还支持 `repository_dispatch`（配合 update-checker 自动触发）。

### 3.3 获取固件

编译完成后（约 1~2 小时，具体取决于配置），有两种方式获取固件：

- **Releases 页面**：工作流会自动创建带时间戳的 Release 并上传固件（保留最近 3 个，旧的自动清理）。
- **Artifacts 工件**：每次运行右上角的 Artifacts 中会生成 `OpenWrt_firmware_*` 压缩包，点击即可下载。

## 4. 编译流程说明

整个编译流程（以 build-AX3000T.yml 为例）按以下步骤执行：

| 步骤 | 说明 |
|------|------|
| 初始化编译环境 | 清理 runner 缓存，安装 OpenWrt 全套编译依赖 |
| 克隆源代码 | 克隆 `hanwckf/immortalwrt-mt798x`（分支 `openwrt-21.02`）到 `/workdir/openwrt` |
| 加载自定义 feeds | 应用 `diy-part1.sh`，追加第三方软件源 |
| 更新 / 安装 feeds | `./scripts/feeds update -a` + `./scripts/feeds install -a` |
| 加载自定义配置 | 将 `ax3000t.config` 写入 `.config`，应用 `diy-part2.sh` |
| 下载软件包 | `make defconfig` + `make download -j8`，清理损坏的下载文件 |
| 编译固件 | `make -j$(nproc)`，失败自动降级 `-j1` 重试，可输出详细日志 |
| 上传与发布 | 上传 Artifacts、创建 Release、清理旧运行记录与旧 Release |

### 环境变量速查（workflow 顶部 env）

| 变量 | AX3000T | ASR3000 | 说明 |
|------|---------|---------|------|
| `REPO_URL` | hanwckf/immortalwrt-mt798x | 同左 | 源码仓库 |
| `REPO_BRANCH` | openwrt-21.02 | 同左 | 源码分支 |
| `CONFIG_FILE` | ax3000t.config | asr3000.config | 编译配置文件名 |
| `ROUTER_IP` | 192.168.3.1 | 192.168.6.1 | 默认后台 IP（diy-part2.sh 读取） |
| `ROUTER_NAME` | Xiaomi-AX3000T | ASR3000 | 默认主机名（diy-part2.sh 读取） |
| `UPLOAD_BIN_DIR` | false | false | 是否上传完整 bin 目录 |
| `UPLOAD_FIRMWARE` | true | true | 是否上传固件到 Artifacts |
| `UPLOAD_RELEASE` | true | true | 是否发布到 Releases |

## 5. DIY 定制脚本

### diy-part1.sh（更新 feeds 前执行）

- 默认追加 `helloworld` 软件源（`fw876/helloworld`），可自行取消注释启用 `passwall` 源，或添加其他第三方源。

### diy-part2.sh（更新 feeds 后执行）

- **修改默认后台 IP**：将源码默认的 `192.168.1.1` 替换为 workflow 中 `$ROUTER_IP` 指定的地址。
- **修改默认主机名**：将默认 `OpenWrt` / `ImmortalWrt` 替换为 `$ROUTER_NAME`。
- **替换默认主题**：默认 `bootstrap` 主题替换为 `argon` 主题。

> 扩展提示：如需加入更多自定义（默认密码、时区、预装插件等），可按需在此脚本追加 `sed` 命令，或参考其他云编译项目的惯例新增 `files/` 目录覆盖源码文件（workflow 已内置对 `files` 目录的支持）。

## 6. 自定义软件包配置

两台设备的固件内容由各自的 `.config` 文件决定：

- `ax3000t.config`、`asr3000.config` 是由 `make menuconfig` 导出的完整配置，包含目标机型、内核选项与预装软件包（LUCI 应用、驱动等）。
- 如需增删软件包：在本地用同一源码分支执行 `make menuconfig` 勾选后导出，或直接编辑对应 `.config` 中的 `CONFIG_PACKAGE_*` 项，然后推送更新即可。

## 7. 源码更新检查（update-checker）

`update-checker.yml` 用于检测上游源码更新并自动触发重新编译：

- 当前监控源为 `hanwckf/immortalwrt-mt798x`（openwrt-21.02 分支），与编译使用的源码仓库一致。
- 定时调度（`schedule`）默认注释，当前仅在 Actions 页面手动运行，或可取消注释恢复每 18 小时自动检查。
- 检测到上游提交变化后，通过 `repository_dispatch` 事件触发「编译 AX3000T / ASR3000」工作流。

## 8. 注意事项

1. **刷机有风险**：请先确认设备已刷入适配的引导环境（本仓库机型基于不死 U-Boot / ubootmod 布局使用），固件仅适用于对应机型，请勿交叉刷写。
2. **首次编译耗时较长**：GitHub Actions 免费额度对公共仓库充足；私有仓库有每月 2000 分钟限制，多次全量编译可能耗尽配额。
3. **Release 自动清理**：Releases 仅保留最近 3 个，工作流运行记录仅保留 2 条，如需长期留存请及时下载到本地。
4. **修改源码仓库**：换用其他 OpenWrt 源码时，只需修改 workflow 中的 `REPO_URL` / `REPO_BRANCH`，并同步更新 `.config`。
5. **编译失败排查**：可在 workflow 运行页查看失败步骤日志；若为软件包下载失败，通常是网络原因，直接重新运行即可。

## 9. 许可证

本项目基于 [MIT](https://github.com/w282184872/Actions-immortalwrt/blob/main/LICENSE) 许可证开源，核心模板版权归 [P3TERX](https://p3terx.com) 所有。