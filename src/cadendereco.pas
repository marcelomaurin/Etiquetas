unit cadendereco;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  DBCtrls, StdCtrls, DBGrids, ComCtrls, DB, dmbase;

type

  { TfrmCadEndereco }

  TfrmCadEndereco = class(TForm)
    pnlTop: TPanel;
    pnlEdicao: TPanel;
    pnlPesquisa: TPanel;
    DBGrid1: TDBGrid;
    dsEndereco: TDataSource;
    StatusBar1: TStatusBar;

    btnNovo: TBitBtn;
    btnEditar: TBitBtn;
    btnSalvar: TBitBtn;
    btnCancelar: TBitBtn;
    btnExcluir: TBitBtn;
    btnFechar: TBitBtn;

    lblInd: TLabel;
    edInd: TDBEdit;
    lblTipoPessoa: TLabel;
    cbTipoPessoa: TComboBox;
    lblDocumento: TLabel;
    edDocumento: TDBEdit;
    lblCEP: TLabel;
    edCEP: TDBEdit;

    lblNome: TLabel;
    edNome: TDBEdit;
    lblLogradouro: TLabel;
    edLogradouro: TDBEdit;
    lblBairro: TLabel;
    edBairro: TDBEdit;
    lblCidade: TLabel;
    edCidade: TDBEdit;
    lblReferencia: TLabel;
    edReferencia: TDBEdit;

    lblBusca: TLabel;
    edBusca: TEdit;
    btnBuscar: TBitBtn;
    btnLimpar: TBitBtn;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure edBuscaKeyPress(Sender: TObject; var Key: char);
    procedure dsEnderecoStateChange(Sender: TObject);
    procedure dsEnderecoDataChange(Sender: TObject; Field: TField);
  private
    procedure AtualizaEstadoInterface;
    procedure AtualizaContadorRegistros;
  public

  end;

var
  frmCadEndereco: TfrmCadEndereco;

implementation

{$R *.lfm}

{ TfrmCadEndereco }

procedure TfrmCadEndereco.FormCreate(Sender: TObject);
begin
  if (fdmbase = nil) then
    fdmbase := Tdmbase.Create(Application);

  if not fdmbase.zendereco.Active then
    fdmbase.zendereco.Open;

  dsEndereco.DataSet := fdmbase.zendereco;
end;

procedure TfrmCadEndereco.FormShow(Sender: TObject);
begin
  AtualizaEstadoInterface;
  AtualizaContadorRegistros;
  if DBGrid1.CanFocus then
    DBGrid1.SetFocus;
end;

procedure TfrmCadEndereco.AtualizaEstadoInterface;
var
  EmEdicao: Boolean;
  TemRegistros: Boolean;
begin
  EmEdicao := (dsEndereco.DataSet <> nil) and (dsEndereco.DataSet.State in [dsInsert, dsEdit]);
  TemRegistros := (dsEndereco.DataSet <> nil) and (dsEndereco.DataSet.Active) and (not dsEndereco.DataSet.IsEmpty);

  btnNovo.Enabled := not EmEdicao;
  btnEditar.Enabled := (not EmEdicao) and TemRegistros;
  btnExcluir.Enabled := (not EmEdicao) and TemRegistros;
  btnSalvar.Enabled := EmEdicao;
  btnCancelar.Enabled := EmEdicao;
  btnFechar.Enabled := not EmEdicao;

  edNome.ReadOnly := not EmEdicao;
  cbTipoPessoa.Enabled := EmEdicao;
  edDocumento.ReadOnly := not EmEdicao;
  edLogradouro.ReadOnly := not EmEdicao;
  edBairro.ReadOnly := not EmEdicao;
  edCidade.ReadOnly := not EmEdicao;
  edCEP.ReadOnly := not EmEdicao;
  edReferencia.ReadOnly := not EmEdicao;

  if EmEdicao then
  begin
    edNome.Color := clWindow;
    cbTipoPessoa.Color := clWindow;
    edDocumento.Color := clWindow;
    edLogradouro.Color := clWindow;
    edBairro.Color := clWindow;
    edCidade.Color := clWindow;
    edCEP.Color := clWindow;
    edReferencia.Color := clWindow;
  end
  else
  begin
    edNome.Color := clBtnFace;
    cbTipoPessoa.Color := clBtnFace;
    edDocumento.Color := clBtnFace;
    edLogradouro.Color := clBtnFace;
    edBairro.Color := clBtnFace;
    edCidade.Color := clBtnFace;
    edCEP.Color := clBtnFace;
    edReferencia.Color := clBtnFace;
  end;

  pnlPesquisa.Enabled := not EmEdicao;
  DBGrid1.Enabled := not EmEdicao;

  if dsEndereco.DataSet <> nil then
  begin
    case dsEndereco.DataSet.State of
      dsInsert: StatusBar1.Panels[0].Text := 'Status: Inserindo novo endereco...';
      dsEdit:   StatusBar1.Panels[0].Text := 'Status: Editando endereco existente...';
      else      StatusBar1.Panels[0].Text := 'Status: Visualizacao';
    end;
  end;
end;

procedure TfrmCadEndereco.AtualizaContadorRegistros;
begin
  if (dsEndereco.DataSet <> nil) and (dsEndereco.DataSet.Active) then
    StatusBar1.Panels[1].Text := Format('Total: %d endereco(s)', [dsEndereco.DataSet.RecordCount])
  else
    StatusBar1.Panels[1].Text := 'Total: 0 endereco(s)';
end;

procedure TfrmCadEndereco.btnNovoClick(Sender: TObject);
begin
  dsEndereco.DataSet.Insert;
  cbTipoPessoa.ItemIndex := 0;
  if edNome.CanFocus then
    edNome.SetFocus;
end;

procedure TfrmCadEndereco.btnEditarClick(Sender: TObject);
begin
  if not dsEndereco.DataSet.IsEmpty then
  begin
    dsEndereco.DataSet.Edit;
    if edNome.CanFocus then
      edNome.SetFocus;
  end;
end;

procedure TfrmCadEndereco.btnSalvarClick(Sender: TObject);
begin
  if Trim(dsEndereco.DataSet.FieldByName('Nome').AsString) = '' then
  begin
    MessageDlg('Atencao', 'O campo Nome / Razao Social e obrigatorio.', mtWarning, [mbOK], 0);
    if edNome.CanFocus then
      edNome.SetFocus;
    Exit;
  end;

  if cbTipoPessoa.ItemIndex >= 0 then
    dsEndereco.DataSet.FieldByName('TipoPessoa').AsInteger := cbTipoPessoa.ItemIndex
  else
    dsEndereco.DataSet.FieldByName('TipoPessoa').AsInteger := 0;

  dsEndereco.DataSet.Post;
  AtualizaContadorRegistros;
  ShowMessage('Endereco salvo com sucesso!');
end;

procedure TfrmCadEndereco.btnCancelarClick(Sender: TObject);
begin
  dsEndereco.DataSet.Cancel;
end;

procedure TfrmCadEndereco.btnExcluirClick(Sender: TObject);
var
  Descricao: string;
begin
  if not dsEndereco.DataSet.IsEmpty then
  begin
    Descricao := dsEndereco.DataSet.FieldByName('Nome').AsString;
    if MessageDlg('Confirmacao de Exclusao',
      Format('Deseja realmente excluir o endereco de "%s"?' + sLineBreak + 'Esta acao nao podera ser desfeita.', [Descricao]),
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      dsEndereco.DataSet.Delete;
      AtualizaContadorRegistros;
      ShowMessage('Endereco excluido com sucesso.');
    end;
  end;
end;

procedure TfrmCadEndereco.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCadEndereco.btnBuscarClick(Sender: TObject);
var
  Termo: string;
begin
  Termo := Trim(edBusca.Text);
  if Termo = '' then
  begin
    btnLimparClick(Sender);
    Exit;
  end;

  fdmbase.zendereco.Filtered := False;
  fdmbase.zendereco.Filter := Format('(Nome LIKE ''%%%s%%'') OR (Documento LIKE ''%%%s%%'') OR (Cidade LIKE ''%%%s%%'') OR (Logradouro LIKE ''%%%s%%'') OR (Bairro LIKE ''%%%s%%'')',
    [Termo, Termo, Termo, Termo, Termo]);
  fdmbase.zendereco.Filtered := True;
  AtualizaContadorRegistros;
end;

procedure TfrmCadEndereco.btnLimparClick(Sender: TObject);
begin
  edBusca.Clear;
  fdmbase.zendereco.Filtered := False;
  fdmbase.zendereco.Filter := '';
  AtualizaContadorRegistros;
end;

procedure TfrmCadEndereco.edBuscaKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
  begin
    Key := #0;
    btnBuscarClick(Sender);
  end;
end;

procedure TfrmCadEndereco.dsEnderecoStateChange(Sender: TObject);
begin
  AtualizaEstadoInterface;
end;

procedure TfrmCadEndereco.dsEnderecoDataChange(Sender: TObject; Field: TField);
begin
  if (dsEndereco.DataSet <> nil) and dsEndereco.DataSet.Active and (not dsEndereco.DataSet.IsEmpty) then
  begin
    if dsEndereco.DataSet.FieldByName('TipoPessoa').AsInteger in [0, 1] then
      cbTipoPessoa.ItemIndex := dsEndereco.DataSet.FieldByName('TipoPessoa').AsInteger
    else
      cbTipoPessoa.ItemIndex := 0;
  end;
  AtualizaEstadoInterface;
  AtualizaContadorRegistros;
end;

end.
