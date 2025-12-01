# 随机Terminal背景图脚本 v2.0
# 每次启动PowerShell时自动更换背景
# 通用版本 - 适用于所有Windows用户
# 新增：时间锁机制，避免频繁切换影响已打开窗口

# ==================== 配置区域 ====================
# 最小切换间隔（秒）- 可根据需要调整
$MinIntervalSeconds = 30  # 默认30秒，可改为60、120等

# 路径配置
$BackgroundsFolder = Join-Path ([Environment]::GetFolderPath('MyPictures')) "PowerShell\Backgrounds"
$SettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$LockFile = Join-Path ([Environment]::GetFolderPath('MyPictures')) "PowerShell\.last-change-time"

# ==================== 时间锁检查 ====================
# 检查上次切换时间
if (Test-Path $LockFile) {
    try {
        $LastChangeTime = Get-Content -Path $LockFile -Raw | ConvertFrom-Json
        $LastTime = [DateTime]::ParseExact($LastChangeTime.Timestamp, "o", $null)
        $ElapsedSeconds = ((Get-Date) - $LastTime).TotalSeconds

        if ($ElapsedSeconds -lt $MinIntervalSeconds) {
            # 时间间隔未到，跳过切换
            # Write-Host "距离上次切换仅 $([Math]::Floor($ElapsedSeconds)) 秒，跳过切换" -ForegroundColor Gray
            return
        }
    }
    catch {
        # 锁文件损坏，继续执行
    }
}

# ==================== 背景切换逻辑 ====================
# 检查背景文件夹是否存在
if (-not (Test-Path $BackgroundsFolder)) {
    # Write-Host "背景图文件夹不存在: $BackgroundsFolder" -ForegroundColor Yellow
    return
}

# 获取所有图片文件
$ImageFiles = Get-ChildItem -Path "$BackgroundsFolder\*" -Include *.png,*.jpg,*.jpeg,*.bmp,*.gif -File

if ($ImageFiles.Count -eq 0) {
    # Write-Host "背景文件夹中没有图片文件" -ForegroundColor Yellow
    return
}

# 随机选择一张图片
$RandomImage = $ImageFiles | Get-Random

# 读取Terminal配置文件
try {
    $Settings = Get-Content -Path $SettingsPath -Raw -ErrorAction Stop | ConvertFrom-Json

    # 查找PowerShell配置项（通过GUID）
    $PowerShellProfile = $Settings.profiles.list | Where-Object { $_.guid -eq "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}" }

    if ($PowerShellProfile) {
        # 检查当前背景是否与即将设置的相同
        $NewBackgroundPath = $RandomImage.FullName -replace '\\', '\\'

        if ($PowerShellProfile.backgroundImage -eq $NewBackgroundPath) {
            # 如果随机选中的图片与当前相同，重新随机（避免"切换"到同一张）
            if ($ImageFiles.Count -gt 1) {
                $OtherImages = $ImageFiles | Where-Object { $_.FullName -ne $RandomImage.FullName }
                $RandomImage = $OtherImages | Get-Random
                $NewBackgroundPath = $RandomImage.FullName -replace '\\', '\\'
            }
        }

        # 更新背景图路径
        $PowerShellProfile.backgroundImage = $NewBackgroundPath

        # 保存配置文件
        $Settings | ConvertTo-Json -Depth 100 | Set-Content -Path $SettingsPath -Encoding UTF8

        # 更新时间锁
        $LockData = @{
            Timestamp = (Get-Date).ToString("o")
            ImagePath = $RandomImage.FullName
            ImageName = $RandomImage.Name
        }
        $LockData | ConvertTo-Json | Set-Content -Path $LockFile -Encoding UTF8

        # 可选：显示切换提示（默认注释掉）
        # Write-Host "✓ 已切换背景: $($RandomImage.Name)" -ForegroundColor Green
    }
}
catch {
    # 静默失败，避免影响PowerShell启动
    # Write-Host "更新背景失败: $_" -ForegroundColor Red
}
