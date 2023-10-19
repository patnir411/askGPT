from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def init():
    return {"response": "Hello, World!"}


@app.post("/query/")
async def query_model(user_input: str):
    # Your code to query the LLM and get a response
    response = "Your response from LLM"
    return {"response": response}

