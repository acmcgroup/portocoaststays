(function () {
  'use strict';
  const BTN_ORIGINAL = 'Entrar';

  function toggleSenha() {
    const input = document.getElementById('senha');
    const icone = document.getElementById('icone-ver');
    if (!input || !icone) return;
    if (input.type === 'password') {
      input.type = 'text';
      icone.innerHTML = `<path d="M17.94 17.94A10.07 10.07 0 0112 20c-7 0-11-8-11-8a18.45 18.45 0 015.06-5.94"/>
        <path d="M9.9 4.24A9.12 9.12 0 0112 4c7 0 11 8 11 8a18.5 18.5 0 01-2.16 3.19"/>
        <line x1="1" y1="1" x2="23" y2="23"/>`;
    } else {
      input.type = 'password';
      icone.innerHTML = `<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>`;
    }
  }

  async function submeterLogin(e) {
    e.preventDefault();
    const email = document.getElementById('email').value.trim();
    const senha = document.getElementById('senha').value;
    const erro  = document.getElementById('login-erro');
    const btn   = document.getElementById('btn-login');

    erro.style.display = 'none';
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-btn"></span>';

    try {
      await AdminPortal.login(email, senha);
      const role   = await AdminPortal.obterMeuRole();
      const client = await AdminPortal.obterMeuClient();
      if (client !== 'portocoaststays') {
        await AdminPortal.signOutLocal();
        throw new Error('A sua conta ainda não foi validada. Aguarde a ativação pela equipa Porto Coast Stays.');
      }
      if (role === 'admin') {
        window.location.href = '/admin/properties';
      } else {
        window.location.href = '/admin/properties';
      }
    } catch (err) {
      erro.textContent = err.message;
      erro.style.display = 'block';
      btn.disabled = false;
      btn.textContent = BTN_ORIGINAL;
    }
  }

  async function verificarSessaoERedirecionar() {
    const sessao = await AdminPortal.obterSessao();
    if (sessao) {
      const client = await AdminPortal.obterMeuClient();
      if (client === 'portocoaststays') {
        window.location.href = '/admin/properties';
        return;
      }
    }
    const params = new URLSearchParams(window.location.search);
    if (params.get('erro') === 'sem_permissao') {
      const caixa = document.getElementById('login-erro');
      caixa.textContent = 'Sem permissão para aceder a este portal.';
      caixa.style.display = 'block';
    }
  }

  document.getElementById('form-login').addEventListener('submit', submeterLogin);
  document.getElementById('btn-ver').addEventListener('click', toggleSenha);
  verificarSessaoERedirecionar();
})();
