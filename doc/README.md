# Documentação do Etiquetas

Bem-vindo à documentação do **Etiquetas**, sistema desktop para gerenciamento e impressão de etiquetas com banco SQLite.

Esta pasta reúne os documentos necessários para instalação, configuração, uso diário e manutenção básica do sistema.

---

## Documentos disponíveis

| Documento | Descrição |
|---|---|
| [Instalação](instalacao.md) | Como instalar, preparar banco de dados e executar o sistema. |
| [Manual do usuário](manual_usuario.md) | Guia prático para usar os módulos principais. |
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
│   └── win64/
│       └── sqlite3.dll
├── img/
├── csv/
└── doc/
```

No primeiro uso, abra a tela de configuração e confirme os caminhos do banco de dados e da biblioteca SQLite.
