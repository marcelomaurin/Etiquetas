# Configuração de impressora

Este guia explica como preparar a impressora para uso com o **Etiquetas**.

Instale e teste a impressora no sistema operacional antes de usá-la no Etiquetas.
Os modelos usam relatórios/driver ou os modos diretos oferecidos pelo módulo.
O editor de QR Code permite escolher o dispositivo na janela de impressão;
etiquetas PDF do Mercado Livre são impressas pelo leitor externo e o envio
direto de ZPL usa a fila de impressão do Windows.

---

## 1. Tipos de impressora

O projeto foi criado com foco em etiquetas, especialmente cenários com impressoras Zebra, mas também pode usar impressoras configuradas no sistema operacional, dependendo do layout e driver.

No painel inicial, escolha uma das quatro famílias:

| Tipo | Mídia | Limite de largura no editor de QR Code |
|---|---|---:|
| Zebra / rolo | Etiquetas adesivas em rolo | Até 104 mm |
| Térmica 80 mm | Bobina de balcão / PDV | Até 72 mm úteis |
| Térmica 58 mm | Bobina compacta / portátil | Até 48 mm úteis |
| Laser / jato de tinta | Folhas A4/Carta e grades Pimaco | Até 190 mm |

Esses limites pertencem ao editor de QR Code e não garantem compatibilidade
com toda impressora dessa família. Confira a largura útil do seu equipamento.
O editor aceita altura de 80 a 277 mm; **Cartaz A4** usa área de 190 × 277 mm.

Outros exemplos de uso:

- Impressora Zebra para etiquetas de gôndola.
- Impressora térmica de etiquetas.
- Impressora comum para testes.
- Impressora padrão do Windows ou Linux.

---

## 2. Instalação no Windows

### Passo 1 — Instalar o driver

Instale o driver oficial da impressora.

Para impressoras Zebra, use preferencialmente o driver fornecido pelo fabricante ou driver compatível já homologado no ambiente.

### Passo 2 — Testar pelo Windows

Antes de testar no Etiquetas:

1. Abra **Configurações** ou **Painel de Controle**.
2. Acesse **Impressoras e scanners**.
3. Selecione a impressora.
4. Imprima uma página de teste.

Se a página de teste não imprimir, o problema está no driver, porta, cabo, rede ou configuração da impressora.

### Passo 3 — Definir impressora padrão

Quando necessário, defina a impressora de etiquetas como impressora padrão do Windows.

O Etiquetas usa a impressão padrão do sistema em vários módulos.

---

## 3. Instalação no Linux

### Passo 1 — Instalar pelo CUPS

Em distribuições Debian/Ubuntu, normalmente o serviço de impressão usa CUPS.

Instale se necessário:

```bash
sudo apt install cups system-config-printer
```

### Passo 2 — Adicionar a impressora

Use a ferramenta gráfica de impressoras ou acesse a interface web do CUPS:

```text
http://localhost:631
```

### Passo 3 — Testar impressão

Imprima uma página de teste pelo próprio sistema operacional.

Somente depois faça o teste no Etiquetas.

---

## 4. Configuração dentro do Etiquetas

No sistema:

1. Abra **Configurações → Preferências** para conferir as preferências gerais.
2. No início, selecione o tipo de impressora e abra o modelo desejado.
3. Confira a impressora e as dimensões na tela do modelo/diálogo de impressão.
4. Nas propriedades do driver, ajuste papel, orientação e margens.
5. Faça um teste com uma etiqueta.

Escolher o cartão de impressora define o modo do modelo. Essa escolha não
instala um dispositivo nem altera automaticamente o papel no driver.

### QR Code de manuais e vídeos

Use **Escolher impressora e imprimir** no editor. Se o formato exceder a área
imprimível informada pelo driver, a impressão será bloqueada. Corrija o papel
ou reduza as dimensões. A opção em folha imprime um cartão individual, sem
distribuir cópias automaticamente em uma grade Pimaco.

### Etiqueta do Mercado Livre

PDF abre no leitor instalado; escolha a impressora nesse leitor e mantenha o
tamanho original do documento. O padrão brasileiro de envio é 100 × 150 mm,
incompatível com bobinas de 58/80 mm. Para ZPL, selecione **Zebra / rolo** no
painel e uma impressora que entenda ZPL no diálogo de envio. O envio direto de
ZPL está disponível no Windows e preserva os comandos originais.

Consulte o [guia de importação e suas fontes oficiais](NOVO_INICIO.md#etiquetas-de-envio-do-mercado-livre).

---

## 5. Impressoras Zebra

Para impressoras Zebra, observe:

- Tamanho correto da etiqueta no driver.
- Orientação da impressão.
- Margens.
- Velocidade e temperatura de impressão.
- Tipo de mídia: térmica direta ou transferência térmica.
- Sensor de etiqueta calibrado.

Se a etiqueta sair deslocada, normalmente o ajuste deve ser feito no driver ou nas configurações físicas da impressora.

---

## 6. Problemas comuns

### A etiqueta sai cortada

Possíveis causas:

- Tamanho da etiqueta errado no driver.
- Margens incompatíveis.
- Layout maior que a etiqueta física.

### A etiqueta sai em branco

Possíveis causas:

- Impressora térmica sem papel térmico correto.
- Ribbon ausente em modo transferência térmica.
- Temperatura muito baixa.
- Driver incorreto.

### Imprime na impressora errada

Possíveis causas:

- Impressora padrão incorreta.
- Impressora selecionada incorretamente no diálogo de impressão.

### Código de barras não lê

Possíveis causas:

- Impressão com baixa qualidade.
- Código muito pequeno.
- Contraste insuficiente.
- Papel inadequado.

---

## 7. Recomendações de operação

- Faça teste com uma etiqueta antes de imprimir lote grande.
- Use etiquetas compatíveis com a impressora.
- Evite imprimir em alta velocidade se o código de barras ficar ruim.
- Mantenha a cabeça térmica limpa.
- Salve uma configuração de driver específica para o tamanho da etiqueta usada.
