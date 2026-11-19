# Imagens da documentação

Atualizadas em 19/11/2026 (versão 0122) a partir das telas e imagens geradas pelo projeto de
verificação `tests/testar_inicio.lpi`. As capturas usam dados demonstrativos;
não contêm dados de compradores ou etiquetas reais de postagem.

| Arquivo | Conteúdo |
|---|---|
| `inicio-visual.png` | Painel inicial com seleção de impressora, busca e cartões de modelos. |
| `editor-qr.png` | Editor de QR Code com imagem de topo de clínica, prévia e ações de exportação/impressão. |
| `editor-qr-fundo.png` | Editor de QR Code com imagem de topo e imagem de fundo (Saúde). |
| `qr-fundo-saude.png` | Etiqueta QR com topo de clínica e fundo de saúde. |
| `qr-fundo-teatro.png` | Etiqueta QR com fundo de teatro. |
| `qr-cartaz-a4.png` | Cartaz A4 (formato da impressora convencional). |
| `fundos-padrao.png` | Miniaturas dos nove fundos de `background/fundos`. |
| `assistente-passo1.png` | Passo 1 do assistente de etiquetas, com protocolo de comunicação. |
| `cadastros.png` | Gerenciador de tabelas do menu Cadastros. |
| `gerenciar-registros.png` | Lista e edição de registros (tabela de QR Code, dados demonstrativos). |
| `mercado-livre.png` | Tela de importação de etiquetas originais de envio. |
| `qr-saude.png` | Exemplo de etiqueta QR com fundo de clínica. |
| `qr-varejo.png` | Exemplo de etiqueta QR com fundo de supermercado. |

O QR dos exemplos contém `https://example.com/manual?produto=123`, um endereço
demonstrativo, sem um manual real hospedado pelo aplicativo.

Para atualizar, compile e execute `tests/testar_inicio.exe`. Copie os arquivos
`inicio.png`, `editor-qr.png`, `editor-qr-fundo.png`, `mercado-livre.png`,
`assistente-passo1.png`, `cadastros.png` e `gerenciar-registros.png` de
`tests/output` para os nomes documentais correspondentes (`inicio.png` vira
`inicio-visual.png`; `qr-0-topo-e-fundo.png` vira `qr-fundo-saude.png` e
`qr-0-teatro.png` vira `qr-fundo-teatro.png`). Para os exemplos de etiqueta, use
`qr-0-fundo-1.png` e `qr-0-fundo-3.png`. Confira visualmente a legibilidade e
execute `python tests/verificar_qr.py` antes de publicar.

As imagens `main.png` e `tags.png` são registros históricos da tela clássica.
Foram preservadas, mas não representam o painel inicial atual.
