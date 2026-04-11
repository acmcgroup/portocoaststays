-- Migration 025: channel manager research + iCal interim sync tasks
-- Contexto: avaliação de build-vs-buy para channel manager (Airbnb + Booking.com APIs)
-- Conclusão: Smoobu para Fase 1; certificações de parceiro para Fase 3 (SaaS).

INSERT INTO public.task_templates (id, client, section_num, section_name, description, criticidade, ambito, resp, notes, sort_order) VALUES

('7.7', 'portocoaststays', 7, 'Sistemas de Alto Impacto',
 'Configurar iCal sync como interim channel manager (grátis, disponível agora)',
 'urgente', 'G', 'G',
 'Solução gratuita enquanto o PMS (Smoobu) não está ativo. Airbnb: Calendário → Exportar URL iCal → importar no Booking.com. Booking.com: Calendário → Sincronizar → Importar. Delay: 15-60 min (Airbnb actualiza a cada ~15 min; Booking.com ~1h). Reduz risco de double booking mas não elimina. Não requer parceria. Substituir pelo channel manager do PMS logo que Smoobu estiver activo.', 615),

('7.8', 'portocoaststays', 7, 'Sistemas de Alto Impacto',
 'Research: Airbnb Connectivity Partner Program (self-build Fase 3 / SaaS)',
 'importante', 'G', 'G',
 'URL: https://www.airbnb.com/partner\nRequisitos: empresa de software estabelecida + volume demonstrado + processo de certificação técnica. Timeline: 3-12 meses. NÃO acessível para operadores individuais — é um programa para ISVs/PMS.\nCusto de build estimado: 400-600h dev + manutenção contínua de APIs.\nRelevante quando PCS gerir 15+ propriedades ou quiser oferecer PMS como produto SaaS.\nPara Fase 1 (1-2 imóveis): usar Smoobu €25/mês — payback em <1 semana de receita extra via Pricelabs.', 625),

('7.9', 'portocoaststays', 7, 'Sistemas de Alto Impacto',
 'Research: Booking.com Connectivity Partner Program (self-build Fase 3 / SaaS)',
 'importante', 'G', 'G',
 'URL: https://partnerhelp.booking.com/hc/en-us/sections/200471929\nContacto parceria: connectivity.partnerships@booking.com\nTem REST API para parceiros certificados (vs Airbnb que usa GraphQL). Processo similar ao Airbnb: certificação + volume mínimo + acordo comercial.\nMiddleware alternativo: Rentals United (já certificado) — pode ser usado como backend de canal sem certificação própria.\nDecisão: avaliar na Fase 3, junto com Airbnb Partner.', 635)

ON CONFLICT (id) DO UPDATE SET
  client       = EXCLUDED.client,
  section_num  = EXCLUDED.section_num,
  section_name = EXCLUDED.section_name,
  description  = EXCLUDED.description,
  criticidade  = EXCLUDED.criticidade,
  ambito       = EXCLUDED.ambito,
  resp         = EXCLUDED.resp,
  notes        = EXCLUDED.notes,
  sort_order   = EXCLUDED.sort_order;

NOTIFY pgrst, 'reload schema';
