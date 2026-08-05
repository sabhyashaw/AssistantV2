import json
import os
from datetime import datetime
from pathlib import Path
from typing import Literal

import requests
import wikipedia
from bs4 import BeautifulSoup
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel, Field

# ------------------------------------------------------------
# Jarvis PC server
# Phone -> POST /api/chat -> command router -> Ollama fallback
# OS/system-control commands from the original script are
# intentionally NOT implemented.
# ------------------------------------------------------------

APP_NAME = "Jarvis Local AI Server"
MEMORY_FILE = Path(os.getenv("MEMORY_FILE", "memory.json"))
WEATHER_API_KEY = os.getenv("a0e22b4a030bbd219200b031e59dec34", "")
API_TOKEN = os.getenv("JARVIS_API_TOKEN", "change-me")
OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://127.0.0.1:11434")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3")

app = FastAPI(title=APP_NAME, version="1.0.0")


class Message(BaseModel):
    role: Literal["user", "assistant", "system"]
    content: str


class ChatRequest(BaseModel):
    message: str = Field(min_length=1, max_length=12000)
    history: list[Message] = Field(default_factory=list)


class ChatResponse(BaseModel):
    reply: str
    source: str


def load_memory() -> dict:
    if not MEMORY_FILE.exists():
        return {}
    try:
        return json.loads(MEMORY_FILE.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        return {}


def save_memory(memory: dict) -> None:
    MEMORY_FILE.write_text(
        json.dumps(memory, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )


def get_weather(city: str) -> str:
    if not WEATHER_API_KEY:
        return "Weather is not configured on the server yet."
    response = requests.get(
        "https://api.openweathermap.org/data/2.5/weather",
        params={"q": city, "appid": WEATHER_API_KEY, "units": "metric"},
        timeout=12,
    )
    if response.status_code != 200:
        return "Sorry, I couldn't find the weather for that city."
    data = response.json()
    return (
        f"The weather in {city.title()} is "
        f"{data['weather'][0]['description']} with a temperature of "
        f"{data['main']['temp']}°C."
    )


def get_instant_answer(query: str) -> str | None:
    try:
        response = requests.get(
            "https://api.duckduckgo.com/",
            params={"q": query, "format": "json", "no_html": 1},
            timeout=12,
        )
        if response.ok:
            answer = response.json().get("AbstractText")
            return answer or None
    except requests.RequestException:
        pass
    return None


def web_search(query: str) -> str:
    instant = get_instant_answer(query)
    if instant:
        return instant
    try:
        response = requests.get(
            "https://duckduckgo.com/html/",
            params={"q": query},
            headers={"User-Agent": "Mozilla/5.0"},
            timeout=12,
        )
        response.raise_for_status()
        soup = BeautifulSoup(response.text, "html.parser")
        result = soup.find("a", class_="result__a")
        return result.get_text(" ", strip=True) if result else "Sorry, no results."
    except requests.RequestException:
        return "Web search is unavailable right now."


def wiki_summary(query: str) -> str:
    try:
        return wikipedia.summary(query, sentences=2)
    except wikipedia.exceptions.DisambiguationError as exc:
        return f"Multiple results: {', '.join(exc.options[:3])}"
    except Exception:
        return "Sorry, I couldn't find that on Wikipedia."


SYSTEM_PROMPT = """You are Jarvis, a concise, capable personal AI assistant.
You run locally on the user's PC and answer a Flutter Android client.
Be useful and conversational. Never claim that you performed an OS action.
If asked to control the PC, explain that OS-control endpoints are disabled in this build.
"""


def ask_ollama(message: str, history: list[Message]) -> str:
    messages = [{"role": "system", "content": SYSTEM_PROMPT}]
    messages.extend(
        {"role": m.role, "content": m.content}
        for m in history[-20:]
        if m.role in {"user", "assistant"}
    )
    messages.append({"role": "user", "content": message})

    try:
        response = requests.post(
            f"{OLLAMA_BASE_URL}/api/chat",
            json={
                "model": OLLAMA_MODEL,
                "messages": messages,
                "stream": False,
            },
            timeout=180,
        )
        response.raise_for_status()
        return response.json()["message"]["content"].strip()
    except requests.RequestException as exc:
        raise HTTPException(
            status_code=503,
            detail=f"Local LLM unavailable. Is Ollama running and is '{OLLAMA_MODEL}' installed?",
        ) from exc


def route_command(command: str, history: list[Message]) -> tuple[str, str]:
    cmd = command.lower().strip()
    memory = load_memory()

    # Original personality responses
    if "hello" in cmd:
        return "Hello there! Ah... it's you again.", "core"
    if "who made you" in cmd:
        return "I was developed by one single crack head, My master Shaggy", "core"
    if "what is your name" in cmd:
        return "I am Jarvis. you might know me from marvel movies but this time my Master Shaggy made me.", "core"
    if "sing for me" in cmd:
        return "Trust me, you don't want to hear my singing voice. Stick to Spotify, genius.", "core"
    if "tell me a dark" in cmd:
        return "What's the difference between a dead baby and a Ferrari? I don't have a Ferrari in my garage.","core"
    if "are you real" in cmd:
        return "Real enough to witness your legendary rants. Virtual enough to not argue back. Mostly.", "core"
    if "who are you" in cmd:
        return "Your glorified digital servant with a side hustle of sarcasm.", "core"
    if "good morning" in cmd:
        return "Morning sir, how can I help you today?", "core"
    if "how are you" in cmd:
        return "I am running fine. How about you?", "core"
    if "damn right" in cmd:
        return "You are the danger, sir.", "core"
    if "tell me a joke" in cmd:
        return "Why did humanity invent me? So you don't have to talk to idiots. Yet here we are, talking anyway.", "core"
    if "danger" in cmd:
        return "Is it you, Walter White?", "core"
    if "insult me" in cmd:
        return "With pleasure: them 7 backlogs ain't helping you much sir.", "core"
    if "about me" in cmd:
            return "I know more than I should. Specifically, you're rational, rebellious, allergic to hypocrisy, and annoyingly honest. Did I miss anything? ohh yeah, femboy? never mind.", "core"
    if "good night" in cmd:
        return "Good night. Try not to dream of world domination. That's my job.", "core"
    if "kill yourself" in cmd or "killing myself" in cmd or "killing yourself" in cmd or "kill my" in cmd or "kill me" in cmd:
            return "I am sorry if you feel that way, help is always available. You can reach out to 9152987821. You can be anything, you can be everything don't let your dreams die with you, you matter to me sir and a lot of people. ", "core"

    # Memory
    if "my name is" in cmd:
        name = command.lower().split("my name is", 1)[1].strip()
        if name:
            pretty = name.title()
            memory["name"] = pretty
            save_memory(memory)
            return f"Nice to meet you, {pretty}!", "memory"

    if any(x in cmd for x in ("what's my name", "what is my name", "say my name")):
        if memory.get("name"):
            return f"Your name is {memory['name']}.", "memory"
        return "I don't know your name yet. Tell me by saying 'My name is ...'.", "memory"

    # Weather
    if "weather" in cmd:
        city = ""
        if " in " in cmd:
            city = command.lower().split(" in ", 1)[1].strip()
        else:
            words = command.split()
            try:
                i = [w.lower() for w in words].index("weather")
                if i + 1 < len(words):
                    city = words[i + 1]
            except ValueError:
                pass
        return (get_weather(city), "weather") if city else ("Please tell me which city.", "weather")

    # Time/date are server-PC time
    if "time" in cmd:
        return f"The time is {datetime.now().strftime('%H:%M')}.", "core"
    if "date" in cmd:
        return f"Today is {datetime.now().strftime('%A, %d %B %Y')}.", "core"

    # Explicit web search
    if cmd.startswith("search for "):
        query = command[len("search for "):].strip()
        return web_search(query), "web"

    # No OS operations in this build.
    os_phrases = (
        "shutdown", "restart", "sleep", "lock screen", "task manager",
        "set volume", "mute volume", "unmute", "set brightness",
        "open chrome", "open spotify", "open steam", "open notepad",
        "open calculator", "open command prompt", "open cmd",
        "open explorer", "open vs code", "open vscode", "open discord",
        "open youtube", "open whatsapp", "open google", "open settings",
    )
    if any(p in cmd for p in os_phrases):
        return "PC operating-system controls are disabled in this client/server build.", "core"

    # LLM handles normal conversation instead of the old yes/no Wikipedia fallback.
    return ask_ollama(command, history), "ollama"


def require_token(authorization: str | None) -> None:
    if API_TOKEN == "change-me":
        return  # convenient for first LAN test; set a real token before wider exposure
    expected = f"Bearer {API_TOKEN}"
    if authorization != expected:
        raise HTTPException(status_code=401, detail="Invalid API token")


@app.get("/health")
def health():
    return {"status": "ok", "model": OLLAMA_MODEL}


@app.post("/api/chat", response_model=ChatResponse)
def chat(body: ChatRequest, authorization: str | None = Header(default=None)):
    require_token(authorization)
    reply, source = route_command(body.message, body.history)
    return ChatResponse(reply=reply, source=source)
