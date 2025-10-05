# backend/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import json, pathlib

app = FastAPI(title="MedGuard Mock API", version="1.0.0")

# Allow cross-origin requests (for Flutter frontend)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load the data file once
DATA_PATH = pathlib.Path(__file__).parent / "data" / "products.json"
DATA = json.loads(DATA_PATH.read_text())

@app.get("/")
def root():
    return {"message": "Welcome to MedGuard API", "total_products": len(DATA)}

@app.get("/api/verify")
def verify(code: str):
    """Verify a medicine GTIN code against the RFDA dataset."""
    # Clean input (remove spaces/non-digits)
    code = "".join([c for c in code if c.isdigit()])

    # Try direct match
    match = next((p for p in DATA if p["gtin"] == code), None)

    # If no direct match, try padded (13 → 14 digits)
    if not match and len(code) == 13:
        code14 = "0" + code
        match = next((p for p in DATA if p["gtin"] == code14), None)

    # Response
    if match:
        return {
            "status": "valid",
            "gtin": code,
            "product": match["productBrandName"],
            "genericName": match["genericName"],
            "dosageForm": match["dosageForm"],
            "strength": match["dosageStrength"],
            "manufacturer": match["manufacturerName"],
            "country": match["manufacturerCountry"],
            "registrationNo": match["registrationNo"],
            "expiryDate": match["expiryDate"],
        }

    return {
        "status": "warning",
        "gtin": code,
        "message": "GTIN not found in RFDA register. Possible counterfeit or unregistered product.",
    }
