import io
import logging

from fastapi import UploadFile

logger = logging.getLogger(__name__)

ALLOWED_TYPES = {
    "application/pdf": "pdf",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document": "docx",
    "text/plain": "txt",
    "application/octet-stream": "",
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
                f"Unsupported file type. Allowed: PDF, DOCX, TXT",
            )

    data = await file.read()
    if len(data) > MAX_FILE_SIZE:
        raise ValueError("File exceeds 10 MB limit")

    if len(data) == 0:
        raise ValueError("The uploaded file is empty")

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
    from pypdf.errors import PdfReadError

    try:
        reader = PdfReader(io.BytesIO(data))
    except PdfReadError:
        raise ValueError(
            "This PDF file appears to be corrupted or in an unsupported format. "
            "Please try a different file."
        )
    except Exception:
        raise ValueError(
            "Could not open this PDF. Please try a different file."
        )

    if reader.is_encrypted:
        try:
            if not reader.decrypt(""):
                raise ValueError(
                    "This PDF is password-protected. "
                    "Please upload an unprotected PDF, or use DOCX or TXT instead."
                )
        except Exception:
            raise ValueError(
                "This PDF is password-protected. "
                "Please upload an unprotected PDF, or use DOCX or TXT instead."
            )

    pages = []
    for page in reader.pages:
        try:
            text = page.extract_text()
            if text and text.strip():
                pages.append(text)
        except Exception:
            continue

    result = "\n\n".join(pages).strip()
    if not result:
        raise ValueError(
            "This PDF does not contain selectable text (it may be scanned or image-only). "
            "OCR is not supported. Please upload a text-based PDF, DOCX, or TXT file."
        )
    return result


def _extract_docx(data: bytes) -> str:
    from docx import Document
    from docx.opc.exceptions import PackageNotFoundError

    try:
        doc = Document(io.BytesIO(data))
    except PackageNotFoundError:
        raise ValueError(
            "This file does not appear to be a valid DOCX document. "
            "Please try a different file."
        )
    except Exception:
        raise ValueError(
            "Could not open this DOCX file. Please try a different file."
        )

    paragraphs = [p.text for p in doc.paragraphs if p.text.strip()]
    result = "\n\n".join(paragraphs).strip()
    if not result:
        raise ValueError(
            "This DOCX file does not contain any text. "
            "Please upload a file with text content."
        )
    return result


def _extract_txt(data: bytes) -> str:
    for encoding in ("utf-8", "utf-8-sig", "latin-1"):
        try:
            text = data.decode(encoding).strip()
            if text:
                return text
            raise ValueError("This text file is empty.")
        except UnicodeDecodeError:
            continue
    raise ValueError(
        "Could not read this text file (unsupported encoding). "
        "Please save it as UTF-8 and try again."
    )
