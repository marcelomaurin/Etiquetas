unit dmbase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, ZConnection, ZDataset;

type

  { TdmBase }

  TdmBase = class(TDataModule)
    zcon: TZConnection;
    zproduct: TZTable;
    zproductDetail01: TStringField;
    zproductDetail02: TStringField;
    zproductidproduto: TLongintField;
    zproductprice: TStringField;
    zproductproductDesc: TStringField;
    zproductproductDetail: TStringField;
    procedure DataModuleCreate(Sender: TObject);
  private

  public
    procedure opendb();
    procedure closedb();
    procedure product();

  end;

var
  fdmBase: TdmBase;

implementation

{$R *.lfm}

{ TdmBase }

procedure TdmBase.DataModuleCreate(Sender: TObject);
begin

end;

procedure TdmBase.opendb();
begin
  zcon.Disconnect;
  //zcon.Database:= ExtractFileDir(ApplicationName)+'\db\etiqueta.db';
  //zcon.LibraryLocation:= ExtractFileDir(ApplicationName)+'\win32\sqlite3.dll';
  zcon.Connect;
end;

procedure TdmBase.closedb();
begin
  zcon.Disconnect;
end;

procedure TdmBase.product();
begin
  if zcon.Connected then
  begin
    zproduct.Close;
    zproduct.open;
  end;
end;

end.

