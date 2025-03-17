# 设置编码为UTF8，以支持中文
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 1. 检查Python环境
Write-Host "正在检查Python环境..." -ForegroundColor Cyan
$pythonInstalled = $null
try {
    $pythonInstalled = python --version
}
catch {
    try {
        $pythonInstalled = python3 --version
    }
    catch {
        Write-Host "未检测到Python环境，请先安装Python后再运行此脚本。" -ForegroundColor Red
        Read-Host "按回车键退出"
        exit
    }
}
Write-Host "Python环境检测成功: $pythonInstalled" -ForegroundColor Green

# 2. 检查mistralai库
Write-Host "正在检查mistralai库..." -ForegroundColor Cyan
$mistralInstalled = $false
try {
    $pipOutput = python -m pip list | Select-String -Pattern "mistralai"
    if ($pipOutput) {
        $mistralInstalled = $true
    }
}
catch {
    try {
        $pipOutput = python3 -m pip list | Select-String -Pattern "mistralai"
        if ($pipOutput) {
            $mistralInstalled = $true
        }
    }
    catch {
        $mistralInstalled = $false
    }
}

if (-not $mistralInstalled) {
    Write-Host "未检测到mistralai库，正在安装..." -ForegroundColor Yellow
    try {
        python -m pip install mistralai
    }
    catch {
        try {
            python3 -m pip install mistralai
        }
        catch {
            Write-Host "安装mistralai库失败，请检查网络连接或手动安装：pip install mistralai" -ForegroundColor Red
            Read-Host "按回车键退出"
            exit
        }
    }
    Write-Host "mistralai库安装成功！" -ForegroundColor Green
}
else {
    Write-Host "mistralai库已安装！" -ForegroundColor Green
}

# 3. 检查key.txt文件
Write-Host "检查Mistral API密钥..." -ForegroundColor Cyan
$keyPath = Join-Path $PSScriptRoot "key.txt"
if (-not (Test-Path $keyPath)) {
    Write-Host "未找到key.txt文件，请输入您的Mistral API密钥:" -ForegroundColor Yellow
    $apiKey = Read-Host
    if ([string]::IsNullOrWhiteSpace($apiKey)) {
        Write-Host "未输入有效的API密钥，程序退出" -ForegroundColor Red
        exit
    }
    $apiKey | Out-File -FilePath $keyPath -Encoding utf8
    Write-Host "已保存API密钥到key.txt" -ForegroundColor Green
}
else {
    Write-Host "已找到key.txt文件" -ForegroundColor Green
}

# 4. 检查PDF文件夹
Write-Host "检查PDF文件夹..." -ForegroundColor Cyan
$pdfFolder = Join-Path $PSScriptRoot "PDF"
if (-not (Test-Path $pdfFolder)) {
    Write-Host "未找到PDF文件夹，正在创建..." -ForegroundColor Yellow
    New-Item -Path $pdfFolder -ItemType Directory | Out-Null
    Write-Host "PDF文件夹已创建，请将您的PDF文件放入该文件夹中" -ForegroundColor Green
}
else {
    Write-Host "已找到PDF文件夹" -ForegroundColor Green
    $pdfFiles = Get-ChildItem -Path $pdfFolder -Filter "*.pdf"
    if ($pdfFiles.Count -eq 0) {
        Write-Host "PDF文件夹中没有PDF文件，请将您的PDF文件放入该文件夹中" -ForegroundColor Yellow
    }
    else {
        Write-Host "PDF文件夹中发现 $($pdfFiles.Count) 个PDF文件" -ForegroundColor Green
    }
}

# 5. 提示按回车继续
Write-Host "`n准备就绪！请确保已将PDF文件放入PDF文件夹中" -ForegroundColor Cyan
Read-Host "按回车键开始OCR转换"

# 6. 执行MistralOCR.py
Write-Host "正在启动OCR转换..." -ForegroundColor Cyan
try {
    python MistralOCR.py
}
catch {
    try {
        python3 MistralOCR.py
    }
    catch {
        Write-Host "执行MistralOCR.py失败，请确保该脚本文件存在且无错误" -ForegroundColor Red
    }
}

Write-Host "OCR处理完成！" -ForegroundColor Green
Read-Host "按回车键退出"
