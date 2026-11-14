"""Confere os QR Codes renderizados pelo teste Lazarus (requer opencv-python)."""
from pathlib import Path

import cv2

detector = cv2.QRCodeDetector()
files = sorted((Path(__file__).parent / "output").glob("qr-*.png"))
assert len(files) >= 20, "Execute testar_inicio antes desta verificação."
for path in files:
    value, _, _ = detector.detectAndDecode(cv2.imread(str(path)))
    assert value == "https://example.com/manual?produto=123", (path.name, value)
print(f"PASSOU: {len(files)} QR Codes decodificados com o conteúdo original.")
