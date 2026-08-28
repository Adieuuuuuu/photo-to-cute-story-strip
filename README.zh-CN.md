# 照片三变可爱四联画

[English](README.md)

这是一个 Codex Skill。只需提供一张原图，它会生成一张纵向四联图：

1. 原图；
2. 韩系稚拙扁平插画；
3. 有纸张与版画质感的童话绘本；
4. 积木微缩场景。

默认流程支持常见的任意原图比例：先锁定用户点名或画面中最突出的主体，制作并检查统一的 `3:1` 原图面板，再以它为参考生成下面三种风格，最后机械拼接真实原图像素。只有用户明确接受顶部由模型重画时，才采用一次性直出四联画。

## 保留内容

- 用户指定的人物、宠物、动物、菜品或物体，即使画面中还有其他对象；
- 主体身份、数量、姿势或动作、视线、轮廓、镜头方向与菜品的关键细节；
- 标志性颜色、纹理、道具和可识别的背景锚点；
- 固定的媒介顺序与干净的 `3:4` 纵向版式；
- 默认流程中，经确定性缩放与可检查裁切后的真实原图像素。

## 环境要求

- 支持内置生图工具的 Codex。
- Windows 需要 PowerShell、`ffmpeg` 与 `ffprobe`，并能从 `PATH` 调用，用于标准裁图与最终拼接。

内置生图路径不需要 API Key。仓库内的裁图与拼接脚本不会安装依赖，也不会改写原图。

## 安装

使用 Codex 自带的 Skill 安装器。

Windows PowerShell：

```powershell
python "$env:USERPROFILE\.codex\skills\.system\skill-installer\scripts\install-skill-from-github.py" `
  --repo Adieuuuuuu/photo-to-cute-story-strip `
  --path photo-to-cute-story-strip
```

macOS/Linux：

```bash
python ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo Adieuuuuuu/photo-to-cute-story-strip \
  --path photo-to-cute-story-strip
```

安装后请重启 Codex 或新建任务，让 Skill 列表重新加载。

## 使用方法

上传一张原图，然后调用：

```text
$photo-to-cute-story-strip
```

也可以补充限制，例如：

```text
$photo-to-cute-story-strip 只保留中间的大碗菜，排除右侧甜品杯，不要装饰标题。
```

## 工作流程

Skill 会：

1. 检查原图，锁定用户指定主体并提取构图锚点；
2. 用可追溯的焦点与缩放参数制作严格 `3:1` 原图面板，并先做视觉验收；
3. 只生成扁平插画、纹理绘本和积木微缩三个等高面板；
4. 拼接已验收的真实原图面板，并检查精确尺寸、顺序、主体连续性、媒介区分、文字与水印；
5. 只交付一张最终图，并说明所选主体与不可避免的裁切限制。

两个辅助脚本都会拒绝覆盖已有文件，并在结果旁生成 SHA-256 校验清单。

## 仓库结构

```text
photo-to-cute-story-strip/
|-- SKILL.md
|-- agents/
|   `-- openai.yaml
`-- scripts/
    |-- prepare_source_panel.ps1
    `-- compose_story_strip.ps1
```

## 隐私

本仓库不包含用户原图、测试成图、凭证、API Key 或本机绝对路径。你的输入图片不属于 Skill 包的一部分。

## 许可证

[MIT](LICENSE)
