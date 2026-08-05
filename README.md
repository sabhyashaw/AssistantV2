# Jarvis AI — Local-First Voice Assistant (Flutter × FastAPI × Ollama)

Assistant V2 is a personal AI assistant inspired by J.A.R.V.I.S. from the Marvel universe. The project focuses on building a privacy-first, locally hosted assistant capable of natural conversations, task automation, and system interaction across multiple platforms.

Unlike traditional cloud-based assistants, Assistant V2 is designed to run primarily on local hardware, giving users greater control over their data while remaining highly extensible.

Implementations

Assistant V2 currently consists of two independent implementations.

## Android Application

The Android version is built using Flutter and communicates with a FastAPI backend through REST APIs. The backend routes requests to dedicated modules such as memory, weather, and web search while using Ollama for local large language model inference.
Features

- Flutter-based Android client
- FastAPI backend
- Local AI inference using Ollama
- Persistent memory system
- Context-aware conversations
- Web search integration
- Wikipedia integration
- Weather information
- Token-based API authentication
- Modular request routing

## Desktop Application (Windows & Linux)

The desktop version is written in Python and is designed to function as a full desktop assistant. It supports both keyboard and voice interaction while providing direct access to operating system features.

# Features

- Voice recognition using Whisper
- Offline text-to-speech
- Text and voice interaction
- Persistent memory
- Web search and Wikipedia lookup
- Weather information
- Spotify playback control
- Volume and brightness control
- Application launcher
- Desktop automation
- System commands
- Modular architecture for future extensions

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

Built by **Sabhya Shaw** — final-year B.Tech CSE (Data Science) student.
