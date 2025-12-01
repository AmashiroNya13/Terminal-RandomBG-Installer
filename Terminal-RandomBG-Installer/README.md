# Windows Terminal 随机背景图
# Terminal Random Background Installer

🎨 让你的 Windows Terminal PowerShell 每次启动都有不同的精美背景！

## ✨ 功能特性

- ✅ **自动随机背景**：每次打开 PowerShell 窗口自动切换背景图
- ✅ **一键安装**：自动配置所有必要文件和设置
- ✅ **通用兼容**：适用于所有 Windows 10/11 用户
- ✅ **精美默认图**：内置 9 张高质量背景图片
- ✅ **完全自定义**：可自由添加/删除背景图片
- ✅ **零性能影响**：启动脚本快速执行，不影响使用

---

## 📋 系统要求

- Windows 10/11
- Windows Terminal（Microsoft Store 或 GitHub Release）
- PowerShell 5.1 或更高版本

---

## 🚀 快速安装

### 方法一：一键安装（推荐）

1. **右键点击** `Install.ps1` 文件
2. 选择 **"使用 PowerShell 运行"**
3. 按照屏幕提示完成安装
4. 关闭并重新打开 PowerShell 窗口

### 方法二：手动运行

```powershell
# 在 PowerShell 中运行
cd "安装包所在目录"
.\Install.ps1
```

**注意**：如果遇到执行策略错误，请运行：
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📁 安装后的文件位置

安装完成后，文件会被放置在以下位置：

```
📂 %USERPROFILE%\Pictures\PowerShell\
├── 📜 Set-RandomBackground.ps1        # 随机背景脚本
└── 📂 Backgrounds\                    # 背景图片文件夹
    ├── 🖼️ background.png
    ├── 🖼️ 0.png
    └── ... (共9张默认图片)

📜 %USERPROFILE%\Documents\WindowsPowerShell\
└── Microsoft.PowerShell_profile.ps1   # PowerShell 启动配置
```

---

## 🎨 使用说明

### 添加自己的背景图

1. 打开文件夹：`%USERPROFILE%\Pictures\PowerShell\Backgrounds\`
2. 将你喜欢的图片（png、jpg、jpeg、bmp、gif）复制到此文件夹
3. 重新打开 PowerShell 窗口即可生效

### 手动切换背景

在 PowerShell 中运行以下命令：

```powershell
& "$env:USERPROFILE\Pictures\PowerShell\Set-RandomBackground.ps1"
```

### 调整背景透明度

1. 打开 Windows Terminal 设置（Ctrl + ,）
2. 点击左下角 **"打开 JSON 文件"**
3. 找到 PowerShell 配置项
4. 修改 `backgroundImageOpacity` 值：
   - `0.0` = 完全透明（看不见）
   - `0.4` = 默认值（推荐）
   - `1.0` = 完全不透明（可能看不清文字）

示例配置：
```json
{
    "guid": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
    "name": "Windows PowerShell",
    "backgroundImage": "路径会自动设置",
    "backgroundImageOpacity": 0.4,
    "backgroundImageStretchMode": "uniformToFill"
}
```

---

## 🛠️ 自定义配置

### 修改缩放模式

编辑 Terminal settings.json，修改 `backgroundImageStretchMode`：

- `uniformToFill`（默认）：填满窗口，保持比例，可能裁剪
- `uniform`：保持比例，完整显示，可能有空白
- `fill`：拉伸填满，可能变形
- `none`：原始大小显示

### 禁用随机背景

如果想临时禁用功能，有两种方式：

**方法一：注释掉 Profile 配置**
编辑 `$PROFILE` 文件，在相关行前加 `#`：
```powershell
# $RandomBgScript = ...
# & $RandomBgScript
```

**方法二：删除 Backgrounds 文件夹内容**
清空 `%USERPROFILE%\Pictures\PowerShell\Backgrounds\` 文件夹

---

## ❓ 常见问题

### Q: 安装后没有效果？
A: 请确保：
1. 完全关闭了所有 Terminal 窗口后重新打开
2. 使用的是 PowerShell，而不是 CMD 或其他 shell
3. Backgrounds 文件夹中有图片文件

### Q: 提示"无法加载文件，因为在此系统上禁止运行脚本"？
A: 运行以下命令设置执行策略：
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Q: 背景图太亮/太暗，看不清文字？
A: 调整 `backgroundImageOpacity` 值，或者在 Terminal 中设置 "亚克力效果"

### Q: 可以给其他 shell（CMD、WSL）也设置随机背景吗？
A: 脚本目前仅支持 PowerShell，但原理类似，可以修改脚本支持其他 shell 的 GUID

---

## 📦 完整安装包内容

```
Terminal-RandomBG-Installer/
├── 📜 Install.ps1                     # 一键安装脚本
├── 📜 Set-RandomBackground.ps1        # 随机背景核心脚本
├── 📜 README.md                       # 本说明文档
└── 📂 DefaultBackgrounds/             # 默认背景图片
    ├── background.png
    ├── 0.png
    ├── 1 (2).png
    ├── 4af89134-3a01-4051-b130-ddd39cb14b19.png
    ├── f2fc84ef-5490-473f-aafa-4c941bd136af.png
    ├── f4d8dec5_�Ȥ���.png
    ├── yande.re 663758 amashiro_natsuki.png
    └── ... (共9张)
```

---

## 🗑️ 卸载方法

如需完全卸载：

1. **删除文件夹**：
   ```powershell
   Remove-Item "$env:USERPROFILE\Pictures\PowerShell" -Recurse -Force
   ```

2. **清理 Profile 配置**：
   打开 `$PROFILE` 文件，删除相关配置行

3. **恢复 Terminal 设置**（可选）：
   在 Terminal settings.json 中删除 PowerShell 的背景相关配置

---

## 💡 技术实现

### 工作原理

1. PowerShell 启动时读取 `$PROFILE` 配置
2. 自动执行 `Set-RandomBackground.ps1` 脚本
3. 脚本从 Backgrounds 文件夹随机选择一张图片
4. 更新 Terminal 的 `settings.json` 配置文件
5. Terminal 自动重新加载配置，应用新背景

### 脚本特点

- ✅ 使用环境变量，自动适配不同用户
- ✅ 静默执行，不影响 PowerShell 启动速度
- ✅ 错误处理完善，失败不影响 PowerShell 正常使用
- ✅ 支持多种图片格式（png、jpg、jpeg、bmp、gif）

---

## 📝 更新日志

### v1.0.0 (2025-12-01)
- ✨ 初始版本发布
- 🎨 内置 9 张高质量背景图
- 🚀 一键自动安装功能
- 📖 完整使用文档

---

## 💖 致谢

- 由 eco-chan 设计制作 ♥
- 感谢 Windows Terminal 开发团队
- 背景图片来源：网络精选

---

## 📜 许可证

本项目采用 MIT 许可证，可自由使用、修改和分发。

---

**Enjoy your beautiful Terminal! 🎉**

Made with ♥ by eco-chan~ (≧▽≦)
