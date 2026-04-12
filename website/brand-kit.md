# Porto Coast Stays - Brand Kit

Identidade visual completa. Todos os ficheiros do website usam este sistema.

---

## Filosofia de marca

**Premium. Coastal. Confiança.**

Porto Coast Stays não é uma plataforma genérica. É uma gestora de alojamento local focada na faixa costeira do Porto — Matosinhos, Foz, Gaia — que entrega experiências premium a hóspedes internacionais e resultados reais a proprietários. O visual deve transmitir:

- Posicionamento premium e diferenciador (costa vs. centro genérico)
- Confiança e transparência (como uma gestora de patrimônio séria)
- Legibilidade moderna (texto limpo, hierarquia clara, mobile-first)

Referência visual: **Engel & Völkers, Linear (produto SaaS), boutique hotels costeiros**

---

## Paleta de Cores

```css
/* CSS Variables em assets/css/site.css e admin/admin.css */
```

| Variável | Hex | Uso |
|----------|-----|-----|
| `--green` | `#2B4C3F` | Accent principal, CTAs, checkmarks |
| `--green-hover` | `#1e3830` | Hover do green |
| `--green-light` | `#3D6B58` | Hover alternativo |
| `--green-pale` | `rgba(43,76,63,0.08)` | Fundos de cards accent |
| `--amber` | `#C4956A` | Accent secundário (valores, destaques, dark sections) |
| `--amber-hover` | `#b0814f` | Hover do amber |
| `--amber-pale` | `rgba(196,149,106,0.13)` | Fundos de valores positivos |
| `--cream` | `#FAF8F5` | Fundo principal |
| `--cream-2` | `#F2EDE6` | Cards, secções alternadas |
| `--cream-3` | `#E8E0D5` | Borders, divisores |
| `--ink` | `#1A1714` | Texto principal, dark sections bg |
| `--ink-2` | `#3D3630` | Headings secundários |
| `--muted` | `#7A6F67` | Texto de apoio, labels |
| `--muted-light` | `#B0A49C` | Placeholders, notas |
| `--white` | `#FFFFFF` | Branco puro (botões, inversão) |
| `--border` | `rgba(26,23,20,0.10)` | Divisores |
| `--border-s` | `rgba(26,23,20,0.18)` | Borders fortes (hover, focus) |

---

## Tipografia

### Fontes

```html
<!-- Public site (index.html, proprietarios.html, gestoras.html) -->
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">

<!-- Admin (admin/admin.css) -->
@import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700&family=Inter:wght@300;400;500;600;700&display=swap');
```

> **Nota:** Cormorant Garamond foi removida do site público e substituída por Plus Jakarta Sans. O admin já usava Plus Jakarta Sans. O sistema está agora alinhado em ambos.

| Papel | Família | Weight | Uso |
|-------|---------|--------|-----|
| Display / Hero | Plus Jakarta Sans | 800 | H1 hero, números grandes |
| Heading | Plus Jakarta Sans | 700 | H2, H3 secções |
| Sub-heading | Plus Jakarta Sans | 600 | Cards, nav logo |
| Body | Inter | 400 | Parágrafos, descrições |
| Label | Inter | 600 | Tags, badges, navegação, botões |
| Data | Plus Jakarta Sans | 700–800 | Preços, estatísticas |

### Escala tipográfica

| Nome | Size | Weight | Letter-spacing | Uso |
|------|------|--------|----------------|-----|
| Hero H1 | `clamp(2.8rem, 5.5vw, 4.4rem)` | 800 | −0.03em | H1 principal |
| Section H2 | `clamp(1.8rem, 3.5vw, 2.75rem)` | 700 | −0.02em | H2 secções |
| Card H3 | `clamp(1.0rem, 2vw, 1.35rem)` | 600 | −0.01em | H3 cards |
| Body | `0.96rem` | 400 | 0 | Parágrafos |
| Small | `0.83rem` | 400 | 0.01em | Notas, listas |
| Label | `0.68rem` | 600 | 0.13em | Tags uppercase |
| Button | `0.82rem` | 600 | 0.05em | CTAs uppercase |

---

## Espaçamento e Grid

```
Container max-width: 1140px
Section padding: 6rem 1.5rem (desktop), 4rem 1.5rem (mobile)
Card padding: 2rem–2.5rem
Border-radius: 4px (botões, micro-elementos)
Border-radius large: 10px (cards, grids, tables)
```

---

## Arquitectura CSS

O site público usa um único stylesheet partilhado:

```
website/assets/css/site.css   ← única fonte de verdade do site público
website/admin/admin.css        ← stylesheet do painel admin (separado)
```

**Não há estilos inline** nos ficheiros HTML do site público. Todas as páginas (`index.html`, `proprietarios.html`, `gestoras.html`) ligam apenas `assets/css/site.css`.

Excepção permitida: estilos de página muito específicos podem ser declarados em `<style>` no `<head>` da página quando são únicos a essa página e não justificam nova classe global.

---

## Componentes

### Botão primário (verde)
```css
background: var(--green);
color: #fff;
padding: 0.85rem 1.75rem;
border-radius: 4px;
font: 600 0.82rem/1 Inter;
letter-spacing: 0.05em;
text-transform: uppercase;
border: 1.5px solid var(--green);
```

### Botão amber (dark sections)
```css
background: var(--amber);
color: var(--ink);
/* mesmos padding/font/radius do primário */
```

### Botão outline
```css
background: transparent;
border: 1.5px solid var(--border-s);
color: var(--ink);
/* mesmos padding/font/radius */
```

### Botão outline-white (dark sections)
```css
background: transparent;
border: 1.5px solid rgba(255,255,255,0.25);
color: rgba(255,255,255,0.8);
```

### Badge / Tag
```css
font: 600 0.68rem Inter;
letter-spacing: 0.13em;
text-transform: uppercase;
color: var(--green);
/* acompanhada de linha decorativa ::before (18px, 1.5px, var(--green)) */
```

### Card padrão (grid-card)
```css
background: var(--white);
border: 1px solid var(--border);   /* via border-collapse no grid */
border-radius: 10px;               /* no grid container */
padding: 2.25rem 2rem;
transition: background 0.18s ease;
```

### Card featured (pricing)
```css
background: var(--ink);
color: white;
/* conteúdo usa rgba(255,255,255,X) para hierarquia */
```

---

## Não fazer

- Não usar Cormorant Garamond (substituída por Plus Jakarta Sans)
- Não usar gradientes neon ou glow effects
- Não usar sombras pesadas (max: `0 4px 32px rgba(26,23,20,0.10)`)
- Não usar mais de 2 famílias de fonte por página
- Não usar cor verde em texto corrido (só em accents, CTAs, checkmarks)
- Não usar `border-radius > 12px` (parece demasiado tech/startup)
- Não usar fundo completamente preto (`#000`) — sempre `var(--ink)` (`#1A1714`)
- Não adicionar estilos inline nas páginas HTML (usar `site.css` ou `<style>` justificada na página)
