unit dmbase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, ZConnection, ZDataset, setmain, dialogs,Interfaces;

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
  //zcon.Database:= ExtractFilePath(ApplicationName)+'\db\etiqueta.db';
  zcon.Database:= FSetMain.DB;

  //zcon.LibraryLocation:= ExtractFilePath(ApplicationName)+'\sqlite\win64\sqlite3.dll';
  zcon.LibraryLocation:= FSetMain.SQLLITEDLL;
  if FileExists(zcon.LibraryLocation) then
  begin
    zcon.Connect;
    if zcon.Connected then
    begin
        selproduct();
    end
     else
    begin
      ShowMessage('Fail to connect in database');
    end;

  end
  else
  begin
    ShowMessage('Not found lib sqllite');

  end;
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
  if zselproduct.Active then
  begin
    zselproduct.Close;
  end;
  zselproduct.open;


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

