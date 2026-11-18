unit crudfinalidade;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Grids, tabelafinalidade;

type
  TCarregarValoresEvent = procedure(const Valores: array of string) of object;
  TObterValoresEvent = procedure(out Valores: TStringArray) of object;

  { TfrmCrudFinalidade }

  TfrmCrudFinalidade = class(TForm)
  private
    FSpec: TTabelaFinalidade;
    FModoSelecao: Boolean;
    FLinhas: TListaLinhasTabela;
    FIdAtual: string;
    FSelecionadoOK: Boolean;
    FValoresSelecionados: TStringArray;

    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    edBusca: TEdit;
    btnBuscar: TButton;
    btnLimparBusca: TButton;
    FGrid: TStringGrid;
    FEditorScroll: TScrollBox;
    lblCampos: array of TLabel;
    edCampos: array of TEdit;
    lblStatusEdicao: TLabel;

    btnNovo: TButton;
    btnSalvar: TButton;
    btnExcluir: TButton;
    btnCancelar: TButton;
    btnUsar: TButton;

    btnImportar: TButton;
    btnExportar: TButton;
    btnModelo: TButton;
    btnLimparTabela: TButton;
    btnFechar: TButton;

    procedure CarregarGrade(const Filtro: string = '');
    procedure PreencherEditorDaLinha(RowIdx: Integer);
    procedure LimparEditorParaNovo;
    function LerCamposEditor: TStringArray;
    procedure BuscarClick(Sender: TObject);
    procedure LimparBuscaClick(Sender: TObject);
    procedure GradeSelectCell(Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);
    procedure GradeDblClick(Sender: TObject);
    procedure NovoClick(Sender: TObject);
    procedure SalvarClick(Sender: TObject);
    procedure ExcluirClick(Sender: TObject);
    procedure CancelarClick(Sender: TObject);
    procedure UsarClick(Sender: TObject);
    procedure ImportarClick(Sender: TObject);
    procedure ExportarClick(Sender: TObject);
    procedure ModeloCSVClick(Sender: TObject);
    procedure LimparTabelaClick(Sender: TObject);
    procedure FecharClick(Sender: TObject);
  public
    constructor CreateComFinalidade(AOwner: TComponent;
      const AChaveFinalidade: string; AModoSelecao: Boolean = True);
    function ObterValoresSelecionados(out Valores: TStringArray): Boolean;
  end;

  { TPainelBancoFinalidade }

  TPainelBancoFinalidade = class(TPanel)
  private
    FChaveFinalidade: string;
    FSpec: TTabelaFinalidade;
    FSpecValido: Boolean;
    FLinhas: TListaLinhasTabela;
    FOnCarregar: TCarregarValoresEvent;
    FOnObter: TObterValoresEvent;

    lblInfo: TLabel;
    cbRegistros: TComboBox;
    btnSalvar: TButton;
    btnCrud: TButton;
    btnImportar: TButton;
    btnExportar: TButton;
    btnLimpar: TButton;

    function ConexaoDisponivel: Boolean;
    procedure SelecionarRegistroChange(Sender: TObject);
    procedure SalvarClick(Sender: TObject);
    procedure CrudClick(Sender: TObject);
    procedure ImportarClick(Sender: TObject);
    procedure ExportarClick(Sender: TObject);
    procedure LimparClick(Sender: TObject);
  protected
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure DefinirFinalidade(const AChaveFinalidade: string);
    procedure AtualizarLista;
    property ChaveFinalidade: string read FChaveFinalidade;
    property OnCarregarValores: TCarregarValoresEvent read FOnCarregar write FOnCarregar;
    property OnObterValores: TObterValoresEvent read FOnObter write FOnObter;
  end;

implementation

function ExecutarImportarCSVDialog(OwnerForm: TComponent; const Spec: TTabelaFinalidade): Boolean;
var
  Dlg: TOpenDialog;
  Importados, Erros: Integer;
begin
  Result := False;
  if (GConexaoFinalidade = nil) or (not GConexaoFinalidade.Connected) then
  begin
    MessageDlg('Banco de Dados', 'Conexão com o banco de dados não está ativa.', mtWarning, [mbOK], 0);
    Exit;
  end;

  Dlg := TOpenDialog.Create(OwnerForm);
  try
    Dlg.Title := 'Importar CSV para ' + Spec.Tabela;
    Dlg.Filter := 'Arquivos CSV (*.csv)|*.csv|Todos os arquivos (*.*)|*.*';
    if Dlg.Execute then
    begin
      try
        ImportarCSVTabela(GConexaoFinalidade, Spec, Dlg.FileName, Importados, Erros);
        Result := True;
        MessageDlg('Importação concluída',
          Format('Tabela: %s' + sLineBreak + 'Importados: %d' + sLineBreak + 'Erros: %d',
            [Spec.Tabela, Importados, Erros]),
          mtInformation, [mbOK], 0);
      except
        on E: Exception do
          MessageDlg('Erro na importação', E.Message, mtError, [mbOK], 0);
      end;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure ExecutarExportarCSVDialog(OwnerForm: TComponent; const Spec: TTabelaFinalidade);
var
  Dlg: TSaveDialog;
  Total: Integer;
begin
  if (GConexaoFinalidade = nil) or (not GConexaoFinalidade.Connected) then
  begin
    MessageDlg('Banco de Dados', 'Conexão com o banco de dados não está ativa.', mtWarning, [mbOK], 0);
    Exit;
  end;

  Dlg := TSaveDialog.Create(OwnerForm);
  try
    Dlg.Title := 'Exportar CSV de ' + Spec.Tabela;
    Dlg.Filter := 'Arquivos CSV (*.csv)|*.csv|Todos os arquivos (*.*)|*.*';
    Dlg.DefaultExt := 'csv';
    Dlg.FileName := Spec.Tabela + '.csv';
    if Dlg.Execute then
    begin
      try
        Total := ExportarCSVTabela(GConexaoFinalidade, Spec, Dlg.FileName);
        MessageDlg('Exportação concluída',
          Format('%d registro(s) exportado(s) para %s.', [Total, Dlg.FileName]),
          mtInformation, [mbOK], 0);
      except
        on E: Exception do
          MessageDlg('Erro na exportação', E.Message, mtError, [mbOK], 0);
      end;
    end;
  finally
    Dlg.Free;
  end;
end;

function ExecutarLimparTabelaDialog(const Spec: TTabelaFinalidade): Boolean;
begin
  Result := False;
  if (GConexaoFinalidade = nil) or (not GConexaoFinalidade.Connected) then
  begin
    MessageDlg('Banco de Dados', 'Conexão com o banco de dados não está ativa.', mtWarning, [mbOK], 0);
    Exit;
  end;

  if MessageDlg('Limpar tabela',
    'ATENÇÃO: Esta ação apagará TODOS os registros da tabela "' + Spec.Tabela + '".' +
    sLineBreak + 'Deseja continuar?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  try
    LimparTabelaFinalidade(GConexaoFinalidade, Spec);
    Result := True;
    MessageDlg('Tabela limpa', 'Todos os registros da tabela "' + Spec.Tabela + '" foram removidos.',
      mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg('Erro ao limpar tabela', E.Message, mtError, [mbOK], 0);
  end;
end;

{ TfrmCrudFinalidade }

constructor TfrmCrudFinalidade.CreateComFinalidade(AOwner: TComponent;
  const AChaveFinalidade: string; AModoSelecao: Boolean);
var
  Topo, Rodape, PainelBusca, PainelCampos: TPanel;
  I, Y: Integer;
begin
  inherited CreateNew(AOwner);
  if not ObterTabelaFinalidade(AChaveFinalidade, FSpec) then
    raise Exception.Create('Finalidade/tabela não encontrada: ' + AChaveFinalidade);

  FModoSelecao := AModoSelecao;
  FSelecionadoOK := False;
  FIdAtual := '';

  Caption := 'Gerenciar Tabela — ' + FSpec.Titulo + ' (' + FSpec.Tabela + ')';
  Position := poScreenCenter;
  BorderStyle := bsSizeable;
  SetBounds(0, 0, 980, 660);
  Constraints.MinWidth := 820;
  Constraints.MinHeight := 540;
  Font.Name := 'Segoe UI';
  Font.Size := 9;

  Topo := TPanel.Create(Self);
  Topo.Parent := Self;
  Topo.Align := alTop;
  Topo.Height := 58;
  Topo.BevelOuter := bvNone;
  Topo.Color := $FAF8F5;

  lblTitulo := TLabel.Create(Self);
  lblTitulo.Parent := Topo;
  lblTitulo.SetBounds(16, 8, 700, 22);
  lblTitulo.Font.Size := 12;
  lblTitulo.Font.Style := [fsBold];
  lblTitulo.Caption := FSpec.Titulo;

  lblSubtitulo := TLabel.Create(Self);
  lblSubtitulo.Parent := Topo;
  lblSubtitulo.SetBounds(16, 33, 700, 18);
  lblSubtitulo.Caption := 'Tabela SQLite: ' + FSpec.Tabela;

  PainelBusca := TPanel.Create(Self);
  PainelBusca.Parent := Self;
  PainelBusca.Align := alTop;
  PainelBusca.Height := 42;
  PainelBusca.BevelOuter := bvNone;

  with TLabel.Create(Self) do
  begin
    Parent := PainelBusca;
    Caption := 'Pesquisar:';
    SetBounds(16, 12, 65, 18);
  end;

  edBusca := TEdit.Create(Self);
  edBusca.Parent := PainelBusca;
  edBusca.SetBounds(86, 8, 320, 26);
  edBusca.TextHint := 'Filtrar por qualquer campo...';

  btnBuscar := TButton.Create(Self);
  btnBuscar.Parent := PainelBusca;
  btnBuscar.Caption := 'Buscar';
  btnBuscar.SetBounds(414, 8, 86, 26);
  btnBuscar.OnClick := @BuscarClick;

  btnLimparBusca := TButton.Create(Self);
  btnLimparBusca.Parent := PainelBusca;
  btnLimparBusca.Caption := 'Limpar filtro';
  btnLimparBusca.SetBounds(508, 8, 96, 26);
  btnLimparBusca.OnClick := @LimparBuscaClick;

  btnImportar := TButton.Create(Self);
  btnImportar.Parent := PainelBusca;
  btnImportar.Caption := 'Importar CSV...';
  btnImportar.SetBounds(624, 8, 106, 26);
  btnImportar.OnClick := @ImportarClick;

  btnExportar := TButton.Create(Self);
  btnExportar.Parent := PainelBusca;
  btnExportar.Caption := 'Exportar CSV...';
  btnExportar.SetBounds(736, 8, 106, 26);
  btnExportar.OnClick := @ExportarClick;

  btnModelo := TButton.Create(Self);
  btnModelo.Parent := PainelBusca;
  btnModelo.Caption := 'Modelo CSV';
  btnModelo.SetBounds(848, 8, 92, 26);
  btnModelo.OnClick := @ModeloCSVClick;

  Rodape := TPanel.Create(Self);
  Rodape.Parent := Self;
  Rodape.Align := alBottom;
  Rodape.Height := 52;
  Rodape.BevelOuter := bvNone;

  btnNovo := TButton.Create(Self);
  btnNovo.Parent := Rodape;
  btnNovo.Caption := 'Novo';
  btnNovo.SetBounds(16, 10, 88, 32);
  btnNovo.OnClick := @NovoClick;

  btnSalvar := TButton.Create(Self);
  btnSalvar.Parent := Rodape;
  btnSalvar.Caption := 'Salvar';
  btnSalvar.SetBounds(112, 10, 94, 32);
  btnSalvar.OnClick := @SalvarClick;

  btnExcluir := TButton.Create(Self);
  btnExcluir.Parent := Rodape;
  btnExcluir.Caption := 'Excluir';
  btnExcluir.SetBounds(214, 10, 88, 32);
  btnExcluir.OnClick := @ExcluirClick;

  btnCancelar := TButton.Create(Self);
  btnCancelar.Parent := Rodape;
  btnCancelar.Caption := 'Cancelar';
  btnCancelar.SetBounds(310, 10, 88, 32);
  btnCancelar.OnClick := @CancelarClick;

  btnLimparTabela := TButton.Create(Self);
  btnLimparTabela.Parent := Rodape;
  btnLimparTabela.Caption := 'Limpar Tabela';
  btnLimparTabela.SetBounds(418, 10, 114, 32);
  btnLimparTabela.OnClick := @LimparTabelaClick;

  btnUsar := TButton.Create(Self);
  btnUsar.Parent := Rodape;
  btnUsar.Caption := 'Usar na Emissão';
  btnUsar.SetBounds(670, 10, 146, 32);
  btnUsar.Visible := FModoSelecao;
  btnUsar.OnClick := @UsarClick;

  btnFechar := TButton.Create(Self);
  btnFechar.Parent := Rodape;
  btnFechar.Caption := 'Fechar';
  btnFechar.SetBounds(826, 10, 114, 32);
  btnFechar.OnClick := @FecharClick;

  PainelCampos := TPanel.Create(Self);
  PainelCampos.Parent := Self;
  PainelCampos.Align := alRight;
  PainelCampos.Width := 360;
  PainelCampos.BevelOuter := bvLowered;

  lblStatusEdicao := TLabel.Create(Self);
  lblStatusEdicao.Parent := PainelCampos;
  lblStatusEdicao.Align := alTop;
  lblStatusEdicao.BorderSpacing.Around := 10;
  lblStatusEdicao.Font.Style := [fsBold];
  lblStatusEdicao.Caption := 'Novo registro';

  FEditorScroll := TScrollBox.Create(Self);
  FEditorScroll.Parent := PainelCampos;
  FEditorScroll.Align := alClient;
  FEditorScroll.BorderStyle := bsNone;

  SetLength(lblCampos, Length(FSpec.Campos));
  SetLength(edCampos, Length(FSpec.Campos));
  Y := 8;
  for I := 0 to High(FSpec.Campos) do
  begin
    lblCampos[I] := TLabel.Create(Self);
    lblCampos[I].Parent := FEditorScroll;
    lblCampos[I].Caption := FSpec.Campos[I].Rotulo;
    lblCampos[I].SetBounds(10, Y, 316, 18);

    edCampos[I] := TEdit.Create(Self);
    edCampos[I].Parent := FEditorScroll;
    edCampos[I].SetBounds(10, Y + 19, 316, 25);
    Inc(Y, 50);
  end;

  FGrid := TStringGrid.Create(Self);
  FGrid.Parent := Self;
  FGrid.Align := alClient;
  FGrid.BorderSpacing.Around := 10;
  FGrid.FixedCols := 0;
  FGrid.FixedRows := 1;
  FGrid.Options := FGrid.Options + [goRowSelect, goColSizing, goThumbTracking];
  FGrid.OnSelectCell := @GradeSelectCell;
  FGrid.OnDblClick := @GradeDblClick;

  CarregarGrade('');
end;

procedure TfrmCrudFinalidade.CarregarGrade(const Filtro: string);
var
  I, J: Integer;
begin
  if (GConexaoFinalidade <> nil) and GConexaoFinalidade.Connected then
    FLinhas := CarregarRegistrosTabela(GConexaoFinalidade, FSpec, Filtro)
  else
    SetLength(FLinhas, 0);

  FGrid.ColCount := 1 + Length(FSpec.Campos);
  FGrid.RowCount := Max(1, 1 + Length(FLinhas));
  FGrid.Cells[0, 0] := 'ID';
  FGrid.ColWidths[0] := 48;
  for J := 0 to High(FSpec.Campos) do
  begin
    FGrid.Cells[J + 1, 0] := FSpec.Campos[J].Rotulo;
    FGrid.ColWidths[J + 1] := 145;
  end;

  for I := 0 to High(FLinhas) do
  begin
    FGrid.Cells[0, I + 1] := FLinhas[I].Id;
    for J := 0 to High(FSpec.Campos) do
      FGrid.Cells[J + 1, I + 1] := FLinhas[I].Valores[J];
  end;

  lblSubtitulo.Caption := Format('Tabela SQLite: %s | %d registro(s)', [FSpec.Tabela, Length(FLinhas)]);
  if Length(FLinhas) > 0 then
  begin
    FGrid.Row := 1;
    PreencherEditorDaLinha(0);
  end
  else
    LimparEditorParaNovo;
end;

procedure TfrmCrudFinalidade.PreencherEditorDaLinha(RowIdx: Integer);
var
  I: Integer;
begin
  if (RowIdx < 0) or (RowIdx > High(FLinhas)) then
  begin
    LimparEditorParaNovo;
    Exit;
  end;
  FIdAtual := FLinhas[RowIdx].Id;
  lblStatusEdicao.Caption := 'Editando registro ID #' + FIdAtual;
  for I := 0 to High(edCampos) do
  begin
    if I <= High(FLinhas[RowIdx].Valores) then
      edCampos[I].Text := FLinhas[RowIdx].Valores[I]
    else
      edCampos[I].Text := '';
  end;
end;

procedure TfrmCrudFinalidade.LimparEditorParaNovo;
var
  I: Integer;
begin
  FIdAtual := '';
  lblStatusEdicao.Caption := 'Novo registro';
  for I := 0 to High(edCampos) do
    edCampos[I].Text := '';
end;

function TfrmCrudFinalidade.LerCamposEditor: TStringArray;
var
  I: Integer;
begin
  SetLength(Result, Length(edCampos));
  for I := 0 to High(edCampos) do
    Result[I] := Trim(edCampos[I].Text);
end;

procedure TfrmCrudFinalidade.BuscarClick(Sender: TObject);
begin
  CarregarGrade(edBusca.Text);
end;

procedure TfrmCrudFinalidade.LimparBuscaClick(Sender: TObject);
begin
  edBusca.Text := '';
  CarregarGrade('');
end;

procedure TfrmCrudFinalidade.GradeSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
  if aRow >= 1 then
    PreencherEditorDaLinha(aRow - 1);
end;

procedure TfrmCrudFinalidade.GradeDblClick(Sender: TObject);
begin
  if FModoSelecao and (Length(FLinhas) > 0) then
    UsarClick(Sender);
end;

procedure TfrmCrudFinalidade.NovoClick(Sender: TObject);
begin
  LimparEditorParaNovo;
  if Length(edCampos) > 0 then
    edCampos[0].SetFocus;
end;

procedure TfrmCrudFinalidade.SalvarClick(Sender: TObject);
var
  Valores: TStringArray;
  I: Integer;
  TemAlgo: Boolean;
begin
  if (GConexaoFinalidade = nil) or (not GConexaoFinalidade.Connected) then
  begin
    MessageDlg('Banco de Dados', 'Conexão com o banco de dados não está ativa.', mtError, [mbOK], 0);
    Exit;
  end;

  Valores := LerCamposEditor;
  TemAlgo := False;
  for I := 0 to High(Valores) do
    if Valores[I] <> '' then TemAlgo := True;

  if not TemAlgo then
  begin
    MessageDlg('Atenção', 'Preencha ao menos um campo antes de salvar.', mtWarning, [mbOK], 0);
    Exit;
  end;

  try
    if FIdAtual = '' then
      InserirRegistroTabela(GConexaoFinalidade, FSpec, Valores)
    else
      AtualizarRegistroTabela(GConexaoFinalidade, FSpec, FIdAtual, Valores);
    CarregarGrade(edBusca.Text);
  except
    on E: Exception do
      MessageDlg('Erro ao salvar', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TfrmCrudFinalidade.ExcluirClick(Sender: TObject);
begin
  if FIdAtual = '' then
  begin
    MessageDlg('Atenção', 'Selecione um registro na grade para excluir.', mtInformation, [mbOK], 0);
    Exit;
  end;
  if MessageDlg('Confirmar exclusão',
    'Deseja excluir o registro ID #' + FIdAtual + ' da tabela "' + FSpec.Tabela + '"?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  try
    ExcluirRegistroTabela(GConexaoFinalidade, FSpec, FIdAtual);
    CarregarGrade(edBusca.Text);
  except
    on E: Exception do
      MessageDlg('Erro ao excluir', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TfrmCrudFinalidade.CancelarClick(Sender: TObject);
var
  RowIdx: Integer;
begin
  RowIdx := FGrid.Row - 1;
  if (RowIdx >= 0) and (RowIdx <= High(FLinhas)) then
    PreencherEditorDaLinha(RowIdx)
  else
    LimparEditorParaNovo;
end;

procedure TfrmCrudFinalidade.UsarClick(Sender: TObject);
begin
  FValoresSelecionados := LerCamposEditor;
  FSelecionadoOK := True;
  ModalResult := mrOK;
end;

procedure TfrmCrudFinalidade.ImportarClick(Sender: TObject);
begin
  if ExecutarImportarCSVDialog(Self, FSpec) then
    CarregarGrade(edBusca.Text);
end;

procedure TfrmCrudFinalidade.ExportarClick(Sender: TObject);
begin
  ExecutarExportarCSVDialog(Self, FSpec);
end;

procedure TfrmCrudFinalidade.ModeloCSVClick(Sender: TObject);
var
  Dlg: TSaveDialog;
begin
  Dlg := TSaveDialog.Create(Self);
  try
    Dlg.Title := 'Salvar modelo CSV para ' + FSpec.Tabela;
    Dlg.Filter := 'Arquivos CSV (*.csv)|*.csv|Todos os arquivos (*.*)|*.*';
    Dlg.DefaultExt := 'csv';
    Dlg.FileName := FSpec.Tabela + '_modelo.csv';
    if Dlg.Execute then
    begin
      ExportarModeloCSVTabela(FSpec, Dlg.FileName);
      MessageDlg('Modelo CSV', 'Modelo salvo em ' + Dlg.FileName, mtInformation, [mbOK], 0);
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmCrudFinalidade.LimparTabelaClick(Sender: TObject);
begin
  if ExecutarLimparTabelaDialog(FSpec) then
    CarregarGrade('');
end;

procedure TfrmCrudFinalidade.FecharClick(Sender: TObject);
begin
  Close;
end;

function TfrmCrudFinalidade.ObterValoresSelecionados(out Valores: TStringArray): Boolean;
begin
  Result := FSelecionadoOK;
  Valores := FValoresSelecionados;
end;

{ TPainelBancoFinalidade }

constructor TPainelBancoFinalidade.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvLowered;
  Color := $F4EFE9;
  Height := 72;

  lblInfo := TLabel.Create(Self);
  lblInfo.Parent := Self;
  lblInfo.AutoSize := False;
  lblInfo.Font.Style := [fsBold];
  lblInfo.SetBounds(10, 8, 360, 18);
  lblInfo.Caption := 'Tabela da finalidade:';

  cbRegistros := TComboBox.Create(Self);
  cbRegistros.Parent := Self;
  cbRegistros.Style := csDropDownList;
  cbRegistros.SetBounds(10, 32, 260, 26);
  cbRegistros.OnChange := @SelecionarRegistroChange;

  btnSalvar := TButton.Create(Self);
  btnSalvar.Parent := Self;
  btnSalvar.Caption := 'Salvar na tabela';
  btnSalvar.SetBounds(278, 31, 112, 28);
  btnSalvar.OnClick := @SalvarClick;

  btnCrud := TButton.Create(Self);
  btnCrud.Parent := Self;
  btnCrud.Caption := 'CRUD';
  btnCrud.SetBounds(396, 31, 74, 28);
  btnCrud.OnClick := @CrudClick;

  btnImportar := TButton.Create(Self);
  btnImportar.Parent := Self;
  btnImportar.Caption := 'Importar CSV';
  btnImportar.SetBounds(476, 31, 96, 28);
  btnImportar.OnClick := @ImportarClick;

  btnExportar := TButton.Create(Self);
  btnExportar.Parent := Self;
  btnExportar.Caption := 'Exportar CSV';
  btnExportar.SetBounds(578, 31, 96, 28);
  btnExportar.OnClick := @ExportarClick;

  btnLimpar := TButton.Create(Self);
  btnLimpar.Parent := Self;
  btnLimpar.Caption := 'Limpar tabela';
  btnLimpar.SetBounds(680, 31, 96, 28);
  btnLimpar.OnClick := @LimparClick;
end;

function TPainelBancoFinalidade.ConexaoDisponivel: Boolean;
begin
  Result := FSpecValido and (GConexaoFinalidade <> nil) and GConexaoFinalidade.Connected;
end;

procedure TPainelBancoFinalidade.DefinirFinalidade(const AChaveFinalidade: string);
begin
  FChaveFinalidade := AChaveFinalidade;
  FSpecValido := ObterTabelaFinalidade(AChaveFinalidade, FSpec);
  AtualizarLista;
end;

procedure TPainelBancoFinalidade.AtualizarLista;
var
  I: Integer;
  Resumo: string;
begin
  cbRegistros.Items.Clear;
  cbRegistros.Items.Add('(Selecionar registro salvo...)');
  SetLength(FLinhas, 0);

  if not FSpecValido then
  begin
    lblInfo.Caption := 'Tabela da finalidade: não configurada';
    cbRegistros.ItemIndex := 0;
    Exit;
  end;

  if not ConexaoDisponivel then
  begin
    lblInfo.Caption := 'Tabela: ' + FSpec.Tabela + ' (banco desconectado)';
    cbRegistros.ItemIndex := 0;
    Exit;
  end;

  FLinhas := CarregarRegistrosTabela(GConexaoFinalidade, FSpec, '');
  lblInfo.Caption := Format('Tabela: %s (%d registro(s))', [FSpec.Tabela, Length(FLinhas)]);
  for I := 0 to High(FLinhas) do
  begin
    Resumo := '#' + FLinhas[I].Id;
    if Length(FLinhas[I].Valores) > 0 then
      Resumo := Resumo + ' — ' + FLinhas[I].Valores[0];
    if (Length(FLinhas[I].Valores) > 1) and (FLinhas[I].Valores[1] <> '') then
      Resumo := Resumo + ' | ' + FLinhas[I].Valores[1];
    cbRegistros.Items.Add(Resumo);
  end;
  cbRegistros.ItemIndex := 0;
end;

procedure TPainelBancoFinalidade.SelecionarRegistroChange(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := cbRegistros.ItemIndex - 1;
  if (Idx < 0) or (Idx > High(FLinhas)) then
    Exit;
  if Assigned(FOnCarregar) then
    FOnCarregar(FLinhas[Idx].Valores);
end;

procedure TPainelBancoFinalidade.SalvarClick(Sender: TObject);
var
  Valores: TStringArray;
begin
  if not ConexaoDisponivel then
  begin
    MessageDlg('Banco de Dados', 'Banco de dados não conectado.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if not Assigned(FOnObter) then
    Exit;

  FOnObter(Valores);
  try
    InserirRegistroTabela(GConexaoFinalidade, FSpec, Valores);
    AtualizarLista;
    MessageDlg('Salvo', 'Registro gravado na tabela "' + FSpec.Tabela + '".', mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg('Erro ao salvar', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TPainelBancoFinalidade.CrudClick(Sender: TObject);
var
  Dlg: TfrmCrudFinalidade;
  Valores: TStringArray;
begin
  if not FSpecValido then
    Exit;

  Dlg := TfrmCrudFinalidade.CreateComFinalidade(Self, FChaveFinalidade, Assigned(FOnCarregar));
  try
    if (Dlg.ShowModal = mrOK) and Dlg.ObterValoresSelecionados(Valores) and Assigned(FOnCarregar) then
      FOnCarregar(Valores);
  finally
    Dlg.Free;
  end;
  AtualizarLista;
end;

procedure TPainelBancoFinalidade.Resize;
begin
  inherited Resize;
  if not Assigned(btnLimpar) then
    Exit;

  if ClientWidth >= 786 then
  begin
    lblInfo.SetBounds(10, 8, Max(120, ClientWidth - 20), 18);
    cbRegistros.SetBounds(10, 32, Max(120, ClientWidth - 526), 26);
    btnSalvar.SetBounds(cbRegistros.Left + cbRegistros.Width + 8, 31, 112, 28);
    btnCrud.SetBounds(btnSalvar.Left + btnSalvar.Width + 6, 31, 74, 28);
    btnImportar.SetBounds(btnCrud.Left + btnCrud.Width + 6, 31, 96, 28);
    btnExportar.SetBounds(btnImportar.Left + btnImportar.Width + 6, 31, 96, 28);
    btnLimpar.SetBounds(btnExportar.Left + btnExportar.Width + 6, 31, 96, 28);
  end
  else
  begin
    lblInfo.SetBounds(10, 8, Max(120, ClientWidth - 20), 18);
    cbRegistros.SetBounds(10, 30, Max(160, ClientWidth - 20), 26);
    btnSalvar.SetBounds(10, 62, 112, 28);
    btnCrud.SetBounds(128, 62, 68, 28);
    btnImportar.SetBounds(202, 62, 94, 28);
    btnExportar.SetBounds(302, 62, 94, 28);
    btnLimpar.SetBounds(402, 62, 96, 28);
  end;
end;

procedure TPainelBancoFinalidade.ImportarClick(Sender: TObject);
begin
  if not ConexaoDisponivel then
  begin
    MessageDlg('Banco de Dados', 'Banco de dados não conectado.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if ExecutarImportarCSVDialog(Self, FSpec) then
    AtualizarLista;
end;

procedure TPainelBancoFinalidade.ExportarClick(Sender: TObject);
begin
  if not ConexaoDisponivel then
  begin
    MessageDlg('Banco de Dados', 'Banco de dados não conectado.', mtWarning, [mbOK], 0);
    Exit;
  end;
  ExecutarExportarCSVDialog(Self, FSpec);
end;

procedure TPainelBancoFinalidade.LimparClick(Sender: TObject);
begin
  if not ConexaoDisponivel then
  begin
    MessageDlg('Banco de Dados', 'Banco de dados não conectado.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if ExecutarLimparTabelaDialog(FSpec) then
    AtualizarLista;
end;

end.
