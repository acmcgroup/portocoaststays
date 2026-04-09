# Porto Coast Stays — Controller de Projeto

Controller local para criar e gerir o projeto Porto Coast Stays no Zoho Projects,
sem guardar credenciais Zoho localmente. Tudo passa pela edge function Supabase
`zoho-projects-sync`, que já tem as credenciais nos secrets.

---

## Dependências

```powershell
pip install requests python-dotenv
```

---

## Setup (1x)

### 1. Copiar .env.example

```powershell
cp .env.example .env
```

Preencher `.env`:

```
SUPABASE_URL=https://avpfuhwmvlofncczqyfm.supabase.co

# Um destes (a edge function aceita qualquer um que coincida com os secrets):
INTERNAL_API_KEY=    # Secret INTERNAL_API_KEY — recomendado para scripts
SUPABASE_ANON_KEY=   # Anon/public JWT (Settings > API)
# Alternativa local: colocar SUPABASE_SERVICE_ROLE_KEY no .env (nunca no frontend)
```

A edge function `zoho-projects-sync` valida contra **ambos** os nomes de secret quando existem: `SUPABASE_ANON_KEY` ou `SB_ANON_KEY`, e `SUPABASE_SERVICE_ROLE_KEY` ou `SB_SERVICE_ROLE_KEY` (útil quando os digest no dashboard diferem).

### 2. Deploy da edge function (se ainda não estiver deployed)

No Supabase Dashboard ou CLI:

```bash
# Via Supabase CLI (na raiz do projeto dappio.pt)
supabase functions deploy zoho-projects-sync
```

A edge function reutiliza os secrets Zoho já existentes:
- `ZOHO_CLIENT_ID`
- `ZOHO_CLIENT_SECRET`
- `ZOHO_REFRESH_TOKEN`

### Erro Zoho `6403 Invalid OAuth scope`

Significa que o `ZOHO_REFRESH_TOKEN` nos secrets do Supabase foi obtido **só com scopes CRM**. É preciso gerar um **novo** refresh token na [Zoho API Console](https://api-console.zoho.eu) (mesmo client) com scopes de Projects, por exemplo:

```
ZohoProjects.portals.READ,ZohoProjects.projects.ALL,ZohoProjects.tasks.ALL,ZohoProjects.milestones.ALL,ZohoProjects.feeds.READ,ZohoProjects.search.READ
```

(Mantém também os scopes CRM que já usas, num único pedido OAuth, se quiseres um único token para `zoho-crm-sync` e `zoho-projects-sync`.)

Depois atualiza o secret:

```bash
supabase secrets set ZOHO_REFRESH_TOKEN="novo_refresh_token" --project-ref avpfuhwmvlofncczqyfm
```

---

## Utilização

```powershell
cd "d:\Projetos\Porto Coast Stays\09-gestao-projetos"

# 1. Listar portais — guarda portal_id em .state.json
python controller.py portals

# 2. Ver projetos existentes
python controller.py projects

# 3. Criar Porto Coast Stays (task lists + tasks completos)
python controller.py create

# 4. Re-sync tarefas em falta (idempotente — não duplica)
python controller.py sync

# 5. Ver estado e contagens
python controller.py status
```

---

## Estrutura criada no Zoho Projects

**Projeto:** Porto Coast Stays — Operações

| Task List | Nº Tarefas | Fase |
|---|---|---|
| B1 — Preparação Física | 8 | Onboarding |
| B2 — Fotos Profissionais | 4 | Onboarding |
| B3 — Listing e OTAs | 4 | Onboarding |
| B4 — Sistemas e Automações | 9 | Onboarding |
| B5 — Go-Live | 4 | Onboarding |
| B6 — Primeiras Reviews | 5 | Onboarding |
| Fase 1 — Lançamento (0–30d) | 2 | Roadmap |
| Fase 2 — Validação (30–90d) | 3 | Roadmap |
| Fase 3 — Expansão (3–6 meses) | 4 | Roadmap |
| Fase 4 — Sistema (6–12 meses) | 4 | Roadmap |
| Direção — Integrações e Stack | 7 | Governação |

---

## Edge function: zoho-projects-sync

**Localização:** `d:\Projetos\dappio.pt\website\supabase\functions\zoho-projects-sync\index.ts`

Actions suportadas:

| Action | Params | Descrição |
|---|---|---|
| `list_portals` | — | Lista portais Zoho |
| `list_projects` | `portal_id` | Lista projetos no portal |
| `get_project` | `portal_id`, `project_id` | Detalhes do projeto |
| `create_project` | `portal_id`, `project` | Cria projeto |
| `list_task_lists` | `portal_id`, `project_id` | Lista task lists |
| `create_task_list` | `portal_id`, `project_id`, `task_list` | Cria task list |
| `list_tasks` | `portal_id`, `project_id`, `task_list_id?` | Lista tasks |
| `create_task` | `portal_id`, `project_id`, `task` | Cria task |
| `update_task` | `portal_id`, `project_id`, `task_id`, `updates` | Atualiza task |
| `create_milestone` | `portal_id`, `project_id`, `milestone` | Cria milestone |

---

## Adicionar novo imóvel

```powershell
# No futuro: basta duplicar o projeto template em Zoho Projects
# ou correr via Zoho Flow quando deal for ganho no CRM
python controller.py create  # cria se não existir, faz sync se existir
```

---

## Scopes OAuth necessários (Zoho API Console)

```
ZohoProjects.portals.READ
ZohoProjects.projects.ALL
ZohoProjects.tasks.ALL
ZohoProjects.milestones.ALL
```

Se o token atual não tem estes scopes, ir a:
https://api-console.zoho.eu → Self Client → Gerar novo refresh token com scopes acima.
