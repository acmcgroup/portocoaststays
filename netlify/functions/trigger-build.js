// netlify/functions/trigger-build.js
// Triggered by the admin portal after publishing posts.
// Requires env vars: NETLIFY_BUILD_HOOK_URL (required), SUPABASE_JWT_SECRET (optional — for auth verification).

const { createClient } = require('@supabase/supabase-js');

const ALLOWED_ROLES     = ['admin'];
const SUPABASE_URL      = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;
const HOOK_URL          = process.env.NETLIFY_BUILD_HOOK_URL;

exports.handler = async (event) => {
  const headers = {
    'Access-Control-Allow-Origin':  '*',
    'Access-Control-Allow-Headers': 'Authorization, Content-Type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Content-Type': 'application/json',
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 204, headers, body: '' };
  }
  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, headers, body: JSON.stringify({ error: 'Method Not Allowed' }) };
  }
  if (!HOOK_URL) {
    return { statusCode: 500, headers, body: JSON.stringify({ error: 'NETLIFY_BUILD_HOOK_URL not set' }) };
  }

  // Verify Supabase JWT if credentials are configured
  if (SUPABASE_URL && SUPABASE_ANON_KEY) {
    const authHeader = event.headers['authorization'] || event.headers['Authorization'];
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return { statusCode: 401, headers, body: JSON.stringify({ error: 'Missing authorization token' }) };
    }
    const token = authHeader.slice(7);
    const sb = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: { headers: { Authorization: `Bearer ${token}` } }
    });
    const { data: { user }, error: authErr } = await sb.auth.getUser();
    if (authErr || !user) {
      return { statusCode: 401, headers, body: JSON.stringify({ error: 'Invalid or expired token' }) };
    }
    const { data: membership, error: profileErr } = await sb
      .from('profile_clients')
      .select('role')
      .eq('user_id', user.id)
      .eq('client', 'portocoaststays')
      .single();
    if (profileErr || !membership || !ALLOWED_ROLES.includes(membership.role)) {
      return { statusCode: 403, headers, body: JSON.stringify({ error: 'Insufficient permissions' }) };
    }
  }

  try {
    const res = await fetch(HOOK_URL, { method: 'POST' });
    if (!res.ok) {
      return { statusCode: 502, headers, body: JSON.stringify({ error: `Build hook returned ${res.status}` }) };
    }
    return { statusCode: 200, headers, body: JSON.stringify({ ok: true, triggered: new Date().toISOString() }) };
  } catch (err) {
    return { statusCode: 500, headers, body: JSON.stringify({ error: String(err.message || err) }) };
  }
};
