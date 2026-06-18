import logging

from fastapi import APIRouter, HTTPException, UploadFile

from app.services.file_extract_service import extract_text

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/files", tags=["Files"])


@router.post("/extract-text")
async def extract_text_endpoint(file: UploadFile) -> dict:
    if not file.filename:
        raise HTTPException(status_code=400, detail="No file provided")

    try:
        text = await extract_text(file)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        await file.close()

    return {
        "text": text,
        "filename": file.filename,
        "chars": len(text),
    }
