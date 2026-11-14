# Imagens da documentação

Atualizadas em 14/11/2026 a partir das telas e imagens geradas pelo projeto de
verificação `tests/testar_inicio.lpi`. As capturas usam dados demonstrativos;
não contêm dados de compradores ou etiquetas reais de postagem.

| Arquivo | Conteúdo |
|---|---|
| `inicio-visual.png` | Painel inicial com seleção de impressora, busca e cartões de modelos. |
| `editor-qr.png` | Editor de QR Code, fundo de clínica, prévia e ações de exportação/impressão. |
| `mercado-livre.png` | Tela de importação de etiquetas originais de envio. |
| `qr-saude.png` | Exemplo de etiqueta QR com fundo de clínica. |
| `qr-varejo.png` | Exemplo de etiqueta QR com fundo de supermercado. |

O QR dos exemplos contém `https://example.com/manual?produto=123`, um endereço
demonstrativo, sem um manual real hospedado pelo aplicativo.

Para atualizar, compile e execute `tests/testar_inicio.exe`. Copie os arquivos
`inicio.png`, `editor-qr.png` e `mercado-livre.png` de `tests/output` para os nomes
documentais correspondentes. Para os exemplos de etiqueta, use
`qr-0-fundo-1.png` e `qr-0-fundo-3.png`. Confira visualmente a legibilidade e
execute `python tests/verificar_qr.py` antes de publicar.

As imagens `main.png` e `tags.png` são registros históricos da tela clássica.
Foram preservadas, mas não representam o painel inicial atual.
