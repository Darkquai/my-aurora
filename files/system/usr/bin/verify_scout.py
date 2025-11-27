#!/usr/bin/env python3
import time
import threading
import requests
import json
import sys

API_URL = "http://localhost:8081/v1/chat/completions"
MODEL = "Qwen/Qwen2.5-14B-Instruct-AWQ"
CONCURRENT_REQUESTS = 8

def send_request(i, results):
    headers = {"Content-Type": "application/json"}
    data = {"model": MODEL, "messages": [{"role": "user", "content": "Explain quantum entanglement."}], "temperature": 0.7, "max_tokens": 50}
    start_time = time.time()
    try:
        response = requests.post(API_URL, headers=headers, json=data)
        if response.status_code == 200:
            results.append((i, time.time() - start_time, "Success"))
        else:
            results.append((i, 0, f"Failed: {response.status_code}"))
    except Exception as e:
        results.append((i, 0, f"Error: {str(e)}"))

def main():
    print(f"🚀 Launching {CONCURRENT_REQUESTS} simultaneous requests...")
    threads, results = [], []
    for i in range(CONCURRENT_REQUESTS):
        t = threading.Thread(target=send_request, args=(i, results))
        threads.append(t)
        t.start()
    for t in threads: t.join()
    print("Done.")

if __name__ == "__main__":
    main()
