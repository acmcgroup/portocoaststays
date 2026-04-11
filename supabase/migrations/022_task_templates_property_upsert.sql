-- Migration 022: upsert all property-level task templates (ambito='A')
-- These are per-property onboarding/operational tasks shown in property-tasks.html
-- Source: 008b_task_templates_seed.sql (A-scope rows only)

INSERT INTO public.task_templates (id, client, section_num, section_name, description, criticidade, ambito, resp, notes, sort_order) VALUES

-- Secção 1: Legalização e Registo
('1.0',  'portocoaststays', 1, 'Legalização e Registo',
 'Definir por escrito titular do RNAL e NIF que constará no registo (contrato de mediação / aditamento)',
 'bloqueante', 'A', 'P+G',
 'Bloqueia 1.2; alinha RNAL + AT + SIBA', 10),

('1.1',  'portocoaststays', 1, 'Legalização e Registo',
 'Verificar zona de contenção AL no Porto (AUGI) antes de registar',
 'bloqueante', 'A', 'P+G',
 'G: pesquisa CMP → AL → Zonas de Contenção; P: confirma elegibilidade do imóvel', 20),

('1.2',  'portocoaststays', 1, 'Legalização e Registo',
 'Pedido de registo no RNAL via ePortugal.gov.pt (área reservada)',
 'bloqueante', 'A', 'P(G)',
 'Titular submete em nome próprio; G apoia documentação. Número gerado após validação; comunicar Câmara em 10 dias', 30),

('1.3',  'portocoaststays', 1, 'Legalização e Registo',
 'Comunicar registo RNAL à Câmara Municipal (Porto ou Matosinhos)',
 'bloqueante', 'A', 'P(G)',
 'Obrigação do titular; G pode tratar com mandato escrito. Prazo: 10 dias após registo', 40),

('1.4',  'portocoaststays', 1, 'Legalização e Registo',
 'Instalar placa identificativa AL na porta/entrada',
 'bloqueante', 'A', 'G',
 '20×14 cm, metálica, com número RNAL; ~€15–30', 50),

('1.5',  'portocoaststays', 1, 'Legalização e Registo',
 'Contratar seguro responsabilidade civil (mínimo €75k cobertura)',
 'bloqueante', 'A', 'P',
 'Fidelidade / Tranquilidade / Generali; ~€300–600/ano c/ multirriscos', 60),

('1.6',  'portocoaststays', 1, 'Legalização e Registo',
 'Registar livro de reclamações eletrónico em livroreclamacoes.pt',
 'bloqueante', 'A', 'P(G)',
 'Colocar aviso/QR visível no apartamento', 70),

('1.7',  'portocoaststays', 1, 'Legalização e Registo',
 'Colocar extintor de incêndio (verificação anual)',
 'bloqueante', 'A', 'G',
 'Obrigatório por lei; verificar validade em cada limpeza', 80),

('1.8',  'portocoaststays', 1, 'Legalização e Registo',
 'Colocar kit de primeiros socorros básico',
 'bloqueante', 'A', 'G',
 'Obrigatório por lei', 90),

('1.9',  'portocoaststays', 1, 'Legalização e Registo',
 'Afixar contactos de emergência visíveis (112, bombeiros, hospital)',
 'bloqueante', 'A', 'G',
 'Pode integrar no guia digital + suporte físico', 100),

('1.10', 'portocoaststays', 1, 'Legalização e Registo',
 'Instalar detetor de fumo',
 'urgente', 'A', 'G',
 'Não obrigatório por lei mas prática standard e exigido por seguros', 110),

('1.11', 'portocoaststays', 1, 'Legalização e Registo',
 'Instalar detetor de CO se houver esquentador a gás',
 'urgente', 'A', 'G',
 'Obrigatório em ambientes com combustão a gás', 120),

-- Secção 3 (A-scope only)
('3.2',  'portocoaststays', 3, 'Comunicações a Entidades Obrigatórias',
 'Registar número RNAL nos listings (Airbnb e Booking.com exigem)',
 'bloqueante', 'A', 'G',
 'Formato AL/Porto/XXXXX ou AL/Matosinhos/XXXXX', 240),

('3.3',  'portocoaststays', 3, 'Comunicações a Entidades Obrigatórias',
 'Comunicar dados de hóspedes ao SIBA por cada reserva',
 'bloqueante', 'A', 'G',
 'Nome, nacionalidade, doc. identificação, data nasc., país residência, datas; prazo 3 dias úteis', 250),

('3.4',  'portocoaststays', 3, 'Comunicações a Entidades Obrigatórias',
 'Comunicar faturas à AT via e-fatura (por cada reserva)',
 'bloqueante', 'A', 'G+C',
 'Automático via InvoiceXpress; verificar mensalmente', 260),

('3.6',  'portocoaststays', 3, 'Comunicações a Entidades Obrigatórias',
 'Notificar Câmara de alterações relevantes no imóvel ou nos dados do RNAL',
 'urgente', 'A', 'P(G)',
 'Ex: mudança de capacidade, titular, tipo de AL', 280),

('3.7',  'portocoaststays', 3, 'Comunicações a Entidades Obrigatórias',
 'Registar AL junto da Câmara para cobrança/liquidação de taxa turística',
 'bloqueante', 'A', 'P(G)',
 'Porto e Matosinhos têm processos distintos; confirmar periodicidade e formulário', 290),

('3.8',  'portocoaststays', 3, 'Comunicações a Entidades Obrigatórias',
 'Incluir linha de taxa turística na faturação ao hóspede',
 'urgente', 'A', 'G',
 'Não pode ser incluída no IVA de dormida; é uma taxa municipal distinta', 300),

-- Secção 4: Serviços Essenciais
('4.1',  'portocoaststays', 4, 'Serviços Essenciais',
 'Confirmar e documentar: localização do contador de água e como cortar',
 'bloqueante', 'A', 'G',
 'Protocolo de emergência: fuga/inundação', 310),

('4.2',  'portocoaststays', 4, 'Serviços Essenciais',
 'Confirmar e documentar: localização do quadro elétrico e disjuntores',
 'bloqueante', 'A', 'G',
 'Protocolo de emergência: sem eletricidade / disjuntor disparado', 320),

('4.3',  'portocoaststays', 4, 'Serviços Essenciais',
 'Contratar internet mínimo 50 Mbps (NOS ou Vodafone)',
 'bloqueante', 'A', 'G',
 'WiFi é critério de review; palavra-passe simples; testar cobertura em todos os quartos', 330),

('4.4',  'portocoaststays', 4, 'Serviços Essenciais',
 'Verificar se o contrato de luz e água admite uso turístico/AL',
 'urgente', 'A', 'G',
 'Alguns contratos residenciais têm restrições; confirmar com fornecedor', 340),

('4.5',  'portocoaststays', 4, 'Serviços Essenciais',
 'Incluir custos de utilities no modelo financeiro (~€130/mês estimado)',
 'urgente', 'A', 'G',
 'Linha de custo operacional no relatório mensal', 350),

('4.6',  'portocoaststays', 4, 'Serviços Essenciais',
 'Criar contacto de emergência para avaria da internet (NOS/Vodafone)',
 'urgente', 'A', 'G',
 'No protocolo de suporte a hóspedes e WhatsApp de operações', 360),

('4.7',  'portocoaststays', 4, 'Serviços Essenciais',
 'Verificar se roteador tem gestão remota (reiniciar em caso de queda)',
 'importante', 'A', 'G',
 'TP-Link Deco, Tele2 Router ou equivalente com app', 370),

('4.8',  'portocoaststays', 4, 'Serviços Essenciais',
 'Considerar rede WiFi de convidados separada da rede de gestão',
 'otimizacao', 'A', 'G',
 'Boas práticas de segurança; reduz suporte técnico', 380),

-- Secção 5: Hardware e Acesso Autónomo
('5.1',  'portocoaststays', 5, 'Hardware e Acesso Autónomo',
 'Instalar Nuki Smart Lock + Keypad + Bridge em cada imóvel',
 'bloqueante', 'A', 'G',
 'Pré-requisito de toda a automação de check-in', 390),

('5.2',  'portocoaststays', 5, 'Hardware e Acesso Autónomo',
 'Testar acesso à porta do prédio (configurar teclado ou Nuki Opener)',
 'bloqueante', 'A', 'G',
 'Prédios com portão exterior: obrigatório Nuki Opener', 400),

('5.3',  'portocoaststays', 5, 'Hardware e Acesso Autónomo',
 'Configurar integração Nuki ↔ PMS (geração automática de códigos por reserva)',
 'bloqueante', 'A', 'G',
 'Código gerado na confirmação, enviado D-1, expirado no check-out', 410),

('5.4',  'portocoaststays', 5, 'Hardware e Acesso Autónomo',
 'Verificar carga das baterias Nuki periodicamente',
 'urgente', 'A', 'G',
 'Incluir na checklist de limpeza; Nuki envia alerta, mas confirmar', 420),

('5.5',  'portocoaststays', 5, 'Hardware e Acesso Autónomo',
 'Definir fallback de acesso físico (caixa de chaves oculta)',
 'urgente', 'A', 'G',
 'Para falha técnica do Nuki; instrução no protocolo de emergências', 430),

-- Secção 6 (A-scope)
('6.2',  'portocoaststays', 6, 'Sistemas e Integrações',
 'Ligar Airbnb ao PMS via Channel Manager',
 'bloqueante', 'A', 'G',
 'Evita double bookings; sincroniza calendário e preços', 450),

('6.3',  'portocoaststays', 6, 'Sistemas e Integrações',
 'Ligar Booking.com ao PMS via Channel Manager',
 'bloqueante', 'A', 'G',
 'Idem', 460),

('6.4',  'portocoaststays', 6, 'Sistemas e Integrações',
 'Configurar sequência de 9 mensagens automáticas no PMS',
 'bloqueante', 'A', 'G',
 'De confirmação de reserva até pedido de review; configurar 1x', 470),

('6.5',  'portocoaststays', 6, 'Sistemas e Integrações',
 'Configurar notificação automática de limpeza pós-checkout (PMS → WhatsApp)',
 'bloqueante', 'A', 'G',
 'Sem isto, a coordenação de limpeza é manual e falha', 480),

('6.6',  'portocoaststays', 6, 'Sistemas e Integrações',
 'Configurar Pricelabs com preço base, mínimo, máximo e regras sazonais',
 'bloqueante', 'A', 'G',
 '+20–30% de receita vs preço fixo; rever semanalmente', 490),

('6.9',  'portocoaststays', 6, 'Sistemas e Integrações',
 'Criar guia digital do apartamento (código porta, WiFi, eletrodomésticos, regras, emergências)',
 'bloqueante', 'A', 'G',
 'Notion, PDF ou funcionalidade nativa do PMS; enviado automaticamente D-1', 530),

('6.10', 'portocoaststays', 6, 'Sistemas e Integrações',
 'Criar grupo WhatsApp de operações (gestora + equipa limpeza)',
 'bloqueante', 'A', 'G',
 'Canal de controlo fotográfico pós-limpeza', 540),

('6.11', 'portocoaststays', 6, 'Sistemas e Integrações',
 'Configurar relatório mensal automático para proprietário (export PMS)',
 'urgente', 'A', 'G',
 'PDF até dia 5; incluir receita bruta, deduções, líquido, ocupação, reviews', 550),

-- Secção 8: Preparação Física
('8.1',  'portocoaststays', 8, 'Preparação Física',
 'Visita ao imóvel: verificar estado, equipamentos, pontos de acesso',
 'bloqueante', 'A', 'G',
 'Bloqueia todos os outros blocos', 630),

('8.2',  'portocoaststays', 8, 'Preparação Física',
 'Equipar cozinha (café, açúcar, sal, azeite, detergente, esponjas)',
 'bloqueante', 'A', 'G',
 'Expectativa base dos hóspedes', 640),

('8.3',  'portocoaststays', 8, 'Preparação Física',
 'Equipar casa de banho (gel, champô, 2+ rolos papel, sabão)',
 'bloqueante', 'A', 'G',
 'Expectativa base dos hóspedes', 650),

('8.4',  'portocoaststays', 8, 'Preparação Física',
 'Comprar 2–3 sets completos de roupa de cama e toalhas (qualidade hotel)',
 'bloqueante', 'A', 'G',
 '2 sets = 1 em uso + 1 na lavandaria', 660),

('8.5',  'portocoaststays', 8, 'Preparação Física',
 'Extra de boas-vindas: café de cápsula, garrafa de água, snack local',
 'urgente', 'A', 'G',
 'Impacto direto nas primeiras reviews', 670),

('8.6',  'portocoaststays', 8, 'Preparação Física',
 'Verificar AC/aquecimento funcionais',
 'urgente', 'A', 'G',
 'Crítico para reviews; Porto tem invernos frios', 680),

('8.7',  'portocoaststays', 8, 'Preparação Física',
 'Contratar fotógrafo profissional (~€150–300; ROI < 1 semana)',
 'urgente', 'A', 'G',
 '15–25 fotos; foto 1 = capa com luz natural', 690),

-- Secção 9: Listagem e Distribuição
('9.1',  'portocoaststays', 9, 'Listagem e Distribuição',
 'Criar listing Airbnb com título, descrição, comodidades, fotos, regras',
 'bloqueante', 'A', 'G',
 'Número RNAL obrigatório; Instant Book ligado', 700),

('9.2',  'portocoaststays', 9, 'Listagem e Distribuição',
 'Criar listing Booking.com replicando conteúdo',
 'bloqueante', 'A', 'G',
 'Idem; ligar ao PMS imediatamente', 710),

('9.3',  'portocoaststays', 9, 'Listagem e Distribuição',
 'Abrir calendário para 4–6 meses',
 'bloqueante', 'A', 'G',
 'Algoritmos penalizam disponibilidade curta', 720),

('9.4',  'portocoaststays', 9, 'Listagem e Distribuição',
 'Definir preço de lançamento −20 a −30% do mercado (dias 1–14)',
 'bloqueante', 'A', 'G',
 'Estratégia de tração para primeiras reviews', 730),

('9.5',  'portocoaststays', 9, 'Listagem e Distribuição',
 'Confirmar sync de calendário sem double bookings antes do go-live',
 'bloqueante', 'A', 'G',
 'Testar com reserva de teste', 740),

('9.6',  'portocoaststays', 9, 'Listagem e Distribuição',
 'Monitorizar taxa de resposta >90% e aceitação >95%',
 'urgente', 'A', 'G',
 'Penalizações de algoritmo imediatas se baixar', 750),

-- Secção 10 (A-scope)
('10.1',  'portocoaststays', 10, 'Operações Recorrentes',
 'Submeter boletim SIBA para cada check-in (via Chekin automático ou portal manual)',
 'bloqueante', 'A', 'G',
 'Prazo: 3 dias úteis após check-in', 760),

('10.2',  'portocoaststays', 10, 'Operações Recorrentes',
 'Emitir fatura por cada reserva (via InvoiceXpress automático)',
 'bloqueante', 'A', 'G',
 '', 770),

('10.3',  'portocoaststays', 10, 'Operações Recorrentes',
 'Confirmar limpeza "pronto" no PMS com fotos antes do próximo check-in',
 'bloqueante', 'A', 'G',
 '', 780),

('10.4',  'portocoaststays', 10, 'Operações Recorrentes',
 'Responder a mensagens em <10 min (SLA operacional)',
 'bloqueante', 'A', 'G',
 '', 790),

('10.5',  'portocoaststays', 10, 'Operações Recorrentes',
 'Rever preços no Pricelabs + eventos próximos 30–60 dias',
 'urgente', 'A', 'G',
 'Frequência: semanal', 800),

('10.6',  'portocoaststays', 10, 'Operações Recorrentes',
 'Verificar taxa de resposta, aceitação e score no PMS',
 'urgente', 'A', 'G',
 'Frequência: semanal', 810),

('10.7',  'portocoaststays', 10, 'Operações Recorrentes',
 'Responder publicamente a cada review (<48h)',
 'urgente', 'A', 'G',
 '', 820),

('10.8',  'portocoaststays', 10, 'Operações Recorrentes',
 'Enviar relatório ao proprietário (até dia 5) + transferência (até dia 10)',
 'bloqueante', 'A', 'G',
 'Frequência: mensal', 830),

('10.10', 'portocoaststays', 10, 'Operações Recorrentes',
 'Liquidar taxa turística à Câmara (Porto e/ou Matosinhos)',
 'bloqueante', 'A', 'P+G',
 'Frequência: mensal ou trimestral; G executa se contratado; titular responsável', 850),

('10.11', 'portocoaststays', 10, 'Operações Recorrentes',
 'Renovar seguro multirriscos + RC',
 'bloqueante', 'A', 'P',
 'Frequência: anual', 860),

('10.12', 'portocoaststays', 10, 'Operações Recorrentes',
 'Verificar extintor (validade)',
 'bloqueante', 'A', 'G',
 'Frequência: anual', 870),

('10.14', 'portocoaststays', 10, 'Operações Recorrentes',
 'Atualizar dados RNAL se houve alterações no imóvel',
 'urgente', 'A', 'P(G)',
 'Titular pede alteração; G apoia', 890),

-- Secção 11: Fornecedores e Emergências (A-scope)
('11.1',  'portocoaststays', 11, 'Fornecedores e Emergências',
 'Contratar equipa de limpeza com backup disponível',
 'bloqueante', 'A', 'G',
 'Janela 11h–13h30; confirmação fotográfica; €40–60 por limpeza', 900),

('11.2',  'portocoaststays', 11, 'Fornecedores e Emergências',
 'Criar lista de contactos de emergência por imóvel (canalizador, eletricista, serralheiro)',
 'bloqueante', 'A', 'G',
 'Para falhas que impedem check-in', 910),

('11.3',  'portocoaststays', 11, 'Fornecedores e Emergências',
 'Definir protocolo de emergência por tipo (água, luz, acesso, incêndio)',
 'bloqueante', 'A', 'G',
 'Completar contactos em falta no protocolo de emergências', 920),

('11.4',  'portocoaststays', 11, 'Fornecedores e Emergências',
 'Identificar e documentar lavandaria parceira por imóvel',
 'urgente', 'A', 'G',
 'Incluir lavandaria explicitamente na proposta ao proprietário', 930),

-- Secção 12 (A-scope)
('12.1',  'portocoaststays', 12, 'Políticas e Reservas Diretas',
 'Definir e publicar hora de check-out clara (11h) no listing e mensagens',
 'urgente', 'A', 'G',
 'Expectativa internacional é ~12h; antecipar surpresa no listing', 950),

('12.2',  'portocoaststays', 12, 'Políticas e Reservas Diretas',
 'Criar política de late check-out pago e publicá-la',
 'urgente', 'A', 'G',
 'Ex: até 14h → €20; até 16h → €40; evita negociação ambígua', 960),

('12.5',  'portocoaststays', 12, 'Políticas e Reservas Diretas',
 'Criar catálogo de upsells por imóvel e inserir nas mensagens automáticas PMS',
 'urgente', 'A', 'G',
 'Ex: early check-in €20, late check-out €30, welcome pack premium €25, transfer aeroporto', 990)

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
