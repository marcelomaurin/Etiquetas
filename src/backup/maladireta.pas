unit MalaDireta;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Buttons, DBCtrls, StdCtrls, DBGrids, Menus, AnchorDockPanel, rxduallist,
  reletiq01, dmbase, DB, setmain;

type

  { TfrmMalaDireta }

  TfrmMalaDireta = class(TForm)
    btAddtoPrint: TSpeedButton;
    btAddtoPrint1: TSpeedButton;
    btAddtoPrint2: TSpeedButton;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    DBGrid4: TDBGrid;
    DBNavigator3: TDBNavigator;
    DBNavigator4: TDBNavigator;
    dsendereco: TDataSource;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    dsendsel: TDataSource;
    edPesqNome: TEdit;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    pcMalaDireta: TPageControl;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    SpeedButton1: TSpeedButton;
    btSeleciona: TSpeedButton;
    btDelete: TSpeedButton;
    Splitter1: TSplitter;
    tsTagType: TTabSheet;
    tsDadosProduto: TTabSheet;
    Wizzard: TTabSheet;
    procedure btAddtoPrint1Click(Sender: TObject);
    procedure btAddtoPrint2Click(Sender: TObject);
    procedure btAddtoPrint3Click(Sender: TObject);
    procedure btAddtoPrintClick(Sender: TObject);
    procedure edPesqNomeKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Panel12Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure btSelecionaClick(Sender: TObject);
    procedure btDeleteClick(Sender: TObject);
  private

  public
     procedure Pesquisar();
     procedure PrintEtiqueta();
  end;

var
  frmMalaDireta: TfrmMalaDireta;

implementation

{$R *.lfm}

{ TfrmMalaDireta }

procedure TfrmMalaDireta.SpeedButton1Click(Sender: TObject);
begin
  close;
end;

procedure TfrmMalaDireta.btSelecionaClick(Sender: TObject);
begin
  //Copiando registro
  if (dsendereco.DataSet.Active) then
  begin
       fdmbase.NewSelEndereco();
  end;
end;

procedure TfrmMalaDireta.btDeleteClick(Sender: TObject);
begin
  //Insere o registro
  if((dsendsel.DataSet.Active) and (dsendereco.DataSet.Active)) then
  begin
    dsendsel.DataSet.Delete;
  end;
end;

procedure TfrmMalaDireta.Pesquisar();
begin


   if(edPesqNome.text ='') then
   begin
     fdmbase.zEndereco.close;
     fdmbase.zEndereco.Filtered:=false;
     fdmbase.zEndereco.Filter:= '';
     fdmbase.zEndereco.open;
   end
   else
   begin
     fdmbase.zEndereco.close;
     fdmbase.zEndereco.Filtered:=true;
     fdmbase.zEndereco.Filter:= ' Nome like '+QuotedStr(edPesqNome.text);
     fdmbase.zEndereco.open;
   end;

end;

procedure TfrmMalaDireta.PrintEtiqueta();
begin
  frmreletiq01 := Tfrmreletiq01.Create(self);
  frmreletiq01.rltoname.Caption := FSetMain.EMPRESA;
  frmreletiq01.RLTOADDRESS01.Caption := FSetMain.ENDERECO1;
  frmreletiq01.RLTOADDRESS2.Caption := FSetMain.ENDERECO2;
  frmreletiq01.RLFROMName.caption := fdmBase.zselendereco.FieldByName('nome').AsString;
  frmreletiq01.RLFROMADDRESS1.caption := fdmBase.zselendereco.FieldByName('logradouro').AsString;
  frmreletiq01.RLFROMADDRESS2.caption := fdmBase.zselendereco.FieldByName('bairro').AsString+' '+fdmBase.zselendereco.FieldByName('cidade').AsString+fdmBase.zselendereco.FieldByName('cep').AsString;
  frmreletiq01.RLBARCODE.caption := fdmBase.zselendereco.FieldByName('BARCODE').AsString;
  frmreletiq01.RLRepGondola02.Preview(nil);
end;

procedure TfrmMalaDireta.FormCreate(Sender: TObject);
begin
  pcMalaDireta.ActivePage := Wizzard;
  fdmbase.SelEndereco();
  fdmbase.zselendereco.open;
end;

procedure TfrmMalaDireta.btAddtoPrintClick(Sender: TObject);
begin
  Pesquisar();
end;

procedure TfrmMalaDireta.btAddtoPrint1Click(Sender: TObject);
begin
  if(fdmbase.zselendereco.RecordCount<>0) then
  begin
      pcMalaDireta.ActivePage := tsDadosProduto;
  end
  else
  begin
    ShowMessage('Select at least one address for shipping');
  end;
end;

procedure TfrmMalaDireta.btAddtoPrint2Click(Sender: TObject);
begin
  if(fdmbase.zselendereco.RecordCount<>0) then
  begin
      pcMalaDireta.ActivePage := tsTagType;
  end
  else
  begin
    ShowMessage('Select at least one address for shipping');
  end;
end;

procedure TfrmMalaDireta.btAddtoPrint3Click(Sender: TObject);
begin

end;

procedure TfrmMalaDireta.edPesqNomeKeyPress(Sender: TObject; var Key: char);
begin
  if(key=#13) then
  begin
    Pesquisar();
  end;
end;

procedure TfrmMalaDireta.FormDestroy(Sender: TObject);
begin
 fdmbase.zendereco.close;
end;

procedure TfrmMalaDireta.FormShow(Sender: TObject);
begin
   Pesquisar();
end;

procedure TfrmMalaDireta.Image3Click(Sender: TObject);
begin
  PrintEtiqueta();
end;

procedure TfrmMalaDireta.Panel12Click(Sender: TObject);
begin

end;

end.

