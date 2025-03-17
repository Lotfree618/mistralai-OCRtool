from mistralai import Mistral, DocumentURLChunk, OCRResponse
import os
import glob

# 从key.txt读取API密钥
with open("key.txt", "r") as f:
    api_key = f.read().strip()

# 初始化Mistral客户端
client = Mistral(api_key=api_key)

# 确保输出目录存在
os.makedirs("Markdown", exist_ok=True)

# 清空Markdown文件夹
for file in glob.glob("Markdown/*"):
    os.remove(file)

# 获取所有PDF文件路径
pdf_files = glob.glob("PDF/*.pdf")

# 定义处理图片的函数
def replace_images_in_markdown(markdown_str: str, images_dict: dict) -> str:
    for img_name, base64_str in images_dict.items():
        markdown_str = markdown_str.replace(f"![{img_name}]({img_name})", f"![{img_name}]({base64_str})")
    return markdown_str

# 定义获取合并markdown的函数
def get_combined_markdown(ocr_response: OCRResponse) -> str:
    markdowns = []
    for page in ocr_response.pages:
        image_data = {}
        for img in page.images:
            image_data[img.id] = img.image_base64
        markdowns.append(replace_images_in_markdown(page.markdown, image_data))
    
    return "\n\n".join(markdowns)

for pdf_path in pdf_files:
    # 获取文件名（不含扩展名）
    file_name = os.path.basename(pdf_path)
    base_name = os.path.splitext(file_name)[0]
    
    print(f"处理文件: {file_name}")
    
    # 上传PDF文件进行OCR处理
    uploaded_pdf = client.files.upload(
        file={
            "file_name": file_name,
            "content": open(pdf_path, "rb"),
        },
        purpose="ocr"
    )
    
    # 获取OCR结果
    signed_url = client.files.get_signed_url(file_id=uploaded_pdf.id)

    ocr_response = client.ocr.process(
        model="mistral-ocr-latest",
        document=DocumentURLChunk(document_url=signed_url.url),
        include_image_base64=True
    )
    
    # 将结果保存为Markdown文件
    output_path = os.path.join("Markdown", f"{base_name}.md")
    with open(output_path, "w", encoding="utf-8") as f:
        combined_markdown = get_combined_markdown(ocr_response)
        f.write(combined_markdown)
    
    print(f"已保存到: {output_path}")

print("所有PDF文件处理完成！")
