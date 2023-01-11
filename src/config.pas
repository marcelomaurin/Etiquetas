unit config;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  Buttons, rxfolderlister, rxtoolbar, setmain, fileutil, PrintersDlgs;

type

  { Tfrmconfig }

  Tfrmconfig = class(TForm)
    btDelete1: TBitBtn;
    btSave: TBitBtn;
    btDelete: TBitBtn;
    edDLL: TFileNameEdit;
    edDB: TFileNameEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    PrinterSetupDialog1: TPrinterSetupDialog;
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
  edDLL.text := FSetMain.SQLLITEDLL;
  edDB.text := FSetMain.db;

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
  FSetMain.db:= edDB.text;
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

