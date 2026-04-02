# Check-in e Check-out — Fluxo Completo

Processo 100% autónomo, sem necessidade de presença física.

---

## Fluxo de Check-in Automático

### Timeline por reserva

| Quando | Ação | Canal |
|--------|------|-------|
| Reserva confirmada | Mensagem de boas-vindas + instruções gerais | Airbnb / Booking |
| D-7 antes da chegada | Lembrete + link do guia digital | Mensagem automática |
| D-1 antes da chegada | Envio do código de acesso + instruções detalhadas | Mensagem automática |
| Dia da chegada (check-in) | Mensagem de "já podes entrar, bom descanso" | Mensagem automática |
| H+2 após check-in | Check-in de bem-estar ("está tudo bem?") | WhatsApp / mensagem |

### Código de acesso

- Gerado automaticamente pelo PMS (integrado com fechadura)
- Único por reserva
- **Ativa:** hora do check-in (ex: 15h00)
- **Expira:** hora do check-out (ex: 11h00 do dia de saída)
- Nunca reutilizado

---

## Guia Digital do Apartamento

### Conteúdo mínimo obrigatório

```
1. Acesso
   - Código da porta do prédio (se aplicável)
   - Código da fechadura do apartamento
   - Localização da caixa de correio / chaves de reserva

2. WiFi
   - Nome da rede: [SSID]
   - Palavra-passe: [PASS]

3. Electrodomésticos
   - Aquecedor / AC: como ligar/desligar
   - Máquina de lavar: instruções básicas
   - Máquina de café: cápsulas em [local]

4. Regras da casa
   - Silêncio após 22h
   - Não fumar (incluindo varanda)
   - Animais de estimação: [sim/não]
   - Máximo de hóspedes: [N]

5. Check-out
   - Hora: 11h00
   - Deixar chaves em [local] ou simplesmente fechar a porta
   - Separação do lixo (se aplicável)

6. Contactos de emergência
   - Anfitriões: [tel]
   - Emergências: 112
   - Hospital mais próximo: [nome + morada]
   - Farmácia 24h: [morada]

7. Recomendações locais
   - Restaurantes favoritos
   - Supermercado mais próximo
   - Transportes (metro, autocarro)
```

---

## Fluxo de Check-out

### Timeline

| Quando | Ação | Canal |
|--------|------|-------|
| D-1 da saída (20h) | Check-out reminder + instruções | Mensagem automática |
| Manhã da saída (8h) | "Lembrete: check-out às 11h" | Mensagem automática |
| 11h00 | Código expira automaticamente | Sistema (Nuki + PMS) |
| 11h15 | Equipa de limpeza contactada para entrada | Protocolo limpeza |

### Instruções de check-out para hóspede

- Deixar as chaves em [local definido]
- Fechar todas as janelas
- Ligar o aquecedor/AC para o modo stand-by
- Separar lixo reciclável
- **Não é necessário limpar** — está incluído no serviço

---

## Late Check-out e Early Check-in

### Política recomendada

| Pedido | Resposta | Preço |
|--------|----------|-------|
| Early check-in (antes das 14h) | Sujeito a disponibilidade | +20–40 € |
| Late check-out (após 12h) | Sujeito a disponibilidade | +20–40 € |
| Late check-out (após 15h) | Equivale a meia diária | +50% do preço/noite |

> Sempre verificar no PMS se há reserva no mesmo dia antes de aceitar.

---

## Protocolo para Check-in Falhado

Se o hóspede reportar problema com o código/fechadura:

1. Verificar no sistema se o código está ativo
2. Gerar código de emergência (Nuki tem PIN de backup)
3. Se persistir: deslocar-se ao local ou enviar alguém de confiança
4. Registar o problema para manutenção preventiva
5. Oferecer desconto/compensação ao hóspede se demora >30 min

---

## Mensagens Automáticas — Templates

### Confirmação de reserva (imediata)

> Olá [Nome]! Obrigado pela tua reserva. Estamos ansiosos por receber-te em [Data Chegada]. Vais receber as instruções de acesso 24h antes da chegada. Qualquer dúvida, estamos aqui. Bem-vindo(a)!

### Envio de código (D-1)

> Olá [Nome]! Amanhã é o grande dia. O teu código de acesso é: **[CÓDIGO]**. A porta do prédio: [INSTRUÇÕES]. O apartamento: 2º esquerdo. O guia completo está aqui: [LINK]. Check-in a partir das 15h. Boa viagem!

### Reminder de check-out (D-1)

> Olá [Nome]! Esperamos que esteja a ser uma estadia fantástica. Lembrete: check-out amanhã às 11h. Basta fechar a porta — o código expira automaticamente. Conta-nos como foi! 😊
