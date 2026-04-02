# Stack Tecnológica — PMS e Automações

Software necessário para gerir o negócio de forma eficiente e escalável.

---

## Visão Geral da Stack

```
Plataformas (Airbnb, Booking.com)
        ↓
    Channel Manager
        ↓
    PMS (Hostaway / Guesty)
        ↓
    ┌────────────────────────────────┐
    │  Pricing (Pricelabs)           │
    │  Fechaduras (Nuki API)         │
    │  Mensagens automáticas         │
    │  Relatórios de receita         │
    └────────────────────────────────┘
```

---

## PMS — Property Management System

O PMS é o sistema central que agrega tudo. Funciona como o "cérebro" da operação.

### Comparação de PMS para escala inicial

| PMS | Preço/mês | Pontos fortes | Ideal para |
|-----|----------|--------------|-----------|
| **Hostaway** | ~50–100 € | Interface intuitiva, bom suporte, excelente integração Nuki + Pricelabs | 1–20 unidades |
| Guesty | ~100–200 € | Muito robusto, mais features | 10+ unidades |
| Lodgify | ~50–80 € | Inclui site próprio, mais simples | Iniciantes |
| Smoobu | ~25–50 € | Económico, bom para começar | 1–5 unidades |

> **Recomendação para começar:** Hostaway ou Smoobu. Smoobu tem plano gratuito até 1 unidade.

### O que o PMS faz

- Sincroniza calendários entre todas as plataformas (evita double bookings)
- Centraliza inbox de mensagens (Airbnb + Booking num único lugar)
- Automatiza mensagens (confirmação, pré-chegada, check-out, review)
- Integra com fechaduras (gera e envia códigos automaticamente)
- Dashboards de ocupação e receita
- Gestão de equipa de limpeza (notificação automática após check-out)

---

## Channel Manager

Ferramenta que sincroniza disponibilidade e preços entre plataformas em tempo real.

> Na maioria dos PMS modernos (Hostaway, Guesty), o channel manager já está incluído.

### Plataformas a ligar

| Plataforma | Prioridade |
|------------|-----------|
| Airbnb | Obrigatório |
| Booking.com | Obrigatório |
| Vrbo | Opcional (fase 2) |
| Site direto | Fase 3+ |

---

## Pricing Dinâmico — Pricelabs

### O que é

Software de revenue management que ajusta os preços automaticamente com base em:
- Ocupação do mercado (concorrência)
- Sazonalidade e época do ano
- Eventos locais (festivais, conferências, feriados)
- Lead time (antecedência da reserva)
- Dias da semana

### Custo

~20–30 € por unidade/mês

### Impacto esperado

- +20–30% de receita vs pricing fixo
- Melhor taxa de ocupação na época baixa (preços mais competitivos)
- Maximização em picos (eventos, verão, feriados)

### Configuração básica

1. Ligar ao PMS via API
2. Definir preço base e limites (mín. e máx.)
3. Configurar regras sazonais (Porto: verão é pico, novembro–fevereiro é baixa)
4. Ativar "Health Score" para sugestões automáticas
5. Rever semanalmente o calendário de preços

---

## Automações Essenciais no PMS

### Mensagens automáticas (configurar 1 vez, funcionam para sempre)

| Trigger | Mensagem | Timing |
|---------|----------|--------|
| Reserva confirmada | Boas-vindas + resumo | Imediato |
| 7 dias antes | Lembrete + antecipação | D-7 |
| 1 dia antes | Código de acesso + guia | D-1, às 15h |
| Dia da chegada | "Bem-vindo, já podes entrar" | Hora do check-in |
| 2h após check-in | "Está tudo bem?" | +2h check-in |
| 1 dia antes saída | Check-out reminder | D-1, às 20h |
| Manhã da saída | Lembrete hora check-out | 8h do dia |
| 24h após check-out | Agradecimento + pedido de review | D+1 |

### Automação de limpeza

- Notificação automática à equipa de limpeza após check-out confirmado
- Incluir: hora de saída, hora da próxima chegada, notas especiais

### Automação de códigos (Nuki + PMS)

- Código gerado na confirmação da reserva
- Enviado ao hóspede no D-1
- Ativado na hora do check-in
- Expirado na hora do check-out

---

## WiFi — Requisitos Mínimos

| Requisito | Porquê |
|-----------|--------|
| Velocidade mínima 50 Mbps download | Streaming sem buffering |
| Router estável sem quedas | Reviews negativas quando falha |
| Palavra-passe simples | Menos suporte necessário |
| Sinal em todos os quartos | Verificar com app de cobertura |

> Operadora recomendada para AL: NOS ou Vodafone (planos sem fidelização para imóveis de renda).

---

## Stack Completa — Custo Total

| Software | Custo mensal |
|----------|-------------|
| PMS (Hostaway/Smoobu) | 50–100 € |
| Pricelabs (2 unidades) | 40–60 € |
| Conta Airbnb | 0 (% por reserva) |
| Conta Booking.com | 0 (% por reserva) |
| **Total software/mês** | **~90–160 €** |

> Para começar com orçamento mínimo: Smoobu (~25 €) + Pricelabs (~40 €) = ~65 €/mês.
