# app/series.py
from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, Query
from app.auth import get_current_user, admin_required
from app.media import (
    fetch_media_list,
    search_media,
    fetch_media_details,
    upload_csv_to_table,
    delete_media_from_table,
    manage_media_for_user_list
)

router = APIRouter()

@router.get("/")
async def get_series(
    current_user: str = Depends(get_current_user)
):

    return {"results": await fetch_media_list("series", "media_content_series", current_user)}


@router.get("/search")
async def search_series(
    query: str = Query(None, description="Search query"),
    current_user: str = Depends(get_current_user)
):

    return {"results": await search_media(query, "media_content_series", current_user)}


@router.get("/{series_id}/")
async def get_series_details(
    series_id: int,
    current_user: str = Depends(get_current_user)
):

    series_details = await fetch_media_details(series_id, "media_content_series", current_user)
    if not series_details:
        raise HTTPException(status_code=404, detail="series not found")
    return {"results": series_details}

@router.post("/{media_id}/add-to-list")
async def add_media_to_list(
    media_id: int,
    status: str = Query(...),
    current_user: str = Depends(get_current_user)
):
    if not current_user:
        raise HTTPException(status_code=401, detail="User is not authenticated")
    print(status, media_id, current_user)
    await manage_media_for_user_list(current_user, media_id, "series", "add", status)
    return {"message": f"Media with ID {media_id} added to your list with status '{status}'."}


@router.post("/{media_id}/remove-from-list")
async def remove_media_from_list(
    media_id: int,
    current_user: str = Depends(get_current_user)
):
    if not current_user:
        raise HTTPException(status_code=401, detail="User is not authenticated")

    await manage_media_for_user_list(current_user, media_id, "series", "remove")
    return {"message": f"Media with ID {media_id} removed from your list."}

@router.post("/upload-csv")
async def upload_series_csv(
    file: UploadFile = File(...),
    user: dict = Depends(admin_required)
):

    return await upload_csv_to_table(file)


@router.delete("/delete-media/{series_id}")
async def delete_series(
    series_id: int,
    user: dict = Depends(admin_required)
):
    return await delete_media_from_table(series_id, "media_content_series")
