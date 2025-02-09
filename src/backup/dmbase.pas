unit dmbase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, csvdataset, ZConnection, ZDataset, ZAbstractRODataset,
  ZSqlUpdate, setmain, dialogs, Interfaces;

type TCSVLayout = ( csv_Nada, csv_Produtos, csv_Endereco, csv_etqlab);

type

  { TdmBase }

  TdmBase = class(TDataModule)
    tbcsv: TCSVDataset;
    dsCSV: TDataSource;
    zcon: TZConnection;
    zetqlab: TZTable;
    zetqlabbarcode: TZRawStringField;
    zetqlabid: TZInt64Field;
    zetqlabrotulo01: TZRawStringField;
    zetqlabrotulo02: TZRawStringField;
    zselendereco: TZTable;
    zEnderecoBairro: TZRawStringField;
    zEnderecoCEP: TZRawStringField;
    zEnderecoCidade: TZRawStringField;
    zEnderecoDocumento: TZRawStringField;
    zEnderecoInd: TZInt64Field;
    zEnderecoLogradouro: TZRawStringField;
    zEnderecoNome: TZRawStringField;
    zEnderecoReferencia: TZRawStringField;
    zEnderecoTipoPessoa: TZInt64Field;
    zproduct: TZTable;
    zqryaux: TZQuery;
    zseletqlab: TZTable;
    zselenderecoBairro: TStringField;
    zselenderecoBARCODE: TStringField;
    zselenderecoCEP: TStringField;
    zselenderecoCidade: TStringField;
    zselenderecodescprod: TStringField;
    zselenderecoDocumento: TStringField;
    zselenderecoInd: TLargeintField;
    zselenderecoLogradouro: TStringField;
    zselenderecoNome: TStringField;
    zselenderecoQRCODE: TStringField;
    zselenderecoReferencia: TStringField;
    zselenderecoTipoPessoa: TLargeintField;
    zseletqlabbarcode: TZRawStringField;
    zseletqlabid: TZInt64Field;
    zseletqlabrotulo01: TZRawStringField;
    zseletqlabrotulo02: TZRawStringField;
    zselproduct: TZTable;
    zproductDetail01: TStringField;
    zproductDetail02: TStringField;
    zproductidproduto: TLongintField;
    zproductprice: TStringField;
    zproductproductDesc: TStringField;
    zproductproductDetail: TStringField;
    zendereco: TZTable;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    function ImportReportDS(): boolean;
    function ImportEderecoDS(): boolean;
    function ImportEtqLabDS(): boolean;

  public
    procedure opendb();
    procedure closedb();
    procedure product();
    procedure Endereco();
    procedure SelEtqLab();
    procedure SelEndereco();
    procedure selproduct();
    procedure delallselectproducts();
    procedure NewSel();
    procedure NewIns();
    function ImportCVSReport( tipo: TCSVLayout; filename: string) : boolean;
    function csvValidaLayout( tipo : TCSVLayout) : boolean;
    function dropproducts(): boolean;
    procedure config();
    procedure NewSelEndereco();
    procedure NewSelEtqLab();
  end;

var
  fdmBase: TdmBase;

implementation

{$R *.lfm}

{ TdmBase }

uses main;

procedure TdmBase.DataModuleCreate(Sender: TObject);
begin
  zcon.Database :=  FSetMain.db;

  if(FileExists(FSetMain.SQLLITEDLL)) then
  begin
    zcon.LibraryLocation:= FSetMain.SQLLITEDLL;
  end
  else
  begin
    ShowMessage('Library path invalid!');
    frmmain.config();
  end;

  if(FileExists(FSetMain.DB)) then
  begin
    zcon.LibraryLocation:= FSetMain.SQLLITEDLL;
  end
  else
  begin
    ShowMessage('Database path invalid!');
    frmmain.config();
  end;

end;

procedure TdmBase.DataModuleDestroy(Sender: TObject);
begin
  zcon.Disconnect;
end;

function TdmBase.ImportReportDS: boolean;
var
  resultado :boolean;
begin
    zproduct.close;
    zproduct.Filtered:= false;
    zproduct.open;

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
        zproduct.ApplyUpdates;
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
  resultado: boolean;
begin
  resultado := true;
  try
    tbcsv.Open;
    tbcsv.First;

    while not tbcsv.EOF do
    begin
      try
        zqryaux.SQL.Text := 'INSERT INTO "endereco" ' +
                            '("Nome", "TipoPessoa", "Documento", "Logradouro", "Bairro", "Cidade", ' +
                            '"CEP", "Referencia") ' +
                            'VALUES (:Nome, :TipoPessoa, :Documento, :Logradouro, :Bairro, :Cidade, :CEP, :Referencia)';
        zqryaux.ParamByName('Nome').AsString := tbcsv.Fields[0].AsString;
        zqryaux.ParamByName('TipoPessoa').AsInteger := StrToInt(tbcsv.Fields[1].AsString);
        zqryaux.ParamByName('Documento').AsString := tbcsv.Fields[2].AsString;
        zqryaux.ParamByName('Logradouro').AsString := tbcsv.Fields[3].AsString;
        zqryaux.ParamByName('Bairro').AsString := tbcsv.Fields[4].AsString;
        zqryaux.ParamByName('Cidade').AsString := tbcsv.Fields[5].AsString;
        zqryaux.ParamByName('CEP').AsString := tbcsv.Fields[6].AsString;
        zqryaux.ParamByName('Referencia').AsString := tbcsv.Fields[7].AsString;

        zqryaux.ExecSQL;
      except
        on E: Exception do
        begin
          ShowMessage('Erro ao importar registro: ' + E.Message);
          resultado := false;
        end;
      end;
      tbcsv.Next;
    end;

    if resultado then
      ShowMessage('Importação do CSV realizada com sucesso.')
    else
      ShowMessage('A importação do CSV terminou com erros em alguns registros.');
  finally
    tbcsv.Close;
  end;

  Result := resultado;
end;

function TdmBase.ImportEtqLabDS(): boolean;
var
  resultado: boolean;
begin
  resultado := true;
  try
    tbcsv.Open;
    tbcsv.First;

    while not tbcsv.EOF do
    begin
      try
        zqryaux.SQL.Text := 'INSERT INTO "etqlab" ' +
                            '("rotulo01", "rotulo02", "barcode") ' +
                            'VALUES (:rotulo01, :rotulo02, :barcode)';
        zqryaux.Prepare;
        zqryaux.ParamByName('rotulo01').AsString := tbcsv.Fields[0].AsString;
        zqryaux.ParamByName('rotulo02').AsString := tbcsv.Fields[1].AsString;
        zqryaux.ParamByName('barcode').AsString := tbcsv.Fields[2].AsString;
        zqryaux.ExecSQL;
        zqryaux.ApplyUpdates;
      except
        on E: Exception do
        begin
          ShowMessage('Erro ao importar registro: ' + E.Message);
          resultado := false;
        end;
      end;
      tbcsv.Next;
    end;

    if resultado then
      ShowMessage('Importação do CSV realizada com sucesso.')
    else
      ShowMessage('A importação do CSV terminou com erros em alguns registros.');
  finally
    tbcsv.Close;
  end;

  Result := resultado;
end;



procedure TdmBase.opendb();
begin
  if zcon.Connected then
    zcon.Disconnect;

  // Define os caminhos do banco de dados e da biblioteca SQLite
  zcon.Database := FSetMain.DB;
  zcon.LibraryLocation := FSetMain.SQLLITEDLL;

  // Verifica se o arquivo do banco de dados e a biblioteca SQLite existem
  if not FileExists(zcon.Database) or not FileExists(zcon.LibraryLocation) then
  begin
    ShowMessage('Arquivo de banco de dados ou biblioteca SQLite não encontrados. Configurando...');
    config; // Chama a função de configuração se os arquivos não existirem
    Exit;   // Sai do procedimento para evitar erros na conexão
  end;

  // Conexão com o banco de dados se os arquivos existirem
  if FileExists(zcon.LibraryLocation) then
  begin
    try
      zcon.Connect;
      if zcon.Connected then
      begin
        selproduct();
        Endereco();
      end
      else
      begin
        ShowMessage('Falha ao conectar ao banco de dados');
      end;
    except
      ShowMessage('Falha ao conectar ao banco de dados');
    end;
  end
  else
  begin
    ShowMessage('Biblioteca SQLite não encontrada');
  end;
end;


procedure TdmBase.closedb();
begin
  zselproduct.close;
  //zcon.Disconnect;
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
  if NOT zcon.Connected then
  begin
    //zendereco.Close;
    zendereco.open;
  end;
  //zEndereco.Refresh;

end;

procedure TdmBase.SelEtqLab();
begin
  if NOT zcon.Connected then
  begin
    //zendereco.Close;
    zetqlab.open;
  end;
  //zEndereco.Refresh;
end;

procedure TdmBase.SelEndereco();
begin
  if NOT zcon.Connected then
  begin
    //zendereco.Close;
    zselendereco.open;
  end;
  //zEndereco.Refresh;

end;

procedure TdmBase.selproduct();
begin
  if zselproduct.Active then
  begin
    zselproduct.Close;
  end;
  zselproduct.open;


end;

procedure TdmBase.delallselectproducts();
begin
  zqryaux.close;
  zqryaux.sql.Text := 'delete from selproduct ';
  zqryaux.ExecSQL;
  zselproduct.Refresh;
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

function TdmBase.ImportCVSReport(tipo: TCSVLayout; filename: string): boolean;
var resultado: boolean;
begin
   resultado := false;
   if FileExists(filename) then
   begin
       try
        tbcsv.LoadFromCSVFile(filename);
        tbcsv.Open;
        if (tipo = csv_Produtos) then
        begin
          if (csvValidaLayout(csv_Produtos)) then
          begin
            if ImportReportDS() then
            begin
                resultado := true;
            end
            else
            begin
              resultado := false;
            end;
          end
          else
          begin
            showmessage('Layout CSV not valid!');
            resultado := false;
          end;
        end;
        if (tipo = csv_Endereco) then
        begin
          if (csvValidaLayout(csv_Endereco)) then
          begin
            if ImportEderecoDS() then
            begin
              resultado := true;
            end
            else
            begin
                ShowMessage('Fail in Import CSV');
                resultado := false;
            end;
          end
          else
          begin
            showmessage('Layout CSV not valid!');
            resultado := false;
          end;
        end;
        if (tipo = csv_etqlab) then
        begin
          if (csvValidaLayout(csv_etqlab)) then
          begin
            if ImportEtqLabDS() then
            begin
              resultado := true;
            end
            else
            begin
                ShowMessage('Fail in Import CSV');
                resultado := false;
            end;
          end
          else
          begin
            showmessage('Layout CSV not valid!');
            resultado := false;
          end;
        end;
        tbcsv.close;

        //resultado := true;

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
    if tipo = csv_Produtos then
    begin
      //ShowMessage(inttostr(tbcsv.Fields.Count));
      if  (tbcsv.Fields.Count = 5) then
      begin
         resultado := true;
      end
      else
      begin
        showmessage('Invalid CSV fields number');
      end;
    end;
    if tipo = csv_Endereco then
    begin
      //ShowMessage(inttostr(tbcsv.Fields.Count));
      if  (tbcsv.Fields.Count = 8) then
      begin
         resultado := true;
      end
      else
      begin
        showmessage('Invalid CSV fields number');
      end;

    end;
    if tipo = csv_etqlab then
    begin
      //ShowMessage(inttostr(tbcsv.Fields.Count));
      if  (tbcsv.Fields.Count = 3) then
      begin
         resultado := true;
      end
      else
      begin
        showmessage('Invalid CSV fields number');
      end;
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

procedure TdmBase.config();
begin
  frmmain.config();
end;

procedure TdmBase.NewSelEndereco();
begin
  if (not zselendereco.Active) then
  begin
    zselendereco.Open;
  end;
  zselendereco.Insert;
  zselendereco.FieldByName('Nome').AsString       := zendereco.FieldByName('Nome').AsString;
  zselendereco.FieldByName('TipoPessoa').AsInteger := zendereco.FieldByName('TipoPessoa').AsInteger;
  zselendereco.FieldByName('Documento').AsString   := zendereco.FieldByName('Documento').AsString;
  zselendereco.FieldByName('Logradouro').AsString  := zendereco.FieldByName('Logradouro').AsString;
  zselendereco.FieldByName('Bairro').AsString      := zendereco.FieldByName('Bairro').AsString;
  zselendereco.FieldByName('Cidade').AsString      := zendereco.FieldByName('Cidade').AsString;
  zselendereco.FieldByName('CEP').AsString         := zendereco.FieldByName('CEP').AsString;
  zselendereco.FieldByName('Referencia').AsString  := zendereco.FieldByName('Referencia').AsString;

  // Caso seja necessário, você pode preencher os campos adicionais da tabela selendereco:
  zselendereco.FieldByName('BARCODE').AsString := '';
  zselendereco.FieldByName('QRCODE').AsString  := '';
  zselendereco.FieldByName('descprod').AsString  := '';

  zselendereco.Post;
end;

procedure TdmBase.NewSelEtqLab();
begin
   if (not zseletqlab.Active) then
  begin
    zseletqlab.Open;
  end;
  zseletqlab.Insert;
  zseletqlab.FieldByName('rotulo01').AsString := zetqlab.FieldByName('rotulo01').AsString;
  zseletqlab.FieldByName('rotulo02').AsString := zetqlab.FieldByName('rotulo02').AsString;
  zseletqlab.FieldByName('barcode').AsString := zetqlab.FieldByName('barcode').AsString;
  zseletqlab.Post;
end;


end.

