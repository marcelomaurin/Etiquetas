# Documentação técnica

Este documento descreve a organização técnica do projeto **Etiquetas**.

O objetivo é ajudar desenvolvedores e técnicos a entenderem a estrutura do sistema, seus módulos principais e os pontos de manutenção.

---

## 1. Tecnologia utilizada

O projeto é uma aplicação desktop desenvolvida com:

- **Lazarus / Free Pascal**.
- **LCL** para interface gráfica.
- **SQLite** como banco de dados local.
- **ZeosLib** para conexão com banco.
- **Fortes Report** para relatórios/impressões.
- Componentes de código de barras/QR Code.
- Componentes auxiliares como Rx e lNet visual.

---

## 2. Arquivo principal

O ponto de entrada do sistema está em:

```text
src/etiquetas.lpr
```

Ele inicializa a aplicação, registra os formulários principais e cria a tela principal `TfrmMain`.

Unidades carregadas no projeto incluem:

- `main`
- `dmbase`
- `setmain`
- `config`
- `gondola`
- `ticket`
- `Import`
- `csvproducts`
- `csvendereco`
- `csvetqlab`
- `MalaDireta`
- `etqlab`
- `pix`
- relatórios de impressão

---

## 3. Tela principal

Arquivo:

```text
src/main.pas
```

Responsabilidades:

- Inicializar configurações globais.
- Criar o DataModule principal.
- Abrir o banco SQLite.
- Exibir versão do sistema.
- Abrir os módulos do sistema.
- Salvar posição da janela ao encerrar.

Versão declarada no fonte:

```pascal
const
  versao = 1.10;
```

---

## 4. Configuração global

Arquivo:

```text
src/setmain.pas
```

Classe principal:

```pascal
TSetMain
```

Responsabilidades:

- Controlar o arquivo de configuração `etiqueta.cfg`.
- Guardar caminho do banco SQLite.
- Guardar caminho da biblioteca SQLite.
- Guardar último CSV usado.
- Guardar dados da empresa.
- Guardar posição da janela.

Parâmetros principais:

| Propriedade | Finalidade |
|---|---|
| `SQLLITEDLL` | Caminho da biblioteca SQLite. |
| `DB` | Caminho do banco `etiqueta.db`. |
| `CSVFOLDER` | Caminho do último CSV usado. |
| `EMPRESA` | Nome da empresa/remetente. |
| `ENDERECO1` | Primeira linha do endereço da empresa. |
| `ENDERECO2` | Segunda linha do endereço da empresa. |
| `SerialPrinter` | Campo reservado para impressora serial. |

---

## 5. Banco de dados

Arquivo principal de acesso:

```text
src/dmbase.pas
```

Classe:

```pascal
TdmBase
```

Responsabilidades:

- Abrir e fechar conexão SQLite.
- Controlar tabelas de produtos, endereços e etiquetas de laboratório.
- Importar CSV.
- Criar seleções temporárias para impressão.
- Apagar seleção de produtos.

Componentes principais:

- `TZConnection`
- `TZTable`
- `TZQuery`
- `TCSVDataset`
- `TDataSource`

Tabelas manipuladas pelo código:

| Tabela | Uso |
|---|---|
| `product` | Produtos para etiquetas de gôndola. |
| `selproduct` | Produtos selecionados para impressão. |
| `endereco` | Endereços para mala direta. |
| `selendereco` | Endereços selecionados para impressão. |
| `etqlab` | Registros de etiqueta de laboratório. |
| `seletqlab` | Registros de laboratório selecionados. |

---

## 6. Módulo de configuração

Arquivo:

```text
src/config.pas
```

Responsabilidades:

- Permitir selecionar o banco SQLite.
- Permitir selecionar a biblioteca SQLite.
- Permitir configurar empresa e endereço.
- Criar banco a partir do modelo, quando o arquivo não existir.
- Excluir banco mediante ação do usuário.
- Abrir diálogo de configuração de impressora.

A tela grava as configurações usando `FSetMain.SalvaContexto(false)`.

---

## 7. Módulo de produtos / gôndola

Arquivos principais:

```text
src/gondola.pas
src/ticket.pas
```

### `gondola.pas`

Tela intermediária que abre o fluxo de impressão de produtos.

### `ticket.pas`

Responsável por:

- Exibir produtos.
- Adicionar produtos à seleção de impressão.
- Apagar seleção.
- Imprimir usando relatórios `relticket` e `relticket02`.

O método `printing` percorre `zselproduct` e chama `PrintItem()` no relatório.

---

## 8. Módulo de importação

Arquivos:

```text
src/Import.pas
src/csvproducts.pas
src/csvendereco.pas
src/csvetqlab.pas
```

Responsabilidades:

- Abrir telas específicas para cada tipo de importação.
- Selecionar arquivo CSV.
- Chamar `fdmBase.ImportCVSReport` com o layout correto.

Layouts suportados:

| Layout | Colunas |
|---|---:|
| Produtos | 5 |
| Endereços | 8 |
| Etiquetas de laboratório | 3 |

---

## 9. Módulo de mala direta

Arquivo:

```text
src/MalaDireta.pas
```

Responsabilidades:

- Pesquisar endereços por nome.
- Selecionar destinatários.
- Montar etiqueta com dados da empresa e do destinatário.
- Abrir pré-visualização/impressão do relatório `reletiq01`.

A impressão usa os campos `EMPRESA`, `ENDERECO1` e `ENDERECO2` da configuração como remetente.

---

## 10. Módulo de etiqueta de laboratório

Arquivo:

```text
src/etqlab.pas
```

Responsabilidades:

- Pesquisar registros por `rotulo01`.
- Selecionar registros para etiqueta.
- Exibir rótulos e código de barras.
- Imprimir a área visual da etiqueta.

Campos principais:

- `rotulo01`
- `rotulo02`
- `barcode`

---

## 11. Módulo PIX

Arquivo:

```text
src/pix.pas
```

Responsabilidades:

- Receber string PIX.
- Atualizar QR Code.
- Imprimir a área visual do QR Code.
- Possui função `CalcCRC16` para cálculo CRC16/CCITT-FALSE.

---

## 12. Relatórios

O projeto utiliza unidades de relatório como:

- `relticket`
- `relticket02`
- `reletiq01`

Essas unidades concentram layouts de impressão.

Ao alterar o tamanho da etiqueta, margem ou aparência, os relatórios devem ser revisados.

---

## 13. Pontos de atenção técnica

### Caminhos Windows/Linux

Há trechos usando barra invertida `\`, inclusive em configurações padrão. Para melhorar compatibilidade Linux, recomenda-se usar `IncludeTrailingPathDelimiter` e `PathDelim`.

### Mensagens de sistema

Algumas mensagens estão em inglês. Para apresentação comercial em português, recomenda-se padronizar mensagens para PT-BR.

### Validação de CSV

A validação atual confere a quantidade de colunas. Pode ser evoluída para validar campos obrigatórios, tipos numéricos e linhas inválidas.

### Impressão por captura de tela

Alguns módulos imprimem capturando a área visual do componente. Isso funciona, mas pode variar conforme resolução, escala de tela e driver. Para versão comercial, recomenda-se migrar esses layouts para relatório ou renderização direta no canvas da impressora.

### Banco SQLite

O sistema usa banco local. Para ambientes com vários usuários simultâneos, seria necessário avaliar migração para banco cliente/servidor ou sincronização.

---

## 14. Sugestões para evolução comercial

- Criar instalador Windows completo.
- Gerar releases versionadas no GitHub.
- Adicionar arquivo `LICENSE`.
- Criar manual com imagens reais das telas.
- Padronizar idioma da interface.
- Melhorar tratamento de erros.
- Criar backup automático do banco antes de importações.
- Criar modelos CSV dentro da pasta `csv/modelos`.
- Adicionar testes de impressão e calibração.
- Criar opção de exportar base de produtos e endereços.
