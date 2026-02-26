import base64
import hashlib
from app.core.config import settings


def _derive_key(secret: str) -> bytes:
    digest = hashlib.sha256(secret.encode("utf-8")).digest()
    return digest


def encrypt_bytes(data: bytes) -> bytes:
    key = _derive_key(settings.DRM_SECRET)
    return bytes(b ^ key[i % len(key)] for i, b in enumerate(data))


def decrypt_bytes(data: bytes) -> bytes:
    # XOR is symmetric
    return encrypt_bytes(data)


def key_fingerprint() -> str:
    key = _derive_key(settings.DRM_SECRET)
    return base64.urlsafe_b64encode(key[:8]).decode("ascii")
