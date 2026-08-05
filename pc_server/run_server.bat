@echo off
set HOST=0.0.0.0
set PORT=8000
python -m uvicorn server:app --host %HOST% --port %PORT%
