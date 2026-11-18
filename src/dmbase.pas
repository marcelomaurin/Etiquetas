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
    function FindTemplateDatabase(): string;
    function ResolveSQLiteLibrary(): string;
    procedure EnsureSchema();

  public
    function EnsureLocalDatabase(const ADestino: string = ''): boolean;
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

uses main, FileUtil, tabelafinalidade;

function TdmBase.FindTemplateDatabase(): string;
var
  AppDir: string;
  Candidatos: array[0..2] of string;
  I: Integer;
begin
  Result := '';
  AppDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  Candidatos[0] := AppDir + 'db' + PathDelim + 'etiqueta.db';
  Candidatos[1] := ExpandFileName(AppDir + '..' + PathDelim + 'db' + PathDelim + 'etiqueta.db');
  Candidatos[2] := IncludeTrailingPathDelimiter(GetAppConfigDir(True)) + 'db' + PathDelim + 'etiqueta.db';

  for I := Low(Candidatos) to High(Candidatos) do
  begin
    if FileExists(Candidatos[I]) then
      Exit(Candidatos[I]);
  end;
end;

function TdmBase.ResolveSQLiteLibrary(): string;
var
  AppDir: string;
  Candidatos: array[0..2] of string;
  I: Integer;
begin
  Result := Trim(FSetMain.SQLLITEDLL);
  if (Result <> '') and FileExists(Result) then
    Exit;

  {$IFDEF WINDOWS}
  AppDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  {$IFDEF WIN64}
  Candidatos[0] := AppDir + 'sqlite\win64\sqlite3.dll';
  Candidatos[2] := AppDir + 'libs\sqlite\win64\sqlite3.dll';
  {$ELSE}
  Candidatos[0] := AppDir + 'sqlite\win32\sqlite3.dll';
  Candidatos[2] := AppDir + 'libs\sqlite\win32\sqlite3.dll';
  {$ENDIF}
  Candidatos[1] := AppDir + 'sqlite3.dll';

  for I := Low(Candidatos) to High(Candidatos) do
  begin
    if FileExists(Candidatos[I]) then
    begin
      FSetMain.SQLLITEDLL := Candidatos[I];
      Exit(Candidatos[I]);
    end;
  end;
  {$ELSE}
  if Result = '' then
    Result := 'libsqlite3.so';
  {$ENDIF}
end;

function TdmBase.EnsureLocalDatabase(const ADestino: string = ''): boolean;
var
  TargetDB, DirDB, TemplateDB: string;
begin
  TargetDB := Trim(ADestino);
  if TargetDB = '' then
    TargetDB := Trim(FSetMain.DB);
  if TargetDB = '' then
  begin
    TargetDB := BancoLocalPadrao;
    FSetMain.DB := TargetDB;
  end;

  DirDB := ExtractFilePath(TargetDB);
  if (DirDB <> '') and (not DirectoryExists(DirDB)) then
  begin
    if not ForceDirectories(DirDB) then
      Exit(False);
  end;

  if not FileExists(TargetDB) then
  begin
    TemplateDB := FindTemplateDatabase();
    if (TemplateDB <> '') and (not SameText(TemplateDB, TargetDB)) and FileExists(TemplateDB) then
      CopyFile(TemplateDB, TargetDB);
  end;

  Result := (DirDB = '') or DirectoryExists(DirDB);
end;

procedure TdmBase.EnsureSchema();
const
  DDLSelecao: array[0..2] of string = (
    'CREATE TABLE IF NOT EXISTS selproduct (' +
    '  idproduto INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  productDesc char(20) not null,' +
    '  productDetail char(40),' +
    '  Detail01 char(20),' +
    '  Detail02 char(20),' +
    '  price char(20)' +
    ')',
    'CREATE TABLE IF NOT EXISTS selendereco (' +
    '  Ind INTEGER PRIMARY KEY,' +
    '  Nome var(40) NOT NULL,' +
    '  TipoPessoa INTEGER NOT NULL,' +
    '  Documento char(40),' +
    '  Logradouro char(40),' +
    '  Bairro char(40),' +
    '  Cidade char(40),' +
    '  CEP char(20),' +
    '  Referencia char(40),' +
    '  BARCODE STRING(20),' +
    '  QRCODE STRING(200),' +
    '  descprod STRING(200)' +
    ')',
    'CREATE TABLE IF NOT EXISTS seletqlab (' +
    '  id INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  rotulo01 STRING(60),' +
    '  rotulo02 STRING(60),' +
    '  barcode STRING(20)' +
    ')'
  );
var
  Q: TZQuery;
  I: Integer;
begin
  if not zcon.Connected then
    Exit;

  CriarTodasTabelasFinalidade(zcon);

  Q := TZQuery.Create(nil);
  try
    Q.Connection := zcon;
    for I := Low(DDLSelecao) to High(DDLSelecao) do
    begin
      Q.SQL.Text := DDLSelecao[I];
      Q.ExecSQL;
    end;
  finally
    Q.Free;
  end;
end;

procedure TdmBase.DataModuleCreate(Sender: TObject);
begin
  GConexaoFinalidade := zcon;
  EnsureLocalDatabase(FSetMain.DB);
  zcon.Database := FSetMain.db;
  zcon.LibraryLocation := ResolveSQLiteLibrary();
end;

procedure TdmBase.DataModuleDestroy(Sender: TObject);
begin
  if GConexaoFinalidade = zcon then
    GConexaoFinalidade := nil;
  zcon.Disconnect;
end;

function TdmBase.ImportReportDS: boolean;
var
  resultado :boolean;
  emTransacao: boolean;
begin
    zproduct.close;
    zproduct.Filtered:= false;
    zproduct.open;

    resultado := true;
    tbcsv.first;
    product();
    emTransacao := zcon.Connected and (not zcon.InTransaction);
    if emTransacao then
      zcon.StartTransaction;
    try
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
          tbcsv.next();
        end;
      end;
      if emTransacao then
        zcon.Commit;
    except
      if emTransacao then
        zcon.Rollback;
      resultado := false;
    end;
    if resultado then ShowMessage('Importação do CSV de produtos concluída com sucesso.');
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

  if not EnsureLocalDatabase(FSetMain.DB) then
  begin
    ShowMessage('Não foi possível criar a pasta do banco de dados (' + ExtractFilePath(FSetMain.DB) + '). Configurando...');
    config;
    Exit;
  end;

  // Define os caminhos do banco de dados e da biblioteca SQLite
  zcon.Database := FSetMain.DB;
  zcon.LibraryLocation := ResolveSQLiteLibrary();

  {$IFDEF WINDOWS}
  if (zcon.LibraryLocation = '') or (not FileExists(zcon.LibraryLocation)) then
  begin
    ShowMessage('Biblioteca SQLite não encontrada. Configurando...');
    config;
    Exit;
  end;
  {$ENDIF}

  try
    zcon.Connect;
    if zcon.Connected then
    begin
      EnsureSchema();
      selproduct();
      Endereco();
    end
    else
    begin
      ShowMessage('Falha ao conectar ao banco de dados');
    end;
  except
    on E: Exception do
      ShowMessage('Falha ao conectar ao banco de dados: ' + E.Message);
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
  if zcon.Connected then
  begin
    zendereco.Close;
    zendereco.open;
  end;
end;

procedure TdmBase.SelEtqLab();
begin
  if zcon.Connected then
  begin
    zetqlab.Close;
    zetqlab.open;
  end;
end;

procedure TdmBase.SelEndereco();
begin
  if zcon.Connected then
  begin
    zselendereco.Close;
    zselendereco.open;
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

