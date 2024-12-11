# app/admin.py
from fastapi import APIRouter, Depends, HTTPException
from app.auth import verify_token

router = APIRouter()

def admin_required(token: str = Depends(verify_token)):
    if token.get("role") != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")
    return token

@router.get("/admin")
async def admin_dashboard(token: dict = Depends(admin_required)):
    return {"msg": "Welcome to the admin dashboard!"}
