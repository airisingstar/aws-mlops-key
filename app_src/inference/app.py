# Tiny FastAPI service so we can build an inference image during CI.
from fastapi import FastAPI
app = FastAPI()

@app.get("/")
def read_root():
    return {"ok": True, "msg": "AWS MLOps Key demo model is alive."}
