# Jarvis AI — complete Flutter Android client

This folder is the phone/client half of the Jarvis client-server architecture.

## Features

- Dark UI matching the supplied reference
- Real chat history
- HTTP/JSON client for `POST /api/chat`
- PC server settings stored on device
- Bearer API token support
- Connection test
- Android speech-to-text
- Optional Android text-to-speech for AI replies
- Suggestion chips
- Loading/error states
- New-chat action
- Android Internet and microphone permissions
- Cleartext LAN HTTP enabled for development

## Open in Android Studio

If this package was generated on a machine without the Flutter SDK, first install Flutter and run this once from the project directory:

    flutter create --platforms=android --org com.shaggy --project-name jarvis_ai .

This generates any SDK-specific Gradle wrapper/Android boilerplate without replacing your `lib/` source. If Android files are regenerated, verify that the provided `AndroidManifest.xml` still contains INTERNET, RECORD_AUDIO, and `usesCleartextTraffic="true"`.

Then:

    flutter pub get
    flutter run

## Connect to your PC

Start the FastAPI server on the PC with:

    python -m uvicorn server:app --host 0.0.0.0 --port 8000

Find the PC's IPv4 address with `ipconfig`.

In the app, open the menu -> Server settings and use:

    http://YOUR_PC_IP:8000

Example:

    http://192.168.1.47:8000

Do not use `localhost` from a physical phone.

For the standard Android emulator, the host machine is normally:

    http://10.0.2.2:8000

The API token must match `JARVIS_API_TOKEN` on the Python server.

## Expected server API

POST `/api/chat`

Request body:

    {
      "message": "Hello",
      "history": [
        {"role": "assistant", "content": "Hello. I am Jarvis."}
      ]
    }

Response:

    {
      "reply": "Hello there!",
      "source": "ollama"
    }

GET `/health` should return HTTP 200.

## Important

This app intentionally does not implement Windows OS operations. Those belong on the server side and were excluded from this build.

Do not expose the development HTTP server directly to the public internet.
