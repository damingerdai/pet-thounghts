import os
from fastapi import APIRouter, File, UploadFile
from fastapi.responses import JSONResponse

router = APIRouter(prefix="/file")

full_path = os.path.join(os.getcwd(), "upload_files")


@router.post("/upload")
async def create_upload_file(file: UploadFile = File(...)):
    try:
        if file.filename is None:
            return JSONResponse(status_code=200, content={"message": "file upload sucessfully"})
        file_location = os.path.join(full_path, file.filename)
        with open(file_location, "wb") as file_object:
            file_object.write(file.file.read())
        return JSONResponse(status_code=200, content={"message": "file upload successfully", "file_path": file_location})
    except Exception as e:
        return JSONResponse(status_code=500, content={"message": "an error accurred during file upload", "error": str(e)})
