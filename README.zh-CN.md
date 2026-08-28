# 照片三变可爱四联画

[English](README.md)

这是一个 Codex Skill。只需提供一张原图，它会生成一张纵向四联图：

1. 原图；
2. 韩系稚拙扁平插画；
3. 有纸张与版画质感的童话绘本；
4. 积木微缩场景。

Skill 会优先尝试一次性生成完整四联画，以保持光色与构图统一。如果生成后的第一格偏离原图，或者用户明确要求顶部必须是真实原图，它会改为生成下面三格，再确定性地拼接原图裁切。

## 保留内容

- 主体身份、数量、姿势或动作、视线、轮廓与镜头方向；
- 标志性颜色、纹理、道具和可识别的背景锚点；
- 固定的媒介顺序与干净的 `3:4` 纵向版式；
- 保真模式下，经确定性缩放与裁切后的真实原图像素。

## 环境要求

- 支持内置生图工具的 Codex。
- Windows 保真回退模式额外需要：PowerShell、`ffmpeg` 与 `ffprobe`，并能从 `PATH` 调用。

默认的一次直出路径不需要 API Key。仓库内的拼接脚本不会安装依赖，也不会改写原图。

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
$photo-to-cute-story-strip 顶部必须使用真实原图，不要装饰标题。
```

## 工作流程

Skill 会：

1. 检查原图，提取主体身份与构图锚点；
2. 优先一次性生成完整四联图；
3. 验收格数、顺序、原图保真度、主体连续性、媒介区分、肢体、文字与水印；
4. 顶部原图不可信时，自动切换到确定性保真拼接；
5. 只交付一张最终图，并说明采用了哪条路径。

保真拼接脚本拒绝覆盖已有文件，并会在最终图片旁生成 SHA-256 校验清单。

## 仓库结构

```text
photo-to-cute-story-strip/
|-- SKILL.md
|-- agents/
|   `-- openai.yaml
`-- scripts/
    `-- compose_story_strip.ps1
```

## 隐私

本仓库不包含用户原图、测试成图、凭证、API Key 或本机绝对路径。你的输入图片不属于 Skill 包的一部分。

## 许可证

[MIT](LICENSE)
