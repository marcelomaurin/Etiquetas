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
    zselproduct: TZTable;
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
    procedure selproduct();
    procedure NewSel();

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
  selproduct();
end;

procedure TdmBase.closedb();
begin
  zselproduct.close;
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

procedure TdmBase.selproduct();
begin
  if zcon.Connected then
  begin
    zselproduct.Close;
    zselproduct.open;
  end;

end;

procedure TdmBase.NewSel();
begin
  zselproduct.Insert();
  zselproduct.fieldbyname('productDesc').asstring := 'New product';
  zselproduct.fieldbyname('productDetail').asstring := 'Product Detail';
  zselproduct.fieldbyname('Detail01').asstring := 'Detail 01';
  zselproduct.fieldbyname('Detail02').asstring := 'Detail 02';
  zselproduct.fieldbyname('price').asstring := 'R$ 1.00';
  zselproduct.Post;
end;

end.

