unit crudfinalidade;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Grids, ComCtrls, Menus, LCLType, tabelafinalidade;

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
    FLinhaAtual: Integer;
    FSelecionadoOK: Boolean;
    FValoresSelecionados: TStringArray;
    FModificado: Boolean;
    FCarregando: Boolean;
    FPrecisaRecarregar: Boolean;

    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    edBusca: TEdit;
    btnBuscar: TButton;
    btnLimparBusca: TButton;
    btnMais: TButton;
    FMenuMais: TPopupMenu;
    FTimerBusca: TTimer;
    FGrid: TStringGrid;
    FEditorScroll: TScrollBox;
    lblCampos: array of TLabel;
    edCampos: array of TEdit;
    lblStatusEdicao: TLabel;
    FBarraStatus: TStatusBar;

    btnNovo: TButton;
    btnSalvar: TButton;
    btnExcluir: TButton;
    btnCancelar: TButton;
    btnUsar: TButton;
    btnFechar: TButton;

    procedure CarregarGrade(const Filtro: string = '');
    procedure PreencherEditorDaLinha(RowIdx: Integer);
    procedure LimparEditorParaNovo;
    function LerCamposEditor: TStringArray;
    procedure DefinirModificado(Valor: Boolean);
    function SalvarAtual: Boolean;
    function ConfirmarDescarte: Boolean;
    procedure SelecionarLinhaPorId(const Id: string);
    procedure RecarregarAsync(Data: PtrInt);
    procedure MostrarStatus(const Msg: string);

    procedure CampoChange(Sender: TObject);
    procedure BuscaChange(Sender: TObject);
    procedure BuscaKeyPress(Sender: TObject; var Key: Char);
    procedure TimerBuscaTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

    procedure BuscarClick(Sender: TObject);
    procedure LimparBuscaClick(Sender: TObject);
    procedure GradeSelectCell(Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);
    procedure GradeDblClick(Sender: TObject);
    procedure NovoClick(Sender: TObject);
    procedure SalvarClick(Sender: TObject);
    procedure ExcluirClick(Sender: TObject);
    procedure CancelarClick(Sender: TObject);
    procedure UsarClick(Sender: TObject);
    procedure MaisClick(Sender: TObject);
    procedure ImportarClick(Sender: TObject);
    procedure ExportarClick(Sender: TObject);
    procedure ModeloCSVClick(Sender: TObject);
    procedure LimparTabelaClick(Sender: TObject);
    procedure FecharClick(Sender: TObject);
  public
    constructor CreateComFinalidade(AOwner: TComponent;
      const AChaveFinalidade: string; AModoSelecao: Boolean = True);
    destructor Destroy; override;
    function ObterValoresSelecionados(out Valores: TStringArray): Boolean;
    property IdSelecionado: string read FIdAtual;
  end;

  { TfrmGerenciadorTabelas }

  TfrmGerenciadorTabelas = class(TForm)
  private
    FTabelas: TTabelasFinalidade;
    FContagens: array of Integer;
    edFiltro: TEdit;
    FArvore: TTreeView;
    lblTabTitulo: TLabel;
    lblTabInfo: TLabel;
    btnAbrir: TButton;
    btnImportar: TButton;
    btnExportar: TButton;
    btnFechar: TButton;
    procedure CarregarContagens;
    procedure MontarArvore;
    function IndiceSelecionado: Integer;
    function TextoNo(Idx: Integer): string;
    procedure AtualizarContagem(Idx: Integer);
    procedure AtualizarDetalhe;
    procedure FiltroChange(Sender: TObject);
    procedure ArvoreSelectionChanged(Sender: TObject);
    procedure ArvoreDblClick(Sender: TObject);
    procedure ArvoreKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AbrirClick(Sender: TObject);
    procedure ImportarClick(Sender: TObject);
    procedure ExportarClick(Sender: TObject);
    procedure FecharClick(Sender: TObject);
  public
    constructor CreateGerenciador(AOwner: TComponent; const AChaveInicial: string = '');
  end;

  { TPainelBancoFinalidade }

  TPainelBancoFinalidade = class(TPanel)
  private
    FChaveFinalidade: string;
    FSpec: TTabelaFinalidade;
    FSpecValido: Boolean;
    FLinhas: TListaLinhasTabela;
    FIdCarregado: string;
    FOnCarregar: TCarregarValoresEvent;
    FOnObter: TObterValoresEvent;

    lblInfo: TLabel;
    cbRegistros: TComboBox;
    btnSalvar: TButton;
    btnCrud: TButton;
    btnMais: TButton;
    FMenuMais: TPopupMenu;

    function ConexaoDisponivel: Boolean;
    procedure SelecionarRegistroChange(Sender: TObject);
    procedure SalvarClick(Sender: TObject);
    procedure CrudClick(Sender: TObject);
    procedure MaisClick(Sender: TObject);
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
    property IdCarregado: string read FIdCarregado;
    property OnCarregarValores: TCarregarValoresEvent read FOnCarregar write FOnCarregar;
    property OnObterValores: TObterValoresEvent read FOnObter write FOnObter;
  end;

function ExecutarImportarCSVDialog(OwnerForm: TComponent; const Spec: TTabelaFinalidade): Boolean;
function ExecutarExportarCSVDialog(OwnerForm: TComponent; const Spec: TTabelaFinalidade): Boolean;
function ExecutarLimparTabelaDialog(OwnerForm: TComponent; const Spec: TTabelaFinalidade): Boolean;

{ Atalhos usados pelo menu Cadastros }
procedure AbrirGerenciarRegistros(AOwner: TComponent; const AChaveFinalidade: string);
procedure AbrirGerenciadorTabelas(AOwner: TComponent; const AChaveInicial: string = '');

implementation

const
  PALAVRA_CONFIRMA_LIMPEZA = 'LIMPAR';

function BancoConectado: Boolean;
begin
  Result := (GConexaoFinalidade <> nil) and GConexaoFinalidade.Connected;
end;

procedure AvisarBancoDesconectado;
begin
  MessageDlg('Banco de Dados', 'Conexão com o banco de dados não está ativa.', mtWarning, [mbOK], 0);
end;

function CriarItemMenu(AOwner: TComponent; Pai: TMenu; const Titulo: string;
  Evento: TNotifyEvent): TMenuItem;
begin
  Result := TMenuItem.Create(AOwner);
  Result.Caption := Titulo;
  Result.OnClick := Evento;
  Pai.Items.Add(Result);
end;

procedure MostrarMenuAbaixo(Menu: TPopupMenu; Botao: TControl);
var
  P: TPoint;
begin
  P := Botao.ClientToScreen(Point(0, Botao.Height));
  Menu.PopUp(P.X, P.Y);
end;

function ExecutarImportarCSVDialog(OwnerForm: TComponent; const Spec: TTabelaFinalidade): Boolean;
var
  Dlg: TOpenDialog;
  Importados, Erros: Integer;
begin
  Result := False;
  if not BancoConectado then
  begin
    AvisarBancoDesconectado;
    Exit;
  end;

  Dlg := TOpenDialog.Create(OwnerForm);
  try
    Dlg.Title := 'Importar CSV — ' + Spec.Titulo;
    Dlg.Filter := 'Arquivos CSV (*.csv)|*.csv|Todos os arquivos (*.*)|*.*';
    if Dlg.Execute then
    begin
      try
        ImportarCSVTabela(GConexaoFinalidade, Spec, Dlg.FileName, Importados, Erros);
        Result := True;
        MessageDlg('Importação concluída',
          Format('%s' + sLineBreak + 'Importados: %d' + sLineBreak + 'Erros: %d',
            [Spec.Titulo, Importados, Erros]),
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

function ExecutarExportarCSVDialog(OwnerForm: TComponent; const Spec: TTabelaFinalidade): Boolean;
var
  Dlg: TSaveDialog;
  Total: Integer;
begin
  Result := False;
  if not BancoConectado then
  begin
    AvisarBancoDesconectado;
    Exit;
  end;

  Dlg := TSaveDialog.Create(OwnerForm);
  try
    Dlg.Title := 'Exportar CSV — ' + Spec.Titulo;
    Dlg.Filter := 'Arquivos CSV (*.csv)|*.csv|Todos os arquivos (*.*)|*.*';
    Dlg.DefaultExt := 'csv';
    Dlg.FileName := Spec.Tabela + '_' + FormatDateTime('yyyymmdd_hhnn', Now) + '.csv';
    Dlg.Options := Dlg.Options + [ofOverwritePrompt];
    if Dlg.Execute then
    begin
      try
        Total := ExportarCSVTabela(GConexaoFinalidade, Spec, Dlg.FileName);
        Result := True;
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

function ExecutarLimparTabelaDialog(OwnerForm: TComponent; const Spec: TTabelaFinalidade): Boolean;
var
  Total: Integer;
  Digitado: string;
begin
  Result := False;
  if not BancoConectado then
  begin
    AvisarBancoDesconectado;
    Exit;
  end;

  Total := ContarRegistrosTabela(GConexaoFinalidade, Spec);
  if Total = 0 then
  begin
    MessageDlg('Limpar tabela', 'A tabela "' + Spec.Titulo + '" já está vazia.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  { 1ª confirmação: avisa e oferece backup (o padrão é Cancelar) }
  case QuestionDlg('Limpar tabela',
    Format('ATENÇÃO: esta ação apaga os %d registro(s) de "%s" e não pode ser desfeita.' +
      sLineBreak + sLineBreak + 'Recomendamos exportar um backup em CSV antes.',
      [Total, Spec.Titulo]),
    mtWarning,
    [mrYes, 'Exportar backup e limpar', mrNo, 'Limpar sem backup',
     mrCancel, 'Cancelar', 'IsDefault', 'IsCancel'],
    0) of
    mrYes:
      if not ExecutarExportarCSVDialog(OwnerForm, Spec) then
      begin
        MessageDlg('Limpar tabela', 'O backup não foi gerado. Nenhum registro foi apagado.',
          mtInformation, [mbOK], 0);
        Exit;
      end;
    mrNo: ;
  else
    Exit;
  end;

  { 2ª confirmação: digitar a palavra de confirmação }
  Digitado := '';
  if not InputQuery('Confirmar limpeza',
    Format('Para apagar os %d registro(s), digite %s:', [Total, PALAVRA_CONFIRMA_LIMPEZA]),
    Digitado) then
    Exit;
  if not SameText(Trim(Digitado), PALAVRA_CONFIRMA_LIMPEZA) then
  begin
    MessageDlg('Limpar tabela', 'Texto de confirmação incorreto. Nenhum registro foi apagado.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  try
    LimparTabelaFinalidade(GConexaoFinalidade, Spec);
    Result := True;
    MessageDlg('Tabela limpa', Format('%d registro(s) de "%s" foram removidos.', [Total, Spec.Titulo]),
      mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg('Erro ao limpar tabela', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure AbrirGerenciarRegistros(AOwner: TComponent; const AChaveFinalidade: string);
var
  Dlg: TfrmCrudFinalidade;
begin
  Dlg := TfrmCrudFinalidade.CreateComFinalidade(AOwner, AChaveFinalidade, False);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

procedure AbrirGerenciadorTabelas(AOwner: TComponent; const AChaveInicial: string);
var
  Dlg: TfrmGerenciadorTabelas;
begin
  Dlg := TfrmGerenciadorTabelas.CreateGerenciador(AOwner, AChaveInicial);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
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
  FLinhaAtual := -1;
  FModificado := False;
  FCarregando := False;
  FPrecisaRecarregar := False;

  Caption := 'Gerenciar registros — ' + FSpec.Titulo;
  Position := poScreenCenter;
  BorderStyle := bsSizeable;
  SetBounds(0, 0, 980, 680);
  Constraints.MinWidth := 820;
  Constraints.MinHeight := 540;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  KeyPreview := True;
  OnKeyDown := @FormKeyDown;
  OnCloseQuery := @FormCloseQuery;

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
  lblSubtitulo.Caption := '';
  lblSubtitulo.Hint := 'Tabela no banco: ' + FSpec.Tabela;
  lblSubtitulo.ShowHint := True;

  PainelBusca := TPanel.Create(Self);
  PainelBusca.Parent := Self;
  PainelBusca.Top := Topo.Top + Topo.Height + 1; { fica abaixo do título }
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
  edBusca.TextHint := 'Digite para filtrar (Enter busca, Ctrl+F)';
  edBusca.OnChange := @BuscaChange;
  edBusca.OnKeyPress := @BuscaKeyPress;

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

  btnMais := TButton.Create(Self);
  btnMais.Parent := PainelBusca;
  btnMais.Caption := 'Mais ▾';
  btnMais.Hint := 'Importar, exportar, modelo CSV e limpar tabela';
  btnMais.ShowHint := True;
  btnMais.SetBounds(624, 8, 90, 26);
  btnMais.OnClick := @MaisClick;

  FMenuMais := TPopupMenu.Create(Self);
  CriarItemMenu(Self, FMenuMais, 'Importar CSV...', @ImportarClick);
  CriarItemMenu(Self, FMenuMais, 'Exportar CSV...', @ExportarClick);
  CriarItemMenu(Self, FMenuMais, 'Salvar modelo CSV...', @ModeloCSVClick);
  CriarItemMenu(Self, FMenuMais, '-', nil);
  CriarItemMenu(Self, FMenuMais, 'Limpar tabela (apagar todos)...', @LimparTabelaClick);

  FTimerBusca := TTimer.Create(Self);
  FTimerBusca.Enabled := False;
  FTimerBusca.Interval := 400;
  FTimerBusca.OnTimer := @TimerBuscaTimer;

  FBarraStatus := TStatusBar.Create(Self);
  FBarraStatus.Parent := Self;
  FBarraStatus.Top := 5000; { sempre na última linha da janela }
  FBarraStatus.Align := alBottom;
  FBarraStatus.SimplePanel := True;
  FBarraStatus.SimpleText := 'Ctrl+N novo · Ctrl+S salvar · Del excluir · Ctrl+F pesquisar · Esc cancelar';

  Rodape := TPanel.Create(Self);
  Rodape.Parent := Self;
  Rodape.Top := 4000;
  Rodape.Align := alBottom;
  Rodape.Height := 52;
  Rodape.BevelOuter := bvNone;

  btnNovo := TButton.Create(Self);
  btnNovo.Parent := Rodape;
  btnNovo.Caption := 'Novo';
  btnNovo.Hint := 'Novo registro (Ctrl+N)';
  btnNovo.ShowHint := True;
  btnNovo.SetBounds(16, 10, 88, 32);
  btnNovo.OnClick := @NovoClick;

  btnSalvar := TButton.Create(Self);
  btnSalvar.Parent := Rodape;
  btnSalvar.Caption := 'Salvar';
  btnSalvar.Hint := 'Salvar o registro (Ctrl+S)';
  btnSalvar.ShowHint := True;
  btnSalvar.SetBounds(112, 10, 94, 32);
  btnSalvar.OnClick := @SalvarClick;

  btnExcluir := TButton.Create(Self);
  btnExcluir.Parent := Rodape;
  btnExcluir.Caption := 'Excluir';
  btnExcluir.Hint := 'Excluir o registro selecionado (Del na grade)';
  btnExcluir.ShowHint := True;
  btnExcluir.SetBounds(214, 10, 88, 32);
  btnExcluir.OnClick := @ExcluirClick;

  btnCancelar := TButton.Create(Self);
  btnCancelar.Parent := Rodape;
  btnCancelar.Caption := 'Cancelar';
  btnCancelar.Hint := 'Desfazer as alterações não salvas (Esc)';
  btnCancelar.ShowHint := True;
  btnCancelar.SetBounds(310, 10, 88, 32);
  btnCancelar.OnClick := @CancelarClick;

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
    edCampos[I].OnChange := @CampoChange;
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

destructor TfrmCrudFinalidade.Destroy;
begin
  Application.RemoveAsyncCalls(Self);
  inherited Destroy;
end;

procedure TfrmCrudFinalidade.MostrarStatus(const Msg: string);
begin
  FBarraStatus.SimpleText := FormatDateTime('hh:nn', Now) + '  ' + Msg;
end;

procedure TfrmCrudFinalidade.DefinirModificado(Valor: Boolean);
begin
  FModificado := Valor;
  if FIdAtual = '' then
    lblStatusEdicao.Caption := 'Novo registro'
  else
    lblStatusEdicao.Caption := 'Editando registro #' + FIdAtual;
  if FModificado then
  begin
    lblStatusEdicao.Caption := lblStatusEdicao.Caption + '  •  alterado (não salvo)';
    lblStatusEdicao.Font.Color := clMaroon;
  end
  else
    lblStatusEdicao.Font.Color := clWindowText;
end;

procedure TfrmCrudFinalidade.CampoChange(Sender: TObject);
begin
  if FCarregando then
    Exit;
  if not FModificado then
    DefinirModificado(True);
end;

procedure TfrmCrudFinalidade.CarregarGrade(const Filtro: string);
var
  I, J: Integer;
begin
  FCarregando := True;
  try
    if BancoConectado then
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

    if not BancoConectado then
      lblSubtitulo.Caption := 'Banco de dados desconectado'
    else if Trim(Filtro) <> '' then
      lblSubtitulo.Caption := Format('%d registro(s) encontrado(s) para "%s"', [Length(FLinhas), Trim(Filtro)])
    else
      lblSubtitulo.Caption := Format('%d registro(s)', [Length(FLinhas)]);

    if Length(FLinhas) > 0 then
    begin
      FGrid.Row := 1;
      PreencherEditorDaLinha(0);
    end
    else
      LimparEditorParaNovo;
  finally
    FCarregando := False;
  end;
end;

procedure TfrmCrudFinalidade.PreencherEditorDaLinha(RowIdx: Integer);
var
  I: Integer;
  EstavaCarregando: Boolean;
begin
  if (RowIdx < 0) or (RowIdx > High(FLinhas)) then
  begin
    LimparEditorParaNovo;
    Exit;
  end;
  EstavaCarregando := FCarregando;
  FCarregando := True;
  try
    FIdAtual := FLinhas[RowIdx].Id;
    FLinhaAtual := RowIdx;
    for I := 0 to High(edCampos) do
    begin
      if I <= High(FLinhas[RowIdx].Valores) then
        edCampos[I].Text := FLinhas[RowIdx].Valores[I]
      else
        edCampos[I].Text := '';
    end;
  finally
    FCarregando := EstavaCarregando;
  end;
  DefinirModificado(False);
end;

procedure TfrmCrudFinalidade.LimparEditorParaNovo;
var
  I: Integer;
  EstavaCarregando: Boolean;
begin
  EstavaCarregando := FCarregando;
  FCarregando := True;
  try
    FIdAtual := '';
    FLinhaAtual := -1;
    for I := 0 to High(edCampos) do
      edCampos[I].Text := '';
  finally
    FCarregando := EstavaCarregando;
  end;
  DefinirModificado(False);
end;

function TfrmCrudFinalidade.LerCamposEditor: TStringArray;
var
  I: Integer;
begin
  SetLength(Result, Length(edCampos));
  for I := 0 to High(edCampos) do
    Result[I] := Trim(edCampos[I].Text);
end;

function TfrmCrudFinalidade.SalvarAtual: Boolean;
var
  Valores: TStringArray;
  I: Integer;
  TemAlgo: Boolean;
  NovoId: Int64;
begin
  Result := False;
  if not BancoConectado then
  begin
    AvisarBancoDesconectado;
    Exit;
  end;

  Valores := LerCamposEditor;
  TemAlgo := False;
  for I := 0 to High(Valores) do
    if Valores[I] <> '' then TemAlgo := True;

  if not TemAlgo then
  begin
    MessageDlg('Atenção', 'Preencha ao menos um campo antes de salvar.', mtWarning, [mbOK], 0);
    if Length(edCampos) > 0 then
      edCampos[0].SetFocus;
    Exit;
  end;

  try
    if FIdAtual = '' then
    begin
      NovoId := InserirRegistroTabela(GConexaoFinalidade, FSpec, Valores);
      FIdAtual := IntToStr(NovoId);
      FPrecisaRecarregar := True;
      MostrarStatus('Registro #' + FIdAtual + ' incluído.');
    end
    else
    begin
      AtualizarRegistroTabela(GConexaoFinalidade, FSpec, FIdAtual, Valores);
      { Atualiza a linha na memória e na grade, sem recarregar a tabela inteira }
      if (FLinhaAtual >= 0) and (FLinhaAtual <= High(FLinhas)) and
         (FLinhas[FLinhaAtual].Id = FIdAtual) then
      begin
        FLinhas[FLinhaAtual].Valores := Copy(Valores, 0, Length(Valores));
        for I := 0 to High(Valores) do
          FGrid.Cells[I + 1, FLinhaAtual + 1] := Valores[I];
      end
      else
        FPrecisaRecarregar := True;
      MostrarStatus('Registro #' + FIdAtual + ' atualizado.');
    end;
    DefinirModificado(False);
    Result := True;
  except
    on E: Exception do
      MessageDlg('Erro ao salvar', E.Message, mtError, [mbOK], 0);
  end;
end;

function TfrmCrudFinalidade.ConfirmarDescarte: Boolean;
var
  Descricao: string;
begin
  Result := True;
  if not FModificado then
    Exit;

  if FIdAtual = '' then
    Descricao := 'O novo registro ainda não foi salvo.'
  else
    Descricao := 'O registro #' + FIdAtual + ' foi alterado e não foi salvo.';

  case QuestionDlg('Alterações não salvas', Descricao + sLineBreak + 'Deseja salvar agora?',
    mtConfirmation,
    [mrYes, 'Salvar', 'IsDefault', mrNo, 'Descartar', mrCancel, 'Continuar editando', 'IsCancel'], 0) of
    mrYes:
      Result := SalvarAtual;
    mrNo:
      begin
        DefinirModificado(False);
        Result := True;
      end;
  else
    Result := False;
  end;
end;

procedure TfrmCrudFinalidade.SelecionarLinhaPorId(const Id: string);
var
  I: Integer;
begin
  if Id = '' then
    Exit;
  for I := 0 to High(FLinhas) do
    if FLinhas[I].Id = Id then
    begin
      FCarregando := True;
      try
        FGrid.Row := I + 1;
        PreencherEditorDaLinha(I);
      finally
        FCarregando := False;
      end;
      Exit;
    end;
end;

procedure TfrmCrudFinalidade.RecarregarAsync(Data: PtrInt);
var
  Id: string;
begin
  FPrecisaRecarregar := False;
  Id := FIdAtual;
  CarregarGrade(edBusca.Text);
  SelecionarLinhaPorId(Id);
end;

procedure TfrmCrudFinalidade.BuscaChange(Sender: TObject);
begin
  { Filtra automaticamente enquanto digita, só quando não há edição pendente }
  FTimerBusca.Enabled := False;
  if (not FCarregando) and (not FModificado) then
    FTimerBusca.Enabled := True;
end;

procedure TfrmCrudFinalidade.TimerBuscaTimer(Sender: TObject);
begin
  FTimerBusca.Enabled := False;
  if not FModificado then
    CarregarGrade(edBusca.Text);
end;

procedure TfrmCrudFinalidade.BuscaKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    BuscarClick(Sender);
  end;
end;

procedure TfrmCrudFinalidade.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = VK_N) then
  begin
    NovoClick(Sender);
    Key := 0;
  end
  else if (ssCtrl in Shift) and (Key = VK_S) then
  begin
    SalvarClick(Sender);
    Key := 0;
  end
  else if ((ssCtrl in Shift) and (Key = VK_F)) or (Key = VK_F3) then
  begin
    edBusca.SetFocus;
    edBusca.SelectAll;
    Key := 0;
  end
  else if (Key = VK_DELETE) and (Shift = []) and (ActiveControl = FGrid) then
  begin
    ExcluirClick(Sender);
    Key := 0;
  end
  else if Key = VK_ESCAPE then
  begin
    if FModificado then
      CancelarClick(Sender)
    else
      Close;
    Key := 0;
  end;
end;

procedure TfrmCrudFinalidade.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmarDescarte;
end;

procedure TfrmCrudFinalidade.BuscarClick(Sender: TObject);
begin
  FTimerBusca.Enabled := False;
  if not ConfirmarDescarte then
    Exit;
  FPrecisaRecarregar := False;
  CarregarGrade(edBusca.Text);
end;

procedure TfrmCrudFinalidade.LimparBuscaClick(Sender: TObject);
begin
  if not ConfirmarDescarte then
    Exit;
  FCarregando := True;
  try
    edBusca.Text := '';
  finally
    FCarregando := False;
  end;
  FTimerBusca.Enabled := False;
  FPrecisaRecarregar := False;
  CarregarGrade('');
end;

procedure TfrmCrudFinalidade.GradeSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
  if FCarregando then
    Exit;
  if (aRow < 1) or (aRow - 1 > High(FLinhas)) then
    Exit;
  if (aRow - 1 = FLinhaAtual) and (FIdAtual <> '') then
    Exit;

  { Não perde o que foi digitado ao clicar em outra linha }
  if not ConfirmarDescarte then
  begin
    CanSelect := False;
    Exit;
  end;

  PreencherEditorDaLinha(aRow - 1);
  { Se um registro novo foi incluído, recarrega a grade depois deste evento }
  if FPrecisaRecarregar then
    Application.QueueAsyncCall(@RecarregarAsync, 0);
end;

procedure TfrmCrudFinalidade.GradeDblClick(Sender: TObject);
begin
  if FModoSelecao and (Length(FLinhas) > 0) then
    UsarClick(Sender);
end;

procedure TfrmCrudFinalidade.NovoClick(Sender: TObject);
begin
  if not ConfirmarDescarte then
    Exit;
  if FPrecisaRecarregar then
  begin
    FPrecisaRecarregar := False;
    CarregarGrade(edBusca.Text);
  end;
  LimparEditorParaNovo;
  MostrarStatus('Preencha os campos e clique em Salvar (Ctrl+S).');
  if Length(edCampos) > 0 then
    edCampos[0].SetFocus;
end;

procedure TfrmCrudFinalidade.SalvarClick(Sender: TObject);
var
  Id: string;
begin
  if not SalvarAtual then
    Exit;
  if FPrecisaRecarregar then
  begin
    FPrecisaRecarregar := False;
    Id := FIdAtual;
    CarregarGrade(edBusca.Text);
    SelecionarLinhaPorId(Id);
  end;
end;

procedure TfrmCrudFinalidade.ExcluirClick(Sender: TObject);
var
  IdExcluido: string;
begin
  if FIdAtual = '' then
  begin
    MessageDlg('Atenção', 'Selecione um registro na grade para excluir.', mtInformation, [mbOK], 0);
    Exit;
  end;
  if MessageDlg('Confirmar exclusão',
    'Deseja excluir o registro #' + FIdAtual + '?' + sLineBreak + 'Esta ação não pode ser desfeita.',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  try
    IdExcluido := FIdAtual;
    ExcluirRegistroTabela(GConexaoFinalidade, FSpec, IdExcluido);
    FModificado := False;
    FPrecisaRecarregar := False;
    CarregarGrade(edBusca.Text);
    MostrarStatus('Registro #' + IdExcluido + ' excluído.');
  except
    on E: Exception do
      MessageDlg('Erro ao excluir', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TfrmCrudFinalidade.CancelarClick(Sender: TObject);
begin
  if (FLinhaAtual >= 0) and (FLinhaAtual <= High(FLinhas)) then
    PreencherEditorDaLinha(FLinhaAtual)
  else
    LimparEditorParaNovo;
  MostrarStatus('Alterações desfeitas.');
end;

procedure TfrmCrudFinalidade.UsarClick(Sender: TObject);
begin
  if FModificado then
  begin
    case QuestionDlg('Usar na emissão',
      'Os dados foram alterados. Deseja salvar na tabela antes de usar?',
      mtConfirmation,
      [mrYes, 'Salvar e usar', 'IsDefault', mrNo, 'Usar sem salvar', mrCancel, 'Cancelar', 'IsCancel'], 0) of
      mrYes:
        if not SalvarAtual then
          Exit;
      mrNo: ;
    else
      Exit;
    end;
  end;
  FValoresSelecionados := LerCamposEditor;
  FSelecionadoOK := True;
  FModificado := False;
  ModalResult := mrOK;
end;

procedure TfrmCrudFinalidade.MaisClick(Sender: TObject);
begin
  MostrarMenuAbaixo(FMenuMais, btnMais);
end;

procedure TfrmCrudFinalidade.ImportarClick(Sender: TObject);
begin
  if not ConfirmarDescarte then
    Exit;
  if ExecutarImportarCSVDialog(Self, FSpec) then
  begin
    FPrecisaRecarregar := False;
    CarregarGrade(edBusca.Text);
    MostrarStatus('Importação concluída.');
  end;
end;

procedure TfrmCrudFinalidade.ExportarClick(Sender: TObject);
begin
  if ExecutarExportarCSVDialog(Self, FSpec) then
    MostrarStatus('Exportação concluída.');
end;

procedure TfrmCrudFinalidade.ModeloCSVClick(Sender: TObject);
var
  Dlg: TSaveDialog;
begin
  Dlg := TSaveDialog.Create(Self);
  try
    Dlg.Title := 'Salvar modelo CSV — ' + FSpec.Titulo;
    Dlg.Filter := 'Arquivos CSV (*.csv)|*.csv|Todos os arquivos (*.*)|*.*';
    Dlg.DefaultExt := 'csv';
    Dlg.FileName := FSpec.Tabela + '_modelo.csv';
    if Dlg.Execute then
    begin
      ExportarModeloCSVTabela(FSpec, Dlg.FileName);
      MostrarStatus('Modelo salvo em ' + Dlg.FileName);
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmCrudFinalidade.LimparTabelaClick(Sender: TObject);
begin
  if ExecutarLimparTabelaDialog(Self, FSpec) then
  begin
    FModificado := False;
    FPrecisaRecarregar := False;
    CarregarGrade('');
    MostrarStatus('Tabela limpa.');
  end;
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

{ TfrmGerenciadorTabelas }

constructor TfrmGerenciadorTabelas.CreateGerenciador(AOwner: TComponent;
  const AChaveInicial: string);
var
  Topo, Direita, Rodape: TPanel;
  I: Integer;
  N: TTreeNode;
begin
  inherited CreateNew(AOwner);
  Caption := 'Cadastros — Tabelas de apoio das etiquetas';
  Position := poScreenCenter;
  BorderStyle := bsSizeable;
  SetBounds(0, 0, 900, 600);
  Constraints.MinWidth := 700;
  Constraints.MinHeight := 420;
  Font.Name := 'Segoe UI';
  Font.Size := 9;

  FTabelas := ListarTodasTabelasFinalidade;

  Topo := TPanel.Create(Self);
  Topo.Parent := Self;
  Topo.Align := alTop;
  Topo.Height := 44;
  Topo.BevelOuter := bvNone;

  with TLabel.Create(Self) do
  begin
    Parent := Topo;
    Caption := 'Localizar tabela:';
    SetBounds(16, 14, 100, 18);
  end;

  edFiltro := TEdit.Create(Self);
  edFiltro.Parent := Topo;
  edFiltro.SetBounds(120, 10, 320, 26);
  edFiltro.TextHint := 'Ex.: gôndola, crachá, tubo...';
  edFiltro.OnChange := @FiltroChange;

  Rodape := TPanel.Create(Self);
  Rodape.Parent := Self;
  Rodape.Align := alBottom;
  Rodape.Height := 50;
  Rodape.BevelOuter := bvNone;

  btnFechar := TButton.Create(Self);
  btnFechar.Parent := Rodape;
  btnFechar.Caption := 'Fechar';
  btnFechar.Width := 104;
  btnFechar.Align := alRight;
  btnFechar.BorderSpacing.Around := 9;
  btnFechar.Cancel := True;
  btnFechar.OnClick := @FecharClick;

  Direita := TPanel.Create(Self);
  Direita.Parent := Self;
  Direita.Align := alRight;
  Direita.Width := 330;
  Direita.BevelOuter := bvLowered;

  lblTabTitulo := TLabel.Create(Self);
  lblTabTitulo.Parent := Direita;
  lblTabTitulo.AutoSize := False;
  lblTabTitulo.WordWrap := True;
  lblTabTitulo.Font.Style := [fsBold];
  lblTabTitulo.Font.Size := 11;
  lblTabTitulo.SetBounds(14, 14, 300, 48);

  lblTabInfo := TLabel.Create(Self);
  lblTabInfo.Parent := Direita;
  lblTabInfo.AutoSize := False;
  lblTabInfo.WordWrap := True;
  lblTabInfo.SetBounds(14, 66, 300, 60);

  btnAbrir := TButton.Create(Self);
  btnAbrir.Parent := Direita;
  btnAbrir.Caption := 'Abrir registros';
  btnAbrir.Hint := 'Incluir, alterar e excluir registros (Enter ou duplo clique)';
  btnAbrir.ShowHint := True;
  btnAbrir.SetBounds(14, 136, 300, 34);
  btnAbrir.OnClick := @AbrirClick;

  btnImportar := TButton.Create(Self);
  btnImportar.Parent := Direita;
  btnImportar.Caption := 'Importar CSV...';
  btnImportar.SetBounds(14, 178, 146, 30);
  btnImportar.OnClick := @ImportarClick;

  btnExportar := TButton.Create(Self);
  btnExportar.Parent := Direita;
  btnExportar.Caption := 'Exportar CSV...';
  btnExportar.SetBounds(168, 178, 146, 30);
  btnExportar.OnClick := @ExportarClick;

  with TLabel.Create(Self) do
  begin
    Parent := Direita;
    AutoSize := False;
    WordWrap := True;
    Font.Color := clGrayText;
    SetBounds(14, 222, 300, 60);
    Caption := 'Para apagar todos os registros de uma tabela, abra os registros e use "Mais ▾ → Limpar tabela".';
  end;

  FArvore := TTreeView.Create(Self);
  FArvore.Parent := Self;
  FArvore.Align := alClient;
  FArvore.BorderSpacing.Around := 8;
  FArvore.ReadOnly := True;
  FArvore.HideSelection := False;
  FArvore.RowSelect := True;
  FArvore.OnSelectionChanged := @ArvoreSelectionChanged;
  FArvore.OnDblClick := @ArvoreDblClick;
  FArvore.OnKeyDown := @ArvoreKeyDown;

  CarregarContagens;
  MontarArvore;

  { Seleciona a tabela inicial, se informada }
  if AChaveInicial <> '' then
    for I := 0 to FArvore.Items.Count - 1 do
    begin
      N := FArvore.Items[I];
      if (N.Data <> nil) and SameText(FTabelas[PtrInt(N.Data) - 1].Chave, AChaveInicial) then
      begin
        N.Selected := True;
        Break;
      end;
    end;
  AtualizarDetalhe;
end;

procedure TfrmGerenciadorTabelas.CarregarContagens;
var
  I: Integer;
begin
  SetLength(FContagens, Length(FTabelas));
  for I := 0 to High(FTabelas) do
  begin
    FContagens[I] := -1;
    if BancoConectado then
      try
        FContagens[I] := ContarRegistrosTabela(GConexaoFinalidade, FTabelas[I]);
      except
        FContagens[I] := -1;
      end;
  end;
end;

function TfrmGerenciadorTabelas.TextoNo(Idx: Integer): string;
begin
  Result := FTabelas[Idx].Titulo;
  if FContagens[Idx] >= 0 then
    Result := Result + Format('  (%d)', [FContagens[Idx]]);
end;

procedure TfrmGerenciadorTabelas.AtualizarContagem(Idx: Integer);
begin
  if BancoConectado then
    try
      FContagens[Idx] := ContarRegistrosTabela(GConexaoFinalidade, FTabelas[Idx]);
    except
      FContagens[Idx] := -1;
    end;
  if FArvore.Selected <> nil then
    FArvore.Selected.Text := TextoNo(Idx);
  AtualizarDetalhe;
end;

procedure TfrmGerenciadorTabelas.MontarArvore;
var
  G, I: Integer;
  NoGrupo: TTreeNode;
  Filtro: string;
begin
  Filtro := LowerCase(Trim(edFiltro.Text));
  FArvore.Items.BeginUpdate;
  try
    FArvore.Items.Clear;
    for G := Low(GRUPOS_TABELA_FINALIDADE) to High(GRUPOS_TABELA_FINALIDADE) do
    begin
      NoGrupo := nil;
      for I := 0 to High(FTabelas) do
      begin
        if GrupoTabelaFinalidade(FTabelas[I]) <> GRUPOS_TABELA_FINALIDADE[G] then
          Continue;
        if (Filtro <> '') and (Pos(Filtro, LowerCase(FTabelas[I].Titulo)) = 0) and
           (Pos(Filtro, LowerCase(GRUPOS_TABELA_FINALIDADE[G])) = 0) then
          Continue;
        if NoGrupo = nil then
          NoGrupo := FArvore.Items.Add(nil, GRUPOS_TABELA_FINALIDADE[G]);
        { Data guarda índice + 1, para que nil continue indicando "nó de grupo" }
        FArvore.Items.AddChildObject(NoGrupo, TextoNo(I), Pointer(PtrInt(I + 1)));
      end;
      if NoGrupo <> nil then
        NoGrupo.Expanded := True;
    end;
  finally
    FArvore.Items.EndUpdate;
  end;
  if (FArvore.Selected = nil) and (FArvore.Items.Count > 1) then
    FArvore.Items[1].Selected := True;
end;

function TfrmGerenciadorTabelas.IndiceSelecionado: Integer;
begin
  Result := -1;
  if (FArvore.Selected <> nil) and (FArvore.Selected.Data <> nil) then
    Result := PtrInt(FArvore.Selected.Data) - 1;
end;

procedure TfrmGerenciadorTabelas.AtualizarDetalhe;
var
  Idx: Integer;
begin
  Idx := IndiceSelecionado;
  btnAbrir.Enabled := Idx >= 0;
  btnImportar.Enabled := Idx >= 0;
  btnExportar.Enabled := Idx >= 0;
  if Idx < 0 then
  begin
    lblTabTitulo.Caption := 'Selecione uma tabela';
    lblTabInfo.Caption := 'As tabelas guardam os registros usados na emissão de cada modelo de etiqueta.';
    lblTabInfo.Hint := '';
    Exit;
  end;
  lblTabTitulo.Caption := FTabelas[Idx].Titulo;
  if FContagens[Idx] >= 0 then
    lblTabInfo.Caption := Format('%d registro(s) salvo(s)' + sLineBreak + '%d campo(s) por registro',
      [FContagens[Idx], Length(FTabelas[Idx].Campos)])
  else
    lblTabInfo.Caption := 'Banco de dados desconectado.';
  lblTabInfo.Hint := 'Tabela no banco: ' + FTabelas[Idx].Tabela;
  lblTabInfo.ShowHint := True;
end;

procedure TfrmGerenciadorTabelas.FiltroChange(Sender: TObject);
begin
  MontarArvore;
  AtualizarDetalhe;
end;

procedure TfrmGerenciadorTabelas.ArvoreSelectionChanged(Sender: TObject);
begin
  AtualizarDetalhe;
end;

procedure TfrmGerenciadorTabelas.ArvoreDblClick(Sender: TObject);
begin
  if IndiceSelecionado >= 0 then
    AbrirClick(Sender);
end;

procedure TfrmGerenciadorTabelas.ArvoreKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (IndiceSelecionado >= 0) then
  begin
    AbrirClick(Sender);
    Key := 0;
  end;
end;

procedure TfrmGerenciadorTabelas.AbrirClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := IndiceSelecionado;
  if Idx < 0 then
    Exit;
  AbrirGerenciarRegistros(Self, FTabelas[Idx].Chave);
  AtualizarContagem(Idx);
end;

procedure TfrmGerenciadorTabelas.ImportarClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := IndiceSelecionado;
  if (Idx >= 0) and ExecutarImportarCSVDialog(Self, FTabelas[Idx]) then
    AtualizarContagem(Idx);
end;

procedure TfrmGerenciadorTabelas.ExportarClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := IndiceSelecionado;
  if Idx >= 0 then
    ExecutarExportarCSVDialog(Self, FTabelas[Idx]);
end;

procedure TfrmGerenciadorTabelas.FecharClick(Sender: TObject);
begin
  Close;
end;

{ TPainelBancoFinalidade }

constructor TPainelBancoFinalidade.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvLowered;
  Color := $F4EFE9;
  Height := 72;
  FIdCarregado := '';

  lblInfo := TLabel.Create(Self);
  lblInfo.Parent := Self;
  lblInfo.AutoSize := False;
  lblInfo.Font.Style := [fsBold];
  lblInfo.SetBounds(10, 8, 360, 18);
  lblInfo.Caption := 'Registros salvos:';

  cbRegistros := TComboBox.Create(Self);
  cbRegistros.Parent := Self;
  cbRegistros.Style := csDropDownList;
  cbRegistros.DropDownCount := 20;
  cbRegistros.SetBounds(10, 32, 260, 26);
  cbRegistros.OnChange := @SelecionarRegistroChange;

  btnSalvar := TButton.Create(Self);
  btnSalvar.Parent := Self;
  btnSalvar.Caption := 'Salvar na tabela';
  btnSalvar.Hint := 'Grava os dados da tela. Se um registro foi carregado, pergunta se deve atualizá-lo.';
  btnSalvar.ShowHint := True;
  btnSalvar.SetBounds(278, 31, 112, 28);
  btnSalvar.OnClick := @SalvarClick;

  btnCrud := TButton.Create(Self);
  btnCrud.Parent := Self;
  btnCrud.Caption := 'Gerenciar registros...';
  btnCrud.Hint := 'Pesquisar, incluir, alterar e excluir registros desta etiqueta';
  btnCrud.ShowHint := True;
  btnCrud.SetBounds(396, 31, 140, 28);
  btnCrud.OnClick := @CrudClick;

  btnMais := TButton.Create(Self);
  btnMais.Parent := Self;
  btnMais.Caption := 'Mais ▾';
  btnMais.Hint := 'Importar, exportar e limpar tabela';
  btnMais.ShowHint := True;
  btnMais.SetBounds(542, 31, 70, 28);
  btnMais.OnClick := @MaisClick;

  FMenuMais := TPopupMenu.Create(Self);
  CriarItemMenu(Self, FMenuMais, 'Importar CSV...', @ImportarClick);
  CriarItemMenu(Self, FMenuMais, 'Exportar CSV...', @ExportarClick);
  CriarItemMenu(Self, FMenuMais, '-', nil);
  CriarItemMenu(Self, FMenuMais, 'Limpar tabela (apagar todos)...', @LimparClick);
end;

function TPainelBancoFinalidade.ConexaoDisponivel: Boolean;
begin
  Result := FSpecValido and BancoConectado;
end;

procedure TPainelBancoFinalidade.DefinirFinalidade(const AChaveFinalidade: string);
begin
  FChaveFinalidade := AChaveFinalidade;
  FSpecValido := ObterTabelaFinalidade(AChaveFinalidade, FSpec);
  FIdCarregado := '';
  AtualizarLista;
end;

procedure TPainelBancoFinalidade.AtualizarLista;
var
  I, IdxSel: Integer;
  Resumo: string;
begin
  cbRegistros.Items.Clear;
  cbRegistros.Items.Add('(Selecionar registro salvo...)');
  SetLength(FLinhas, 0);

  if not FSpecValido then
  begin
    lblInfo.Caption := 'Registros salvos: tabela não configurada';
    cbRegistros.ItemIndex := 0;
    FIdCarregado := '';
    Exit;
  end;

  lblInfo.Hint := FSpec.Titulo + ' (tabela ' + FSpec.Tabela + ')';
  lblInfo.ShowHint := True;

  if not ConexaoDisponivel then
  begin
    lblInfo.Caption := 'Registros salvos: banco desconectado';
    cbRegistros.ItemIndex := 0;
    FIdCarregado := '';
    Exit;
  end;

  FLinhas := CarregarRegistrosTabela(GConexaoFinalidade, FSpec, '');
  lblInfo.Caption := Format('Registros salvos: %d', [Length(FLinhas)]);
  IdxSel := 0;
  for I := 0 to High(FLinhas) do
  begin
    Resumo := '#' + FLinhas[I].Id;
    if Length(FLinhas[I].Valores) > 0 then
      Resumo := Resumo + ' — ' + FLinhas[I].Valores[0];
    if (Length(FLinhas[I].Valores) > 1) and (FLinhas[I].Valores[1] <> '') then
      Resumo := Resumo + ' | ' + FLinhas[I].Valores[1];
    cbRegistros.Items.Add(Resumo);
    if (FIdCarregado <> '') and (FLinhas[I].Id = FIdCarregado) then
      IdxSel := I + 1;
  end;
  { Mantém selecionado o registro carregado, se ele ainda existir }
  if IdxSel = 0 then
    FIdCarregado := '';
  cbRegistros.ItemIndex := IdxSel;
end;

procedure TPainelBancoFinalidade.SelecionarRegistroChange(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := cbRegistros.ItemIndex - 1;
  if (Idx < 0) or (Idx > High(FLinhas)) then
  begin
    FIdCarregado := '';
    Exit;
  end;
  FIdCarregado := FLinhas[Idx].Id;
  if Assigned(FOnCarregar) then
    FOnCarregar(FLinhas[Idx].Valores);
end;

procedure TPainelBancoFinalidade.SalvarClick(Sender: TObject);
var
  Valores: TStringArray;
  NovoId: Int64;
  Atualizar: Boolean;
  Hora: string;
begin
  if not ConexaoDisponivel then
  begin
    MessageDlg('Banco de Dados', 'Banco de dados não conectado.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if not Assigned(FOnObter) then
    Exit;

  { Se os dados vieram de um registro salvo, pergunta se é para atualizá-lo }
  Atualizar := False;
  if FIdCarregado <> '' then
    case QuestionDlg('Salvar na tabela',
      'Os dados da tela vieram do registro #' + FIdCarregado + '.' + sLineBreak +
      'Deseja atualizar esse registro ou gravar um novo?',
      mtConfirmation,
      [mrYes, 'Atualizar #' + FIdCarregado, 'IsDefault', mrNo, 'Salvar como novo',
       mrCancel, 'Cancelar', 'IsCancel'], 0) of
      mrYes: Atualizar := True;
      mrNo: Atualizar := False;
    else
      Exit;
    end;

  FOnObter(Valores);
  try
    if Atualizar then
      AtualizarRegistroTabela(GConexaoFinalidade, FSpec, FIdCarregado, Valores)
    else
    begin
      NovoId := InserirRegistroTabela(GConexaoFinalidade, FSpec, Valores);
      FIdCarregado := IntToStr(NovoId);
    end;
    AtualizarLista;
    Hora := FormatDateTime('hh:nn', Now);
    if FIdCarregado <> '' then
    begin
      if Atualizar then
        lblInfo.Caption := lblInfo.Caption + '  ·  #' + FIdCarregado + ' atualizado às ' + Hora
      else
        lblInfo.Caption := lblInfo.Caption + '  ·  #' + FIdCarregado + ' incluído às ' + Hora;
    end;
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
    begin
      FOnCarregar(Valores);
      FIdCarregado := Dlg.IdSelecionado;
    end;
  finally
    Dlg.Free;
  end;
  AtualizarLista;
end;

procedure TPainelBancoFinalidade.MaisClick(Sender: TObject);
begin
  MostrarMenuAbaixo(FMenuMais, btnMais);
end;

procedure TPainelBancoFinalidade.Resize;
begin
  inherited Resize;
  if not Assigned(btnMais) then
    Exit;

  if ClientWidth >= 560 then
  begin
    lblInfo.SetBounds(10, 8, Max(120, ClientWidth - 20), 18);
    cbRegistros.SetBounds(10, 32, Max(120, ClientWidth - 362), 26);
    btnSalvar.SetBounds(cbRegistros.Left + cbRegistros.Width + 8, 31, 112, 28);
    btnCrud.SetBounds(btnSalvar.Left + btnSalvar.Width + 6, 31, 140, 28);
    btnMais.SetBounds(btnCrud.Left + btnCrud.Width + 6, 31, 70, 28);
  end
  else
  begin
    lblInfo.SetBounds(10, 8, Max(120, ClientWidth - 20), 18);
    cbRegistros.SetBounds(10, 30, Max(160, ClientWidth - 20), 26);
    btnSalvar.SetBounds(10, 62, 112, 28);
    btnCrud.SetBounds(128, 62, 140, 28);
    btnMais.SetBounds(274, 62, 70, 28);
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
  if ExecutarLimparTabelaDialog(Self, FSpec) then
  begin
    FIdCarregado := '';
    AtualizarLista;
  end;
end;

end.
