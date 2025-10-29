# Simple FastAPI container to act as our "model server" example.
FROM public.ecr.aws/lts/ubuntu:22.04
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*
COPY app.py /app/app.py
WORKDIR /app
RUN pip3 install fastapi uvicorn
EXPOSE 8080
CMD ["python3", "-m", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
