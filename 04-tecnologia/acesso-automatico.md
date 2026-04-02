# Acesso Automático — Hardware e Configuração

Check-in 100% autónomo: elimina a necessidade de presença física em qualquer chegada.

---

## Componentes Necessários

### 1. Fechadura Inteligente (porta do apartamento)

| Produto | Preço | Notas |
|---------|-------|-------|
| **Nuki Smart Lock 4.0** | ~130–180 € | Recomendado. Instala sobre fechadura existente, sem obras |
| Nuki Smart Lock 3.0 | ~100–130 € | Versão anterior, igualmente funcional |
| Yale Linus Smart Lock | ~150–200 € | Alternativa sólida |
| Tedee Go | ~130–160 € | Boa integração com PMS |

> **Nuki é a escolha recomendada** — melhor integração com PMS como Hostaway e Guesty.

---

### 2. Teclado de Acesso PIN (keypad)

| Produto | Preço | Notas |
|---------|-------|-------|
| **Nuki Keypad 2.0** | ~80–100 € | Necessário para acesso sem smartphone |
| Nuki Keypad (original) | ~60–80 € | Versão anterior, funcional |

> Permite que hóspedes sem app ou com telemóvel descarregado entrem com PIN.

---

### 3. Acesso Porta do Prédio

Esta é frequentemente a parte mais complexa. Opções por tipo de porteiro:

#### Opção A — Prédio com interfone/videoporteiro

| Produto | Preço | Funcionamento |
|---------|-------|--------------|
| **Nuki Opener** | ~80–100 € | Liga ao sistema de intercomunicação existente. Abre remotamente via app |
| ButterflyMX | Mais caro | Solução empresarial |

> Nuki Opener é a solução mais elegante: instala em minutos, abre a porta do prédio remotamente ou com código.

#### Opção B — Prédio sem sistema eletrónico (fechadura mecânica)

- Instalar **caixa de chaves com código** (key box) na entrada do prédio
- Custo: 20–50 €
- Menos elegante, mas funcional
- Alternativa: solicitar ao condomínio instalação de interfone

#### Opção C — Porta do prédio sempre aberta durante o dia

- Verificar horários de fecho
- Guiar hóspede para chegar dentro do horário
- Ter plano de backup para chegadas tardias

---

## Diagrama de Acesso Completo

```
Hóspede chega ao prédio
    ↓
[Nuki Opener] — Insere PIN no teclado exterior
    OU
[App Nuki] — Carrega botão na app
    ↓
Porta do prédio abre
    ↓
Hóspede sobe as escadas / elevador
    ↓
[Nuki Smart Lock + Keypad] — Insere PIN do apartamento
    ↓
Porta do apartamento abre
    ↓
Check-in completo — sem qualquer interação humana
```

---

## Gestão de Códigos de Acesso

### Funcionamento com PMS (Hostaway/Guesty)

1. Reserva confirmada na plataforma
2. PMS comunica com Nuki via API
3. Código único gerado automaticamente
4. Código enviado ao hóspede por mensagem automática
5. Código ativa na hora do check-in
6. Código expira na hora do check-out
7. Nenhuma ação manual necessária

### Tipos de código

| Tipo | Quando usar |
|------|------------|
| Código de hóspede | Único, expira no check-out |
| Código de limpeza | Fixo, para equipa de limpeza |
| Código de emergência | Guardado de forma segura, para falhas |
| Código de manutenção | Temporário, para técnicos |

---

## Instalação — Guia Rápido (Nuki)

### Smart Lock

1. Abrir app Nuki no telemóvel
2. Seguir instalação guiada (sem obras, sem furos)
3. Calibrar a fechadura (reconhece posição aberta/fechada)
4. Testar com app antes de configurar PMS

### Keypad 2.0

1. Montar na parede ao lado da porta (dupla-face ou parafusos)
2. Parear com a Smart Lock via Bluetooth
3. Adicionar primeiros PINs de teste

### Nuki Bridge (recomendado)

- Permite controlo remoto via internet (não só Bluetooth)
- Custo adicional: ~60–80 €
- **Obrigatório** para integração com PMS e automação de códigos

---

## Considerações de Segurança

- Códigos são únicos por reserva — hóspede anterior nunca tem acesso após check-out
- Todos os acessos ficam registados (log com data/hora de cada abertura)
- Em caso de suspeita de intrusão: revogar todos os códigos remotamente
- Bateria da Smart Lock: dura ~6 meses, alertas automáticos quando baixa
- Manter sempre 1 chave física de backup em local seguro (não no apartamento)
