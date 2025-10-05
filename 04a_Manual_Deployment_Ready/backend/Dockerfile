# 1. Base Stage: Use an official Python runtime as a parent image
FROM python:3.9-slim

# 2. Set Environment Variables
# Prevents Python from writing pyc files to disc
ENV PYTHONDONTWRITEBYTECODE 1
# Ensures Python output is sent straight to the terminal without buffering
ENV PYTHONUNBUFFERED 1

# 3. Set the working directory in the container
WORKDIR /app

# 4. Install dependencies
# Copy the requirements file into the container
COPY requirements.txt .
# Install the Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 5. Copy the application code into the container
COPY . .

# 6. Expose the port the app runs on
# The PORT environment variable will be automatically provided by Cloud Run.
EXPOSE 8000

# 7. Define the command to run the application
# Use gunicorn for a production-ready server. Cloud Run sends a SIGTERM signal
# to stop the container, which gunicorn handles gracefully.
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 "main:app" -k uvicorn.workers.UvicornWorker
