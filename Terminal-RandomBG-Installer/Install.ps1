# ========================================
# Windows Terminal 随机背景图安装脚本
# Terminal Random Background Installer
# ========================================
# 一键安装，自动配置随机背景功能
# Made with ♥ by eco-chan~
# ========================================

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Terminal Random Background" -ForegroundColor Cyan
Write-Host "  随机背景图安装程序" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 获取路径
$PicturesPath = [Environment]::GetFolderPath('MyPictures')
$InstallPath = Join-Path $PicturesPath "PowerShell"
$BackgroundsPath = Join-Path $InstallPath "Backgrounds"
$ScriptPath = Join-Path $InstallPath "Set-RandomBackground.ps1"
$InstallerDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TerminalSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# 检查Windows Terminal是否安装
Write-Host "[1/6] 检查 Windows Terminal..." -ForegroundColor Yellow
if (-not (Test-Path $TerminalSettingsPath)) {
    Write-Host "    ❌ 未检测到 Windows Terminal" -ForegroundColor Red
    Write-Host "    请先安装 Windows Terminal: https://aka.ms/terminal" -ForegroundColor Red
    Write-Host ""
    Read-Host "按回车键退出"
    exit
}
Write-Host "    ✓ Windows Terminal 已安装" -ForegroundColor Green
Write-Host ""

# 创建文件夹结构
Write-Host "[2/6] 创建文件夹结构..." -ForegroundColor Yellow
try {
    New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null
    New-Item -ItemType Directory -Force -Path $BackgroundsPath | Out-Null
    Write-Host "    ✓ 文件夹创建完成" -ForegroundColor Green
    Write-Host "      安装路径: $InstallPath" -ForegroundColor Gray
}
catch {
    Write-Host "    ❌ 创建文件夹失败: $_" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit
}
Write-Host ""

# 复制脚本文件
Write-Host "[3/6] 安装随机背景脚本..." -ForegroundColor Yellow
$SourceScript = Join-Path $InstallerDir "Set-RandomBackground.ps1"
if (Test-Path $SourceScript) {
    Copy-Item -Path $SourceScript -Destination $ScriptPath -Force
    Write-Host "    ✓ 脚本安装完成" -ForegroundColor Green
}
else {
    Write-Host "    ❌ 未找到脚本文件" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit
}
Write-Host ""

# 复制默认背景图片（如果存在）
Write-Host "[4/6] 复制默认背景图片..." -ForegroundColor Yellow
$DefaultBgFolder = Join-Path $InstallerDir "DefaultBackgrounds"
if (Test-Path $DefaultBgFolder) {
    $ImageFiles = Get-ChildItem -Path $DefaultBgFolder -Include *.png,*.jpg,*.jpeg,*.bmp,*.gif -Recurse
    if ($ImageFiles.Count -gt 0) {
        foreach ($img in $ImageFiles) {
            Copy-Item -Path $img.FullName -Destination $BackgroundsPath -Force
        }
        Write-Host "    ✓ 已复制 $($ImageFiles.Count) 张背景图片" -ForegroundColor Green
    }
    else {
        Write-Host "    ⚠ 未找到默认背景图片，请手动添加图片到:" -ForegroundColor Yellow
        Write-Host "      $BackgroundsPath" -ForegroundColor Gray
    }
}
else {
    Write-Host "    ⚠ 未找到默认背景文件夹，请手动添加图片到:" -ForegroundColor Yellow
    Write-Host "      $BackgroundsPath" -ForegroundColor Gray
}
Write-Host ""

# 配置PowerShell Profile
Write-Host "[5/6] 配置 PowerShell 启动脚本..." -ForegroundColor Yellow
$ProfilePath = $PROFILE
$ProfileDir = Split-Path -Parent $ProfilePath

# 创建Profile目录（如果不存在）
if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Force -Path $ProfileDir | Out-Null
}

# 创建或更新Profile文件
$ProfileContent = @"
# ====================================
# Random Terminal Background
# ====================================
`$RandomBgScript = Join-Path ([Environment]::GetFolderPath('MyPictures')) "PowerShell\Set-RandomBackground.ps1"
if (Test-Path `$RandomBgScript) {
    & `$RandomBgScript
}
"@

if (Test-Path $ProfilePath) {
    $ExistingContent = Get-Content -Path $ProfilePath -Raw
    if ($ExistingContent -notlike "*Set-RandomBackground.ps1*") {
        Add-Content -Path $ProfilePath -Value "`n$ProfileContent"
        Write-Host "    ✓ 已添加到现有 Profile" -ForegroundColor Green
    }
    else {
        Write-Host "    ✓ Profile 已包含配置（跳过）" -ForegroundColor Green
    }
}
else {
    Set-Content -Path $ProfilePath -Value $ProfileContent
    Write-Host "    ✓ Profile 创建完成" -ForegroundColor Green
}
Write-Host ""

# 配置Terminal背景设置
Write-Host "[6/6] 配置 Terminal 背景效果..." -ForegroundColor Yellow
try {
    $Settings = Get-Content -Path $TerminalSettingsPath -Raw | ConvertFrom-Json
    $PowerShellProfile = $Settings.profiles.list | Where-Object { $_.guid -eq "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}" }

    if ($PowerShellProfile) {
        # 检查是否已配置背景
        if (-not $PowerShellProfile.backgroundImageOpacity) {
            $PowerShellProfile | Add-Member -NotePropertyName "backgroundImageOpacity" -NotePropertyValue 0.4 -Force
            $PowerShellProfile | Add-Member -NotePropertyName "backgroundImageStretchMode" -NotePropertyValue "uniformToFill" -Force

            # 保存配置
            $Settings | ConvertTo-Json -Depth 100 | Set-Content -Path $TerminalSettingsPath -Encoding UTF8
            Write-Host "    ✓ 已配置背景透明度和缩放模式" -ForegroundColor Green
        }
        else {
            Write-Host "    ✓ 背景配置已存在（保持原设置）" -ForegroundColor Green
        }
    }
}
catch {
    Write-Host "    ⚠ 配置Terminal失败，将在首次启动时自动配置" -ForegroundColor Yellow
}
Write-Host ""

# 完成
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  ✨ 安装完成！" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📝 使用说明：" -ForegroundColor Yellow
Write-Host "  1. 关闭并重新打开 PowerShell 窗口" -ForegroundColor White
Write-Host "  2. 每次打开新窗口都会随机切换背景" -ForegroundColor White
Write-Host "  3. 添加更多背景图到此文件夹：" -ForegroundColor White
Write-Host "     $BackgroundsPath" -ForegroundColor Gray
Write-Host ""
Write-Host "🎨 自定义设置：" -ForegroundColor Yellow
Write-Host "  • 调整透明度：编辑 Terminal settings.json" -ForegroundColor White
Write-Host "  • backgroundImageOpacity: 0.4 (范围 0.0-1.0)" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 手动切换背景：" -ForegroundColor Yellow
Write-Host "  在 PowerShell 中运行: & '$ScriptPath'" -ForegroundColor Gray
Write-Host ""
Read-Host "按回车键关闭"
