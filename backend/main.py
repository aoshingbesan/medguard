from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import json, pathlib

app = FastAPI(title="MedGuard Mock API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DATA_PATH = pathlib.Path(__file__).parent / "data" / "products.json"
DATA = json.loads(DATA_PATH.read_text())

@app.get("/")
def root():
    return {"message": "Welcome to MedGuard API", "total_products": len(DATA)}

@app.get("/api/verify")
def verify(code: str):
    code = "".join([c for c in code if c.isdigit()])

    match = next((p for p in DATA if p["gtin"] == code), None)

    if not match and len(code) == 13:
        code14 = "0" + code
        match = next((p for p in DATA if p["gtin"] == code14), None)

    if match:
        return {
            "status": "valid",
            "gtin": code,
            "product": match["productBrandName"],
            "genericName": match["genericName"],
            "dosageForm": match["dosageForm"],
            "strength": match["dosageStrength"],
            "pack_size": match["packSize"],
            "batch": "N/A",
            "mfg_date": "N/A",
            "registration_date": match["registrationDate"],
            "license_expiry_date": match["expiryDate"],
            "expiry": match["expiryDate"],
            "shelf_life": match["shelfLife"],
            "packaging_type": match["packagingType"],
            "marketing_authorization_holder": match["marketingAuthorizationHolder"],
            "local_technical_representative": match["localTechnicalRepresentative"]
        }

    return {
        "status": "warning",
        "gtin": code,
        "message": "GTIN not found in RFDA register. Possible counterfeit or unregistered product.",
    }
