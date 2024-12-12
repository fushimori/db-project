# app/admin.py
from fastapi import APIRouter, Depends, HTTPException
from app.auth import verify_token, admin_required

router = APIRouter()

@router.get("/admin")
async def admin_dashboard(token: dict = Depends(admin_required)):
    return {"msg": "Welcome to the admin dashboard!"}
