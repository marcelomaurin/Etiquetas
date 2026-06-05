# Importação de CSV

O **Etiquetas** permite importar dados por arquivos CSV para alimentar as bases usadas na impressão.

Atualmente existem três layouts principais:

1. Produtos.
2. Endereços.
3. Etiquetas de laboratório.

O sistema valida o número de colunas antes da importação.

---

## 1. Regras gerais

- O arquivo deve estar em formato CSV.
- Mantenha sempre a mesma ordem de colunas.
- Evite linhas vazias.
- Evite ponto e vírgula ou vírgula solta dentro dos campos, salvo se o arquivo estiver corretamente tratado pelo editor CSV.
- Faça um teste com poucos registros antes de importar uma base grande.
- Faça backup do banco `etiqueta.db` antes de importações grandes.

---

## 2. CSV de produtos

O CSV de produtos deve ter **5 colunas**.

### Ordem das colunas

| Coluna | Campo | Descrição |
|---|---|---|
| 1 | `productDesc` | Descrição principal do produto. |
| 2 | `productDetail` | Detalhe complementar do produto. |
| 3 | `Detail01` | Informação adicional 1. |
| 4 | `Detail02` | Informação adicional 2. |
| 5 | `price` | Preço ou texto de preço. |

### Exemplo

```csv
Arroz Tipo 1,Pacote 5kg,Oferta,Válido até domingo,R$ 25,90
Feijão Carioca,Pacote 1kg,Preço especial,Lote promocional,R$ 7,99
Café Tradicional,500g,Torrado e moído,Oferta da semana,R$ 18,50
```

Observação: caso o preço contenha vírgula decimal, recomenda-se testar o separador usado pelo arquivo CSV. Em alguns ambientes pode ser melhor usar ponto decimal ou separar por ponto e vírgula, conforme o componente de leitura configurado.

---

## 3. CSV de endereços

O CSV de endereços deve ter **8 colunas**.

### Ordem das colunas

| Coluna | Campo | Descrição |
|---|---|---|
| 1 | `Nome` | Nome da pessoa ou empresa. |
| 2 | `TipoPessoa` | Código do tipo de pessoa. |
| 3 | `Documento` | CPF, CNPJ ou documento equivalente. |
| 4 | `Logradouro` | Rua, avenida ou endereço principal. |
| 5 | `Bairro` | Bairro. |
| 6 | `Cidade` | Cidade. |
| 7 | `CEP` | CEP. |
| 8 | `Referencia` | Complemento ou referência. |

### Exemplo

```csv
Empresa Exemplo,1,00.000.000/0001-00,Rua Central 100,Centro,Ribeirão Preto,14000-000,Próximo à praça
João da Silva,0,000.000.000-00,Avenida Brasil 250,Jardim Paulista,Ribeirão Preto,14090-000,Apto 12
```

---

## 4. CSV de etiquetas de laboratório

O CSV de etiquetas de laboratório deve ter **3 colunas**.

### Ordem das colunas

| Coluna | Campo | Descrição |
|---|---|---|
| 1 | `rotulo01` | Primeira linha da etiqueta. |
| 2 | `rotulo02` | Segunda linha da etiqueta. |
| 3 | `barcode` | Valor usado para gerar o código de barras. |

### Exemplo

```csv
Amostra 001,Soro,789000000001
Amostra 002,Plasma,789000000002
Amostra 003,Urina,789000000003
```

---

## 5. Como importar

1. Abra o sistema.
2. Acesse **Importação**.
3. Escolha o tipo de importação.
4. Selecione o arquivo CSV.
5. Confirme a importação.
6. Aguarde a mensagem de sucesso ou erro.

---

## 6. Mensagens comuns

### `Layout CSV not valid!`

O arquivo não tem o número de colunas esperado para o tipo de importação selecionado.

Verifique:

- Se escolheu o tipo certo de importação.
- Se o CSV tem a quantidade correta de colunas.
- Se há vírgulas extras dentro de algum campo.

### `Invalid CSV fields number`

O número de campos detectado não bate com o layout esperado.

### `File not exist`

O caminho do arquivo CSV está errado ou o arquivo foi movido.

---

## 7. Boas práticas

- Salve modelos de CSV para cada tipo de importação.
- Não misture produtos, endereços e laboratório no mesmo arquivo.
- Faça backup antes de importar bases grandes.
- Valide os dados em uma planilha antes de importar.
- Use nomes de arquivo claros, por exemplo:

```text
produtos_2026_06.csv
enderecos_clientes.csv
etiquetas_laboratorio_lote_001.csv
```
