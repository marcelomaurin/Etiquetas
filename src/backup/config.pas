unit config;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  Buttons, ComCtrls, ExtCtrls, rxfolderlister, rxtoolbar, setmain, fileutil,
  PrintersDlgs;

type

  { Tfrmconfig }

  Tfrmconfig = class(TForm)
    btDelete: TBitBtn;
    btDelete1: TBitBtn;
    btSave: TBitBtn;
    edDB: TFileNameEdit;
    edDLL: TFileNameEdit;
    edEndereco1: TEdit;
    edSerial: TEdit;
    edPessoa: TEdit;
    edPessoa1: TEdit;
    edEndereco2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    PrinterSetupDialog1: TPrinterSetupDialog;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    tsconn: TTabSheet;
    tsLocation: TTabSheet;
    procedure btDelete1Click(Sender: TObject);
    procedure btDeleteClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure btSalvarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public
    procedure CreateDB(local: String; destino : String);
    procedure DropDB(destino: string);

  end;

var
  frmconfig: Tfrmconfig;

implementation

{$R *.lfm}

{ Tfrmconfig }

procedure Tfrmconfig.FormShow(Sender: TObject);
begin
  // Carrega os valores dos campos a partir do FSetMain
  edDLL.Text     := FSetMain.SQLLITEDLL;
  edDB.Text      := FSetMain.db;
  edPessoa.Text  := FSetMain.EMPRESA;    // Novo: EMPRESA
  edEndereco1.Text := FSetMain.ENDERECO1;  // Novo: ENDERECO1
  edEndereco2.Text := FSetMain.ENDERECO2;  // Novo: ENDERECO2

end;

procedure Tfrmconfig.CreateDB(local: String; destino: String);
begin
  {$IFDEF WINDOWS}
    CopyFile(local+'etiqueta.db',destino);
  {$ENDIF}
  {$IFDEF LINUX}
    CopyFile(local+'etiqueta.db',destino);
  {$ENDIF}
end;

procedure Tfrmconfig.DropDB(destino: string);
begin
  if(FileExists(destino)) then
  begin
    DeleteFile(destino);
    showmessage('Database deleted');
  end
  else
  begin
    showmessage('Database not exist!');
  end;
end;

procedure Tfrmconfig.btSalvarClick(Sender: TObject);
begin


end;

procedure Tfrmconfig.btSaveClick(Sender: TObject);
begin
  if not FileExists(edDB.text) then
  begin
   {$IFDEF WINDOWS}
      CreateDB(ExtractFilePath(application.exename)+'db\',edDB.text);
   {$ENDIF}
   {$IFDEF LINUX}
      CreateDB(ExtractFilePath(application.exename)+'db\',edDB.text);
   {$ENDIF}
  end;
  FSetMain.SQLLITEDLL:= edDLL.Text;
  FSetMain.db         := edDB.Text;
  FSetMain.EMPRESA    := edPessoa.Text;    // Novo: EMPRESA
  FSetMain.ENDERECO1  := edEndereco1.Text; // Novo: ENDERECO1
  FSetMain.ENDERECO2  := edEndereco2.Text; // Novo: ENDERECO2
  FSetMain.SalvaContexto(false);
  close;
end;

procedure Tfrmconfig.btDeleteClick(Sender: TObject);
begin
  if FileExists(edDB.text) then
  begin
   {$IFDEF WINDOWS}
      DropDB(edDB.text);
   {$ENDIF}
   {$IFDEF LINUX}
      DropDB(edDB.text);
   {$ENDIF}
  end
   else
  begin
    showmessage('Database not exist!');
  end;

end;

procedure Tfrmconfig.btDelete1Click(Sender: TObject);
begin
  PrinterSetupDialog1.Execute;
end;

end.

