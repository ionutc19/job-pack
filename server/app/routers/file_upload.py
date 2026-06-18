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
        raise HTTPException(status_code=422, detail=str(e))
    except Exception:
        logger.exception("Unexpected error during text extraction")
        raise HTTPException(
            status_code=500,
            detail="An unexpected error occurred while processing your file. Please try again.",
        )
    finally:
        await file.close()

    return {
        "text": text,
        "filename": file.filename,
        "chars": len(text),
    }
