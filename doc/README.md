# Documentação do Etiquetas

Bem-vindo à documentação do **Etiquetas**, sistema desktop para gerenciamento e impressão de etiquetas com banco SQLite.

Esta pasta reúne os documentos necessários para instalação, configuração, uso diário e manutenção básica do sistema.

---

## Documentos disponíveis

| Documento | Descrição |
|---|---|
| [Instalação](instalacao.md) | Como instalar, preparar banco de dados e executar o sistema. |
| [Manual do usuário](manual_usuario.md) | Guia prático para usar os módulos principais. |
| [Início visual, QR Code e Mercado Livre](NOVO_INICIO.md) | Seleção por impressora, fundos, manuais/vídeos e importação de etiquetas de envio. |
| [Configuração de impressora](configuracao_impressora.md) | Como preparar impressoras Zebra, térmicas ou impressoras padrão do sistema. |
| [Importação de CSV](importacao_csv.md) | Estrutura dos arquivos CSV aceitos pelo sistema. |
| [Documentação técnica](documentacao_tecnica.md) | Organização interna do projeto, módulos e dependências. |
| [Solução de problemas](solucao_de_problemas.md) | Erros comuns e formas de correção. |

---

## Público-alvo

Esta documentação foi escrita para dois públicos:

1. **Usuário final**, que precisa instalar, configurar e imprimir etiquetas.
2. **Desenvolvedor ou técnico**, que precisa manter o sistema, compilar o projeto ou ajustar banco e impressoras.

---

## Resumo do sistema

O Etiquetas permite:

- Gerenciar produtos para impressão de etiquetas de preço.
- Importar dados por CSV.
- Gerar etiquetas de gôndola.
- Gerar etiquetas de mala direta.
- Gerar etiquetas de laboratório com código de barras.
- Gerar QR Code PIX para impressão.
- Criar QR Codes de manuais e vídeos com textos, imagens, logotipos e fundos de saúde ou varejo.
- Importar etiquetas originais do Mercado Livre em PDF, ZIP ou ZPL/TXT/PRN.
- Escolher modelos por impressora em um painel ilustrado com busca e filtros.
- Usar banco SQLite local.

---

## Recomendação para implantação

Para uma instalação com aparência mais profissional, recomenda-se entregar ao usuário final uma pasta contendo:

```text
Etiquetas/
├── etiquetas.exe
├── db/
│   └── etiqueta.db
├── sqlite/
│   └── win32/
│       └── sqlite3.dll
├── background/
│   └── qrcode/
│       ├── saude-clinica.png
│       ├── saude-laboratorio.png
│       ├── varejo-mercado.png
│       └── varejo-loja.png
├── img/
├── csv/
└── doc/
```

No primeiro uso, abra **Configurações → Preferências** e confirme os caminhos do
banco e da biblioteca SQLite. Use a biblioteca da mesma arquitetura do
executável; a compilação Windows validada nesta atualização é de 32 bits.
Para importar PDFs de envio, é necessário um leitor de PDF instalado.

## Por onde começar

1. Escolha o tipo de impressora no painel inicial.
2. Abra o modelo, o editor de QR Code ou a importação do Mercado Livre.
3. Confira conteúdo, dimensões, dispositivo e papel antes da impressão.

A escolha no painel não instala a impressora nem altera o papel do driver.
Os módulos anteriores permanecem em **Configurações → Alternar início / tela clássica**.
