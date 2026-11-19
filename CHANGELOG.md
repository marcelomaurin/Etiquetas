# Histórico de versões — Etiquetas

## 0122 — 19/11/2026

Instalador: `bin/setup_etiquetas_0122.exe`.

### Novidades

- **Menu Cadastros e gerenciador de tabelas.** Um único menu reúne todas as
  tabelas de apoio das etiquetas, agrupadas por segmento (varejo, laboratório,
  hospital, logística, crachás, atendimento, QR Code/PIX, clássicos). O
  gerenciador mostra quantos registros cada tabela tem e permite abrir os
  registros, importar e exportar CSV.
- **Gerenciar registros (CRUD).** Lista com pesquisa, edição lateral,
  atalhos de teclado (Ctrl+N, Ctrl+S, Del, Ctrl+F, Esc) e o menu **Mais ▾**
  com importação/exportação CSV e limpeza da tabela.
- **Protocolo de comunicação no Passo 1 do assistente.** A saída de impressão
  começa pelo protocolo (ZPL, EPL, ESC/POS, Padrão Windows etc.) e mostra só
  os campos da conexão escolhida: serial (porta e velocidade), rede (host e
  porta) ou a **impressora do Windows por nome** (TAIPOSPrinter).
- **Início em coluna.** Os tipos de impressora ficam numa coluna à esquerda e
  os modelos ocupam o painel principal, com busca e filtro por finalidade.
- **QR Code com imagem de topo e imagem de fundo.**
  - O antigo "Fundo ilustrado" passa a se chamar **Imagem de topo** (ilustração
    acima do título), com a opção **Nenhuma**.
  - Novo campo **Imagem de fundo**, que cobre a etiqueta inteira sem distorcer:
    nove fundos padrão (Saúde, Logística, Empresa, Teatro, Educação,
    Alimentação, Tecnologia, Eventos e Neutro) ou **Escolher imagem...** para
    usar um PNG/JPG/BMP próprio.
  - O QR Code é sempre desenhado sobre um quadro branco com margem (zona de
    silêncio), para continuar legível sobre qualquer fundo.
  - O fundo aparece na prévia, no **Salvar imagem PNG** e na impressão
    (inclusive no Cartaz A4) e fica salvo com o registro.
- **Impressão do QR Code como relatório do Windows** (FortesReport): uma página
  por etiqueta, com pré-visualização e escolha da impressora instalada.

### Banco de dados

- Nova coluna `imagem_fundo` no fim da tabela `etq_qr_midia`. Bancos criados
  por versões anteriores recebem a coluna automaticamente ao abrir o programa;
  os registros existentes ficam com fundo branco.

### Instalador

- Inclui `background\fundos\*.png` (fundos padrão do QR Code).
- Versão 0122 (1.22) no executável e no instalador.

### Ferramentas e testes

- `tools/gerar_fundos.py` gera os nove fundos (1063 × 1417 px, 90 × 120 mm a
  300 dpi) com Pillow: `python tools\gerar_fundos.py background\fundos`.
- `tests/testar_inicio.lpr` cobre os fundos, a migração do banco e captura as
  telas usadas na documentação; `tests/verificar_qr.py` decodifica todos os QR
  gerados.

## 0121 — 18/11/2026

- Criação automática do banco local em `C:\db\`, CRUD e ferramentas CSV por
  finalidade, modelo Mercado Livre 150 × 100 mm, exclusividade por tipo de
  impressora e assistente de impressão em 3 etapas.

## 0120 — 14/11/2026

- Início visual com cartões, editor de QR Code para manuais e vídeos e
  importação de etiquetas do Mercado Livre.
