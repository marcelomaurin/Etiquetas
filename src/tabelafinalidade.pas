unit tabelafinalidade;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, ZConnection, ZDataset;

type
  TCampoTabelaDef = record
    Coluna: string;
    Rotulo: string;
  end;

  TTabelaFinalidade = record
    Chave: string;
    Tabela: string;
    Titulo: string;
    ChaveId: string;
    UsaCriadoEm: Boolean;
    Campos: array of TCampoTabelaDef;
  end;

  TTabelasFinalidade = array of TTabelaFinalidade;

  TStringArray = array of string;

  TLinhaTabela = record
    Id: string;
    Valores: TStringArray;
  end;

  TListaLinhasTabela = array of TLinhaTabela;

var
  GConexaoFinalidade: TZConnection = nil;

function ChaveTabelaSetorial(ModeloIndex: Integer): string;
function ChaveTabelaPimaco(FinalidadeIndex: Integer): string;
function ObterTabelaFinalidade(const Chave: string; out Spec: TTabelaFinalidade): Boolean;
function ListarTodasTabelasFinalidade: TTabelasFinalidade;

function GerarSQLCriarTabela(const Spec: TTabelaFinalidade): string;
procedure CriarTodasTabelasFinalidade(Conn: TZConnection);

function ContarRegistrosTabela(Conn: TZConnection; const Spec: TTabelaFinalidade): Integer;
function CarregarRegistrosTabela(Conn: TZConnection; const Spec: TTabelaFinalidade;
  const Filtro: string = ''): TListaLinhasTabela;
function InserirRegistroTabela(Conn: TZConnection; const Spec: TTabelaFinalidade;
  const Valores: array of string): Int64;
procedure AtualizarRegistroTabela(Conn: TZConnection; const Spec: TTabelaFinalidade;
  const IdValor: string; const Valores: array of string);
procedure ExcluirRegistroTabela(Conn: TZConnection; const Spec: TTabelaFinalidade;
  const IdValor: string);
procedure LimparTabelaFinalidade(Conn: TZConnection; const Spec: TTabelaFinalidade);

function ExportarCSVTabela(Conn: TZConnection; const Spec: TTabelaFinalidade;
  const CaminhoCSV: string): Integer;
function ExportarModeloCSVTabela(const Spec: TTabelaFinalidade;
  const CaminhoCSV: string): Boolean;
procedure ImportarCSVTabela(Conn: TZConnection; const Spec: TTabelaFinalidade;
  const CaminhoCSV: string; out Importados, Erros: Integer);

implementation

var
  GRegistroTabelas: TTabelasFinalidade;
  GRegistroInicializado: Boolean = False;

function Campo(const Coluna, Rotulo: string): TCampoTabelaDef;
begin
  Result.Coluna := Coluna;
  Result.Rotulo := Rotulo;
end;

procedure RegistrarTabela(const Chave, Tabela, Titulo, ChaveId: string;
  UsaCriadoEm: Boolean; const Campos: array of TCampoTabelaDef);
var
  Idx, I: Integer;
begin
  Idx := Length(GRegistroTabelas);
  SetLength(GRegistroTabelas, Idx + 1);
  GRegistroTabelas[Idx].Chave := Chave;
  GRegistroTabelas[Idx].Tabela := Tabela;
  GRegistroTabelas[Idx].Titulo := Titulo;
  GRegistroTabelas[Idx].ChaveId := ChaveId;
  GRegistroTabelas[Idx].UsaCriadoEm := UsaCriadoEm;
  SetLength(GRegistroTabelas[Idx].Campos, Length(Campos));
  for I := 0 to High(Campos) do
    GRegistroTabelas[Idx].Campos[I] := Campos[I];
end;

procedure InicializarRegistroTabelas;
begin
  if GRegistroInicializado then
    Exit;
  GRegistroInicializado := True;

  { 13 finalidades setoriais (Zebra / Térmica 80mm / Térmica 40mm) }
  RegistrarTabela('setorial_0', 'etq_lab_tubo_coleta',
    'Laboratório: Tubo de Coleta / Vacutainer', 'id', True, [
    Campo('paciente', 'Nome do Paciente'),
    Campo('data_nasc_idade_sexo', 'Data Nasc. / Idade / Sexo'),
    Campo('exame_material', 'Exame / Material'),
    Campo('tubo_bancada', 'Tubo / Tampa e Bancada'),
    Campo('data_hora_coleta', 'Data e Hora da Coleta'),
    Campo('unidade_leito', 'Unidade / Leito / Origem'),
    Campo('observacao_clinica', 'Observação Clínica'),
    Campo('codigo_amostra', 'Nº da Amostra / Código de Barras')
  ]);

  RegistrarTabela('setorial_1', 'etq_lab_lamina_biopsia',
    'Laboratório: Lâmina de Biópsia / Patologia / Citologia', 'id', True, [
    Campo('bloco_lamina', 'Nº do Bloco / Lâmina'),
    Campo('iniciais_prontuario', 'Iniciais do Paciente + Prontuário'),
    Campo('topografia_peca', 'Topografia / Peça Anatômica'),
    Campo('coloracao', 'Coloração'),
    Campo('data_processamento', 'Data do Processamento'),
    Campo('patologista', 'Patologista Responsável'),
    Campo('fragmento_corte', 'Fragmento / Corte'),
    Campo('codigo_barras', 'Código Compacto da Lâmina (Barras)')
  ]);

  RegistrarTabela('setorial_2', 'etq_lab_bolsa_sangue',
    'Laboratório: Bolsa de Sangue / Hemoterapia', 'id', True, [
    Campo('grupo_sanguineo', 'Grupo Sanguíneo ABO / Fator Rh'),
    Campo('hemocomponente', 'Hemocomponente'),
    Campo('volume_anticoagulante', 'Volume (ml) e Anticoagulante'),
    Campo('coleta_validade', 'Data da Coleta e Validade'),
    Campo('sorologia', 'Sorologia / Testes'),
    Campo('receptor_prova', 'Paciente Receptor / Prova Cruzada'),
    Campo('temperatura', 'Temperatura de Conservação'),
    Campo('numero_bolsa', 'Nº da Bolsa / ISBT (Barras)')
  ]);

  RegistrarTabela('setorial_3', 'etq_lab_transporte_bio',
    'Laboratório: Transporte Material Biológico UN 3373', 'id', True, [
    Campo('classificacao_onu', 'Classificação ONU / ANVISA'),
    Campo('remetente', 'Laboratório / Unidade Remetente'),
    Campo('destinatario', 'Laboratório Central / Destinatário'),
    Campo('temperatura_exigida', 'Faixa de Temperatura Exigida'),
    Campo('quantidade_amostras', 'Quantidade e Tipo de Amostras'),
    Campo('responsavel_envio', 'Responsável e Data/Hora'),
    Campo('telefone_emergencia', 'Telefone de Emergência 24h'),
    Campo('codigo_malote', 'Código do Malote / Lacre (Barras)')
  ]);

  RegistrarTabela('setorial_4', 'etq_med_posologia',
    'Farmácia: Medicamento Avulso / Posologia', 'id', True, [
    Campo('medicamento', 'Medicamento + Concentração'),
    Campo('paciente', 'Nome do Paciente'),
    Campo('posologia', 'Posologia / Instrução de Uso'),
    Campo('horarios', 'Horários Sugeridos'),
    Campo('lote_validade', 'Lote e Data de Validade'),
    Campo('advertencias', 'Advertências / Conservação'),
    Campo('farmaceutico_crf', 'Farmacêutico Responsável (CRF)'),
    Campo('codigo_barras', 'Código de Barras / EAN')
  ]);

  RegistrarTabela('setorial_5', 'etq_med_fracionamento',
    'Farmácia Hospitalar: Dose Unitária / Fracionamento', 'id', True, [
    Campo('principio_ativo', 'Princípio Ativo (DCB) + Dose'),
    Campo('forma_via', 'Forma Farmacêutica e Via'),
    Campo('lote_fabricante', 'Lote Original e Fabricante'),
    Campo('validade_fracionamento', 'Validade após Fracionamento'),
    Campo('classificacao_alerta', 'Classificação / Alerta'),
    Campo('farmacia_responsavel', 'Farmácia / Responsável'),
    Campo('registro_anvisa', 'Registro MS / ANVISA'),
    Campo('codigo_unitario', 'Código Unitário (Barras)')
  ]);

  RegistrarTabela('setorial_6', 'etq_med_soro_infusao',
    'Hospitalar: Rótulo de Soro / Infusão Endovenosa', 'id', True, [
    Campo('paciente_prontuario', 'Nome do Paciente + Prontuário'),
    Campo('unidade_quarto_leito', 'Unidade / Quarto / Leito'),
    Campo('solucao_base', 'Solução Base'),
    Campo('aditivos', 'Aditivos / Medicamentos Diluídos'),
    Campo('velocidade_infusao', 'Velocidade de Infusão / Gotejamento'),
    Campo('inicio_termino', 'Início e Término Previsto'),
    Campo('profissional_coren_crm', 'Preparado por (COREN) / Prescritor'),
    Campo('codigo_prescricao', 'Código da Prescrição (Barras)')
  ]);

  RegistrarTabela('setorial_7', 'etq_sup_gondola',
    'Supermercado: Gôndola Preço + Kg/Litro', 'id', True, [
    Campo('descricao_produto', 'Descrição do Produto na Gôndola'),
    Campo('marca_categoria', 'Marca / Categoria / Embalagem'),
    Campo('preco_venda', 'Preço de Venda em Destaque'),
    Campo('preco_por_kg_litro', 'Preço por Quilo / Litro / 100g'),
    Campo('preco_atacado', 'Preço Atacado / Clube'),
    Campo('codigo_plu_data', 'Código Interno (PLU) e Data'),
    Campo('corredor_prateleira', 'Corredor / Prateleira / Fornecedor'),
    Campo('codigo_ean13', 'Código de Barras EAN-13')
  ]);

  RegistrarTabela('setorial_8', 'etq_sup_balanca',
    'Supermercado: Balança Padaria / Açougue / Frios EAN-13', 'id', True, [
    Campo('produto', 'Produto (Padaria / Açougue / Frios)'),
    Campo('codigo_plu', 'Código PLU (5 dígitos)'),
    Campo('peso_preco_kg', 'Peso Líquido e Preço por Kg'),
    Campo('valor_total', 'Valor Total a Pagar'),
    Campo('embalagem_validade', 'Data de Embalagem e Validade'),
    Campo('ingredientes_alergenicos', 'Ingredientes / Alergênicos'),
    Campo('conservacao', 'Conservação'),
    Campo('codigo_ean13_balanca', 'Código EAN-13 de Balança')
  ]);

  RegistrarTabela('setorial_9', 'etq_sup_validade',
    'Supermercado & Saúde: Validade ANVISA RDC 216', 'id', True, [
    Campo('alimento_insumo', 'Alimento / Insumo Manipulado'),
    Campo('data_abertura', 'Data e Hora da Abertura'),
    Campo('data_validade', 'Data e Hora Limite de Validade'),
    Campo('conservacao', 'Método de Conservação'),
    Campo('setor', 'Setor'),
    Campo('responsavel', 'Responsável pela Manipulação'),
    Campo('lote_original', 'Lote Original / SIF'),
    Campo('codigo_controle', 'Código de Controle Interno (Barras)')
  ]);

  RegistrarTabela('setorial_10', 'etq_envio_despacho',
    'Logística & Varejo: Envio e Despacho de Volumes', 'id', True, [
    Campo('destinatario', 'Destinatário / Cliente / Filial'),
    Campo('endereco_entrega', 'Endereço Completo de Entrega'),
    Campo('bairro_cidade_uf_cep', 'Bairro, Cidade / UF e CEP'),
    Campo('remetente', 'Remetente / Centro de Distribuição'),
    Campo('nf_pedido_transportadora', 'NF, Pedido e Transportadora'),
    Campo('volume', 'Volume Atual / Total'),
    Campo('cuidados_transporte', 'Cuidados no Transporte'),
    Campo('codigo_remessa', 'Código da Remessa / Chave NF (Barras)')
  ]);

  RegistrarTabela('setorial_11', 'etq_cracha_visitante',
    'Hospitalar: Crachá de Visitante / Acompanhante', 'id', True, [
    Campo('tipo_credencial', 'Tipo de Credencial'),
    Campo('nome_visitante', 'Nome Completo do Visitante'),
    Campo('documento_telefone', 'Documento (CPF / RG) e Telefone'),
    Campo('paciente_visitado', 'Paciente Visitado'),
    Campo('unidade_quarto_leito', 'Unidade / Ala / Quarto / Leito'),
    Campo('data_hora_entrada', 'Data e Hora de Entrada / Validade'),
    Campo('portaria_recepcionista', 'Portaria / Recepcionista'),
    Campo('codigo_credencial', 'Código da Credencial (Barras)')
  ]);

  RegistrarTabela('setorial_12', 'etq_cracha_funcionario',
    'Varejo & Saúde: Crachá de Funcionário / Operador', 'id', True, [
    Campo('empresa', 'Nome da Empresa / Hospital'),
    Campo('nome_guerra', 'Nome de Guerra'),
    Campo('cargo_funcao', 'Cargo / Função'),
    Campo('nome_completo', 'Nome Completo do Colaborador'),
    Campo('setor_matricula', 'Setor / Matrícula / Registro Profissional'),
    Campo('tipo_sanguineo_admissao', 'Tipo Sanguíneo / Admissão'),
    Campo('nivel_acesso', 'Nível de Acesso'),
    Campo('codigo_matricula', 'Matrícula / Crachá (Barras)'),
    Campo('caminho_foto', 'Caminho da Foto (Opcional)')
  ]);

  RegistrarTabela('setorial_13', 'etq_envio_ml_150x100',
    'Logística & E-commerce: Etiqueta Tipo ML (150 x 100 mm)', 'id', True, [
    Campo('destinatario', 'Destinatário / Comprador'),
    Campo('endereco_entrega', 'Endereço Completo (Rua, Nº, Compl.)'),
    Campo('bairro_cidade_uf_cep', 'Bairro, Cidade / UF e CEP'),
    Campo('remetente', 'Remetente / Loja'),
    Campo('pedido_nf_volume', 'Venda / Pedido / NF / Volume'),
    Campo('modalidade_rota', 'Transportadora / Modalidade / Rota'),
    Campo('observacao_conteudo', 'Observação / Conteúdo'),
    Campo('codigo_rastreio', 'Código de Rastreio / Etiqueta (Barras)')
  ]);

  RegistrarTabela('setorial_14', 'etq_ribbon_patrimonio',
    'Ribbon / Zebra: Patrimônio e Ativo Fixo (50 x 25 mm)', 'id', True, [
    Campo('empresa_instituicao', 'Empresa / Instituição'),
    Campo('descricao_bem', 'Descrição do Bem / Equipamento'),
    Campo('setor_localizacao', 'Setor / Localização'),
    Campo('responsavel', 'Responsável / Centro de Custo'),
    Campo('numero_serie_nf', 'Nº Série / Nota Fiscal'),
    Campo('data_aquisicao', 'Data de Aquisição / Tombamento'),
    Campo('estado_conservacao', 'Observação / Garantia'),
    Campo('numero_patrimonio', 'Nº do Patrimônio (Barras)')
  ]);

  RegistrarTabela('setorial_15', 'etq_term80_comanda',
    'Térmica 80 col: Comanda / Pedido de Cozinha e Balcão', 'id', True, [
    Campo('numero_pedido', 'Nº do Pedido / Mesa / Comanda'),
    Campo('cliente_atendente', 'Cliente / Atendente'),
    Campo('itens_pedido', 'Itens / Quantidades'),
    Campo('adicionais_obs', 'Adicionais / Observações de Preparo'),
    Campo('setor_producao', 'Setor (Cozinha / Copa / Balcão)'),
    Campo('data_hora_pedido', 'Data e Hora do Pedido'),
    Campo('forma_entrega', 'Consumo Local / Viagem / Entrega'),
    Campo('codigo_comanda', 'Código da Comanda (Barras)')
  ]);

  RegistrarTabela('setorial_16', 'etq_term80_senha',
    'Térmica 80 col: Senha / Ficha de Atendimento', 'id', True, [
    Campo('estabelecimento', 'Estabelecimento / Unidade'),
    Campo('tipo_atendimento', 'Tipo de Atendimento (Normal / Preferencial)'),
    Campo('numero_senha', 'Número da Senha'),
    Campo('guiche_setor', 'Setor / Guichê'),
    Campo('data_hora_emissao', 'Data e Hora da Emissão'),
    Campo('previsao_fila', 'Observação / Fila'),
    Campo('orientacao', 'Orientação ao Usuário'),
    Campo('codigo_senha', 'Código de Chamada (Barras)')
  ]);

  RegistrarTabela('setorial_17', 'etq_term55_delivery',
    'Térmica 55/58 mm: Sacola / Delivery Compacta', 'id', True, [
    Campo('loja_restaurante', 'Loja / Restaurante'),
    Campo('cliente', 'Nome do Cliente'),
    Campo('endereco_entrega', 'Endereço / Referência'),
    Campo('telefone_contato', 'Telefone / WhatsApp'),
    Campo('itens_resumo', 'Pedido / Volumes'),
    Campo('forma_pagamento', 'Pagamento / Troco'),
    Campo('observacao', 'Observação de Entrega'),
    Campo('codigo_pedido', 'Código do Pedido (Barras)')
  ]);

  RegistrarTabela('setorial_18', 'etq_term55_preco',
    'Térmica 55/58 mm: Preço Rápido de Corredor', 'id', True, [
    Campo('produto', 'Descrição Curta do Produto'),
    Campo('unidade_medida', 'Unidade / Embalagem'),
    Campo('preco_venda', 'Preço de Venda'),
    Campo('preco_promocional', 'Preço Promocional / Clube'),
    Campo('validade_oferta', 'Validade da Oferta'),
    Campo('corredor_secao', 'Corredor / Seção'),
    Campo('codigo_interno', 'Código Interno / PLU'),
    Campo('codigo_barras', 'Código de Barras')
  ]);

  RegistrarTabela('setorial_19', 'etq_term55_comanda',
    'Térmica 55/58 mm: Comanda Resumida Portátil', 'id', True, [
    Campo('numero_comanda', 'Nº da Comanda / Mesa'),
    Campo('cliente', 'Cliente'),
    Campo('itens', 'Itens / Observação'),
    Campo('atendente', 'Atendente'),
    Campo('data_hora', 'Data e Hora'),
    Campo('valor_total', 'Total / Status'),
    Campo('local_entrega', 'Balcão / Mesa'),
    Campo('codigo_comanda', 'Código da Comanda (Barras)')
  ]);

  RegistrarTabela('setorial_20', 'etq_term55_senha',
    'Térmica 55/58 mm: Senha / Ticket Portátil', 'id', True, [
    Campo('unidade', 'Unidade / Evento'),
    Campo('numero_senha', 'Senha / Ticket'),
    Campo('categoria', 'Categoria (Geral / Preferencial)'),
    Campo('setor', 'Setor / Sala'),
    Campo('data_hora', 'Data e Hora'),
    Campo('observacao', 'Observação'),
    Campo('validade', 'Validade'),
    Campo('codigo_ticket', 'Código do Ticket (Barras)')
  ]);

  { 6 finalidades Pimaco / Laser / Jato de Tinta }
  RegistrarTabela('pimaco_0', 'pimaco_supermercado',
    'Pimaco: Supermercado / Varejo (Preço / EAN)', 'id', True, [
    Campo('descricao_produto', 'Descrição do Produto'),
    Campo('marca_detalhe', 'Marca / Detalhe / Peso líquido'),
    Campo('preco_por_kg', 'Preço por Kg / Litro'),
    Campo('preco_venda', 'Preço de Venda em Destaque'),
    Campo('unidade_oferta', 'Unidade / Observação de Oferta'),
    Campo('codigo_barras', 'Código de Barras EAN-13 / PLU')
  ]);

  RegistrarTabela('pimaco_1', 'pimaco_validade',
    'Pimaco: Validade / Padaria (ANVISA RDC 216)', 'id', True, [
    Campo('produto_manipulado', 'Produto Manipulado / Fracionado'),
    Campo('data_manipulacao', 'Data/Hora de Manipulação'),
    Campo('data_validade', 'Data/Hora de Validade'),
    Campo('conservacao', 'Conservação'),
    Campo('responsavel_setor', 'Responsável / Setor'),
    Campo('lote_codigo', 'Lote / Código Interno')
  ]);

  RegistrarTabela('pimaco_2', 'pimaco_laboratorio',
    'Pimaco: Laboratório (Tubos / Lâminas / Exames)', 'id', True, [
    Campo('paciente', 'Nome do Paciente'),
    Campo('exame_material', 'Exame / Material Biológico'),
    Campo('data_hora_coleta', 'Data e Hora da Coleta'),
    Campo('convenio_bancada_tubo', 'Convênio / Bancada / Tubo'),
    Campo('medico_origem', 'Médico Solicitante / Origem'),
    Campo('numero_amostra', 'Nº da Amostra / Código de Barras')
  ]);

  RegistrarTabela('pimaco_3', 'pimaco_medicamento',
    'Pimaco: Medicamento Avulso / Posologia / Soro', 'id', True, [
    Campo('medicamento', 'Medicamento / Princípio Ativo'),
    Campo('posologia', 'Posologia / Modo de Usar'),
    Campo('lote_fabricante', 'Lote e Fabricante'),
    Campo('validade', 'Validade'),
    Campo('alerta_crf', 'Alerta / Farmacêutico (CRF)'),
    Campo('codigo_barras', 'Código de Barras / Rastreabilidade')
  ]);

  RegistrarTabela('pimaco_4', 'pimaco_despacho',
    'Pimaco: Envio e Despacho de Produtos', 'id', True, [
    Campo('remetente', 'Remetente / Unidade Expedidora'),
    Campo('destinatario', 'Destinatário / Cliente / Hospital'),
    Campo('endereco_entrega', 'Endereço de Entrega'),
    Campo('cep_cidade_uf', 'CEP e Cidade / UF'),
    Campo('nota_fiscal_obs', 'Nota Fiscal / Conservação / Obs.'),
    Campo('codigo_rastreio', 'Código de Rastreio / Pedido (Barras)')
  ]);

  RegistrarTabela('pimaco_5', 'pimaco_cracha',
    'Pimaco: Crachás (Visitante / Hospital / Varejo)', 'id', True, [
    Campo('categoria_topo', 'Categoria no Topo'),
    Campo('nome', 'Nome Completo / Nome de Guerra'),
    Campo('setor_cargo_leito', 'Setor / Cargo ou Paciente / Leito'),
    Campo('documento', 'Documento (CPF / RG / Matrícula)'),
    Campo('empresa_ala_validade', 'Empresa / Ala / Validade'),
    Campo('codigo_acesso', 'Código de Acesso (Barras)'),
    Campo('caminho_foto', 'Caminho da Foto (Opcional)')
  ]);

  RegistrarTabela('pimaco_6', 'pimaco_aviso_a4',
    'Papel A4 Convencional: Aviso / Identificação de Caixa e Prateleira', 'id', True, [
    Campo('titulo_aviso', 'Título Principal'),
    Campo('subtitulo_setor', 'Setor / Subtítulo'),
    Campo('descricao_conteudo', 'Descrição / Instrução'),
    Campo('destaque_codigo', 'Destaque / Identificação'),
    Campo('responsavel_data', 'Responsável / Data'),
    Campo('codigo_barras', 'Código de Barras (Opcional)')
  ]);

  { Outras finalidades específicas }
  RegistrarTabela('pulseira', 'etq_pulseira',
    'Identificação Neonatal: Pulseira de Bebê', 'id', True, [
    Campo('bebe', 'Nome do Bebê'),
    Campo('mae', 'Nome da Mãe'),
    Campo('identificador', 'Identificador / Atendimento'),
    Campo('data_nascimento', 'Data de Nascimento (dd/mm/aaaa)'),
    Campo('hora_nascimento', 'Hora de Nascimento (hh:mm)'),
    Campo('inicio_mm', 'Início da Impressão (mm)'),
    Campo('area_mm', 'Área Útil (mm)')
  ]);

  RegistrarTabela('medica_despacho', 'etq_medica_despacho',
    'Médica / Hospitalar: Despacho 100 x 150 mm', 'id', True, [
    Campo('remetente', 'Remetente'),
    Campo('endereco_remetente', 'Endereço do Remetente'),
    Campo('destinatario', 'Destinatário'),
    Campo('endereco_entrega', 'Endereço de Entrega'),
    Campo('cidade_uf', 'Cidade / UF'),
    Campo('cep', 'CEP'),
    Campo('codigo_remessa', 'Pedido / Remessa (Barras)'),
    Campo('volume_atual', 'Volume Atual'),
    Campo('total_volumes', 'Total de Volumes'),
    Campo('conservacao', 'Conservação'),
    Campo('observacoes', 'Observações de Transporte'),
    Campo('referencia', 'Conteúdo / Referência')
  ]);

  RegistrarTabela('medica_exame', 'etq_medica_exame',
    'Médica / Laboratorial: Exame 51 x 25 mm', 'id', True, [
    Campo('paciente', 'Nome do Paciente'),
    Campo('exame_material', 'Exame / Material'),
    Campo('identificador', 'Identificador da Amostra (Barras)'),
    Campo('data_hora_coleta', 'Data/Hora da Coleta (dd/mm/aaaa hh:mm)')
  ]);

  RegistrarTabela('qr_midia', 'etq_qr_midia',
    'Conteúdo Digital: QR Code (Manuais e Vídeos)', 'id', True, [
    Campo('finalidade', 'Conteúdo do QR Code (Índice)'),
    Campo('link', 'Link Público (HTTP/HTTPS)'),
    Campo('titulo', 'Título'),
    Campo('texto', 'Texto de Apoio'),
    Campo('chamada', 'Chamada Abaixo do QR Code'),
    Campo('fundo', 'Fundo Ilustrado (Índice)'),
    Campo('formato', 'Formato de Impressão (Índice)'),
    Campo('largura_mm', 'Largura (mm)'),
    Campo('altura_mm', 'Altura (mm)'),
    Campo('caminho_imagem', 'Caminho da Imagem / Logo')
  ]);

  RegistrarTabela('pix', 'etq_pix',
    'Financeiro: QR Code PIX', 'id', True, [
    Campo('descricao', 'Descrição / Identificação'),
    Campo('chave_pix', 'String / Payload PIX')
  ]);

  { Tabelas clássicas já existentes no sistema }
  RegistrarTabela('classica_product', 'product',
    'Clássico: Produtos / Gôndola', 'idproduto', False, [
    Campo('productDesc', 'Descrição do Produto'),
    Campo('productDetail', 'Detalhe / Marca'),
    Campo('Detail01', 'Detalhe 01'),
    Campo('Detail02', 'Código de Barras / Detalhe 02'),
    Campo('price', 'Preço')
  ]);

  RegistrarTabela('classica_endereco', 'endereco',
    'Clássico: Endereços / Mala Direta', 'Ind', False, [
    Campo('Nome', 'Nome'),
    Campo('TipoPessoa', 'Tipo Pessoa (0=PF, 1=PJ)'),
    Campo('Documento', 'Documento'),
    Campo('Logradouro', 'Logradouro'),
    Campo('Bairro', 'Bairro'),
    Campo('Cidade', 'Cidade'),
    Campo('CEP', 'CEP'),
    Campo('Referencia', 'Referência')
  ]);

  RegistrarTabela('classica_etqlab', 'etqlab',
    'Clássico: Etiquetas de Laboratório', 'id', False, [
    Campo('rotulo01', 'Rótulo 01'),
    Campo('rotulo02', 'Rótulo 02'),
    Campo('barcode', 'Código de Barras')
  ]);
end;

function ChaveTabelaSetorial(ModeloIndex: Integer): string;
begin
  Result := 'setorial_' + IntToStr(ModeloIndex);
end;

function ChaveTabelaPimaco(FinalidadeIndex: Integer): string;
begin
  Result := 'pimaco_' + IntToStr(FinalidadeIndex);
end;

function ObterTabelaFinalidade(const Chave: string; out Spec: TTabelaFinalidade): Boolean;
var
  I: Integer;
begin
  InicializarRegistroTabelas;
  for I := 0 to High(GRegistroTabelas) do
  begin
    if SameText(GRegistroTabelas[I].Chave, Chave) or SameText(GRegistroTabelas[I].Tabela, Chave) then
    begin
      Spec := GRegistroTabelas[I];
      Exit(True);
    end;
  end;
  Result := False;
end;

function ListarTodasTabelasFinalidade: TTabelasFinalidade;
begin
  InicializarRegistroTabelas;
  Result := Copy(GRegistroTabelas, 0, Length(GRegistroTabelas));
end;

function GerarSQLCriarTabela(const Spec: TTabelaFinalidade): string;
var
  I: Integer;
  TipoColuna: string;
begin
  if SameText(Spec.Tabela, 'product') then
  begin
    Result :=
      'CREATE TABLE IF NOT EXISTS product (' +
      '  idproduto INTEGER PRIMARY KEY AUTOINCREMENT,' +
      '  productDesc char(20) not null,' +
      '  productDetail char(40),' +
      '  Detail01 char(20),' +
      '  Detail02 char(20),' +
      '  price char(20)' +
      ')';
    Exit;
  end;

  if SameText(Spec.Tabela, 'endereco') then
  begin
    Result :=
      'CREATE TABLE IF NOT EXISTS endereco (' +
      '  Ind INTEGER PRIMARY KEY,' +
      '  Nome var(40) NOT NULL,' +
      '  TipoPessoa INTEGER NOT NULL,' +
      '  Documento char(40),' +
      '  Logradouro char(40),' +
      '  Bairro char(40),' +
      '  Cidade char(40),' +
      '  CEP char(20),' +
      '  Referencia char(40)' +
      ')';
    Exit;
  end;

  if SameText(Spec.Tabela, 'etqlab') then
  begin
    Result :=
      'CREATE TABLE IF NOT EXISTS etqlab (' +
      '  id INTEGER PRIMARY KEY AUTOINCREMENT,' +
      '  rotulo01 STRING(60),' +
      '  rotulo02 STRING(60),' +
      '  barcode STRING(20)' +
      ')';
    Exit;
  end;

  Result := 'CREATE TABLE IF NOT EXISTS "' + Spec.Tabela + '" (' +
            '"' + Spec.ChaveId + '" INTEGER PRIMARY KEY AUTOINCREMENT';
  for I := 0 to High(Spec.Campos) do
  begin
    TipoColuna := 'TEXT';
    Result := Result + ', "' + Spec.Campos[I].Coluna + '" ' + TipoColuna;
  end;
  if Spec.UsaCriadoEm then
    Result := Result + ', "criado_em" TEXT';
  Result := Result + ')';
end;

procedure CriarTodasTabelasFinalidade(Conn: TZConnection);
var
  I: Integer;
  Q: TZQuery;
begin
  if (Conn = nil) or (not Conn.Connected) then
    Exit;

  InicializarRegistroTabelas;
  Q := TZQuery.Create(nil);
  try
    Q.Connection := Conn;
    for I := 0 to High(GRegistroTabelas) do
    begin
      Q.SQL.Text := GerarSQLCriarTabela(GRegistroTabelas[I]);
      Q.ExecSQL;
    end;
  finally
    Q.Free;
  end;
end;

function ContarRegistrosTabela(Conn: TZConnection; const Spec: TTabelaFinalidade): Integer;
var
  Q: TZQuery;
begin
  Result := 0;
  if (Conn = nil) or (not Conn.Connected) then
    Exit;

  Q := TZQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT COUNT(*) AS total FROM "' + Spec.Tabela + '"';
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.FieldByName('total').AsInteger;
  finally
    Q.Free;
  end;
end;

function CarregarRegistrosTabela(Conn: TZConnection; const Spec: TTabelaFinalidade;
  const Filtro: string = ''): TListaLinhasTabela;
var
  Q: TZQuery;
  SQL, Cond: string;
  I, RowIdx: Integer;
begin
  SetLength(Result, 0);
  if (Conn = nil) or (not Conn.Connected) then
    Exit;

  Q := TZQuery.Create(nil);
  try
    Q.Connection := Conn;
    SQL := 'SELECT "' + Spec.ChaveId + '"';
    for I := 0 to High(Spec.Campos) do
      SQL := SQL + ', "' + Spec.Campos[I].Coluna + '"';
    SQL := SQL + ' FROM "' + Spec.Tabela + '"';

    if Trim(Filtro) <> '' then
    begin
      Cond := '';
      for I := 0 to High(Spec.Campos) do
      begin
        if Cond <> '' then
          Cond := Cond + ' OR ';
        Cond := Cond + 'CAST(COALESCE("' + Spec.Campos[I].Coluna + '", '''') AS TEXT) LIKE :filtro';
      end;
      if Cond <> '' then
        SQL := SQL + ' WHERE (' + Cond + ')';
    end;
    SQL := SQL + ' ORDER BY "' + Spec.ChaveId + '" DESC';

    Q.SQL.Text := SQL;
    if Trim(Filtro) <> '' then
      Q.ParamByName('filtro').AsString := '%' + Trim(Filtro) + '%';
    Q.Open;

    RowIdx := 0;
    while not Q.EOF do
    begin
      SetLength(Result, RowIdx + 1);
      Result[RowIdx].Id := Q.FieldByName(Spec.ChaveId).AsString;
      SetLength(Result[RowIdx].Valores, Length(Spec.Campos));
      for I := 0 to High(Spec.Campos) do
        Result[RowIdx].Valores[I] := Q.FieldByName(Spec.Campos[I].Coluna).AsString;
      Inc(RowIdx);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure AtribuirParametroCampo(Q: TZQuery; const ParamNome, Coluna, Valor: string);
begin
  if SameText(Coluna, 'TipoPessoa') then
    Q.ParamByName(ParamNome).AsInteger := StrToIntDef(Trim(Valor), 0)
  else
    Q.ParamByName(ParamNome).AsString := Valor;
end;

function InserirRegistroTabela(Conn: TZConnection; const Spec: TTabelaFinalidade;
  const Valores: array of string): Int64;
var
  Q: TZQuery;
  Cols, Params, Val: string;
  I: Integer;
begin
  Result := 0;
  if (Conn = nil) or (not Conn.Connected) then
    raise Exception.Create('Banco de dados não conectado.');

  Q := TZQuery.Create(nil);
  try
    Q.Connection := Conn;
    Cols := '';
    Params := '';
    for I := 0 to High(Spec.Campos) do
    begin
      if Cols <> '' then
      begin
        Cols := Cols + ', ';
        Params := Params + ', ';
      end;
      Cols := Cols + '"' + Spec.Campos[I].Coluna + '"';
      Params := Params + ':p' + IntToStr(I);
    end;
    if Spec.UsaCriadoEm then
    begin
      Cols := Cols + ', "criado_em"';
      Params := Params + ', :criado_em';
    end;

    Q.SQL.Text := 'INSERT INTO "' + Spec.Tabela + '" (' + Cols + ') VALUES (' + Params + ')';
    for I := 0 to High(Spec.Campos) do
    begin
      if I <= High(Valores) then
        Val := Valores[I]
      else
        Val := '';
      AtribuirParametroCampo(Q, 'p' + IntToStr(I), Spec.Campos[I].Coluna, Val);
    end;
    if Spec.UsaCriadoEm then
      Q.ParamByName('criado_em').AsString := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
    Q.ExecSQL;

    Q.SQL.Text := 'SELECT last_insert_rowid() AS novo_id';
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.FieldByName('novo_id').AsLargeInt;
  finally
    Q.Free;
  end;
end;

procedure AtualizarRegistroTabela(Conn: TZConnection; const Spec: TTabelaFinalidade;
  const IdValor: string; const Valores: array of string);
var
  Q: TZQuery;
  Sets, Val: string;
  I: Integer;
begin
  if (Conn = nil) or (not Conn.Connected) then
    raise Exception.Create('Banco de dados não conectado.');
  if Trim(IdValor) = '' then
    raise Exception.Create('Informe o registro a atualizar.');

  Q := TZQuery.Create(nil);
  try
    Q.Connection := Conn;
    Sets := '';
    for I := 0 to High(Spec.Campos) do
    begin
      if Sets <> '' then
        Sets := Sets + ', ';
      Sets := Sets + '"' + Spec.Campos[I].Coluna + '" = :p' + IntToStr(I);
    end;

    Q.SQL.Text := 'UPDATE "' + Spec.Tabela + '" SET ' + Sets +
                  ' WHERE "' + Spec.ChaveId + '" = :id';
    for I := 0 to High(Spec.Campos) do
    begin
      if I <= High(Valores) then
        Val := Valores[I]
      else
        Val := '';
      AtribuirParametroCampo(Q, 'p' + IntToStr(I), Spec.Campos[I].Coluna, Val);
    end;
    Q.ParamByName('id').AsLargeInt := StrToInt64Def(Trim(IdValor), -1);
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure ExcluirRegistroTabela(Conn: TZConnection; const Spec: TTabelaFinalidade;
  const IdValor: string);
var
  Q: TZQuery;
begin
  if (Conn = nil) or (not Conn.Connected) then
    raise Exception.Create('Banco de dados não conectado.');
  if Trim(IdValor) = '' then
    Exit;

  Q := TZQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'DELETE FROM "' + Spec.Tabela + '" WHERE "' + Spec.ChaveId + '" = :id';
    Q.ParamByName('id').AsLargeInt := StrToInt64Def(Trim(IdValor), -1);
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure LimparTabelaFinalidade(Conn: TZConnection; const Spec: TTabelaFinalidade);
var
  Q: TZQuery;
begin
  if (Conn = nil) or (not Conn.Connected) then
    raise Exception.Create('Banco de dados não conectado.');

  Q := TZQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'DELETE FROM "' + Spec.Tabela + '"';
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function EscaparCampoCSV(const Valor: string; Delimitador: Char): string;
var
  Limpo: string;
begin
  Limpo := StringReplace(Valor, '"', '""', [rfReplaceAll]);
  if (Pos(Delimitador, Limpo) > 0) or (Pos('"', Valor) > 0) or
     (Pos(#10, Limpo) > 0) or (Pos(#13, Limpo) > 0) then
    Result := '"' + Limpo + '"'
  else
    Result := Limpo;
end;

function JuntarLinhaCSV(const Valores: array of string; Delimitador: Char): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(Valores) do
  begin
    if I > 0 then
      Result := Result + Delimitador;
    Result := Result + EscaparCampoCSV(Valores[I], Delimitador);
  end;
end;

function DetectarDelimitadorCSV(const Linha: string): Char;
var
  I: Integer;
  EmAspas: Boolean;
  TemVirgula, TemPontoVirgula: Boolean;
begin
  EmAspas := False;
  TemVirgula := False;
  TemPontoVirgula := False;
  for I := 1 to Length(Linha) do
  begin
    if Linha[I] = '"' then
      EmAspas := not EmAspas
    else if not EmAspas then
    begin
      if Linha[I] = ',' then TemVirgula := True
      else if Linha[I] = ';' then TemPontoVirgula := True;
    end;
  end;
  if TemPontoVirgula and (not TemVirgula) then
    Result := ';'
  else
    Result := ',';
end;

function ParseLinhaCSV(const Linha: string; Delimitador: Char): TStringArray;
var
  I, Len, Count: Integer;
  EmAspas: Boolean;
  Atual: string;
begin
  SetLength(Result, 0);
  Count := 0;
  Atual := '';
  EmAspas := False;
  I := 1;
  Len := Length(Linha);
  while I <= Len do
  begin
    if EmAspas then
    begin
      if Linha[I] = '"' then
      begin
        if (I < Len) and (Linha[I + 1] = '"') then
        begin
          Atual := Atual + '"';
          Inc(I);
        end
        else
          EmAspas := False;
      end
      else
        Atual := Atual + Linha[I];
    end
    else
    begin
      if Linha[I] = '"' then
        EmAspas := True
      else if Linha[I] = Delimitador then
      begin
        SetLength(Result, Count + 1);
        Result[Count] := Atual;
        Inc(Count);
        Atual := '';
      end
      else
        Atual := Atual + Linha[I];
    end;
    Inc(I);
  end;
  SetLength(Result, Count + 1);
  Result[Count] := Atual;
end;

function LinhaEhCabecalho(const Cols: TStringArray; const Spec: TTabelaFinalidade): Boolean;
var
  I, Matches: Integer;
  Token: string;
begin
  Result := False;
  if Length(Cols) = 0 then
    Exit;
  Matches := 0;
  for I := 0 to High(Spec.Campos) do
  begin
    if I > High(Cols) then
      Break;
    Token := Trim(Cols[I]);
    if SameText(Token, Spec.Campos[I].Coluna) or SameText(Token, Spec.Campos[I].Rotulo) then
      Inc(Matches);
  end;
  Result := (Matches >= 2) or ((Length(Spec.Campos) = 1) and (Matches = 1));
end;

function ExportarCSVTabela(Conn: TZConnection; const Spec: TTabelaFinalidade;
  const CaminhoCSV: string): Integer;
var
  Linhas: TListaLinhasTabela;
  Saida: TStringList;
  Cab, CamposLinha: TStringArray;
  I, J: Integer;
begin
  Result := 0;
  if (Conn = nil) or (not Conn.Connected) then
    raise Exception.Create('Banco de dados não conectado.');

  Linhas := CarregarRegistrosTabela(Conn, Spec, '');
  Saida := TStringList.Create;
  try
    SetLength(Cab, Length(Spec.Campos));
    for J := 0 to High(Spec.Campos) do
      Cab[J] := Spec.Campos[J].Coluna;
    Saida.Add(JuntarLinhaCSV(Cab, ','));

    for I := High(Linhas) downto 0 do
    begin
      SetLength(CamposLinha, Length(Spec.Campos));
      for J := 0 to High(Spec.Campos) do
        CamposLinha[J] := Linhas[I].Valores[J];
      Saida.Add(JuntarLinhaCSV(CamposLinha, ','));
      Inc(Result);
    end;

    Saida.SaveToFile(CaminhoCSV);
  finally
    Saida.Free;
  end;
end;

function ExportarModeloCSVTabela(const Spec: TTabelaFinalidade;
  const CaminhoCSV: string): Boolean;
var
  Saida: TStringList;
  Cab: TStringArray;
  J: Integer;
begin
  Saida := TStringList.Create;
  try
    SetLength(Cab, Length(Spec.Campos));
    for J := 0 to High(Spec.Campos) do
      Cab[J] := Spec.Campos[J].Coluna;
    Saida.Add(JuntarLinhaCSV(Cab, ','));
    Saida.SaveToFile(CaminhoCSV);
    Result := True;
  finally
    Saida.Free;
  end;
end;

procedure ImportarCSVTabela(Conn: TZConnection; const Spec: TTabelaFinalidade;
  const CaminhoCSV: string; out Importados, Erros: Integer);
var
  Arquivo: TStringList;
  I, J: Integer;
  Delim: Char;
  LinhaTxt: string;
  Cols, Valores: TStringArray;
  EmTransacao, TemConteudo: Boolean;
begin
  Importados := 0;
  Erros := 0;
  if (Conn = nil) or (not Conn.Connected) then
    raise Exception.Create('Banco de dados não conectado.');
  if not FileExists(CaminhoCSV) then
    raise Exception.Create('Arquivo CSV não encontrado: ' + CaminhoCSV);

  Arquivo := TStringList.Create;
  try
    Arquivo.LoadFromFile(CaminhoCSV);
    if Arquivo.Count = 0 then
      Exit;

    LinhaTxt := Arquivo[0];
    if Copy(LinhaTxt, 1, 3) = #$EF#$BB#$BF then
      Delete(LinhaTxt, 1, 3);
    Delim := DetectarDelimitadorCSV(LinhaTxt);

    EmTransacao := not Conn.InTransaction;
    if EmTransacao then
      Conn.StartTransaction;
    try
      for I := 0 to Arquivo.Count - 1 do
      begin
        LinhaTxt := Arquivo[I];
        if (I = 0) and (Copy(LinhaTxt, 1, 3) = #$EF#$BB#$BF) then
          Delete(LinhaTxt, 1, 3);
        if Trim(LinhaTxt) = '' then
          Continue;

        Cols := ParseLinhaCSV(LinhaTxt, Delim);
        if (I = 0) and LinhaEhCabecalho(Cols, Spec) then
          Continue;

        SetLength(Valores, Length(Spec.Campos));
        TemConteudo := False;
        for J := 0 to High(Spec.Campos) do
        begin
          if J <= High(Cols) then
            Valores[J] := Trim(Cols[J])
          else
            Valores[J] := '';
          if Valores[J] <> '' then
            TemConteudo := True;
        end;
        if not TemConteudo then
          Continue;

        try
          InserirRegistroTabela(Conn, Spec, Valores);
          Inc(Importados);
        except
          Inc(Erros);
        end;
      end;
      if EmTransacao then
        Conn.Commit;
    except
      if EmTransacao then
        Conn.Rollback;
      raise;
    end;
  finally
    Arquivo.Free;
  end;
end;

end.
