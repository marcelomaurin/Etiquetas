# Solução de problemas

Este documento reúne erros comuns do **Etiquetas** e orientações para correção.

---

## 1. O sistema não abre

### Possíveis causas

- Executável incompleto.
- Bibliotecas ausentes.
- Sistema operacional incompatível com a versão compilada.
- Permissão insuficiente no Linux.

### Soluções

No Windows:

- Confirme se todos os arquivos da pasta do sistema foram copiados.
- Execute o sistema a partir de uma pasta local.
- Evite rodar diretamente de arquivo compactado.

No Linux:

```bash
chmod +x etiquetas
./etiquetas
```

---

## 2. Erro de banco de dados

### Mensagens possíveis

- `Database path invalid!`
- `Arquivo de banco de dados ou biblioteca SQLite não encontrados.`
- `Falha ao conectar ao banco de dados`

### Possíveis causas

- Arquivo `etiqueta.db` não encontrado.
- Caminho do banco configurado errado.
- Pasta sem permissão de leitura ou escrita.
- Banco corrompido.

### Soluções

1. Abra **Configuração**.
2. Confira o caminho do banco.
3. Verifique se o arquivo existe.
4. Teste copiar o sistema para uma pasta simples, como `C:\Etiquetas\`.
5. Restaure um backup do banco, se necessário.

---

## 3. Erro da biblioteca SQLite

### Mensagens possíveis

- `Library path invalid!`
- `Biblioteca SQLite não encontrada`

### Possíveis causas

- `sqlite3.dll` ausente no Windows.
- Caminho configurado incorretamente.
- DLL incompatível com a arquitetura do executável.

### Soluções

1. Verifique se a DLL existe.
2. Confirme se o caminho está correto em **Configuração**.
3. Use DLL 32 bits para executável 32 bits.
4. Use DLL 64 bits para executável 64 bits.
5. Reinicie o sistema após salvar a configuração.

---

## 4. CSV não importa

### Mensagens possíveis

- `Layout CSV not valid!`
- `Invalid CSV fields number`
- `File not exist`

### Possíveis causas

- Arquivo CSV não encontrado.
- Número errado de colunas.
- Tipo de importação incorreto.
- Separador incompatível.
- Vírgulas extras dentro dos campos.

### Soluções

1. Confira o layout em [Importação de CSV](importacao_csv.md).
2. Teste com um arquivo pequeno.
3. Remova linhas vazias.
4. Confira se escolheu a importação correta: produtos, endereços ou laboratório.
5. Salve novamente o arquivo em formato CSV simples.

---

## 5. Impressora não imprime

### Possíveis causas

- Impressora não instalada no sistema operacional.
- Impressora errada como padrão.
- Driver incorreto.
- Cabo, USB, rede ou porta com problema.
- Fila de impressão travada.

### Soluções

1. Imprima uma página de teste pelo sistema operacional.
2. Defina a impressora correta como padrão.
3. Reinicie a fila de impressão.
4. Reinstale o driver, se necessário.
5. Teste outro cabo ou porta.

---

## 6. Etiqueta sai desalinhada

### Possíveis causas

- Tamanho da etiqueta errado no driver.
- Margens incompatíveis.
- Escala de tela ou impressão alterando o tamanho.
- Layout não ajustado ao modelo físico da etiqueta.

### Soluções

1. Configure o tamanho correto da etiqueta no driver.
2. Faça teste com uma etiqueta.
3. Ajuste orientação retrato/paisagem.
4. Revise margens no driver.
5. Para ajuste definitivo, revise o relatório correspondente no Lazarus.

---

## 7. Código de barras não lê

### Possíveis causas

- Código impresso pequeno demais.
- Impressão fraca.
- Contraste ruim.
- Impressora térmica descalibrada.
- Código informado incorretamente.

### Soluções

1. Aumente o tamanho do código no layout.
2. Melhore a densidade/temperatura da impressora térmica.
3. Use etiqueta adequada.
4. Confirme se o valor do campo `barcode` está correto.
5. Teste com outro leitor.

---

## 8. QR Code PIX não funciona

### Possíveis causas

- String PIX inválida.
- String incompleta.
- QR Code impresso pequeno demais.
- Baixa qualidade de impressão.

### Soluções

1. Confirme a string PIX no sistema de origem.
2. Gere novamente o payload PIX.
3. Aumente o tamanho do QR Code no layout.
4. Teste leitura pelo celular antes de distribuir.

---

## 9. Dados da empresa não aparecem na mala direta

### Possíveis causas

- Empresa e endereço não foram configurados.
- Configuração não foi salva.
- Arquivo `etiqueta.cfg` não pôde ser gravado.

### Soluções

1. Abra **Configuração**.
2. Preencha empresa e endereço.
3. Clique em salvar.
4. Feche e abra o sistema novamente.
5. Teste a etiqueta de mala direta.

---

## 10. Backup recomendado

Antes de manutenção ou atualização, copie:

```text
db/etiqueta.db
```

Também é recomendável guardar o arquivo de configuração do usuário `etiqueta.cfg`, localizado na pasta de configuração da aplicação.
