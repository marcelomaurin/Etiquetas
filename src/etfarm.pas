unit etfarm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  DBCtrls, StdCtrls, DBGrids, ComCtrls, DB, dmbase;

type

  { Tfrmetfarm }

  Tfrmetfarm = class(TForm)
    pnlTop: TPanel;
    pnlEdicao: TPanel;
    pnlPesquisa: TPanel;
    DBGrid1: TDBGrid;
    dsEtFarm: TDataSource;
    StatusBar1: TStatusBar;

    btnNovo: TBitBtn;
    btnEditar: TBitBtn;
    btnSalvar: TBitBtn;
    btnCancelar: TBitBtn;
    btnExcluir: TBitBtn;
    btnFechar: TBitBtn;

    lblID: TLabel;
    edID: TDBEdit;
    lblBarcode: TLabel;
    edBarcode: TDBEdit;
    lblRotulo01: TLabel;
    edRotulo01: TDBEdit;
    lblRotulo02: TLabel;
    edRotulo02: TDBEdit;

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
    procedure dsEtFarmStateChange(Sender: TObject);
    procedure dsEtFarmDataChange(Sender: TObject; Field: TField);
  private
    procedure AtualizaEstadoInterface;
    procedure AtualizaContadorRegistros;
  public

  end;

var
  frmetfarm: Tfrmetfarm;

implementation

{$R *.lfm}

{ Tfrmetfarm }

procedure Tfrmetfarm.FormCreate(Sender: TObject);
begin
  if (fdmbase = nil) then
    fdmbase := Tdmbase.Create(Application);

  if not fdmbase.zetqlab.Active then
    fdmbase.zetqlab.Open;

  dsEtFarm.DataSet := fdmbase.zetqlab;
end;

procedure Tfrmetfarm.FormShow(Sender: TObject);
begin
  AtualizaEstadoInterface;
  AtualizaContadorRegistros;
  if DBGrid1.CanFocus then
    DBGrid1.SetFocus;
end;

procedure Tfrmetfarm.AtualizaEstadoInterface;
var
  EmEdicao: Boolean;
  TemRegistros: Boolean;
begin
  EmEdicao := (dsEtFarm.DataSet <> nil) and (dsEtFarm.DataSet.State in [dsInsert, dsEdit]);
  TemRegistros := (dsEtFarm.DataSet <> nil) and (dsEtFarm.DataSet.Active) and (not dsEtFarm.DataSet.IsEmpty);

  btnNovo.Enabled := not EmEdicao;
  btnEditar.Enabled := (not EmEdicao) and TemRegistros;
  btnExcluir.Enabled := (not EmEdicao) and TemRegistros;
  btnSalvar.Enabled := EmEdicao;
  btnCancelar.Enabled := EmEdicao;
  btnFechar.Enabled := not EmEdicao;

  edRotulo01.ReadOnly := not EmEdicao;
  edRotulo02.ReadOnly := not EmEdicao;
  edBarcode.ReadOnly := not EmEdicao;

  if EmEdicao then
  begin
    edRotulo01.Color := clWindow;
    edRotulo02.Color := clWindow;
    edBarcode.Color := clWindow;
  end
  else
  begin
    edRotulo01.Color := clBtnFace;
    edRotulo02.Color := clBtnFace;
    edBarcode.Color := clBtnFace;
  end;

  pnlPesquisa.Enabled := not EmEdicao;
  DBGrid1.Enabled := not EmEdicao;

  if dsEtFarm.DataSet <> nil then
  begin
    case dsEtFarm.DataSet.State of
      dsInsert: StatusBar1.Panels[0].Text := 'Status: Inserindo novo registro...';
      dsEdit:   StatusBar1.Panels[0].Text := 'Status: Editando registro existente...';
      else      StatusBar1.Panels[0].Text := 'Status: Visualizacao';
    end;
  end;
end;

procedure Tfrmetfarm.AtualizaContadorRegistros;
begin
  if (dsEtFarm.DataSet <> nil) and (dsEtFarm.DataSet.Active) then
    StatusBar1.Panels[1].Text := Format('Total: %d registro(s)', [dsEtFarm.DataSet.RecordCount])
  else
    StatusBar1.Panels[1].Text := 'Total: 0 registro(s)';
end;

procedure Tfrmetfarm.btnNovoClick(Sender: TObject);
begin
  dsEtFarm.DataSet.Insert;
  if edRotulo01.CanFocus then
    edRotulo01.SetFocus;
end;

procedure Tfrmetfarm.btnEditarClick(Sender: TObject);
begin
  if not dsEtFarm.DataSet.IsEmpty then
  begin
    dsEtFarm.DataSet.Edit;
    if edRotulo01.CanFocus then
      edRotulo01.SetFocus;
  end;
end;

procedure Tfrmetfarm.btnSalvarClick(Sender: TObject);
begin
  if Trim(dsEtFarm.DataSet.FieldByName('rotulo01').AsString) = '' then
  begin
    MessageDlg('Atencao', 'O campo Rotulo 1 (Medicamento / Descricao) e obrigatorio.', mtWarning, [mbOK], 0);
    if edRotulo01.CanFocus then
      edRotulo01.SetFocus;
    Exit;
  end;

  if Trim(dsEtFarm.DataSet.FieldByName('barcode').AsString) = '' then
  begin
    MessageDlg('Atencao', 'O campo Codigo de Barras e obrigatorio.', mtWarning, [mbOK], 0);
    if edBarcode.CanFocus then
      edBarcode.SetFocus;
    Exit;
  end;

  dsEtFarm.DataSet.Post;
  AtualizaContadorRegistros;
  ShowMessage('Registro salvo com sucesso!');
end;

procedure Tfrmetfarm.btnCancelarClick(Sender: TObject);
begin
  dsEtFarm.DataSet.Cancel;
end;

procedure Tfrmetfarm.btnExcluirClick(Sender: TObject);
var
  Descricao: string;
begin
  if not dsEtFarm.DataSet.IsEmpty then
  begin
    Descricao := dsEtFarm.DataSet.FieldByName('rotulo01').AsString;
    if MessageDlg('Confirmacao de Exclusao',
      Format('Deseja realmente excluir o rotulo "%s"?' + sLineBreak + 'Esta acao nao podera ser desfeita.', [Descricao]),
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      dsEtFarm.DataSet.Delete;
      AtualizaContadorRegistros;
      ShowMessage('Registro excluido com sucesso.');
    end;
  end;
end;

procedure Tfrmetfarm.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure Tfrmetfarm.btnBuscarClick(Sender: TObject);
var
  Termo: string;
begin
  Termo := Trim(edBusca.Text);
  if Termo = '' then
  begin
    btnLimparClick(Sender);
    Exit;
  end;

  fdmbase.zetqlab.Filtered := False;
  fdmbase.zetqlab.Filter := Format('(rotulo01 LIKE ''%%%s%%'') OR (rotulo02 LIKE ''%%%s%%'') OR (barcode LIKE ''%%%s%%'')',
    [Termo, Termo, Termo]);
  fdmbase.zetqlab.Filtered := True;
  AtualizaContadorRegistros;
end;

procedure Tfrmetfarm.btnLimparClick(Sender: TObject);
begin
  edBusca.Clear;
  fdmbase.zetqlab.Filtered := False;
  fdmbase.zetqlab.Filter := '';
  AtualizaContadorRegistros;
end;

procedure Tfrmetfarm.edBuscaKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
  begin
    Key := #0;
    btnBuscarClick(Sender);
  end;
end;

procedure Tfrmetfarm.dsEtFarmStateChange(Sender: TObject);
begin
  AtualizaEstadoInterface;
end;

procedure Tfrmetfarm.dsEtFarmDataChange(Sender: TObject; Field: TField);
begin
  AtualizaEstadoInterface;
  AtualizaContadorRegistros;
end;

end.
