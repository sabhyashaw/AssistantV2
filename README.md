# Jarvis AI — Local-First Voice Assistant (Flutter × FastAPI × Ollama)

A native Android assistant backed by a self-hosted Python server — no cloud LLM API, no per-token billing, nothing leaving your network. The app talks to a FastAPI backend over LAN, which routes each message through a rule-based command layer and falls back to a locally-hosted **Ollama (Llama 3)** model for open-ended conversation. This is a client-server rewrite of an earlier single-machine assistant, split into a proper mobile client and a reusable backend service.

## Architecture

```
┌─────────────────────────┐   HTTP/JSON over LAN   ┌──────────────────────────┐
│  Android App (Flutter)   │ ─────────────────────▶ │  FastAPI Server (Python)  │
│  Chat UI, STT/TTS, auth  │ ◀───────────────────── │  Router, memory, Ollama   │
└─────────────────────────┘                        └──────────────────────────┘
```

## Features

- **Client:** dark chat UI, on-device speech-to-text + text-to-speech, bearer-token auth, connection test, persistent chat history
- **Server:** REST API (`/api/chat`, `/health`), rule-based intent router, persistent memory, weather/search/Wikipedia tools, local LLM fallback via Ollama

## Tech stack

| Layer | Technology |
|---|---|
| Mobile | Flutter, Dart, `http`, `speech_to_text`, `flutter_tts` |
| Backend | Python, FastAPI, Pydantic, Uvicorn |
| LLM | Ollama (local Llama 3) |
| Data | OpenWeatherMap, Wikipedia, DuckDuckGo, JSON memory store |

## Quick start

```bash
# Backend
cd pc_server
pip install -r requirements.txt
ollama pull llama3
python -m uvicorn server:app --host 0.0.0.0 --port 8000

# Client
flutter pub get
flutter run
```

Point the app's Settings screen at your machine's LAN IP (e.g. `http://192.168.1.47:8000`), with a token matching `JARVIS_API_TOKEN` on the server.

## Author

Built by **Sabhya Shaw** — third-year B.Tech CSE (Data Science) student.