import ray
from ray import serve
from starlette.requests import Request
import httpx
import json
import logging
import time

SCOUT_URL = "http://localhost:8081/v1/chat/completions"
ORACLE_URL = "http://localhost:8082/v1/chat/completions"
logger = logging.getLogger("ray.serve")

@serve.deployment(num_replicas=1)
class Gateway:
    def __init__(self):
        self.client = httpx.AsyncClient(timeout=300.0)
        logger.info("Gateway Initialized.")

    async def query_model(self, url, model, messages, temperature=0.7):
        try:
            resp = await self.client.post(url, json={"model": model, "messages": messages, "temperature": temperature, "max_tokens": 2048})
            resp.raise_for_status()
            return resp.json()["choices"][0]["message"]["content"]
        except Exception as e:
            return f"Error: {str(e)}"

    async def __call__(self, req: Request):
        data = await req.json()
        prompt = data.get("prompt", "")
        
        classifier = await self.query_model(SCOUT_URL, "Qwen/Qwen2.5-14B-Instruct-AWQ", 
            [{"role": "system", "content": "Reply SIMPLE for factual/greetings. Reply COMPLEX for reasoning/coding."}, 
             {"role": "user", "content": prompt}], temperature=0.1)
        
        if "SIMPLE" in classifier.upper():
            return await self.query_model(SCOUT_URL, "Qwen/Qwen2.5-14B-Instruct-AWQ", [{"role": "user", "content": prompt}])
        
        draft = await self.query_model(ORACLE_URL, "/models/Llama-3.3-70B-Instruct-Q4_K_M.gguf", 
            [{"role": "system", "content": "Detailed reasoning required."}, {"role": "user", "content": prompt}])
            
        critique = await self.query_model(SCOUT_URL, "Qwen/Qwen2.5-14B-Instruct-AWQ", 
            [{"role": "user", "content": f"Critique this text for errors: {draft}"}], temperature=0.1)
            
        return {"draft": draft, "critique": critique}

entrypoint = Gateway.bind()
