/* =============================================================
   Porto Coast Stays Admin — Core JS
   ============================================================= */

function getAdminConfig() {
  const c = typeof window !== 'undefined' && window.ADMIN_CONFIG;
  if (!c || !c.SUPABASE_URL || !c.SUPABASE_ANON_KEY) {
    throw new Error('Missing Supabase config: include /admin/config.js before admin.js');
  }
  return c;
}

const _cfg = getAdminConfig();
const ADMIN_BASE = '/admin';
const CLIENT_ID = _cfg.CLIENT_ID || 'portocoaststays';

function adminHref(page) {
  const p = String(page ?? '').replace(/^\//, '').replace(/\.html$/i, '');
  if (!p || p === 'index') return `${ADMIN_BASE}/`;
  return `${ADMIN_BASE}/${p}`;
}

const _sb = supabase.createClient(
  _cfg.SUPABASE_URL,
  _cfg.SUPABASE_ANON_KEY,
  { auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true } }
);

// ── Auth ─────────────────────────────────────────────────────

/** RPC só insere (user_id, portocoaststays, 'user'); promoção a admin só via admin existente. */
async function garantirAdesaoPortalPosLogin() {
  const { error } = await _sb.rpc('portocoaststays_ensure_membership_on_login');
  if (error) console.warn('[Admin] portocoaststays_ensure_membership_on_login:', error.message);
}

/** Chama após sessão já existente (ex.: voltar ao login com cookie) para criar adesão a este portal se faltar. */
async function sincronizarAdesaoPortalSeAutenticado() {
  const session = await obterSessao();
  if (!session) return null;
  await garantirAdesaoPortalPosLogin();
  return obterAdesaoPortalAtual();
}

async function obterAdesaoPortalAtual() {
  const { data, error } = await _sb.rpc('minha_adesao_portal', { p_client: CLIENT_ID });
  if (error) { console.error('[Admin] minha_adesao_portal failed:', error.message); return null; }
  return data?.[0] || null;
}

async function login(email, password) {
  const { data, error } = await _sb.auth.signInWithPassword({ email, password });
  if (error) throw new Error(translateAuthError(error.message));
  await garantirAdesaoPortalPosLogin();
  return data.session;
}

async function logout() {
  await _sb.auth.signOut();
  window.location.href = adminHref('login');
}

async function signOutLocal() { await _sb.auth.signOut(); }

async function obterSessao() {
  const { data: { session } } = await _sb.auth.getSession();
  return session;
}

async function obterUser() {
  const { data: { user } } = await _sb.auth.getUser();
  return user;
}

async function obterMeuRole() {
  const { data, error } = await _sb.rpc('obter_meu_role');
  if (error) { console.error('[Admin] obter_meu_role failed:', error.message); return 'user'; }
  return data || 'user';
}

async function obterMeuClient() {
  const { data, error } = await _sb.rpc('obter_meu_client');
  if (error) { console.error('[Admin] obter_meu_client failed:', error.message); return null; }
  return data || null;
}

async function verificarAdmin() {
  const session = await obterSessao();
  if (!session) { window.location.href = adminHref('login'); return null; }
  const { data, error } = await _sb.rpc('minha_adesao_portal', { p_client: CLIENT_ID });
  const adesao = data?.[0];
  if (error || !adesao || adesao.role !== 'admin') {
    await _sb.auth.signOut();
    window.location.href = adminHref('login') + '?erro=sem_permissao';
    return null;
  }
  return session;
}

async function verificarAcesso() {
  const session = await obterSessao();
  if (!session) { window.location.href = adminHref('login'); return null; }
  const { data, error } = await _sb.rpc('minha_adesao_portal', { p_client: CLIENT_ID });
  if (error || !data?.[0]) {
    await _sb.auth.signOut();
    window.location.href = adminHref('login') + '?erro=sem_permissao';
    return null;
  }
  return session;
}

_sb.auth.onAuthStateChange((event) => {
  if (event === 'SIGNED_OUT') window.location.href = adminHref('login');
});

function translateAuthError(msg) {
  if (msg.includes('Invalid login credentials')) return 'Email ou palavra-passe incorretos.';
  if (msg.includes('Email not confirmed'))       return 'Confirme o seu email antes de entrar.';
  if (msg.includes('Too many requests'))         return 'Demasiadas tentativas. Aguarde um momento.';
  if (msg.includes('User not found'))            return 'Utilizador não encontrado.';
  return msg;
}

// ── Users ─────────────────────────────────────────────────────

async function listarUtilizadores() {
  const { data, error } = await _sb.rpc('listar_utilizadores_do_portal', { p_client: CLIENT_ID });
  if (error) throw error;
  return data || [];
}

async function promoverAdmin(userId) {
  const { error } = await _sb.rpc('portocoaststays_promover_admin', { target_id: userId });
  if (error) throw new Error(error.message);
}

async function revogarAdmin(userId) {
  const { error } = await _sb.rpc('portocoaststays_revogar_admin', { target_id: userId });
  if (error) throw new Error(error.message);
}

async function assignClient(userId) {
  const { error } = await _sb.rpc('portocoaststays_assign_client', { target_id: userId });
  if (error) throw new Error(error.message);
}

// ── Posts CRUD ────────────────────────────────────────────────

async function listarPosts({ status = null, pesquisa = '', limite = 50, offset = 0 } = {}) {
  let q = _sb.from('posts').select('*', { count: 'exact' });
  if (status)   q = q.eq('status', status);
  if (pesquisa) q = q.or(`pt_title.ilike.%${pesquisa}%,en_title.ilike.%${pesquisa}%,slug_pt.ilike.%${pesquisa}%`);
  q = q.order('created_at', { ascending: false }).range(offset, offset + limite - 1);
  const { data, error, count } = await q;
  if (error) throw error;
  return { data, count };
}

async function obterPost(id) {
  const { data, error } = await _sb.from('posts').select('*').eq('id', id).single();
  if (error) throw error;
  return data;
}

async function criarPost(payload) {
  const { data, error } = await _sb.from('posts').insert(payload).select().single();
  if (error) throw error;
  return data;
}

async function atualizarPost(id, payload) {
  const { data, error } = await _sb.from('posts').update(payload).eq('id', id).select().single();
  if (error) throw error;
  return data;
}

async function publicarPost(id) {
  const { data, error } = await _sb.from('posts')
    .update({ status: 'published', published_at: new Date().toISOString() })
    .eq('id', id).select().single();
  if (error) throw error;
  return data;
}

async function despublicarPost(id) {
  const { data, error } = await _sb.from('posts').update({ status: 'draft' }).eq('id', id).select().single();
  if (error) throw error;
  return data;
}

async function apagarPost(id) {
  const { error } = await _sb.from('posts').delete().eq('id', id);
  if (error) throw error;
}

const POST_PUBLISH_SYNC_SLOP_MS = 5000;
function postTemAlteracoesAposPublicacao(post) {
  if (!post || post.status !== 'published' || !post.published_at || !post.updated_at) return false;
  const u = new Date(post.updated_at).getTime();
  const p = new Date(post.published_at).getTime();
  if (Number.isNaN(u) || Number.isNaN(p)) return false;
  return u > p + POST_PUBLISH_SYNC_SLOP_MS;
}

// ── Build trigger ─────────────────────────────────────────────

let _buildDebounceTimer = null;
const BUILD_DEBOUNCE_MS = 1500;
let _buildWaiters = [];

async function dispararBuildSitePublico() {
  const session = await obterSessao();
  const token = session?.access_token || '';
  const r = await fetch('/.netlify/functions/trigger-build', {
    method: 'POST',
    headers: token ? { Authorization: `Bearer ${token}` } : {},
  });
  if (!r.ok) {
    let msg = 'HTTP ' + r.status;
    try { const j = await r.json(); if (j.error) msg = j.error; } catch (_) {}
    throw new Error(msg);
  }
  return true;
}

function agendarBuildSitePublico() {
  return new Promise((resolve) => {
    _buildWaiters.push(resolve);
    if (_buildDebounceTimer) clearTimeout(_buildDebounceTimer);
    _buildDebounceTimer = setTimeout(async () => {
      _buildDebounceTimer = null;
      const waiters = _buildWaiters.splice(0);
      try {
        await dispararBuildSitePublico();
        waiters.forEach((w) => w({ ok: true }));
      } catch (e) {
        waiters.forEach((w) => w({ ok: false, error: e.message || String(e) }));
      }
    }, BUILD_DEBOUNCE_MS);
  });
}

// ── Media ─────────────────────────────────────────────────────

const MEDIA_BUCKET = _cfg.STORAGE_BUCKET || 'portocoaststays-media';

function safeStorageObjectKey(fileName) {
  const m = String(fileName).match(/\.([^.]+)$/);
  const rawExt = m ? m[1] : 'bin';
  const ext = rawExt.toLowerCase().replace(/[^a-z0-9]/g, '') || 'bin';
  const base = String(fileName)
    .replace(/\.[^.]+$/, '')
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-zA-Z0-9._-]+/g, '-')
    .replace(/^-+|-+$/g, '').slice(0, 100);
  return `${base || 'image'}-${Date.now()}.${ext}`;
}

async function uploadMedia(file, opts = {}) {
  const postId = opts.postId || null;
  const key = opts.path || (postId
    ? `posts/${postId}/${safeStorageObjectKey(file.name)}`
    : `library/${safeStorageObjectKey(file.name)}`);
  const { data, error } = await _sb.storage.from(MEDIA_BUCKET).upload(key, file, {
    upsert: false, contentType: file.type || undefined,
  });
  if (error) throw new Error(error.message || String(error));
  const { data: urlData } = _sb.storage.from(MEDIA_BUCKET).getPublicUrl(data.path);
  const publicUrl = urlData.publicUrl;
  const row = { filename: file.name, storage_path: data.path, public_url: publicUrl,
    mime_type: file.type || 'application/octet-stream', file_size: file.size };
  if (postId) row.post_id = postId;
  const { error: dbErr } = await _sb.from('media_assets').insert(row);
  if (dbErr) console.warn('[Admin] media_assets insert failed:', dbErr.message);
  return publicUrl;
}

async function listarMedia({ limite = 50, offset = 0, preferPostId = null } = {}) {
  const { data, error } = await _sb.from('media_assets').select('*')
    .order('created_at', { ascending: false }).range(offset, offset + limite - 1);
  if (error) throw error;
  const list = data || [];
  if (preferPostId && list.length) {
    const rank = (row) => row.post_id === preferPostId ? 0 : row.post_id == null ? 1 : 2;
    list.sort((a, b) => rank(a) - rank(b) || new Date(b.created_at) - new Date(a.created_at));
  }
  return list;
}

async function apagarMedia(storagePath, assetId) {
  await _sb.storage.from(MEDIA_BUCKET).remove([storagePath]);
  if (assetId) await _sb.from('media_assets').delete().eq('id', assetId);
}

// ── Properties CRUD ───────────────────────────────────────────

async function listarPropriedades({ status = null, ownerId = null } = {}) {
  let q = _sb.from('properties').select('*, profiles(nome, email)', { count: 'exact' });
  if (status)  q = q.eq('status', status);
  if (ownerId) q = q.eq('owner_id', ownerId);
  q = q.order('created_at', { ascending: false });
  const { data, error, count } = await q;
  if (error) throw error;
  return { data, count };
}

async function obterPropriedade(id) {
  const { data, error } = await _sb.from('properties')
    .select('*, profiles(nome, email)').eq('id', id).single();
  if (error) throw error;
  return data;
}

async function criarPropriedade(payload) {
  const { data, error } = await _sb.from('properties').insert(payload).select().single();
  if (error) throw error;
  return data;
}

async function atualizarPropriedade(id, payload) {
  const { data, error } = await _sb.from('properties').update(payload).eq('id', id).select().single();
  if (error) throw error;
  return data;
}

async function apagarPropriedade(id) {
  const { error } = await _sb.from('properties').delete().eq('id', id);
  if (error) throw error;
}

// ── Task templates ────────────────────────────────────────────

async function listarTaskTemplates({ ambito = null } = {}) {
  let q = _sb.from('task_templates').select('*').order('sort_order', { ascending: true });
  if (ambito) q = q.eq('ambito', ambito);
  const { data, error } = await q;
  if (error) throw error;
  return data || [];
}

// ── Property task status ──────────────────────────────────────

async function listarPropertyTaskStatus(propertyId) {
  const { data, error } = await _sb.from('property_task_status')
    .select('*').eq('property_id', propertyId);
  if (error) throw error;
  return data || [];
}

async function upsertPropertyTaskStatus(propertyId, taskId, status) {
  const { data, error } = await _sb.from('property_task_status')
    .upsert({ property_id: propertyId, task_id: taskId, status,
      updated_by: (await obterUser())?.id, updated_at: new Date().toISOString() },
      { onConflict: 'property_id,task_id' })
    .select().single();
  if (error) throw error;
  return data;
}

// ── Owner global task status ──────────────────────────────────

async function listarOwnerGlobalTaskStatus(ownerId) {
  const { data, error } = await _sb.from('owner_global_task_status')
    .select('*').eq('owner_id', ownerId);
  if (error) throw error;
  return data || [];
}

async function upsertOwnerGlobalTaskStatus(ownerId, taskId, status) {
  const { data, error } = await _sb.from('owner_global_task_status')
    .upsert({ owner_id: ownerId, task_id: taskId, status,
      updated_by: (await obterUser())?.id, updated_at: new Date().toISOString() },
      { onConflict: 'owner_id,task_id' })
    .select().single();
  if (error) throw error;
  return data;
}

// ── Task comments ─────────────────────────────────────────────

async function listarTaskComments({ propertyId = null, ownerId = null, taskId, showInternal = false } = {}) {
  let q = _sb.from('task_comments').select('*, profiles(nome, email, role)')
    .eq('task_id', taskId).order('created_at', { ascending: true });
  if (propertyId) q = q.eq('property_id', propertyId);
  if (ownerId)    q = q.eq('owner_id', ownerId);
  if (!showInternal) q = q.eq('is_internal', false);
  const { data, error } = await q;
  if (error) throw error;
  return data || [];
}

async function criarTaskComment({ propertyId = null, ownerId = null, taskId, content, isInternal = false }) {
  const user = await obterUser();
  const role = await obterMeuRole();
  const { data, error } = await _sb.from('task_comments').insert({
    property_id: propertyId, owner_id: ownerId, task_id: taskId,
    author_id: user.id, author_role: role, content, is_internal: isInternal,
  }).select().single();
  if (error) throw error;
  return data;
}

async function apagarTaskComment(commentId) {
  const { error } = await _sb.from('task_comments').delete().eq('id', commentId);
  if (error) throw error;
}

// ── Toast ─────────────────────────────────────────────────────

function escapeHtml(s) {
  return String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function toast(mensagem, tipo = 'success', duracao = 4000) {
  let container = document.querySelector('.admin-toast-container');
  if (!container) {
    container = Object.assign(document.createElement('div'), { className: 'admin-toast-container' });
    document.body.appendChild(container);
  }
  const icons = { success: '✓', error: '✕', info: 'ℹ', warning: '⚠' };
  const item = Object.assign(document.createElement('div'), {
    className: `admin-toast ${tipo}`,
    innerHTML: `<span>${icons[tipo] || '✓'}</span><span>${escapeHtml(mensagem)}</span>`,
  });
  container.appendChild(item);
  setTimeout(() => item.classList.add('visible'), 10);
  setTimeout(() => { item.classList.remove('visible'); setTimeout(() => item.remove(), 400); }, duracao);
}

// ── Utilities ─────────────────────────────────────────────────

function toSlug(str) {
  return String(str).toLowerCase()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
}

function wireCharCounter(inputEl, counterEl, maxLen) {
  function update() {
    const n = inputEl.value.length;
    counterEl.textContent = `${n} / ${maxLen}`;
    counterEl.className = 'char-counter' + (n > maxLen ? ' over' : n > maxLen * 0.85 ? ' warn' : '');
  }
  inputEl.addEventListener('input', update);
  update();
}

function initTabs(containerEl) {
  containerEl.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      containerEl.querySelectorAll('.tab-btn').forEach(b => {
        b.classList.remove('active');
        if (b.hasAttribute('aria-selected')) b.setAttribute('aria-selected', 'false');
      });
      containerEl.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
      btn.classList.add('active');
      if (btn.hasAttribute('aria-selected')) btn.setAttribute('aria-selected', 'true');
      containerEl.querySelectorAll(`.tab-panel[data-panel="${btn.dataset.tab}"]`).forEach(p => p.classList.add('active'));
    });
  });
  const first = containerEl.querySelector('.tab-btn');
  if (first) first.click();
}

function sanitizeHtml(html) {
  const doc = new DOMParser().parseFromString(html, 'text/html');
  doc.querySelectorAll('script, iframe, object, embed, form, input, button, meta, link').forEach(el => el.remove());
  doc.querySelectorAll('*').forEach(el => {
    Array.from(el.attributes).forEach(attr => {
      if (/^on/i.test(attr.name)) { el.removeAttribute(attr.name); return; }
      if (attr.name === 'srcdoc')  { el.removeAttribute(attr.name); return; }
      if (['href','src','action'].includes(attr.name) && /^(javascript:|data:)/i.test(attr.value.trim()))
        el.removeAttribute(attr.name);
    });
  });
  return doc.body.innerHTML;
}

// Task status helpers
const TASK_STATUS_LABELS = {
  pending:     'Pendente',
  in_progress: 'Em curso',
  completed:   'Concluído',
  blocked:     'Bloqueado',
};

const CRITICIDADE_LABELS = {
  bloqueante:  'Bloqueante',
  urgente:     'Urgente',
  importante:  'Importante',
  otimizacao:  'Otimização',
};

function taskStatusBadgeHtml(status) {
  const label = TASK_STATUS_LABELS[status] || status;
  return `<span class="badge badge-task-${status}">${label}</span>`;
}

function criticidadeBadgeHtml(c) {
  const label = CRITICIDADE_LABELS[c] || c;
  return `<span class="badge badge-crit-${c}">${label}</span>`;
}

window.AdminPortal = {
  login, logout, signOutLocal, obterSessao, obterUser, obterMeuRole, obterMeuClient,
  obterAdesaoPortalAtual, sincronizarAdesaoPortalSeAutenticado,
  verificarAdmin, verificarAcesso,
  listarUtilizadores, promoverAdmin, revogarAdmin, assignClient,
  listarPosts, obterPost, criarPost, atualizarPost, publicarPost, despublicarPost, apagarPost,
  postTemAlteracoesAposPublicacao, dispararBuildSitePublico, agendarBuildSitePublico,
  uploadMedia, listarMedia, apagarMedia,
  listarPropriedades, obterPropriedade, criarPropriedade, atualizarPropriedade, apagarPropriedade,
  listarTaskTemplates, listarPropertyTaskStatus, upsertPropertyTaskStatus,
  listarOwnerGlobalTaskStatus, upsertOwnerGlobalTaskStatus,
  listarTaskComments, criarTaskComment, apagarTaskComment,
  toast, toSlug, wireCharCounter, initTabs, sanitizeHtml, adminHref, escapeHtml,
  taskStatusBadgeHtml, criticidadeBadgeHtml,
  TASK_STATUS_LABELS, CRITICIDADE_LABELS,
};
