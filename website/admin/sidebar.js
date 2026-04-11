/* sidebar.js — shared sidebar HTML generator */
function renderSidebar(activePage) {
  const links = [
    { group: 'Imóveis', items: [
      { href: '/admin/properties', label: 'Todos os Imóveis', page: 'properties', icon: '<path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/>' },
      { href: '/admin/property',   label: 'Novo Imóvel',      page: 'property-new', icon: '<line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>' },
    ]},
    { group: 'Empresa', items: [
      { href: '/admin/company-tasks', label: 'Tasks Globais', page: 'company-tasks', icon: '<path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>' },
    ]},
    { group: 'Conteúdo', items: [
      { href: '/admin/posts',   label: 'Blog Posts', page: 'posts',  icon: '<path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/>' },
      { href: '/admin/editor',  label: 'Novo Post',  page: 'editor', icon: '<line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>' },
    ]},
    { group: 'Media', items: [
      { href: '/admin/media', label: 'Imagens', page: 'media', icon: '<rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/>' },
    ]},
    { group: 'Sistema', items: [
      { href: '/admin/users', label: 'Utilizadores', page: 'users', icon: '<path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/>' },
    ]},
  ];

  const navHtml = links.map(group => {
    const items = group.items.map(item => {
      const isActive = activePage === item.page;
      return `<a href="${item.href}" class="${isActive ? 'active' : ''}">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">${item.icon}</svg>
        ${item.label}
      </a>`;
    }).join('');
    return `<div class="sidebar-nav-label">${group.group}</div>${items}`;
  }).join('');

  return `
    <aside class="sidebar">
      <div class="sidebar-logo">
        <img class="sidebar-logo-img" src="/assets/images/logo.svg" alt="Porto Coast Stays"/>
        <div class="sidebar-logo-text">
          <span class="sidebar-logo-name">Porto Coast Stays</span>
          <div class="sidebar-logo-sub">Admin</div>
        </div>
      </div>
      <nav class="sidebar-nav">${navHtml}</nav>
      <div class="sidebar-user">
        <span class="sidebar-user-email" id="sidebar-email">—</span>
        <button onclick="AdminPortal.logout()">Sair</button>
      </div>
      <div class="sidebar-footer">Porto Coast Stays © 2026</div>
    </aside>`;
}

async function initSidebar(activePage, requireAdmin = false) {
  const session = requireAdmin
    ? await AdminPortal.verificarAdmin()
    : await AdminPortal.verificarAcesso();
  if (!session) return null;
  const el = document.getElementById('sidebar-mount');
  if (el) el.innerHTML = renderSidebar(activePage);
  const user = await AdminPortal.obterUser();
  if (user) {
    const emailEl = document.getElementById('sidebar-email');
    if (emailEl) emailEl.textContent = user.email;
  }
  return session;
}

window.renderSidebar = renderSidebar;
window.initSidebar   = initSidebar;
