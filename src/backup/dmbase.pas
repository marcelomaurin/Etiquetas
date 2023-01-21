unit dmbase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, csvdataset, ZConnection, ZDataset, setmain, dialogs,
  Interfaces;

type TCSVLayout = ( csv_Nada, csv_Produtos);

type

  { TdmBase }

  TdmBase = class(TDataModule)
    tbcsv: TCSVDataset;
    dsCSV: TDataSource;
    zcon: TZConnection;
    zenderecoBairro: TStringField;
    zenderecoCEP: TStringField;
    zenderecoCidade: TStringField;
    zenderecoDocumento: TStringField;
    zenderecoInd: TLargeintField;
    zenderecoLogradouro: TStringField;
    zenderecoNome: TStringField;
    zenderecoReferencia: TStringField;
    zenderecoTipoPessoa: TLargeintField;
    zproduct: TZTable;
    zendereco: TZTable;
    zselproduct: TZTable;
    zproductDetail01: TStringField;
    zproductDetail02: TStringField;
    zproductidproduto: TLongintField;
    zproductprice: TStringField;
    zproductproductDesc: TStringField;
    zproductproductDetail: TStringField;
    procedure DataModuleCreate(Sender: TObject);
  private
    function ImportReportDS(): boolean;
    function ImportEderecoDS(): boolean;

  public
    procedure opendb();
    procedure closedb();
    procedure product();
    procedure Endereco();
    procedure selproduct();
    procedure NewSel();
    procedure NewIns();
    function ImportCVSReport( filename: string) : boolean;
    function ImportCVSEndereco( filename: string) : boolean;
    function csvValidaLayout( tipo : TCSVLayout) : boolean;
    function csvValidaLayoutEndereco( tipo : TCSVLayout) : boolean;
    function dropproducts(): boolean;

  end;

var
  fdmBase: TdmBase;

implementation

{$R *.lfm}

{ TdmBase }

procedure TdmBase.DataModuleCreate(Sender: TObject);
begin
  zcon.Database :=  FSetMain.db;
  zcon.LibraryLocation:= FSetMain.SQLLITEDLL;

end;

function TdmBase.ImportReportDS: boolean;
var
  resultado :boolean;
begin
    resultado := true;
    tbcsv.first;
    //zproduct.open;
    product();
    while not tbcsv.EOF do
    begin
      try
        zproduct.Append();
        zproduct.FieldByName('productDesc').asstring := tbcsv.Fields[0].asstring;
        zproduct.FieldByName('productDetail').asstring := tbcsv.Fields[1].asstring;
        zproduct.FieldByName('Detail01').asstring := tbcsv.Fields[2].asstring;
        zproduct.FieldByName('Detail02').asstring := tbcsv.Fields[3].asstring;
        zproduct.FieldByName('price').asstring := tbcsv.Fields[4].asstring;

        zproduct.Post;
        tbcsv.next();

      except
        resultado := false;
      end;
    end;
    if resultado then ShowMessage('Success in CSV Import ');
    zproduct.Prior;
    zproduct.close;
    result := resultado;
end;

function TdmBase.ImportEderecoDS: boolean;
var
  resultado :boolean;
begin
    resultado := true;
    tbcsv.first;
    //zproduct.open;
    Endereco();
    while not tbcsv.EOF do
    begin
      try
        zendereco.Append();
        zendereco.FieldByName('Nome').asstring := tbcsv.Fields[0].asstring;
        zendereco.FieldByName('TipoPessoa').asstring := tbcsv.Fields[1].asstring;
        zendereco.FieldByName('Documento').asstring := tbcsv.Fields[2].asstring;
        zendereco.FieldByName('Logradouro').asstring := tbcsv.Fields[3].asstring;
        zendereco.FieldByName('Bairro').asstring := tbcsv.Fields[4].asstring;
        zendereco.FieldByName('Cidade').asstring := tbcsv.Fields[5].asstring;
        zendereco.FieldByName('CEP').asstring := tbcsv.Fields[6].asstring;
        zendereco.FieldByName('Referencia').asstring := tbcsv.Fields[7].asstring;
        zendereco.Post;
        tbcsv.next();

      except
        resultado := false;
      end;
    end;
    if resultado then ShowMessage('Success in CSV Import ');
    zendereco.Prior;
    zendereco.close;
    result := resultado;
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

procedure TdmBase.Endereco;
begin
  if zcon.Connected then
  begin
    zendereco.Close;
    zendereco.open;

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
  zselproduct.fieldbyname('productDesc').asstring := zproduct.fieldbyname('productDesc').asstring;
  zselproduct.fieldbyname('productDetail').asstring := zproduct.fieldbyname('productDetail').asstring;
  zselproduct.fieldbyname('Detail01').asstring := zproduct.fieldbyname('Detail01').asstring;
  zselproduct.fieldbyname('Detail02').asstring := zproduct.fieldbyname('Detail02').asstring;
  zselproduct.fieldbyname('price').asstring := zproduct.fieldbyname('price').asstring;
  zselproduct.Post;
end;

procedure TdmBase.NewIns;
begin
  zproduct.Insert();
  zproduct.fieldbyname('productDesc').asstring := 'New product';
  zproduct.fieldbyname('productDetail').asstring := 'Product Detail';
  zproduct.fieldbyname('Detail01').asstring := 'Detail 01';
  zproduct.fieldbyname('Detail02').asstring := 'Detail 02';
  zproduct.fieldbyname('price').asstring := 'R$ 1.00';
  zproduct.Post;
end;

function TdmBase.ImportCVSReport(filename: string): boolean;
var resultado: boolean;
begin
   resultado := false;
   if FileExists(filename) then
   begin
       try
        tbcsv.LoadFromCSVFile(filename);
        tbcsv.Open;
        if (csvValidaLayoutEndereco(csv_Produtos)) then
        begin
          if ImportReportDS() then
          begin

          end
          else
          begin

          end;
        end
        else
        begin
          showmessage('Layout CSV not valid!');
        end;

        tbcsv.close;

        resultado := true;

       finally
       end;

   end
   else
   begin
     showmessage('File not exist');
   end;
   result := resultado;
end;

function TdmBase.ImportCVSEndereco(filename: string): boolean;
var resultado: boolean;
begin
resultado := false;
if FileExists(filename) then
begin
    try
     tbcsv.LoadFromCSVFile(filename);
     tbcsv.Open;
     if (csvValidaLayout(csv_Produtos)) then
     begin
       if ImportReportDS() then
       begin

       end
       else
       begin

       end;
     end
     else
     begin
       showmessage('Layout CSV not valid!');
     end;

     tbcsv.close;

     resultado := true;

    finally
    end;

end
else
begin
  showmessage('File not exist');
end;
result := resultado;
end;

function TdmBase.csvValidaLayout(tipo: TCSVLayout): boolean;
var
   resultado : boolean;
begin
    resultado := false;
    //ShowMessage(inttostr(tbcsv.Fields.Count));
    if  (tbcsv.Fields.Count = 5) then
    begin
       resultado := true;
    end
    else
    begin
      showmessage('Invalid CSV fields number');
    end;
    result := resultado;
end;

function TdmBase.csvValidaLayoutEndereco(tipo: TCSVLayout): boolean;
var
   resultado : boolean;
begin
    resultado := false;
    //ShowMessage(inttostr(tbcsv.Fields.Count));
    if  (tbcsv.Fields.Count = 5) then
    begin
       resultado := true;
    end
    else
    begin
      showmessage('Invalid CSV fields number');
    end;
    result := resultado;
end;


function TdmBase.dropproducts: boolean;
var
   resultado : boolean;
begin
  resultado := false;
  try
    zproduct.Delete;

  finally;
    resultado := true;
  end;

  result := resultado;
end;


end.

