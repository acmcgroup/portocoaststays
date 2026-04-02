# Homestay - Brand Kit

Identidade visual completa. Todos os ficheiros do website usam este sistema.

---

## Filosofia de marca

**Clássico. Editorial. Confiança.**

A Homestay não é uma startup de néon. É uma empresa de gestão imobiliária que usa tecnologia invisível para fazer o trabalho pesado. O visual deve transmitir:

- Solidez e confiança (como uma consultora premium)
- Clareza e transparência (como um relatório financeiro limpo)
- Modernidade discreta (a tecnologia está implícita, não gritada)

Referência visual: **HomeLovers, Engel & Völkers, Kinfolk magazine**

---

## Paleta de Cores

```
CSS Variables usadas em todos os ficheiros
```

| Variável | Hex | Uso |
|----------|-----|-----|
| `--cream` | `#FAF8F5` | Fundo principal |
| `--cream-2` | `#F2EDE6` | Cards, secções alternadas |
| `--cream-3` | `#E8E0D5` | Borders, divisores |
| `--ink` | `#1A1714` | Texto principal |
| `--ink-2` | `#3D3630` | Headings secundários |
| `--muted` | `#7A6F67` | Texto de apoio, labels |
| `--muted-light` | `#B0A49C` | Placeholders, notas |
| `--green` | `#2B4C3F` | Cor de destaque (accent principal) |
| `--green-light` | `#3D6B58` | Hover do accent |
| `--green-pale` | `rgba(43,76,63,0.08)` | Fundos de cards accent |
| `--amber` | `#C4956A` | Accent secundário (valores, destaques) |
| `--amber-pale` | `rgba(196,149,106,0.12)` | Fundos de valores positivos |
| `--white` | `#FFFFFF` | Branco puro (botões, inversão) |
| `--border` | `rgba(26,23,20,0.1)` | Divisores |
| `--border-strong` | `rgba(26,23,20,0.18)` | Borders de cards em hover |

---

## Tipografia

### Fontes

```html
<link href="https://fonts.googleapis.com/css2?
  family=Cormorant+Garamond:ital,wght@0,300;0,400;0,500;0,600;1,300;1,400;1,500&
  family=Inter:wght@300;400;500;600&
  display=swap" rel="stylesheet">
```

| Papel | Família | Weight | Uso |
|-------|---------|--------|-----|
| Display | Cormorant Garamond | 300–500 | H1 hero, quotes grandes |
| Heading | Cormorant Garamond | 500–600 | H2, H3 secções |
| Body | Inter | 300–400 | Parágrafos, descrições |
| Label | Inter | 500–600 | Tags, badges, navegação |
| Data | Inter | 600 | Números, valores, tabelas |

### Escala tipográfica

| Nome | Size | Line-height | Letter-spacing | Uso |
|------|------|-------------|----------------|-----|
| `--text-hero` | `clamp(3.5rem, 8vw, 7rem)` | 0.95 | −0.03em | H1 principal |
| `--text-display` | `clamp(2.2rem, 5vw, 3.5rem)` | 1.1 | −0.02em | H2 secções |
| `--text-heading` | `clamp(1.4rem, 3vw, 2rem)` | 1.2 | −0.01em | H3 cards |
| `--text-sub` | `1.1rem` | 1.65 | 0 | Lead paragraphs |
| `--text-body` | `0.95rem` | 1.7 | 0 | Corpo de texto |
| `--text-small` | `0.82rem` | 1.6 | 0.01em | Notas, footnotes |
| `--text-label` | `0.72rem` | 1 | 0.1em | Tags uppercase |

---

## Espaçamento e Grid

```
Container max-width: 1140px
Section padding: 6rem 1.5rem
Card padding: 2rem–2.5rem
Border-radius: 4px (minimal, quase square = elegante)
Border-radius large: 12px (modais, cards maiores)
```

---

## Componentes

### Botão primário
```css
background: var(--green);
color: #fff;
padding: 0.85rem 2rem;
border-radius: 4px;
font: 500 0.88rem/1 Inter;
letter-spacing: 0.05em;
text-transform: uppercase;
```

### Botão secundário (outline)
```css
background: transparent;
border: 1px solid var(--ink);
color: var(--ink);
/* mesmos padding/font do primário */
```

### Badge / Tag
```css
font: 600 0.68rem Inter;
letter-spacing: 0.12em;
text-transform: uppercase;
color: var(--green);
border-bottom: 1px solid var(--green);
padding-bottom: 2px;
```

### Card padrão
```css
background: var(--cream-2);
border: 1px solid var(--cream-3);
border-radius: 4px;
padding: 2rem;
```

---

## Não fazer

- Não usar gradientes neon ou glow effects
- Não usar sombras pesadas (max box-shadow: 0 8px 40px rgba(0,0,0,0.08))
- Não usar mais de 2 pesos de fonte por página
- Não usar cor verde em texto corrido (só em accents e CTAs)
- Não usar border-radius > 12px (parece demasiado tech/startup)
- Não usar fundo completamente preto (#000) - sempre cream ou ink (#1A1714)
