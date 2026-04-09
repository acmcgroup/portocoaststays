"""
controller.py — Porto Coast Stays local project controller
=============================================================
Calls the zoho-projects-sync Supabase edge function to manage
Zoho Projects without storing Zoho credentials locally.

Usage (PowerShell):
  python controller.py portals              # list Zoho portals, auto-saves portal ID
  python controller.py projects             # list existing projects
  python controller.py create               # create Porto Coast Stays in Zoho Projects
  python controller.py sync                 # re-sync tasks (adds missing, skips existing)
  python controller.py status               # print project URL and task counts
"""

from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path
from typing import Any

import requests
from dotenv import load_dotenv

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
ROOT = Path(__file__).resolve().parent
load_dotenv(ROOT / ".env")

SUPABASE_URL = os.environ["SUPABASE_URL"].rstrip("/")
SUPABASE_ANON_KEY = os.environ.get("SUPABASE_ANON_KEY", "")
INTERNAL_API_KEY = os.environ.get("INTERNAL_API_KEY", "")
ZOHO_PORTAL_ID = os.environ.get("ZOHO_PORTAL_ID", "")

EDGE_URL = f"{SUPABASE_URL}/functions/v1/zoho-projects-sync"

STATE_FILE = ROOT / ".state.json"   # stores portal_id and project_id between runs

# ---------------------------------------------------------------------------
# HTTP helpers
# ---------------------------------------------------------------------------

def _headers() -> dict[str, str]:
    h = {"Content-Type": "application/json"}
    if INTERNAL_API_KEY:
        h["x-internal-key"] = INTERNAL_API_KEY
    elif SUPABASE_ANON_KEY:
        h["apikey"] = SUPABASE_ANON_KEY
        h["Authorization"] = f"Bearer {SUPABASE_ANON_KEY}"
    return h


def call(action: str, **kwargs: Any) -> dict[str, Any]:
    payload = {"action": action, **kwargs}
    r = requests.post(EDGE_URL, json=payload, headers=_headers(), timeout=30)
    if not r.ok:
        print(f"[HTTP {r.status_code}] {r.text[:400]}")
        r.raise_for_status()
    return r.json()


def load_state() -> dict[str, Any]:
    if STATE_FILE.exists():
        return json.loads(STATE_FILE.read_text())
    return {}


def save_state(data: dict[str, Any]) -> None:
    STATE_FILE.write_text(json.dumps(data, indent=2))


# ---------------------------------------------------------------------------
# Porto Coast Stays — project definition (source of truth from markdown)
# ---------------------------------------------------------------------------

PROJECT_DEF = {
    "name": "Porto Coast Stays — Operações",
    "description": (
        "Gestão de alojamento local: onboarding por imóvel, operação diária, "
        "integrações de sistemas e direção estratégica."
    ),
    "status": "active",
    "template_id": None,       # set to a template ID if you have one in Zoho
}

# Each task list → list of (name, description, priority, tag)
# priority: "high" | "medium" | "low"  (Zoho accepts these strings)
TASK_LISTS: list[dict[str, Any]] = [
    {
        "name": "B1 — Preparação Física",
        "milestone": "Onboarding Imóvel",
        "tasks": [
            ("Visita e aprovação do imóvel",
             "Estado, equipamentos, acesso prédio, RNAL se aplicável", "high"),
            ("Instalar Nuki + Keypad + Bridge",
             "Bloqueia automação de códigos e check-in autónomo", "high"),
            ("Configurar acesso porta do prédio",
             "Teclado numérico ou integração com PMS", "high"),
            ("Auditoria WiFi e climatização",
             "Mín. 50 Mbps; AC/aquecimento testado", "medium"),
            ("Stock cozinha e WC",
             "Café, detergentes, papel higiénico, amenities", "medium"),
            ("Roupa de cama e toalhas — 2–3 sets",
             "Qualidade hotel; um set por cama + extras em armário", "medium"),
            ("Kit boas-vindas",
             "Água, snack local, café cápsula, cartão personalizado", "low"),
            ("Limpeza pré-fotos",
             "Imóvel 100% pronto para sessão fotográfica", "high"),
        ],
    },
    {
        "name": "B2 — Fotos Profissionais",
        "milestone": "Onboarding Imóvel",
        "tasks": [
            ("Contratar fotógrafo AL",
             "Orçamento 150–300 €; briefing: ordem de fotos e styling", "high"),
            ("Preparar set do dia de fotos",
             "Luz natural, sem clutter, cama feita, toalhas dobradas estilo hotel", "high"),
            ("Sessão e seleção 15–25 fotos",
             "Horizontal; ordem: capa (quarto/vista) → sala → cozinha → WC → detalhes", "high"),
            ("Entrega final validada pelo gestor",
             "Consistência visual; aprovação antes de publicar listing", "high"),
        ],
    },
    {
        "name": "B3 — Listing e OTAs",
        "milestone": "Onboarding Imóvel",
        "tasks": [
            ("Criar listing Airbnb — título, hook, comodidades",
             "Instant Book ativo; calendário 4–6 meses; pricing lançamento -20/-30%", "high"),
            ("Criar listing Booking.com",
             "Replicar conteúdo do Airbnb; ligar ao PMS via channel manager", "high"),
            ("Configurar regras da casa e políticas",
             "Silêncio 22h, não fumar, máx. hóspedes, pet policy", "medium"),
            ("Ativar descontos semanal/mensal de arranque",
             "5–10% semanal / 15–20% mensal; estadia mín. 1–2 noites", "medium"),
        ],
    },
    {
        "name": "B4 — Sistemas e Automações",
        "milestone": "Onboarding Imóvel",
        "tasks": [
            ("PMS + Channel Manager (Hostaway/Smoobu)",
             "Ligar Airbnb + Booking; testar sync de calendário", "high"),
            ("Integração Nuki ↔ PMS",
             "Código único por reserva; ativa no check-in, expira no check-out", "high"),
            ("Sequência de 9 mensagens automáticas",
             "Ver fluxo-completo.md: reserva confirmada → D-7 → D-1 15h → check-in → H+2 → D-1 20h → manhã saída → D+1", "high"),
            ("Notificação automática de limpeza pós-checkout",
             "PMS → WhatsApp grupo operações; inclui hora saída e próxima chegada", "high"),
            ("Pricelabs — pricing dinâmico",
             "Base/min/max definidos; fds +15–25%; eventos +30–80%; Health Score ativo", "medium"),
            ("Guia digital do apartamento",
             "Notion/PDF/Hostaway: código porta, WiFi, eletrodomésticos, regras, emergências", "medium"),
            ("Faturação InvoiceXpress — integração PMS",
             "IVA 6%; emissão automática por reserva; e-fatura → AT", "high"),
            ("SIBA — registo de hóspedes",
             "Chekin ou portal manual; teste end-to-end antes do go-live", "high"),
            ("Relatório mensal automático proprietário",
             "Export PMS: receita bruta, comissões, custos, líquido; envio até dia 5", "medium"),
        ],
    },
    {
        "name": "B5 — Go-Live",
        "milestone": "Onboarding Imóvel",
        "tasks": [
            ("Reserva de teste end-to-end",
             "Código Nuki, mensagens, calendário sync, notificação limpeza — tudo verificado", "high"),
            ("Validar anti double-booking",
             "Airbnb vs Booking vs PMS — testar bloqueio cruzado", "high"),
            ("Limpeza principal + fallback contratados",
             "Contacto backup disponível em <30 min", "high"),
            ("Publicar listing e monitorizar 72h",
             "Resposta <1h; aceitação >90%; Instant Book ativo; sem bloqueios", "high"),
        ],
    },
    {
        "name": "B6 — Primeiras Reviews",
        "milestone": "Onboarding Imóvel",
        "tasks": [
            ("SLA de respostas <1h",
             "Notificações push PMS + Airbnb ativas no telemóvel", "high"),
            ("Pedido de review D+1 automático",
             "Template simples: 'a review would mean a lot' — configurado no PMS", "medium"),
            ("Responder a todas as reviews <48h",
             "Airbnb e Booking; reviews negativas com ação correctiva pública", "medium"),
            ("Ajuste de pricing após 3–5 reviews",
             "+10% por bloco de 3–5 reviews; Pricelabs pleno após 10 reviews", "medium"),
            ("Marco: 10 reviews >4.8 e ocupação >65%",
             "KPIs semanais: resposta, aceitação, score, ocupação futura 30d", "high"),
        ],
    },
    {
        "name": "Fase 1 — Lançamento (0–30d)",
        "milestone": "Fase 1",
        "tasks": [
            ("Completar Blocos B1–B6 — imóvel 1 (T0 Boa Morte)",
             "Marco: primeira reserva confirmada", "high"),
            ("Replicar onboarding — imóvel 2 (T1 Matosinhos)",
             "Usar template de projeto; paralelo ao B6 do imóvel 1", "high"),
        ],
    },
    {
        "name": "Fase 2 — Validação (30–90d)",
        "milestone": "Fase 2",
        "tasks": [
            ("Pricelabs em modo pleno + análise ocupação/ADR",
             "Dashboard semanal: ocupação, RevPAR, ADR vs mercado", "medium"),
            ("Documentar SOPs para delegação",
             "Limpeza, suporte hóspede, onboarding novo imóvel — tudo escrito", "medium"),
            ("Marco: 10 reviews positivas + ocupação >65%",
             "Subir preços para par com mercado; preparar pitch para proprietários", "high"),
        ],
    },
    {
        "name": "Fase 3 — Expansão (3–6 meses)",
        "milestone": "Fase 3",
        "tasks": [
            ("Pipeline de proprietários — 10–15 abordagens",
             "Usar proposta-proprietarios.md; argumento: 15% vs 25% Liiiving", "medium"),
            ("Fechar 1–3 contratos de gestão (revenue share 15%)",
             "Setup inicial €500 por unidade", "medium"),
            ("Contratar suporte part-time",
             "Inbox e escalations de hóspedes; libertar diretor de execução", "low"),
            ("Marco: 5 unidades geridas, receita gestão >2.000 €/mês",
             "Relatórios proprietários; dados reais de ROI para novos pitches", "high"),
        ],
    },
    {
        "name": "Fase 4 — Sistema (6–12 meses)",
        "milestone": "Fase 4",
        "tasks": [
            ("Operations manager + limpeza dedicada",
             "Nível 10+ unidades; custo marginal por unidade desce", "low"),
            ("Sistema de onboarding em <1 semana por imóvel",
             "Checklist B1–B6 executa em 5 dias; sem dependência de diretor", "low"),
            ("Dashboard consolidado — todos os imóveis numa vista",
             "Hostaway + Pricelabs; KPIs semanais em ecrã único", "medium"),
            ("Marco: 10 unidades, receita >5.000 €/mês, operação delegada",
             "Avaliar site próprio para reservas diretas (0% OTA)", "high"),
        ],
    },
    {
        "name": "Direção — Integrações e Stack",
        "milestone": "Stack Direção",
        "tasks": [
            ("Zoho Projects: template por imóvel",
             "Projeto-mãe 'Porto Coast Stays'; duplicar por unidade nova", "high"),
            ("Zoho CRM ↔ Projects via Zoho Flow",
             "Deal ganho (proprietário) → criar projeto com Blocos B1–B6 automaticamente", "high"),
            ("Deploy zoho-projects-sync edge function",
             "Supabase Dashboard > Edge Functions > deploy; testar list_portals", "high"),
            ("GitHub: repo docs + branch protection em main",
             "PR checklist para alterações a SOPs; sem commits diretos em main", "medium"),
            ("Netlify / Vercel: deploy automático via GitHub",
             "preview por PR; main = produção; secrets no painel, não no repo", "medium"),
            ("Painel semanal de direção (KPIs read-only)",
             "Resposta <1h, ocupação, reviews, limpezas OK — agregador Sheets ou Analytics", "high"),
            ("Supabase: só para produto próprio (guest app futura)",
             "PMS continua como fonte de verdade para reservas e calendário", "low"),
        ],
    },
]

# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

def cmd_portals() -> None:
    """List Zoho portals and save portal ID to state."""
    print("📡 Fetching Zoho portals…")
    data = call("list_portals")
    portals = data.get("portals") or []
    if not portals:
        print("No portals found or unexpected response:")
        print(json.dumps(data, indent=2))
        return
    print(f"\n{'ID':<20} {'Name'}")
    print("─" * 50)
    for p in portals:
        print(f"{p['id']:<20} {p['name']}")

    state = load_state()
    if len(portals) == 1:
        state["portal_id"] = portals[0]["id"]
        save_state(state)
        print(f"\n✅ Saved portal_id={portals[0]['id']} to .state.json")
        print("   Add it to .env as ZOHO_PORTAL_ID= if you want it permanent.")
    else:
        print("\nMultiple portals. Edit .state.json or .env to set portal_id.")


def cmd_projects() -> None:
    """List existing Zoho Projects in the portal."""
    state = load_state()
    portal_id = ZOHO_PORTAL_ID or state.get("portal_id")
    if not portal_id:
        print("❌ No portal_id. Run: python controller.py portals first.")
        return
    print(f"📋 Fetching projects in portal {portal_id}…")
    data = call("list_projects", portal_id=portal_id)
    projects = data.get("projects") or []
    if not projects:
        print("No projects found or unexpected response:")
        print(json.dumps(data, indent=2))
        return
    print(f"\n{'ID':<20} {'Name':<40} Status")
    print("─" * 70)
    for p in projects:
        print(f"{p['id']:<20} {p['name']:<40} {p.get('status', {}).get('name', '-')}")


def cmd_create() -> None:
    """Create Porto Coast Stays project with all task lists and tasks."""
    state = load_state()
    portal_id = ZOHO_PORTAL_ID or state.get("portal_id")
    if not portal_id:
        print("❌ No portal_id. Run: python controller.py portals first.")
        return

    # Check if project already exists
    print(f"🔍 Checking existing projects in portal {portal_id}…")
    projects_data = call("list_projects", portal_id=portal_id)
    existing = {p["name"]: p["id"] for p in (projects_data.get("projects") or [])}

    if PROJECT_DEF["name"] in existing:
        project_id = existing[PROJECT_DEF["name"]]
        print(f"ℹ️  Project already exists (id={project_id}). Running sync instead…")
        state["project_id"] = project_id
        save_state(state)
        cmd_sync()
        return

    # Create project
    print(f"🚀 Creating project '{PROJECT_DEF['name']}'…")
    proj_payload = {
        "name": PROJECT_DEF["name"],
        "description": PROJECT_DEF["description"],
    }
    resp = call("create_project", portal_id=portal_id, project=proj_payload)
    created = (resp.get("projects") or [{}])[0]
    project_id = created.get("id")
    if not project_id:
        print("❌ Failed to create project:")
        print(json.dumps(resp, indent=2))
        return
    print(f"✅ Project created — id={project_id}")
    state["project_id"] = project_id
    save_state(state)

    _create_task_lists(portal_id, project_id, mode="create")


def cmd_sync() -> None:
    """Add missing task lists and tasks (idempotent)."""
    state = load_state()
    portal_id = ZOHO_PORTAL_ID or state.get("portal_id")
    project_id = state.get("project_id")
    if not portal_id or not project_id:
        print("❌ Missing portal_id or project_id in .state.json. Run: python controller.py create")
        return
    print(f"🔄 Syncing task lists for project {project_id}…")
    _create_task_lists(portal_id, project_id, mode="sync")


def cmd_status() -> None:
    """Print project status and task counts."""
    state = load_state()
    portal_id = ZOHO_PORTAL_ID or state.get("portal_id")
    project_id = state.get("project_id")
    if not portal_id or not project_id:
        print("❌ Missing portal_id or project_id. Run portals → create first.")
        return
    data = call("get_project", portal_id=portal_id, project_id=project_id)
    proj = (data.get("projects") or [{}])[0]
    print(f"\n📊 Project: {proj.get('name')}")
    print(f"   ID     : {proj.get('id')}")
    print(f"   Status : {proj.get('status', {}).get('name', '-')}")
    print(f"   URL    : {proj.get('link', {}).get('self', {}).get('url', '-')}")

    tl_data = call("list_task_lists", portal_id=portal_id, project_id=project_id)
    task_lists = tl_data.get("tasklists") or []
    print(f"\n   Task Lists: {len(task_lists)}")
    for tl in task_lists:
        print(f"     • {tl['name']}")


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

def _create_task_lists(portal_id: str, project_id: str, mode: str = "create") -> None:
    # Fetch existing task lists to skip duplicates in sync mode
    existing_tl: dict[str, str] = {}
    if mode == "sync":
        tl_data = call("list_task_lists", portal_id=portal_id, project_id=project_id)
        existing_tl = {tl["name"]: tl["id"] for tl in (tl_data.get("tasklists") or [])}

    for tl_def in TASK_LISTS:
        tl_name = tl_def["name"]
        if tl_name in existing_tl:
            tl_id = existing_tl[tl_name]
            print(f"  ↩  Task list exists: {tl_name}")
        else:
            resp = call(
                "create_task_list",
                portal_id=portal_id,
                project_id=project_id,
                task_list={"name": tl_name},
            )
            created_lists = resp.get("tasklists") or []
            if not created_lists:
                print(f"  ❌ Failed to create task list '{tl_name}':")
                print("    ", json.dumps(resp, indent=2)[:300])
                continue
            tl_id = created_lists[0]["id"]
            print(f"  ✅ Task list created: {tl_name} (id={tl_id})")

        # Fetch existing tasks for this list (sync mode)
        existing_tasks: set[str] = set()
        if mode == "sync":
            t_data = call(
                "list_tasks",
                portal_id=portal_id,
                project_id=project_id,
                task_list_id=tl_id,
            )
            existing_tasks = {t["name"] for t in (t_data.get("tasks") or [])}

        for task_name, task_desc, priority in tl_def["tasks"]:
            if task_name in existing_tasks:
                print(f"    ↩  Task exists: {task_name}")
                continue
            t_resp = call(
                "create_task",
                portal_id=portal_id,
                project_id=project_id,
                task={
                    "name": task_name,
                    "description": task_desc,
                    "priority": priority,
                    "tasklist_id": tl_id,
                },
            )
            created_tasks = t_resp.get("tasks") or []
            if created_tasks:
                print(f"    ✅ Task: {task_name}")
            else:
                print(f"    ❌ Failed: {task_name} → {json.dumps(t_resp)[:200]}")
            time.sleep(0.15)  # stay within Zoho rate limits

    print("\n🎉 Done.")


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------
COMMANDS = {
    "portals": cmd_portals,
    "projects": cmd_projects,
    "create": cmd_create,
    "sync": cmd_sync,
    "status": cmd_status,
}

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] not in COMMANDS:
        print("Usage: python controller.py <command>")
        print("Commands:", " | ".join(COMMANDS))
        sys.exit(1)

    COMMANDS[sys.argv[1]]()
