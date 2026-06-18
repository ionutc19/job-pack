import io
import logging

from fastapi import UploadFile

logger = logging.getLogger(__name__)

ALLOWED_TYPES = {
    "application/pdf": "pdf",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document": "docx",
    "text/plain": "txt",
}

ALLOWED_EXTENSIONS = {"pdf", "docx", "txt"}
MAX_FILE_SIZE = 10 * 1024 * 1024


def _get_extension(filename: str) -> str:
    if "." in filename:
        return filename.rsplit(".", 1)[-1].lower()
    return ""


async def extract_text(file: UploadFile) -> str:
    ext = _get_extension(file.filename or "")

    if ext not in ALLOWED_EXTENSIONS:
        content_type = file.content_type or ""
        ext = ALLOWED_TYPES.get(content_type, "")
        if not ext:
            raise ValueError(
                f"Unsupported file type. Allowed: {', '.join(sorted(ALLOWED_EXTENSIONS))}",
            )

    data = await file.read()
    if len(data) > MAX_FILE_SIZE:
        raise ValueError("File exceeds 10 MB limit")

    try:
        if ext == "pdf":
            return _extract_pdf(data)
        elif ext == "docx":
            return _extract_docx(data)
        else:
            return _extract_txt(data)
    finally:
        del data


def _extract_pdf(data: bytes) -> str:
    from pypdf import PdfReader

    reader = PdfReader(io.BytesIO(data))
    pages = []
    for page in reader.pages:
        text = page.extract_text()
        if text:
            pages.append(text)
    result = "\n\n".join(pages).strip()
    if not result:
        raise ValueError("Could not extract text from PDF")
    return result


def _extract_docx(data: bytes) -> str:
    from docx import Document

    doc = Document(io.BytesIO(data))
    paragraphs = [p.text for p in doc.paragraphs if p.text.strip()]
    result = "\n\n".join(paragraphs).strip()
    if not result:
        raise ValueError("Could not extract text from DOCX")
    return result


def _extract_txt(data: bytes) -> str:
    for encoding in ("utf-8", "utf-8-sig", "latin-1"):
        try:
            return data.decode(encoding).strip()
        except UnicodeDecodeError:
            continue
    raise ValueError("Could not decode text file")
