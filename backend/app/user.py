# app/user.py
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from app.auth import verify_password, get_password_hash, create_access_token
from db.queriers import get_user_by_username, create_user
from fastapi.security import OAuth2PasswordRequestForm

router = APIRouter()

class UserRegisterRequest(BaseModel):
    username: str
    email: str
    password: str

@router.post("/register")
async def register(user: UserRegisterRequest):
    existing_user = await get_user_by_username(user.username)
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    hashed_password = get_password_hash(user.password)
    await create_user(user.username, user.email, hashed_password)
    return {"msg": "User created successfully"}

@router.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = await get_user_by_username(form_data.username)
    if not user or not verify_password(form_data.password, user["password"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )
    access_token = create_access_token(data={"sub": user["username"], "role": user["role"]})
    return {"access_token": access_token, "token_type": "bearer"}
