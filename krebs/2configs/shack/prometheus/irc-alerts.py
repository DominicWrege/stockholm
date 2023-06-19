import base64
import cgi
import json
import os
import re
import socket
import ssl
import sys
from http.server import BaseHTTPRequestHandler
from typing import List, Optional, Tuple
from urllib.parse import urlparse

DEBUG = os.environ.get("DEBUG") is not None


def _irc_send(
    server: str,
    nick: str,
    channel: str,
    sasl_password: Optional[str] = None,
    server_password: Optional[str] = None,
    tls: bool = True,
    port: int = 6697,
    messages: List[str] = [],
) -> None:
    if not messages:
        return

    sock = socket.socket()
    if tls:
        sock = ssl.wrap_socket(
            sock, cert_reqs=ssl.CERT_NONE, ssl_version=ssl.PROTOCOL_TLSv1_2
        )

    def _send(command: str) -> int:
        if DEBUG:
            print(command)
        return sock.send((f"{command}\r\n").encode())

    def _pong(ping: str):
        if ping.startswith("PING"):
            sock.send(ping.replace("PING", "PONG").encode("ascii"))

    recv_file = sock.makefile(mode="r")

    print(f"connect {server}:{port}")
    sock.connect((server, port))
    if server_password:
        _send(f"PASS {server_password}")
    _send(f"USER {nick} 0 * :{nick}")
    _send(f"NICK {nick}")
    for line in recv_file.readline():
        if re.match(r"^:[^ ]* (MODE|221|376|422) ", line):
            break
        else:
            _pong(line)

    if sasl_password:
        _send("CAP REQ :sasl")
        _send("AUTHENTICATE PLAIN")
        auth = base64.encodebytes(f"{nick}\0{nick}\0{sasl_password}".encode("utf-8"))
        _send(f"AUTHENTICATE {auth.decode('ascii')}")
        _send("CAP END")
    _send(f"JOIN :{channel}")

    for m in messages:
        _send(f"PRIVMSG {channel} :{m}")

    _send("INFO")
    for line in recv_file:
        if DEBUG:
            print(line, end="")
        # Assume INFO reply means we are done
        if "End of /INFO" in line:
            break
        else:
            _pong(line)

    sock.send(b"QUIT")
    print("disconnect")
    sock.close()


def irc_send(
    url: str, notifications: List[str], password: Optional[str] = None
) -> None:
    parsed = urlparse(f"{url}")
    username = parsed.username or "prometheus"
    server = parsed.hostname or "chat.freenode.net"
    if parsed.fragment != "":
        channel = f"#{parsed.fragment}"
    else:
        channel = "#krebs-announce"
    port = parsed.port or 6697
    if not password:
        password = parsed.password
    if len(notifications) == 0:
        return
    _irc_send(
        server=server,
        nick=username,
        sasl_password=password,
        channel=channel,
        port=port,
        messages=notifications,
        tls=parsed.scheme == "irc+tls",
    )


class PrometheusWebHook(BaseHTTPRequestHandler):
    def __init__(
        self,
        irc_url: str,
        conn: socket.socket,
        addr: Tuple[str, int],
        password: Optional[str] = None,
    ) -> None:
        self.irc_url = irc_url
        self.password = password
        self.rfile = conn.makefile("rb")
        self.wfile = conn.makefile("wb")
        self.client_address = addr
        self.handle()

    # for testing
    def do_GET(self) -> None:
        if DEBUG:
            print("GET: Request Received")
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(b"ok")

    def do_POST(self) -> None:
        if DEBUG:
            print("POST: Request Received")
        content_type, _ = cgi.parse_header(self.headers.get("content-type"))

        # refuse to receive non-json content
        if content_type != "application/json":
            if DEBUG:
                print(f"POST: wrong content type {content_type}")
            self.send_response(400)
            self.end_headers()
            return

        length = int(self.headers.get("content-length"))
        payload = json.loads(self.rfile.read(length))
        messages = []
        for alert in payload["alerts"]:
            description = alert["annotations"]["description"]
            messages.append(f"{alert['status']}: {description}")
        irc_send(self.irc_url, messages, password=self.password)

        self.do_GET()


def systemd_socket_response() -> None:
    irc_url = os.environ.get("IRC_URL", None)
    if irc_url is None:
        print(
            "IRC_URL environment variable not set: i.e. IRC_URL=irc+tls://mic92-prometheus@chat.freenode.net/#krebs-announce",
            file=sys.stderr,
        )
        sys.exit(1)

    password = None
    irc_password_file = os.environ.get("IRC_PASSWORD_FILE", None)
    if irc_password_file:
        with open(irc_password_file) as f:
            password = f.read()

    msgs = sys.argv[1:]

    if msgs != []:
        irc_send(irc_url, msgs, password=password)
        return

    nfds = os.environ.get("LISTEN_FDS", None)
    if nfds is None:
        print(
            "LISTEN_FDS not set. Run me with systemd(TM) socket activation?",
            file=sys.stderr,
        )
        sys.exit(1)
    fds = range(3, 3 + int(nfds))

    for fd in fds:
        sock = socket.fromfd(fd, socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(0)

        try:
            while True:
                PrometheusWebHook(irc_url, *sock.accept(), password=password)
        except BlockingIOError:
            # no more connections
            pass


if __name__ == "__main__":
    if DEBUG:
        print("Starting in DEBUG mode")
    if len(sys.argv) == 3:
        print(f"{sys.argv[1]} {sys.argv[2]}")
        irc_send(sys.argv[1], [sys.argv[2]])
    else:
        systemd_socket_response()
