"""
Kleiner lokaler YouTube-Audio-Resolver fuer den VIP-Ghettoblaster (vip_radio_s.lua).

Laeuft als eigener Prozess NEBEN dem MTA-Server auf dem gleichen Rechner und
liefert per HTTP eine direkte Audio-Stream-URL fuer einen YouTube-Link/eine
Video-ID zurueck, per yt-dlp extrahiert. MTA's playSound3D kann diese direkte
Stream-URL dann abspielen (im Gegensatz zu einer normalen YouTube-Seite).

Voraussetzungen:
    pip install yt-dlp

Start:
    python yt_resolver.py
(Standardmaessig auf http://127.0.0.1:8927 - Port unten anpassbar)

Aufruf aus MTA:
    fetchRemote("http://127.0.0.1:8927/resolve?id=<videoId>", ...)
    -> Antwort: {"url": "https://...googlevideo.com/..."} oder {"error": "..."}
"""

import json
import subprocess
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs

HOST = "127.0.0.1"
PORT = 8927


def resolve_stream_url(video_id):
    # -f bestaudio: beste reine Audiospur, -g: nur die direkte URL ausgeben,
    # ohne irgendetwas herunterzuladen.
    result = subprocess.run(
        [sys.executable, "-m", "yt_dlp", "-f", "bestaudio", "-g", f"https://www.youtube.com/watch?v={video_id}"],
        capture_output=True, text=True, timeout=20
    )
    stream_url = result.stdout.strip().splitlines()[0] if result.stdout.strip() else None
    if not stream_url:
        return None, result.stderr.strip() or "yt-dlp lieferte keine URL zurueck."
    return stream_url, None


class ResolverHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        print("[yt_resolver] " + (format % args))

    def do_GET(self):
        query = parse_qs(urlparse(self.path).query)
        video_id = (query.get("id") or [None])[0]

        if not video_id:
            self.send_response(400)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": "Parameter 'id' fehlt."}).encode("utf-8"))
            return

        try:
            stream_url, error = resolve_stream_url(video_id)
        except Exception as e:
            stream_url, error = None, str(e)

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        if stream_url:
            self.wfile.write(json.dumps({"url": stream_url}).encode("utf-8"))
        else:
            self.wfile.write(json.dumps({"error": error}).encode("utf-8"))


if __name__ == "__main__":
    server = HTTPServer((HOST, PORT), ResolverHandler)
    print(f"[yt_resolver] Laeuft auf http://{HOST}:{PORT} - bereit fuer Anfragen von vip_radio_s.lua.")
    server.serve_forever()
