# Mistral AI OCR工具

这是一个使用Mistral AI的OCR技术将PDF文件转换为Markdown格式的简易工具。

## 功能特点

- 自动处理PDF文件夹中的所有PDF文件
- 使用Mistral AI的OCR技术识别文本和图像
- 将识别结果保存为Markdown格式
- 保留图像并将其转换为内嵌的base64格式
- 自动检查运行环境并安装必要依赖

## 使用说明

1. 确保您的系统已安装Python（3.6+）
2. 在PowerShell中执行以下命令：
   ```
   ./start.ps1
   ```
3. 首次运行时，脚本会：
   - 检查Python环境
   - 安装必要的mistralai库
   - 提示输入Mistral API密钥（需要先在[Mistral AI平台](https://mistral.ai)注册获取）
   - 创建必要的文件夹

4. 将您需要处理的PDF文件放入`PDF`文件夹中
5. 转换完成后，所有生成的Markdown文件将保存在`Markdown`文件夹中
