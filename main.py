from dotenv import load_dotenv
from fastapi import FastAPI
from routers import file, ping

load_dotenv()

app = FastAPI(
    title="pet throught", version="1.0.0", description="a api server for pet throught"
)

app.include_router(ping.router)
app.include_router(file.router)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8080)
