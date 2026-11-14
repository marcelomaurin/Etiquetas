# Etiquetas médicas, laboratoriais, varejo, despacho e crachás

O sistema agora separa todas as etiquetas pelas **4 categorias de impressoras** na tela principal e nos menus superiores:

1. **Impressora Tipo Zebra (Rolo Adesivo)** (`src/etiquetasmedicas.pas`, `src/pulseira.pas`, `src/etiquetasnovas.pas`)
   - **Despacho médico e logístico (100 × 150 mm):** remetente, destinatário, endereço, CEP, remessa com Code 128, volume atual/total (`1/N..N/N`), conservação e observações opcionais.
   - **Exame laboratorial / Tubo de Coleta (51 × 25 mm):** paciente, exame/material, bancada/tubo, identificador da amostra com Code 128 e data/hora da coleta.
   - **Lâmina de Biópsia / Patologia (25 × 15 mm):** nº do bloco/lâmina, iniciais do paciente, topografia/coloração e código de barras compacto.
   - **Bolsa de Sangue / Hemocomponentes (100 × 70 mm):** grupo ABO/Rh em destaque, componente, volume, validade, sorologia e código ISBT.
   - **Transporte Biológico UN 3373 (100 × 100 mm):** Substância Biológica Categoria B, remetente/destinatário, faixa térmica (2°C a 8°C) e telefone de emergência.
   - **Medicamento Avulso / Posologia (60 × 40 mm):** princípio ativo, posologia, horários sugeridos, lote/validade, CRF e EAN.
   - **Dose Unitária / Fracionamento Hospitalar (40 × 30 mm):** princípio ativo, forma/via, lote/validade após fracionamento, alerta de alta vigilância (MAV) e código unitário.
   - **Rótulo de Soro / Infusão Endovenosa (80 × 50 mm):** paciente, quarto/leito, solução base, aditivos, vazão (ml/h), início/término e responsável (COREN).
   - **Supermercado / Varejo:** Gôndola com Preço por Kg/Litro (`100 × 35 mm`), Balança de Padaria/Açougue com gerador de **EAN-13 prefixo 2** (`60 × 40 mm`) e Validade ANVISA RDC 216 (`50 × 30 mm`).
   - **Crachás:** Visitante/Acompanhante Hospitalar (`80 × 50 mm`) e Funcionário/Operador com Foto 3×4 tratada por `TGrayscaleFilter` e `TBrightnessContrastFilter` (`54 × 86 mm`).

2. **Impressora Térmica 80 Colunas (Bobina 80 mm PDV)** (`src/etiquetasnovas.pas` + `TAIPOSPrinter`)
   - Todos os modelos acima formatados para bobina de 80 mm, com opção de pré-visualização gráfica Windows ou envio direto via componente `TAIPOSPrinter` (`pmElginI9`, protocolo `ppEscPos`, porta Serial ou Rede 9100).

3. **Impressora Térmica 40 Colunas / 58 mm (Tipo Maquininha de Cartão)** (`src/etiquetasnovas.pas` + `TAIPOSPrinter`)
   - Todos os modelos adaptados para bobina de 58 mm (32/40 colunas via `pmQR203`), ideais para coletores móveis de supermercado, beira-leito hospitalar e coleta domiciliar.

4. **Impressora Laser ou Jato de Tinta Comum (Folhas Pimaco A4 / Carta e Cartazes)** (`src/etiquetaspimaco.pas`)
   - Modelos **Pimaco A4248 (96/folha), A4251 (65/folha), A4255 (27/folha), A4260 (21/folha), A4262 (14/folha), A4263 (10/folha), A4268 (4/folha), Carta 6180 (30/folha), Carta 6182 (14/folha)** e **Cartaz de Oferta A4**, permitindo definir **linha e coluna inicial** para reaproveitar folhas parcialmente usadas.
