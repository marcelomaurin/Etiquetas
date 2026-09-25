# Etiquetas médicas e laboratoriais

No menu principal:

- **Despacho médico (100 x 150)**: remetente, destinatário, endereço, CEP, remessa com Code 128, volume atual/total, conservação e observações opcionais.
- **Exame laboratorial (51 x 25)**: paciente (até duas linhas), exame/material, identificador da amostra com Code 128 e coleta opcional no formato dd/mm/aaaa hh:mm.

Preencha os dados e use **Pré-visualizar / imprimir**. Na pré-visualização, escolha a impressora Zebra instalada no Windows. Configure o papel correspondente e escala de 100%. Cada relatório gera uma etiqueta; o diálogo de impressão permite selecionar cópias.

Os modelos usam o FortesReport já presente no projeto. Não há integração com marketplaces. Os dados destes formulários não são gravados no banco; os campos começam vazios, exceto volume 1/1.

Textos que excedam o espaço são rejeitados, sem truncamento. O tamanho disponível também limita o identificador: códigos numéricos com quantidade par de dígitos usam Code 128 C; os demais usam Code 128 B. O código não é comprimido para caber.

Validação realizada: compilação Win32 do projeto completo; preparação de uma página nos dois formatos; renderização visual com dados fictícios; rejeição de coleta inválida, código excessivo e nome que não cabe. A impressão física e a leitura por scanner precisam ser verificadas na impressora utilizada.
