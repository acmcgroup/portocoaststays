-- Tasks Globais [G] — upsert a partir de lista-tarefas-prioritarias.md / 008b
-- Garante que o admin vê todas as tasks de empresa/carteira em company-tasks.html

INSERT INTO public.task_templates (id, client, section_num, section_name, description, criticidade, ambito, resp, notes, sort_order) VALUES

-- Secção 2: Fiscal e Contabilidade
('2.1',  'portocoaststays', 2, 'Fiscal e Contabilidade',
 'Registar atividade na AT (Finanças) — início AL / abertura de atividade',
 'bloqueante', 'G', 'P+C',
 'Titular da atividade económica (Categoria B). Portal das Finanças', 130),

('2.2',  'portocoaststays', 2, 'Fiscal e Contabilidade',
 'Registar em IVA no Portal das Finanças se receita prevista > €14.500/ano',
 'bloqueante', 'G', 'P+C',
 'Com 2 imóveis (~€43k/ano): obrigatório; regime trimestral', 140),

('2.3',  'portocoaststays', 2, 'Fiscal e Contabilidade',
 'Contratar contabilista especializado em AL',
 'bloqueante', 'G', 'P',
 '~€50–100/mês; declarações IVA trimestrais + IRS anual', 150),

('2.4',  'portocoaststays', 2, 'Fiscal e Contabilidade',
 'Configurar software de faturação certificado AT (InvoiceXpress ou Moloni)',
 'bloqueante', 'G', 'G+C',
 'IVA 6%; integração PMS → fatura automática → e-fatura AT', 160),

('2.5',  'portocoaststays', 2, 'Fiscal e Contabilidade',
 'Confirmar onde extrair o RFI/certificado da Booking.com',
 'urgente', 'G', 'G',
 'Extranet Booking → separador Finanças (não vem por e-mail)', 170),

('2.6',  'portocoaststays', 2, 'Fiscal e Contabilidade',
 'Confirmar onde extrair faturas/IVA do Airbnb',
 'urgente', 'G', 'G',
 'Fluxo: Hoje → Todas as reservas → Documentos fiscais (UI muda; atualizar anualmente)', 180),

('2.7',  'portocoaststays', 2, 'Fiscal e Contabilidade',
 'Criar processo anual de recolha de documentos fiscais por plataforma',
 'importante', 'G', 'G+C',
 'Checklist com localização exata por plataforma + pessoa responsável', 190),

('2.8',  'portocoaststays', 2, 'Fiscal e Contabilidade',
 'Declarar rendimentos AL na Categoria B do IRS anualmente',
 'bloqueante', 'G', 'P+C',
 'Com contabilista; considerar derrama municipal Porto/Matosinhos 1,5%', 200),

('2.9',  'portocoaststays', 2, 'Fiscal e Contabilidade',
 'Registar e liquidar taxa turística municipal (Porto €2/noite; Matosinhos €1/noite)',
 'bloqueante', 'G', 'P+G',
 'Cobrada ao hóspede por noite; liquidada ao município periodicamente; não confundir com IVA', 210),

('2.10', 'portocoaststays', 2, 'Fiscal e Contabilidade',
 'Incluir linha "taxa turística" no relatório mensal ao proprietário e no modelo financeiro',
 'urgente', 'G', 'G',
 '~€450–600/ano com 2 imóveis a 66% ocup.', 220),

-- Secção 3
('3.1',  'portocoaststays', 3, 'Comunicações a Entidades Obrigatórias',
 'Criar conta no portal SIBA (SEF/AIMA) para submissão de boletins de alojamento',
 'bloqueante', 'G', 'P+G',
 'Dados da entidade exploradora = titular RNAL; G configura fluxo e credenciais operacionais. sef.pt; 3 dias úteis após check-in', 230),

('3.5',  'portocoaststays', 3, 'Comunicações a Entidades Obrigatórias',
 'Entregar IVA trimestral à AT',
 'bloqueante', 'G', 'P+C',
 'Com contabilista; 2 imóveis → ~€657/trimestre', 270),

-- Secção 6 (âmbito G)
('6.1',  'portocoaststays', 6, 'Sistemas e Integrações',
 'Contratar e configurar PMS (Hostaway recomendado para 1–20 un.)',
 'bloqueante', 'G', 'G',
 'Alternativa inicial: Smoobu (~25€/mês); versão gratuita até 1 unidade', 440),

('6.7',  'portocoaststays', 6, 'Sistemas e Integrações',
 'Configurar InvoiceXpress: NIF, IVA 6%, integração PMS, e-fatura AT',
 'bloqueante', 'G', 'G+C',
 'Fatura emitida automaticamente por reserva', 500),

('6.8',  'portocoaststays', 6, 'Sistemas e Integrações',
 'Configurar fluxo automático de recolha de dados SIBA (Chekin ou Akia → PMS → SIBA)',
 'bloqueante', 'G', 'G',
 'Trigger na confirmação de reserva → link check-in online → upload documento → submissão automática ao SIBA em ≤3 dias úteis. Detalhe: 03-operacoes/siba-recolha-dados.md', 510),

('6.8a', 'portocoaststays', 6, 'Sistemas e Integrações',
 'Inserir templates EN/PT de pedido de dados nos templates PMS (fallback para reservas sem Chekin)',
 'urgente', 'G', 'G',
 'Templates prontos em 03-operacoes/siba-recolha-dados.md; usar enquanto Chekin não está ativo', 520),

('6.12', 'portocoaststays', 6, 'Sistemas e Integrações',
 'Incluir envio de faturas das plataformas ao proprietário como serviço',
 'urgente', 'G', 'G',
 'RFI Booking + faturas Airbnb; criar checklist anual por plataforma com localização exata', 560),

-- Secção 7
('7.1',  'portocoaststays', 7, 'Sistemas de Alto Impacto',
 'Integrar Chekin ou Akia (verificação de identidade + SIBA automático)',
 'urgente', 'G', 'G',
 '~€5–15/mês; obrigatório a partir de 3 imóveis para escala', 570),

('7.2',  'portocoaststays', 7, 'Sistemas de Alto Impacto',
 'Ativar dashboard em tempo real para proprietários (acesso Hostaway)',
 'importante', 'G', 'G',
 'Argumento de venda; transparência total', 580),

('7.3',  'portocoaststays', 7, 'Sistemas de Alto Impacto',
 'Configurar Zoho Projects (gestão de tarefas via Supabase edge function)',
 'importante', 'G', 'G',
 'Já existe controller.py; sincronizar tarefas B1–B6', 590),

('7.4',  'portocoaststays', 7, 'Sistemas de Alto Impacto',
 'Ativar VRBO como 3.ª plataforma de distribuição',
 'importante', 'G', 'G',
 'Fase 2; ligar ao PMS via Channel Manager', 600),

('7.5',  'portocoaststays', 7, 'Sistemas de Alto Impacto',
 'Motor de reservas diretas no website (0% comissão OTA)',
 'importante', 'G', 'G',
 'Avaliar Lodgify, Hostaway Pages ou Stripe direto', 610),

('7.6',  'portocoaststays', 7, 'Sistemas de Alto Impacto',
 'AI chatbot para suporte a hóspedes (GuestAgent equivalente)',
 'importante', 'G', 'G',
 'Avaliar Akia AI, Hostaway AI ou Tidio; necessário antes dos 3–5 imóveis para manter SLA <10 min', 620),

-- Secção 10 (só G)
('10.9', 'portocoaststays', 10, 'Operações Recorrentes',
 'Entregar IVA à AT com contabilista',
 'bloqueante', 'G', 'P+C',
 'Frequência: trimestral', 840),

('10.13', 'portocoaststays', 10, 'Operações Recorrentes',
 'Declarar rendimentos AL (IRS Categoria B)',
 'bloqueante', 'G', 'P+C',
 'Frequência: anual', 880),

-- Secção 11
('11.5', 'portocoaststays', 11, 'Fornecedores e Emergências',
 'Subscrever Fixando.pt ou equivalente para manutenções pontuais',
 'importante', 'G', 'G',
 'Já referenciado em suporte-hospedes.md', 940),

-- Secção 12
('12.3', 'portocoaststays', 12, 'Políticas e Reservas Diretas',
 'Criar política de reserva direta (depósito, dados, SIBA, cancelamento)',
 'urgente', 'G', 'G',
 'Sinal: ~50% para bloquear calendário; dados SIBA obrigatórios para todos', 970),

('12.4', 'portocoaststays', 12, 'Políticas e Reservas Diretas',
 'Reposicionar linguagem do contrato: "sem compromisso mínimo, aviso 30 dias"',
 'urgente', 'G', 'G',
 'Zero custo implementar; barreira desnecessária removida', 980)

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
