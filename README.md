# MapEditor —— 虚空三态地图可视化编辑器

本地 Web 可视化地图编辑器：在浏览器中编辑 / 生成 / 导入导出三态网格地图（空格 / 障碍 / 虚空），并调用四种「模拟玩家决策」算法对地图做最短路延长决策，支持逐帧重放动画与虚空语义双投影实验台。

- **零依赖单机运行**：.NET 10 SDK + 任意现代浏览器，无需数据库 / 外部服务
- **四种决策引擎**：元策略（快）、构造式（强）、束搜索、真贪心——全部支持虚空三态
- **内置防线四件套**：导出往返自检、l 值交叉核对、坐标帧回声、断帧自检

## 目录结构

```
├── start_editor.bat        # 一键构建 + 启动（自动开浏览器）
├── build_all.bat           # 全量构建四个项目
├── docs/
│   ├── fmg2-format.md      # FMG1 / FMG2 v1.1 地图格式规范
│   ├── engines.md          # 四种决策引擎说明与 CLI 用法
│   └── flexiblemapgen.md   # 生成器参数与难度指标说明
├── skills/                 # 本链路沉淀的 5 条工程纪律（SKILL.md）
└── src/
    ├── MapEditor/          # harness（本地 Web 宿主）+ 前端单文件 index.html
    ├── MetaPlayer/         # 元策略决策引擎
    ├── RMG_V1_1/           # 构造式决策引擎（induced）+ 蛇形回退
    ├── FlexibleMapGen/     # 地图生成器 + 束搜索/真贪心决策器
    └── meta/memory/best.json   # 元策略训练权重（引擎必需资产）
```

## 快速开始

环境要求：[.NET 10 SDK](https://dotnet.microsoft.com/)，Windows / Linux / macOS 均可。

```bat
build_all.bat        # 或逐个: dotnet build src/MapEditor -c Release 等
start_editor.bat     # 构建 MapEditor 并启动 harness，自动打开浏览器
```

harness 默认监听 `http://127.0.0.1:5099`。首次运行会自动生成一张 16×16 随机地图。

> 注意：请在普通终端（cmd / PowerShell 会话）启动 harness。某些后台任务管理器启动的进程，其子进程派生可能异常（表现为求解一直等待），重启即可恢复。

## 界面操作

| 操作 | 方式 |
|---|---|
| 平移地图 | **长按鼠标右键**拖动（仅地图范围内生效） |
| 缩放地图 | 鼠标滚轮（以光标为锚点） |
| 编辑画笔 | 左键绘制：空格 / 障碍 / 虚空橡皮 / 出怪口 S / 入怪口 E |
| 生成地图 | 填尺寸（`WxH` 格式）、seed 序列、虚空雕刻数、形态后点「生成」 |
| 决策演示 | 选引擎、填预算 n → 求解 → ◀ / ▶ / ▶\| 逐帧重放，状态栏实时显示步号与 L 值 |
| 双投影实验 | 「虚空语义实验台」：原生三态 vs 虚空→障碍 vs 虚空→空格 三方对照，自动统计越界 |
| 导入导出 | FMG1（矩形宇宙）/ FMG2（含虚空）单行文本 |

界面细节：

- 地图在**固定尺寸显示框**内居中展示（初始自适应缩放），框内只显示地图本身
- 当前地图的 seed 常驻状态栏，并同步在 seed 输入槽中，直到地图被重新生成 / 导入
- 尺寸输入实时校验（`数值x数值`），不合法红框提示并拦截生成

## 三态语义（虚空）

| 状态 | 通行 | 决策 | 语义 |
|---|---|---|---|
| 空格（白） | 可 | 可 | 存在 |
| 障碍（黑） | 不可 | 可（放置→空格 / 移除→障碍） | 存在 |
| 虚空（浅灰） | 不可 | **不可**（不可放置、不可移除） | **按不存在处理** |

虚空不是「可挖的墙」也不是「可选的空格」——所有引擎均强制此语义（详见 docs/fmg2-format.md）。

## 决策引擎一览

| 引擎 | 项目 | 特征 | 耗时 |
|---|---|---|---|
| 元策略 | MetaPlayer | 训练权重的近似贪心，贴路径单格放置 | 通常 <1s |
| 构造式 | RMG_V1_1 (induced) | 无弦路径构造 + 蛇形回退，能力最强 | ~60s 固定搜索预算 + 回退 |
| 束搜索 | FlexibleMapGen (beam) | place+remove 复合动作束搜索 | 通常 <1s |
| 真贪心 | FlexibleMapGen (greedy) | 纯封堵贪心（对照基线） | 通常 <1s |

计算不限时：引擎计算无超时上限，等待期状态栏实时显示进度百分比。CLI 用法详见 [docs/engines.md](docs/engines.md)。

## 地图格式

```
FMG1,seed,W,H,Sx,Sy,Ex,Ey,L0,deceived,obs=x:y|x:y|...
FMG2,seed,W,H,Sx,Sy,Ex,Ey,L0,deceived,obs=x:y|...,void=x:y|...
```

坐标系以地图左上角为原点 (0,0)。完整规范（缺省语义、冲突拒绝、版本演进）见 [docs/fmg2-format.md](docs/fmg2-format.md)。

## 工程纪律（skills/）

本仓库在开发过程中沉淀了 5 条可直接复用的工程纪律（每条含实施步骤与验收标准，见 `skills/`）：

- [boundary-invariant-check](skills/boundary-invariant-check/SKILL.md) —— 跨层边界不变量交叉校验
- [byte-roundtrip-selftest](skills/byte-roundtrip-selftest/SKILL.md) —— 序列化字节级往返自检
- [explicit-frame-discipline](skills/explicit-frame-discipline/SKILL.md) —— 显式坐标帧纪律
- [fullchain-property-probe](skills/fullchain-property-probe/SKILL.md) —— 全链性质回归探针
- [structural-fault-discipline](skills/structural-fault-discipline/SKILL.md) —— 结构防错三纪律
