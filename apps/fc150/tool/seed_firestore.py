#!/usr/bin/env python3
"""Seed the FC150 Firestore database with the initial content.

Mirrors lib/data/seed_data.dart (players, league, fixtures, results, invites,
disputes, pending registrations) plus the admin roster draft. Idempotent —
re-running overwrites the same documents. Uses the locally-authenticated
Firebase CLI credentials (no secrets in this file).

Run:  python3 tool/seed_firestore.py
"""
import json, os, urllib.request, urllib.parse, urllib.error

PROJECT = "fc150-arena"
BASE = f"https://firestore.googleapis.com/v1/projects/{PROJECT}/databases/(default)/documents"


def access_token():
    cfg = json.load(open(os.path.expanduser("~/.config/configstore/firebase-tools.json")))
    rt = cfg["tokens"]["refresh_token"]
    data = urllib.parse.urlencode({
        "client_id": "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com",
        "client_secret": "j9iVZfS8kkCEFUPaAeJV0sAi",
        "refresh_token": rt, "grant_type": "refresh_token"}).encode()
    return json.load(urllib.request.urlopen("https://oauth2.googleapis.com/token", data))["access_token"]


TOKEN = access_token()


def fsval(v):
    if isinstance(v, bool): return {"booleanValue": v}
    if isinstance(v, int): return {"integerValue": str(v)}
    if isinstance(v, float): return {"doubleValue": v}
    if isinstance(v, str): return {"stringValue": v}
    if v is None: return {"nullValue": None}
    if isinstance(v, list): return {"arrayValue": {"values": [fsval(x) for x in v]}}
    if isinstance(v, dict): return {"mapValue": {"fields": {k: fsval(x) for k, x in v.items()}}}
    raise ValueError(v)


def put(collection, doc_id, fields):
    url = f"{BASE}/{collection}/{urllib.parse.quote(doc_id)}"
    body = json.dumps({"fields": {k: fsval(v) for k, v in fields.items()}}).encode()
    req = urllib.request.Request(url, data=body, method="PATCH",
                                 headers={"Authorization": "Bearer " + TOKEN, "Content-Type": "application/json"})
    urllib.request.urlopen(req)


def clamp(v): return max(34, min(99, v))


def stats_for(pos, ovr):
    if pos == "ATT":
        return dict(pac=clamp(ovr - 2), sho=clamp(ovr + 1), pas=clamp(ovr - 16), dri=clamp(ovr - 4), defe=clamp(ovr - 48), phy=clamp(ovr - 12))
    if pos == "DEF":
        return dict(pac=clamp(ovr - 14), sho=clamp(ovr - 36), pas=clamp(ovr - 16), dri=clamp(ovr - 18), defe=clamp(ovr + 1), phy=clamp(ovr - 2))
    return dict(pac=clamp(ovr - 8), sho=clamp(ovr - 12), pas=clamp(ovr + 1), dri=clamp(ovr - 2), defe=clamp(ovr - 18), phy=clamp(ovr - 10))


def st(pac, sho, pas, dri, d, phy):
    return dict(pac=pac, sho=sho, pas=pas, dri=dri, defe=d, phy=phy)


# Note: 'def' is a Python keyword, so stats use 'defe' in Firestore; the Dart
# Stats.fromMap reads 'defe'.
NAMED = [
    ("p01", "Khadar Agab", "NL", "ATT", "AGAB_010", 94, "base", "neon", st(92, 95, 78, 90, 42, 84)),
    ("p02", "Hodan Ali", "SO", "MID", "HODA_07", 93, "base", "neon", st(84, 80, 91, 88, 70, 79)),
    ("p03", "Guled Farah", "SO", "DEF", "GULED_FC", 91, "base", "neon", st(78, 55, 75, 74, 90, 88)),
    ("p04", "Liam de Jong", "NL", "ATT", "LIAM_NL9", 90, "base", "neon", st(90, 88, 76, 86, 40, 82)),
    ("p05", "Noah Keita", "SN", "MID", "KEITA_X", 89, "base", "neon", st(82, 79, 87, 85, 72, 80)),
    ("p06", "Adam Osman", "SO", "ATT", "OSMAN_AD", 88, "base", "neon", st(88, 86, 70, 84, 38, 79)),
    ("p07", "Yusuf Rashid", "SO", "DEF", "YR_WALL", 87, "base", "neon", st(75, 50, 72, 70, 88, 86)),
    ("p08", "Marco Bianchi", "IT", "MID", "BIANCHI8", 86, "base", "neon", st(80, 74, 85, 83, 68, 77)),
    ("p09", "Omar Sheikh", "SO", "ATT", "OMAR_S10", 85, "base", "neon", st(86, 83, 68, 82, 36, 75)),
    ("p10", "Kenji Sato", "JP", "MID", "SATO_K", 84, "base", "neon", st(83, 72, 84, 86, 64, 70)),
    ("p11", "Tomas Novak", "CZ", "DEF", "NOVAK_CZ", 83, "base", "neon", st(72, 48, 70, 68, 85, 84)),
    ("p12", "Bilal Hassan", "SO", "ATT", "BILAL_H", 82, "base", "neon", st(85, 80, 66, 80, 34, 73)),
]

GEN_NAMES = [
    ("Aron Visser", "NL"), ("Mateo Rossi", "IT"), ("Daud Jama", "SO"), ("Lars Berg", "SE"),
    ("Hiro Mori", "JP"), ("Pavel Dvorak", "CZ"), ("Bruno Alves", "BR"), ("Tiago Costa", "PT"),
    ("Luis Reyes", "MX"), ("Mamadou Diop", "SN"), ("Sem Bakker", "NL"), ("Gianni Conti", "IT"),
    ("Said Nur", "SO"), ("Felix Holm", "SE"), ("Ren Kato", "JP"), ("Jan Kucera", "CZ"),
    ("Caio Lima", "BR"), ("Diogo Faria", "PT"), ("Mateo Cruz", "MX"), ("Ousmane Ba", "SN"),
    ("Tim Mulder", "NL"), ("Enzo Greco", "IT"), ("Abdi Yusuf", "SO"), ("Nils Sand", "SE"),
    ("Sota Abe", "JP"), ("Petr Marek", "CZ"), ("Rafael Souza", "BR"), ("Hugo Pinto", "PT"),
    ("Ivan Lopez", "MX"), ("Cheikh Fall", "SN"), ("Daan Smit", "NL"), ("Luca Ferri", "IT"),
    ("Farah Aden", "SO"), ("Emil Lund", "SE"), ("Kenta Ito", "JP"), ("Milan Horak", "CZ"),
    ("Pedro Rocha", "BR"), ("Andre Melo", "PT"),
]
POSITIONS = ["ATT", "MID", "DEF"]


def psn_of(name):
    return "".join(c for c in name.upper().replace(" ", "_") if c.isalpha() or c == "_")


def seed_players():
    n = 0
    for (pid, short, country, pos, psn, rating, tier, variant, stats) in NAMED:
        put("players", pid, dict(id=pid, name=short.upper(), short=short, country=country, pos=pos,
                                 psn=psn, rating=rating, tier=tier, variant=variant, stats=stats, photo=None))
        n += 1
    for i, (short, country) in enumerate(GEN_NAMES):
        pos = POSITIONS[i % 3]
        ovr = 86 - i
        pid = f"r{i + 13:02d}"
        put("players", pid, dict(id=pid, name=short.upper(), short=short, country=country, pos=pos,
                                 psn=psn_of(short), rating=ovr, tier="base", variant="neon",
                                 stats=stats_for(pos, ovr), photo=None))
        n += 1
    return n


LEAGUE = [
    (1, "p02", 19, 14, 3, 2, 41, 16, 45, ["W", "W", "D", "W", "W"]),
    (2, "p01", 19, 13, 4, 2, 44, 19, 43, ["W", "W", "W", "D", "W"]),
    (3, "p03", 19, 12, 5, 2, 30, 13, 41, ["D", "W", "W", "W", "D"]),
    (4, "p04", 19, 12, 2, 5, 38, 22, 38, ["W", "L", "W", "W", "L"]),
    (5, "p05", 19, 10, 6, 3, 33, 21, 36, ["D", "W", "D", "W", "W"]),
    (6, "p06", 19, 10, 3, 6, 35, 27, 33, ["W", "W", "L", "D", "W"]),
    (7, "p08", 19, 9, 4, 6, 29, 25, 31, ["L", "W", "D", "W", "D"]),
    (8, "p07", 19, 8, 5, 6, 22, 21, 29, ["D", "D", "W", "L", "W"]),
    (9, "p10", 19, 7, 5, 7, 27, 28, 26, ["W", "L", "D", "L", "W"]),
    (10, "p09", 19, 6, 6, 7, 25, 28, 24, ["D", "L", "W", "D", "L"]),
    (11, "p11", 19, 5, 5, 9, 18, 29, 20, ["L", "D", "L", "W", "L"]),
    (12, "p12", 19, 3, 4, 12, 17, 38, 13, ["L", "L", "D", "L", "L"]),
]
FIXTURES = [
    ("f1", "p01", "p06", "Today · 20:30", "Premier League", 20, "locked"),
    ("f2", "p03", "p05", "Today · 21:00", "Premier League", 20, "scheduled"),
    ("f3", "p02", "p04", "Tomorrow · 19:00", "Premier League", 20, "scheduled"),
    ("f4", "p01", "p09", "Sat · 18:30", "Premier League", 21, "scheduled"),
]
RESULTS = [
    ("r1", "p01", "p10", 4, 1, "Premier League", "Yesterday", "confirmed"),
    ("r2", "p02", "p07", 2, 0, "Premier League", "Yesterday", "confirmed"),
    ("r3", "p08", "p03", 1, 1, "Premier League", "2 days ago", "confirmed"),
    ("r4", "p06", "p12", 3, 0, "Premier League", "2 days ago", "noshow"),
]
INVITES = [
    ("inv1", "p06", "1v1", "Today · 20:30", "Friendly", "pending"),
    ("inv2", "p10", "1v1", "Fri · 21:30", "Friendly", "pending"),
]
DISPUTES = [("d1", "p06", "p12", "3–0 win", "No-show, replay", "20m ago")]
PENDING = [
    ("pr1", "Ismail Warsame", "WARSAME_10", "SO", "12m ago"),
    ("pr2", "Sven Eriksson", "SVEN_E", "SE", "1h ago"),
    ("pr3", "Diego Santos", "SANTOS_BR", "BR", "3h ago"),
]


def main():
    # SHIP CLEAN: no demo data at all. Real players register in-app (→ pendingReg),
    # the admin approves + drafts them into competitions, and standings build up
    # from there. We only initialise empty rosters + a meta marker.
    put("rosters", "pl", dict(playerIds=[]))
    put("rosters", "ucl", dict(playerIds=[]))
    put("rosters", "wc", dict(playerIds=[]))
    put("meta", "seed", dict(version=3, clean=True))
    print("Initialised empty rosters (ship-clean — no players/match/demo data).")


if __name__ == "__main__":
    main()
