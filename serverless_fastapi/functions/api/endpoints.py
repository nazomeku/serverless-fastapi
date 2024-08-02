from fastapi import FastAPI, HTTPException
from pydantic import BaseModel


app = FastAPI()
items = []


class Item(BaseModel):
    text: str
    is_done: bool = False


@app.get('/')
async def index() -> dict[str, str]:
    return {'info': 'Try /docs for documentation'}


@app.get('/custom/{path}')
async def custom_path(path: str) -> dict[str, str]:
    return {'custom path': path}


@app.post('/items')
def create_item(item: Item) -> list[Item]:
    items.append(item)
    return items


@app.get('/items', response_model=list[Item])
def list_items(limit: int = 10) -> list[Item]:
    return items[:limit]


@app.get('/items/{item_id}', response_model=Item)
def get_item(item_id: int) -> Item:
    if item_id < len(items):
        return items[item_id]
    raise HTTPException(status_code=404, detail=f'Item {item_id} not found')
