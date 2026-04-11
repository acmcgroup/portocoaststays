-- Migration 024: obrigações AL identificadas via gov.pt (sessão autenticada 2026-04-11)
-- Novas tarefas: entrega de comprovativo de seguro (pós-RNAL), comprovativo de exercício
-- de atividade (anual), renovação de seguro e cessação de atividade.
-- Corrige também notes da tarefa 10.14 (prazo 10 dias explicitado).

INSERT INTO public.task_templates (id, client, section_num, section_name, description, criticidade, ambito, resp, notes, sort_order) VALUES

('1.5a', 'portocoaststays', 1, 'Legalização e Registo',
 'Entregar comprovativo do seguro RC via ePortugal (após atribuição do número RNAL)',
 'bloqueante', 'A', 'P(G)',
 'Passo separado e obrigatório após obter o RNAL. Repetir sempre que renovar ou alterar o seguro. Serviço: gov.pt → "Entregar comprovativo de seguro do Alojamento Local"', 65),

('10.15', 'portocoaststays', 10, 'Operações Recorrentes',
 'Entregar comprovativo de exercício de atividade AL (declaração contributiva + formulário gov.pt)',
 'bloqueante', 'A', 'P(G)',
 'Obrigação anual do titular; se omitida, a Câmara pode cancelar o RNAL. Usar IVA trimestral como declaração contributiva. Isenção: imóvel em habitação própria e permanente com ≤120 noites/ano — confirmar por imóvel. Serviço: gov.pt → "Enviar o comprovativo do exercício da atividade de alojamento local"', 891),

('10.16', 'portocoaststays', 10, 'Operações Recorrentes',
 'Renovar entrega de comprovativo de seguro RC no ePortugal (a cada renovação ou alteração do seguro)',
 'bloqueante', 'A', 'P(G)',
 'Obrigação do titular; G coordena com renovação anual do seguro (ver 10.11). Serviço: gov.pt → "Entregar comprovativo de seguro do Alojamento Local"', 892),

('10.17', 'portocoaststays', 10, 'Operações Recorrentes',
 'Comunicar cessação de atividade AL (se imóvel sair do AL)',
 'bloqueante', 'A', 'P(G)',
 'Obrigação legal do titular quando a exploração do AL terminar. Serviço: gov.pt → "Alojamento local cessação da atividade"', 893)

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

-- Corrigir notes da 10.14 (prazo 10 dias)
UPDATE public.task_templates
SET notes = 'Titular pede alteração; G apoia. Prazo: 10 dias após a ocorrência'
WHERE id = '10.14';

NOTIFY pgrst, 'reload schema';
