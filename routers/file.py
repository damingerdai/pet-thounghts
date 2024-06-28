import os
import base64
from typing import Annotated
from fastapi import APIRouter, Depends, File, UploadFile
from fastapi.responses import JSONResponse
from langchain_core.messages import HumanMessage
from langchain_google_genai import ChatGoogleGenerativeAI
from services.llm import get_google_generative_ai


router = APIRouter(prefix="/file")

full_path = os.path.join(os.getcwd(), "upload_files")


@router.post("/upload")
async def create_upload_file(llm: Annotated[ChatGoogleGenerativeAI, Depends(get_google_generative_ai)], file: UploadFile = File(...)):
    try:
        if file.filename is None:
            return JSONResponse(status_code=200, content={"message": "file upload sucessfully"})
        image_data = file.file.read()
        encoded_image = base64.b64encode(image_data).decode('utf-8')
        message = HumanMessage(content=[
            {"type": "text", "text": "你是一位熟练的宠物语言翻译员，根据用户传的照片，你识别出是什么宠物，准确猜测宠物的情绪和想法，你可以根据宠物的肢体语言、表情、周围环境猜测宠物想说什么。翻译完后，请根据宠物的语气给出宠物的“声音”，口语自然一点，用中文回答，格式如下：🐶：<这是什么宠物><宠物的想法>。用户上传的图片中，如果没有宠物，则返回“图片中没有宠物~"""},
            {"type": "image_url", "image_url": f"data:image/png;base64,{encoded_image}"}
        ])
        result = llm.invoke([message])
        content = result.content
        return JSONResponse(status_code=200, content={"message": content})
    except Exception as e:
        return JSONResponse(status_code=500, content={"message": "an error accurred during file upload", "error": str(e)})
