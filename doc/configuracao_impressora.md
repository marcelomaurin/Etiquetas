# Configuração de impressora

Este guia explica como preparar a impressora para uso com o **Etiquetas**.

O sistema envia a impressão para o mecanismo padrão de impressão do sistema operacional. Por isso, antes de configurar dentro do Etiquetas, a impressora deve estar instalada e funcionando no Windows ou Linux.

---

## 1. Tipos de impressora

O projeto foi criado com foco em etiquetas, especialmente cenários com impressoras Zebra, mas também pode usar impressoras configuradas no sistema operacional, dependendo do layout e driver.

Exemplos de uso:

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

1. Abra **Configuração**.
2. Use a opção de configuração de impressora, quando disponível.
3. Escolha a impressora desejada.
4. Salve a configuração.
5. Faça um teste com uma etiqueta.

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
