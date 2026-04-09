"""One-off test: call deployed zoho-projects-sync. Run from any dir."""
import json
import re
import sys
from pathlib import Path

import requests

PROJETOS = Path(__file__).resolve().parents[2]
CLIENT = PROJETOS / "dappio.pt" / "website" / "src" / "integrations" / "supabase" / "client.ts"
ENV_LOCAL = PROJETOS / "dappio.pt" / "website" / "supabase" / ".env.local"


def _load_env_local() -> dict[str, str]:
    out: dict[str, str] = {}
    if ENV_LOCAL.is_file():
        for line in ENV_LOCAL.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, _, v = line.partition("=")
            out[k.strip()] = v.strip().strip('"').strip("'")
    return out


_env = _load_env_local()
service_role = _env.get("SUPABASE_SERVICE_ROLE_KEY", "")

text = CLIENT.read_text(encoding="utf-8")
m = re.search(r'SUPABASE_PUBLISHABLE_KEY\s*=\s*"([^"]+)"', text)
anon = m.group(1) if m else ""

# Prefer service role for zoho-projects-sync (anon in repo often != edge secret SUPABASE_ANON_KEY)
key = service_role or anon
if not key:
    sys.exit("Need SUPABASE_SERVICE_ROLE_KEY in dappio.pt/website/supabase/.env.local or anon in client.ts")

BASE = "https://avpfuhwmvlofncczqyfm.supabase.co/functions/v1"
headers = {
    "apikey": key,
    "Authorization": f"Bearer {key}",
    "Content-Type": "application/json",
}


def post(fn: str, body: dict) -> tuple[int, dict]:
    r = requests.post(f"{BASE}/{fn}", json=body, headers=headers, timeout=90)
    try:
        return r.status_code, r.json()
    except Exception:
        return r.status_code, {"raw": r.text[:2000]}


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "list_portals"
    code: int
    data: dict

    if cmd == "ping_crm":
        r = requests.post(
            f"{BASE}/zoho-crm-sync",
            json={"action": "list_products"},
            headers={"Content-Type": "application/json"},
            timeout=90,
        )
        try:
            code, data = r.status_code, r.json()
        except Exception:
            code, data = r.status_code, {"raw": r.text[:2000]}
    elif cmd == "crm_auth":
        code, data = post(
            "zoho-crm-sync",
            {"action": "search_lead", "email": "nonexistent-test@example.com"},
        )
    elif cmd == "list_portals":
        code, data = post("zoho-projects-sync", {"action": "list_portals"})
    elif cmd == "create_test":
        portal_id = sys.argv[2]
        code, data = post(
            "zoho-projects-sync",
            {
                "action": "create_project",
                "portal_id": portal_id,
                "project": {
                    "name": "TEST API — Porto Coast (apagar se quiseres)",
                    "description": "Criado automaticamente para validar zoho-projects-sync.",
                },
            },
        )
    else:
        print("Usage: _test_zoho_projects_api.py [ping_crm|crm_auth|list_portals|create_test PORTAL_ID]")
        return
    print("HTTP", code)
    print(json.dumps(data, indent=2)[:8000])


if __name__ == "__main__":
    main()
