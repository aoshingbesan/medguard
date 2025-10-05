from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import json, pathlib

app = FastAPI(title="MedGuard Mock API")

# Allow requests from frontend (e.g., localhost)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], allow_credentials=True,
    allow_methods=["*"], allow_headers=["*"],
)

DATA_PATH = pathlib.Path(__file__).parent / "data" / "products.json"
DATA = json.loads(DATA_PATH.read_text())

@app.get("/api/verify")
def verify(code: str):
    code = "".join([c for c in code if c.isdigit()])
    match = next((p for p in DATA if p["gtin"] == code), None)
    if match:
        return {"status": "valid", "gtin": code, **match}
    return {
        "status": "warning",
        "gtin": code,
        "message": "GTIN not found in RFDA register."
    }
