unit wizardimpressao;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, Spin, Grids, LCLType, tabelafinalidade, crudfinalidade;

type
  TModoImpressaoWizard = (
    miwUmRegistroNVezes,
    miwMultiplosRegistros
  );

  TOpcaoPapelWizard = record
    Codigo: string;
    Descricao: string;
    ChaveFinalidade: string;
  end;

  TOpcoesPapelWizard = array of TOpcaoPapelWizard;

  TExecutarImpressaoWizardEvent = procedure(
    const OpcaoPapel: TOpcaoPapelWizard;
    Modo: TModoImpressaoWizard;
    Repeticoes: Integer;
    const Registros: TListaLinhasTabela;
    ApenasPrevia: Boolean) of object;

  { TfrmWizardImpressao }

  TfrmWizardImpressao = class(TForm)
  private
    FOpcoesPapel: TOpcoesPapelWizard;
    FValoresTelaAtual: TStringArray;
    FPossuiTelaAtual: Boolean;
    FChaveFinalidade: string;
    FSpec: TTabelaFinalidade;
    FSpecValido: Boolean;
    FLinhas: TListaLinhasTabela;
    FMarcados: array of Boolean;
    FOnExecutar: TExecutarImpressaoWizardEvent;

    { Cabeçalho de passos }
    pnlTopo: TPanel;
    lblPassoTitulo: TLabel;
    lblPassoSub: TLabel;
    lblIndicador: TLabel;

    { Páginas do Wizard }
    pcWizard: TPageControl;
    tsPasso1: TTabSheet;
    tsPasso2: TTabSheet;
    tsPasso3: TTabSheet;

    { Passo 1: Tipo de etiqueta / papel }
    cbPapel: TComboBox;
    lblInfoPapel: TLabel;

    { Passo 2: 1 registro N vezes vs múltiplos registros }
    rgModo: TRadioGroup;
    pnlRepeticoes: TPanel;
    lblRepeticoes: TLabel;
    seRepeticoes: TSpinEdit;
    chkUsarTelaAtual: TCheckBox;
    lblResumoModo: TLabel;

    { Passo 3: Filtros, seleção de registros, prévia e impressão }
    edFiltroGeral: TEdit;
    cbColunaFiltro: TComboBox;
    edFiltroColuna: TEdit;
    btnFiltrar: TButton;
    btnLimparFiltro: TButton;
    btnMarcarTodos: TButton;
    btnDesmarcarTodos: TButton;
    btnInverterSel: TButton;
    btnAbrirCrud: TButton;
    FGrid: TStringGrid;
    lblResumoSelecao: TLabel;
    mmoPrevia: TMemo;

    { Rodapé }
    pnlRodape: TPanel;
    btnVoltar: TButton;
    btnAvancar: TButton;
    btnPrevia: TButton;
    btnImprimir: TButton;
    btnCancelar: TButton;

    procedure AtualizarPassoUI;
    procedure AtualizarResumoModo;
    procedure AtualizarResumoSelecao;
    procedure PopularColunasFiltro;
    procedure CarregarRegistrosFiltrados;
    procedure RenderizarGrade;
    function ContarMarcados: Integer;
    function ObterRegistrosParaImpressao(out Lista: TListaLinhasTabela; out ErroMsg: string): Boolean;
    procedure AlternarMarcacaoLinha(RowIdx: Integer);

    procedure PapelChange(Sender: TObject);
    procedure ModoChange(Sender: TObject);
    procedure UsarTelaAtualChange(Sender: TObject);
    procedure RepeticoesChange(Sender: TObject);
    procedure FiltrarClick(Sender: TObject);
    procedure LimparFiltroClick(Sender: TObject);
    procedure MarcarTodosClick(Sender: TObject);
    procedure DesmarcarTodosClick(Sender: TObject);
    procedure InverterSelClick(Sender: TObject);
    procedure AbrirCrudClick(Sender: TObject);
    procedure GridMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridSelectCell(Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);
    procedure VoltarClick(Sender: TObject);
    procedure AvancarClick(Sender: TObject);
    procedure PreviaClick(Sender: TObject);
    procedure ImprimirClick(Sender: TObject);
    procedure CancelarClick(Sender: TObject);
  public
    constructor CreateWizard(AOwner: TComponent;
      const AChaveFinalidade: string;
      const AOpcoesPapel: TOpcoesPapelWizard;
      AIndicePapelInicial: Integer;
      const AValoresTelaAtual: array of string;
      ARepeticoesIniciais: Integer = 1);
    property OnExecutarImpressao: TExecutarImpressaoWizardEvent read FOnExecutar write FOnExecutar;
  end;

implementation

{ TfrmWizardImpressao }

constructor TfrmWizardImpressao.CreateWizard(AOwner: TComponent;
  const AChaveFinalidade: string;
  const AOpcoesPapel: TOpcoesPapelWizard;
  AIndicePapelInicial: Integer;
  const AValoresTelaAtual: array of string;
  ARepeticoesIniciais: Integer);
var
  I: Integer;
  PnlBotoesSel, PnlFiltros, PnlPrevia: TPanel;
begin
  inherited CreateNew(AOwner);
  FChaveFinalidade := AChaveFinalidade;
  FSpecValido := ObterTabelaFinalidade(FChaveFinalidade, FSpec);
  FOpcoesPapel := Copy(AOpcoesPapel, 0, Length(AOpcoesPapel));

  SetLength(FValoresTelaAtual, Length(AValoresTelaAtual));
  FPossuiTelaAtual := False;
  for I := 0 to High(AValoresTelaAtual) do
  begin
    FValoresTelaAtual[I] := AValoresTelaAtual[I];
    if Trim(AValoresTelaAtual[I]) <> '' then
      FPossuiTelaAtual := True;
  end;

  Caption := 'Wizard de Impressão';
  Position := poScreenCenter;
  BorderStyle := bsSizeable;
  SetBounds(0, 0, 960, 660);
  Constraints.MinWidth := 820;
  Constraints.MinHeight := 560;
  Font.Name := 'Segoe UI';
  Font.Size := 9;

  { Topo }
  pnlTopo := TPanel.Create(Self);
  pnlTopo.Parent := Self;
  pnlTopo.Align := alTop;
  pnlTopo.Height := 64;
  pnlTopo.BevelOuter := bvNone;
  pnlTopo.Color := $FAF8F5;

  lblIndicador := TLabel.Create(Self);
  lblIndicador.Parent := pnlTopo;
  lblIndicador.SetBounds(20, 8, 900, 18);
  lblIndicador.Font.Color := $C66A26;
  lblIndicador.Font.Style := [fsBold];

  lblPassoTitulo := TLabel.Create(Self);
  lblPassoTitulo.Parent := pnlTopo;
  lblPassoTitulo.SetBounds(20, 26, 900, 22);
  lblPassoTitulo.Font.Size := 12;
  lblPassoTitulo.Font.Style := [fsBold];

  lblPassoSub := TLabel.Create(Self);
  lblPassoSub.Parent := pnlTopo;
  lblPassoSub.SetBounds(20, 46, 900, 16);

  { Rodapé }
  pnlRodape := TPanel.Create(Self);
  pnlRodape.Parent := Self;
  pnlRodape.Align := alBottom;
  pnlRodape.Height := 52;
  pnlRodape.BevelOuter := bvNone;

  btnVoltar := TButton.Create(Self);
  btnVoltar.Parent := pnlRodape;
  btnVoltar.Caption := '< Voltar';
  btnVoltar.SetBounds(20, 10, 100, 32);
  btnVoltar.OnClick := @VoltarClick;

  btnAvancar := TButton.Create(Self);
  btnAvancar.Parent := pnlRodape;
  btnAvancar.Caption := 'Avançar >';
  btnAvancar.SetBounds(128, 10, 110, 32);
  btnAvancar.OnClick := @AvancarClick;

  btnPrevia := TButton.Create(Self);
  btnPrevia.Parent := pnlRodape;
  btnPrevia.Caption := 'Pré-visualizar';
  btnPrevia.SetBounds(560, 10, 130, 32);
  btnPrevia.OnClick := @PreviaClick;

  btnImprimir := TButton.Create(Self);
  btnImprimir.Parent := pnlRodape;
  btnImprimir.Caption := 'Imprimir';
  btnImprimir.SetBounds(698, 10, 130, 32);
  btnImprimir.OnClick := @ImprimirClick;

  btnCancelar := TButton.Create(Self);
  btnCancelar.Parent := pnlRodape;
  btnCancelar.Caption := 'Fechar';
  btnCancelar.SetBounds(836, 10, 104, 32);
  btnCancelar.OnClick := @CancelarClick;

  { PageControl sem abas visíveis: controlado pelos botões Voltar/Avançar }
  pcWizard := TPageControl.Create(Self);
  pcWizard.Parent := Self;
  pcWizard.Align := alClient;
  pcWizard.ShowTabs := False;

  tsPasso1 := TTabSheet.Create(pcWizard);
  tsPasso1.PageControl := pcWizard;
  tsPasso1.Caption := 'Passo 1';

  tsPasso2 := TTabSheet.Create(pcWizard);
  tsPasso2.PageControl := pcWizard;
  tsPasso2.Caption := 'Passo 2';

  tsPasso3 := TTabSheet.Create(pcWizard);
  tsPasso3.PageControl := pcWizard;
  tsPasso3.Caption := 'Passo 3';

  { === PASSO 1: Seleção do tipo de etiqueta / papel === }
  with TLabel.Create(Self) do
  begin
    Parent := tsPasso1;
    Caption := 'Selecione o tipo de etiqueta ou papel para esta impressão:';
    Font.Style := [fsBold];
    SetBounds(24, 24, 600, 20);
  end;

  cbPapel := TComboBox.Create(Self);
  cbPapel.Parent := tsPasso1;
  cbPapel.Style := csDropDownList;
  cbPapel.SetBounds(24, 50, 740, 28);
  for I := 0 to High(FOpcoesPapel) do
    cbPapel.Items.Add(FOpcoesPapel[I].Descricao);
  if cbPapel.Items.Count > 0 then
    cbPapel.ItemIndex := EnsureRange(AIndicePapelInicial, 0, cbPapel.Items.Count - 1);
  cbPapel.OnChange := @PapelChange;

  lblInfoPapel := TLabel.Create(Self);
  lblInfoPapel.Parent := tsPasso1;
  lblInfoPapel.AutoSize := False;
  lblInfoPapel.WordWrap := True;
  lblInfoPapel.SetBounds(24, 96, 740, 120);

  { === PASSO 2: 1 registro N vezes ou múltiplos registros === }
  rgModo := TRadioGroup.Create(Self);
  rgModo.Parent := tsPasso2;
  rgModo.Caption := 'Como deseja imprimir os registros?';
  rgModo.SetBounds(24, 20, 760, 110);
  rgModo.Items.Add('1 registro em N etiquetas (repetir a mesma etiqueta N vezes)');
  rgModo.Items.Add('1 etiqueta por registro (selecionar múltiplos registros da tabela)');
  rgModo.ItemIndex := 0;
  rgModo.OnClick := @ModoChange;

  pnlRepeticoes := TPanel.Create(Self);
  pnlRepeticoes.Parent := tsPasso2;
  pnlRepeticoes.BevelOuter := bvLowered;
  pnlRepeticoes.SetBounds(24, 144, 760, 110);

  lblRepeticoes := TLabel.Create(Self);
  lblRepeticoes.Parent := pnlRepeticoes;
  lblRepeticoes.Caption := 'Quantidade de etiquetas (N repetições do mesmo registro):';
  lblRepeticoes.Font.Style := [fsBold];
  lblRepeticoes.SetBounds(16, 18, 420, 20);

  seRepeticoes := TSpinEdit.Create(Self);
  seRepeticoes.Parent := pnlRepeticoes;
  seRepeticoes.MinValue := 1;
  seRepeticoes.MaxValue := 500;
  seRepeticoes.Value := Max(1, ARepeticoesIniciais);
  seRepeticoes.SetBounds(440, 14, 90, 28);
  seRepeticoes.OnChange := @RepeticoesChange;

  chkUsarTelaAtual := TCheckBox.Create(Self);
  chkUsarTelaAtual.Parent := pnlRepeticoes;
  chkUsarTelaAtual.Caption := 'Usar os dados atualmente preenchidos na tela de emissão (sem precisar selecionar na tabela)';
  chkUsarTelaAtual.SetBounds(16, 60, 720, 24);
  chkUsarTelaAtual.Visible := FPossuiTelaAtual;
  chkUsarTelaAtual.Checked := FPossuiTelaAtual;
  chkUsarTelaAtual.OnChange := @UsarTelaAtualChange;

  lblResumoModo := TLabel.Create(Self);
  lblResumoModo.Parent := tsPasso2;
  lblResumoModo.AutoSize := False;
  lblResumoModo.WordWrap := True;
  lblResumoModo.SetBounds(24, 272, 760, 60);

  { === PASSO 3: Filtros, seleção de registros, prévia e impressão === }
  PnlFiltros := TPanel.Create(Self);
  PnlFiltros.Parent := tsPasso3;
  PnlFiltros.Align := alTop;
  PnlFiltros.Height := 72;
  PnlFiltros.BevelOuter := bvNone;

  with TLabel.Create(Self) do
  begin
    Parent := PnlFiltros;
    Caption := 'Filtro geral:';
    SetBounds(12, 10, 80, 18);
  end;
  edFiltroGeral := TEdit.Create(Self);
  edFiltroGeral.Parent := PnlFiltros;
  edFiltroGeral.SetBounds(90, 6, 220, 26);
  edFiltroGeral.TextHint := 'Buscar em qualquer campo...';

  with TLabel.Create(Self) do
  begin
    Parent := PnlFiltros;
    Caption := 'Coluna:';
    SetBounds(322, 10, 50, 18);
  end;
  cbColunaFiltro := TComboBox.Create(Self);
  cbColunaFiltro.Parent := PnlFiltros;
  cbColunaFiltro.Style := csDropDownList;
  cbColunaFiltro.SetBounds(376, 6, 170, 26);

  edFiltroColuna := TEdit.Create(Self);
  edFiltroColuna.Parent := PnlFiltros;
  edFiltroColuna.SetBounds(554, 6, 160, 26);
  edFiltroColuna.TextHint := 'Valor na coluna...';

  btnFiltrar := TButton.Create(Self);
  btnFiltrar.Parent := PnlFiltros;
  btnFiltrar.Caption := 'Filtrar';
  btnFiltrar.SetBounds(722, 6, 86, 26);
  btnFiltrar.OnClick := @FiltrarClick;

  btnLimparFiltro := TButton.Create(Self);
  btnLimparFiltro.Parent := PnlFiltros;
  btnLimparFiltro.Caption := 'Limpar';
  btnLimparFiltro.SetBounds(814, 6, 86, 26);
  btnLimparFiltro.OnClick := @LimparFiltroClick;

  PnlBotoesSel := TPanel.Create(Self);
  PnlBotoesSel.Parent := PnlFiltros;
  PnlBotoesSel.SetBounds(12, 38, 910, 30);
  PnlBotoesSel.BevelOuter := bvNone;

  btnMarcarTodos := TButton.Create(Self);
  btnMarcarTodos.Parent := PnlBotoesSel;
  btnMarcarTodos.Caption := 'Marcar todos';
  btnMarcarTodos.SetBounds(0, 1, 110, 26);
  btnMarcarTodos.OnClick := @MarcarTodosClick;

  btnDesmarcarTodos := TButton.Create(Self);
  btnDesmarcarTodos.Parent := PnlBotoesSel;
  btnDesmarcarTodos.Caption := 'Desmarcar todos';
  btnDesmarcarTodos.SetBounds(116, 1, 126, 26);
  btnDesmarcarTodos.OnClick := @DesmarcarTodosClick;

  btnInverterSel := TButton.Create(Self);
  btnInverterSel.Parent := PnlBotoesSel;
  btnInverterSel.Caption := 'Inverter seleção';
  btnInverterSel.SetBounds(248, 1, 120, 26);
  btnInverterSel.OnClick := @InverterSelClick;

  btnAbrirCrud := TButton.Create(Self);
  btnAbrirCrud.Parent := PnlBotoesSel;
  btnAbrirCrud.Caption := 'Gerenciar Tabela (CRUD / CSV)';
  btnAbrirCrud.SetBounds(384, 1, 210, 26);
  btnAbrirCrud.OnClick := @AbrirCrudClick;

  lblResumoSelecao := TLabel.Create(Self);
  lblResumoSelecao.Parent := PnlBotoesSel;
  lblResumoSelecao.AutoSize := False;
  lblResumoSelecao.Font.Style := [fsBold];
  lblResumoSelecao.SetBounds(606, 5, 300, 18);

  PnlPrevia := TPanel.Create(Self);
  PnlPrevia.Parent := tsPasso3;
  PnlPrevia.Align := alBottom;
  PnlPrevia.Height := 118;
  PnlPrevia.BevelOuter := bvNone;

  with TLabel.Create(Self) do
  begin
    Parent := PnlPrevia;
    Caption := 'Prévia dos dados selecionados para impressão:';
    Font.Style := [fsBold];
    SetBounds(12, 4, 400, 18);
  end;

  mmoPrevia := TMemo.Create(Self);
  mmoPrevia.Parent := PnlPrevia;
  mmoPrevia.ReadOnly := True;
  mmoPrevia.ScrollBars := ssVertical;
  mmoPrevia.SetBounds(12, 24, 916, 86);
  mmoPrevia.Anchors := [akLeft, akTop, akRight, akBottom];

  FGrid := TStringGrid.Create(Self);
  FGrid.Parent := tsPasso3;
  FGrid.Align := alClient;
  FGrid.BorderSpacing.Around := 10;
  FGrid.FixedCols := 0;
  FGrid.FixedRows := 1;
  FGrid.Options := FGrid.Options + [goRowSelect, goColSizing, goThumbTracking];
  FGrid.OnMouseDown := @GridMouseDown;
  FGrid.OnKeyDown := @GridKeyDown;
  FGrid.OnSelectCell := @GridSelectCell;

  pcWizard.ActivePageIndex := 0;
  PapelChange(nil);
  PopularColunasFiltro;
  CarregarRegistrosFiltrados;
  AtualizarResumoModo;
  AtualizarPassoUI;
end;

procedure TfrmWizardImpressao.PopularColunasFiltro;
var
  I: Integer;
begin
  cbColunaFiltro.Items.Clear;
  cbColunaFiltro.Items.Add('(Todas as colunas)');
  if FSpecValido then
    for I := 0 to High(FSpec.Campos) do
      cbColunaFiltro.Items.Add(FSpec.Campos[I].Rotulo);
  cbColunaFiltro.ItemIndex := 0;
end;

procedure TfrmWizardImpressao.CarregarRegistrosFiltrados;
var
  Brutas: TListaLinhasTabela;
  Filtradas: TListaLinhasTabela;
  I, ColIdx, Count: Integer;
  ValorCol, TermoCol: string;
begin
  SetLength(FLinhas, 0);
  SetLength(FMarcados, 0);

  if FSpecValido and (GConexaoFinalidade <> nil) and GConexaoFinalidade.Connected then
    Brutas := CarregarRegistrosTabela(GConexaoFinalidade, FSpec, edFiltroGeral.Text)
  else
    SetLength(Brutas, 0);

  ColIdx := cbColunaFiltro.ItemIndex - 1;
  TermoCol := LowerCase(Trim(edFiltroColuna.Text));
  if (ColIdx >= 0) and (TermoCol <> '') then
  begin
    Count := 0;
    SetLength(Filtradas, 0);
    for I := 0 to High(Brutas) do
    begin
      if ColIdx <= High(Brutas[I].Valores) then
        ValorCol := LowerCase(Brutas[I].Valores[ColIdx])
      else
        ValorCol := '';
      if Pos(TermoCol, ValorCol) > 0 then
      begin
        SetLength(Filtradas, Count + 1);
        Filtradas[Count] := Brutas[I];
        Inc(Count);
      end;
    end;
    FLinhas := Filtradas;
  end
  else
    FLinhas := Brutas;

  SetLength(FMarcados, Length(FLinhas));
  for I := 0 to High(FMarcados) do
    FMarcados[I] := False;

  if (rgModo.ItemIndex = 0) and (Length(FMarcados) > 0) and (not chkUsarTelaAtual.Checked) then
    FMarcados[0] := True;

  RenderizarGrade;
  AtualizarResumoSelecao;
end;

procedure TfrmWizardImpressao.RenderizarGrade;
var
  I, J: Integer;
begin
  if not FSpecValido then
  begin
    FGrid.ColCount := 2;
    FGrid.RowCount := 1;
    FGrid.Cells[0, 0] := 'Sel';
    FGrid.Cells[1, 0] := 'ID';
    Exit;
  end;

  FGrid.ColCount := 2 + Length(FSpec.Campos);
  FGrid.RowCount := Max(1, 1 + Length(FLinhas));
  FGrid.Cells[0, 0] := 'Sel';
  FGrid.ColWidths[0] := 44;
  FGrid.Cells[1, 0] := 'ID';
  FGrid.ColWidths[1] := 48;

  for J := 0 to High(FSpec.Campos) do
  begin
    FGrid.Cells[J + 2, 0] := FSpec.Campos[J].Rotulo;
    FGrid.ColWidths[J + 2] := 145;
  end;

  for I := 0 to High(FLinhas) do
  begin
    if FMarcados[I] then
      FGrid.Cells[0, I + 1] := '[X]'
    else
      FGrid.Cells[0, I + 1] := '[ ]';
    FGrid.Cells[1, I + 1] := FLinhas[I].Id;
    for J := 0 to High(FSpec.Campos) do
      if J <= High(FLinhas[I].Valores) then
        FGrid.Cells[J + 2, I + 1] := FLinhas[I].Valores[J]
      else
        FGrid.Cells[J + 2, I + 1] := '';
  end;

  if Length(FLinhas) > 0 then
    FGrid.Row := 1;
end;

function TfrmWizardImpressao.ContarMarcados: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to High(FMarcados) do
    if FMarcados[I] then Inc(Result);
end;

procedure TfrmWizardImpressao.AlternarMarcacaoLinha(RowIdx: Integer);
var
  I: Integer;
begin
  if (RowIdx < 0) or (RowIdx > High(FMarcados)) then
    Exit;

  if rgModo.ItemIndex = 0 then
  begin
    for I := 0 to High(FMarcados) do
      FMarcados[I] := (I = RowIdx);
    chkUsarTelaAtual.Checked := False;
  end
  else
    FMarcados[RowIdx] := not FMarcados[RowIdx];

  RenderizarGrade;
  FGrid.Row := RowIdx + 1;
  AtualizarResumoSelecao;
end;

procedure TfrmWizardImpressao.AtualizarResumoModo;
begin
  pnlRepeticoes.Visible := (rgModo.ItemIndex = 0);
  if rgModo.ItemIndex = 0 then
  begin
    if chkUsarTelaAtual.Checked then
      lblResumoModo.Caption := Format('Modo selecionado: imprimir %d etiqueta(s) repetindo os dados atualmente preenchidos na tela.', [seRepeticoes.Value])
    else
      lblResumoModo.Caption := Format('Modo selecionado: escolher 1 registro da tabela no Passo 3 e imprimir %d etiqueta(s) repetida(s).', [seRepeticoes.Value]);
  end
  else
  begin
    chkUsarTelaAtual.Checked := False;
    lblResumoModo.Caption := 'Modo selecionado: imprimir 1 etiqueta para cada registro marcado na tabela no Passo 3.';
  end;
  AtualizarResumoSelecao;
end;

procedure TfrmWizardImpressao.AtualizarResumoSelecao;
var
  Marcados, I, J, TotalEtiquetas: Integer;
  LinhasPrevia: TStringList;
  ResumoItem: string;
begin
  if not Assigned(lblResumoSelecao) then
    Exit;

  btnMarcarTodos.Enabled := (rgModo.ItemIndex = 1);
  btnDesmarcarTodos.Enabled := (rgModo.ItemIndex = 1);
  btnInverterSel.Enabled := (rgModo.ItemIndex = 1);

  Marcados := ContarMarcados;
  if rgModo.ItemIndex = 0 then
  begin
    if chkUsarTelaAtual.Checked then
      TotalEtiquetas := seRepeticoes.Value
    else if Marcados > 0 then
      TotalEtiquetas := seRepeticoes.Value
    else
      TotalEtiquetas := 0;
    lblResumoSelecao.Caption := Format('Modo 1xN | Total: %d etiqueta(s)', [TotalEtiquetas]);
  end
  else
  begin
    TotalEtiquetas := Marcados;
    lblResumoSelecao.Caption := Format('Selecionados: %d registro(s) = %d etiqueta(s)', [Marcados, TotalEtiquetas]);
  end;

  LinhasPrevia := TStringList.Create;
  try
    if (rgModo.ItemIndex = 0) and chkUsarTelaAtual.Checked then
    begin
      ResumoItem := '';
      for J := 0 to High(FValoresTelaAtual) do
        if Trim(FValoresTelaAtual[J]) <> '' then
        begin
          if ResumoItem <> '' then ResumoItem := ResumoItem + ' | ';
          ResumoItem := ResumoItem + FValoresTelaAtual[J];
        end;
      LinhasPrevia.Add(Format('[Dados atuais da tela] x %d etiqueta(s): %s', [seRepeticoes.Value, ResumoItem]));
    end
    else
    begin
      for I := 0 to High(FLinhas) do
      begin
        if FMarcados[I] then
        begin
          ResumoItem := '#' + FLinhas[I].Id + ': ';
          for J := 0 to Min(3, High(FLinhas[I].Valores)) do
            if Trim(FLinhas[I].Valores[J]) <> '' then
              ResumoItem := ResumoItem + FLinhas[I].Valores[J] + ' | ';
          if rgModo.ItemIndex = 0 then
            ResumoItem := ResumoItem + Format('(x %d cópias)', [seRepeticoes.Value]);
          LinhasPrevia.Add(ResumoItem);
        end;
      end;
      if LinhasPrevia.Count = 0 then
        LinhasPrevia.Add('Nenhum registro selecionado. Clique na coluna "Sel" ou pressione Espaço sobre uma linha.');
    end;
    mmoPrevia.Lines.Assign(LinhasPrevia);
  finally
    LinhasPrevia.Free;
  end;
end;

procedure TfrmWizardImpressao.AtualizarPassoUI;
var
  Passo: Integer;
begin
  Passo := pcWizard.ActivePageIndex;
  lblIndicador.Caption := Format('PASSO %d DE 3', [Passo + 1]);
  case Passo of
    0:
    begin
      lblPassoTitulo.Caption := '1) Seleção do tipo de etiqueta ou papel';
      lblPassoSub.Caption := 'Escolha o formato de etiqueta / folha antes de definir a quantidade e os registros.';
    end;
    1:
    begin
      lblPassoTitulo.Caption := '2) Modo de impressão (1 registro N vezes ou múltiplos registros)';
      lblPassoSub.Caption := 'Defina se deseja repetir uma etiqueta N vezes ou imprimir 1 etiqueta por registro selecionado.';
    end;
    2:
    begin
      lblPassoTitulo.Caption := '3) Seleção do(s) registro(s), prévia e impressão';
      lblPassoSub.Caption := 'Filtre a tabela, marque os registros desejados, confira a prévia e imprima.';
    end;
  end;

  btnVoltar.Enabled := (Passo > 0);
  btnAvancar.Enabled := (Passo < 2);
  btnPrevia.Visible := (Passo = 2);
  btnImprimir.Visible := (Passo = 2);
end;

function TfrmWizardImpressao.ObterRegistrosParaImpressao(
  out Lista: TListaLinhasTabela; out ErroMsg: string): Boolean;
var
  I, Count: Integer;
begin
  SetLength(Lista, 0);
  ErroMsg := '';
  if (rgModo.ItemIndex = 0) and chkUsarTelaAtual.Checked then
  begin
    SetLength(Lista, 1);
    Lista[0].Id := '';
    Lista[0].Valores := Copy(FValoresTelaAtual, 0, Length(FValoresTelaAtual));
    Exit(True);
  end;

  Count := 0;
  for I := 0 to High(FLinhas) do
  begin
    if FMarcados[I] then
    begin
      SetLength(Lista, Count + 1);
      Lista[Count] := FLinhas[I];
      Inc(Count);
      if rgModo.ItemIndex = 0 then
        Break;
    end;
  end;

  if Count = 0 then
  begin
    ErroMsg := 'Selecione ao menos um registro na grade (ou ative os dados da tela atual no Passo 2).';
    Exit(False);
  end;
  Result := True;
end;

procedure TfrmWizardImpressao.PapelChange(Sender: TObject);
var
  Op: TOpcaoPapelWizard;
  NovaSpec: TTabelaFinalidade;
begin
  if (cbPapel.ItemIndex < 0) or (cbPapel.ItemIndex > High(FOpcoesPapel)) then
    Exit;
  Op := FOpcoesPapel[cbPapel.ItemIndex];
  if (Op.ChaveFinalidade <> '') and (not SameText(Op.ChaveFinalidade, FChaveFinalidade)) then
  begin
    if ObterTabelaFinalidade(Op.ChaveFinalidade, NovaSpec) then
    begin
      FChaveFinalidade := Op.ChaveFinalidade;
      FSpec := NovaSpec;
      FSpecValido := True;
      PopularColunasFiltro;
      CarregarRegistrosFiltrados;
    end;
  end;

  if FSpecValido then
    lblInfoPapel.Caption := Format('Finalidade: %s' + sLineBreak + 'Tabela SQLite associada: %s (%d registro(s))',
      [FSpec.Titulo, FSpec.Tabela, ContarRegistrosTabela(GConexaoFinalidade, FSpec)])
  else
    lblInfoPapel.Caption := 'Formato selecionado: ' + Op.Descricao;
end;

procedure TfrmWizardImpressao.ModoChange(Sender: TObject);
var
  I: Integer;
begin
  if (rgModo.ItemIndex = 0) and (ContarMarcados > 1) then
  begin
    for I := 1 to High(FMarcados) do
      FMarcados[I] := False;
    RenderizarGrade;
  end;
  AtualizarResumoModo;
end;

procedure TfrmWizardImpressao.UsarTelaAtualChange(Sender: TObject);
begin
  AtualizarResumoModo;
end;

procedure TfrmWizardImpressao.RepeticoesChange(Sender: TObject);
begin
  AtualizarResumoModo;
end;

procedure TfrmWizardImpressao.FiltrarClick(Sender: TObject);
begin
  CarregarRegistrosFiltrados;
end;

procedure TfrmWizardImpressao.LimparFiltroClick(Sender: TObject);
begin
  edFiltroGeral.Text := '';
  cbColunaFiltro.ItemIndex := 0;
  edFiltroColuna.Text := '';
  CarregarRegistrosFiltrados;
end;

procedure TfrmWizardImpressao.MarcarTodosClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to High(FMarcados) do
    FMarcados[I] := True;
  RenderizarGrade;
  AtualizarResumoSelecao;
end;

procedure TfrmWizardImpressao.DesmarcarTodosClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to High(FMarcados) do
    FMarcados[I] := False;
  RenderizarGrade;
  AtualizarResumoSelecao;
end;

procedure TfrmWizardImpressao.InverterSelClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to High(FMarcados) do
    FMarcados[I] := not FMarcados[I];
  RenderizarGrade;
  AtualizarResumoSelecao;
end;

procedure TfrmWizardImpressao.AbrirCrudClick(Sender: TObject);
var
  Dlg: TfrmCrudFinalidade;
begin
  if not FSpecValido then
    Exit;
  Dlg := TfrmCrudFinalidade.CreateComFinalidade(Self, FChaveFinalidade, False);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
  CarregarRegistrosFiltrados;
end;

procedure TfrmWizardImpressao.GridMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Col, Row: Integer;
begin
  FGrid.MouseToCell(X, Y, Col, Row);
  if (Row >= 1) and ((Col = 0) or (rgModo.ItemIndex = 0)) then
    AlternarMarcacaoLinha(Row - 1);
end;

procedure TfrmWizardImpressao.GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_SPACE) and (FGrid.Row >= 1) then
  begin
    AlternarMarcacaoLinha(FGrid.Row - 1);
    Key := 0;
  end;
end;

procedure TfrmWizardImpressao.GridSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
  if (aRow >= 1) and (rgModo.ItemIndex = 0) and (not chkUsarTelaAtual.Checked) then
    AtualizarResumoSelecao;
end;

procedure TfrmWizardImpressao.VoltarClick(Sender: TObject);
begin
  if pcWizard.ActivePageIndex > 0 then
  begin
    pcWizard.ActivePageIndex := pcWizard.ActivePageIndex - 1;
    AtualizarPassoUI;
  end;
end;

procedure TfrmWizardImpressao.AvancarClick(Sender: TObject);
begin
  if pcWizard.ActivePageIndex < 2 then
  begin
    pcWizard.ActivePageIndex := pcWizard.ActivePageIndex + 1;
    if pcWizard.ActivePageIndex = 2 then
      AtualizarResumoSelecao;
    AtualizarPassoUI;
  end;
end;

procedure TfrmWizardImpressao.PreviaClick(Sender: TObject);
var
  Lista: TListaLinhasTabela;
  Op: TOpcaoPapelWizard;
  Modo: TModoImpressaoWizard;
  ErroMsg: string;
begin
  if not ObterRegistrosParaImpressao(Lista, ErroMsg) then
  begin
    MessageDlg('Wizard de Impressão', ErroMsg, mtWarning, [mbOK], 0);
    Exit;
  end;
  if (cbPapel.ItemIndex >= 0) and (cbPapel.ItemIndex <= High(FOpcoesPapel)) then
    Op := FOpcoesPapel[cbPapel.ItemIndex]
  else
  begin
    Op.Codigo := '';
    Op.Descricao := '';
    Op.ChaveFinalidade := FChaveFinalidade;
  end;
  if rgModo.ItemIndex = 0 then Modo := miwUmRegistroNVezes else Modo := miwMultiplosRegistros;
  if Assigned(FOnExecutar) then
    FOnExecutar(Op, Modo, seRepeticoes.Value, Lista, True);
end;

procedure TfrmWizardImpressao.ImprimirClick(Sender: TObject);
var
  Lista: TListaLinhasTabela;
  Op: TOpcaoPapelWizard;
  Modo: TModoImpressaoWizard;
  ErroMsg: string;
begin
  if not ObterRegistrosParaImpressao(Lista, ErroMsg) then
  begin
    MessageDlg('Wizard de Impressão', ErroMsg, mtWarning, [mbOK], 0);
    Exit;
  end;
  if (cbPapel.ItemIndex >= 0) and (cbPapel.ItemIndex <= High(FOpcoesPapel)) then
    Op := FOpcoesPapel[cbPapel.ItemIndex]
  else
  begin
    Op.Codigo := '';
    Op.Descricao := '';
    Op.ChaveFinalidade := FChaveFinalidade;
  end;
  if rgModo.ItemIndex = 0 then Modo := miwUmRegistroNVezes else Modo := miwMultiplosRegistros;
  if Assigned(FOnExecutar) then
    FOnExecutar(Op, Modo, seRepeticoes.Value, Lista, False);
end;

procedure TfrmWizardImpressao.CancelarClick(Sender: TObject);
begin
  Close;
end;

end.
