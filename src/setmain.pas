//Objetivo: construir os parâmetros de setup da classe principal
//Criado por Marcelo Maurin Martins - modificado por ChatGPT
//Data: 07/02/2021

unit setmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, funcoes;

const
  filename = 'etiqueta.cfg';

type
  { TSetMain }

  TSetMain = class(TObject)
  public
    constructor create();
    destructor destroy();
  private
    arquivo : TStringList;
    ckdevice : boolean;
    FPosX : integer;
    FPosY : integer;
    FFixar : boolean;
    FStay : boolean;
    FLastFiles : String;
    FPATH : string;
    FHeight : integer;
    FWidth : integer;
    FSQLLITEDLL : string;
    FCSVFOLDER : String;
    FDB : string;
    // Novos parâmetros:
    FEMPRESA: string;
    FENDERECO1: string;
    FENDERECO2: string;
    procedure SetDevice(const Value: Boolean);
    procedure SetPOSX(value: integer);
    procedure SetPOSY(value: integer);
    procedure SetFixar(value: boolean);
    procedure SetStay(value: boolean);
    procedure SetLastFiles(value: string);
    procedure Default();
  public
    procedure SalvaContexto(flag: boolean);
    procedure CarregaContexto();
    procedure IdentificaArquivo(flag: boolean);
    property device : boolean read ckdevice write SetDevice;
    property posx : integer read FPosX write SetPOSX;
    property posy : integer read FPosY write SetPOSY;
    property fixar : boolean read FFixar write SetFixar;
    property stay : boolean read FStay write SetStay;
    property lastfiles: string read FLastFiles write SetLastFiles;
    property Height: integer read FHeight write FHeight;
    property Width : integer read FWidth write FWidth;
    property SQLLITEDLL: String read FSQLLITEDLL write FSQLLITEDLL;
    property CSVFOLDER: String read FCSVFOLDER write FCSVFOLDER;
    property db: String read Fdb write Fdb;
    // Novas propriedades:
    property EMPRESA: string read FEMPRESA write FEMPRESA;
    property ENDERECO1: string read FENDERECO1 write FENDERECO1;
    property ENDERECO2: string read FENDERECO2 write FENDERECO2;
  end;

var
  FSetMain: TSetMain;

implementation

procedure TSetMain.SetDevice(const Value: Boolean);
begin
  ckdevice := Value;
end;

// Valores default do código, incluindo os novos parâmetros
procedure TSetMain.Default();
var
  ProgramDataPath: String;
begin
  ckdevice := false;
  fixar := false;
  stay := false;
  fposx := 0;
  fposy := 0;
  // Valores padrão para os novos parâmetros
  FEMPRESA := '';
  FENDERECO1 := '';
  FENDERECO2 := '';

  ProgramDataPath := GetAppConfigDir(False); // Define a pasta global de dados
  FSQLLITEDLL := ExtractFilePath(ApplicationName) + '\sqlite\win64\sqlite3.dll';
  FDB := ExtractFilePath(ApplicationName) + '\db\etiqueta.db';
  FCSVFOLDER := ProgramDataPath + '\csv\etiquetas.csv';
end;

procedure TSetMain.SetPOSX(value: integer);
begin
  FPosX := value;
end;

procedure TSetMain.SetPOSY(value: integer);
begin
  FPosY := value;
end;

procedure TSetMain.SetFixar(value: boolean);
begin
  FFixar := value;
end;

procedure TSetMain.SetStay(value: boolean);
begin
  FStay := value;
end;

procedure TSetMain.SetLastFiles(value: string);
begin
  FLastFiles := value;
end;

procedure TSetMain.CarregaContexto();
var
  posicao: integer;
begin
  if BuscaChave(arquivo, 'DEVICE:', posicao) then
    ckdevice := (RetiraInfo(arquivo.Strings[posicao]) = '1');

  if BuscaChave(arquivo, 'POSX:', posicao) then
    FPosX := StrToInt(RetiraInfo(arquivo.Strings[posicao]));

  if BuscaChave(arquivo, 'POSY:', posicao) then
    FPosY := StrToInt(RetiraInfo(arquivo.Strings[posicao]));

  if BuscaChave(arquivo, 'FIXAR:', posicao) then
    FFixar := StrToBool(RetiraInfo(arquivo.Strings[posicao]));

  if BuscaChave(arquivo, 'STAY:', posicao) then
    FStay := StrToBool(RetiraInfo(arquivo.Strings[posicao]));

  if BuscaChave(arquivo, 'LASTFILES:', posicao) then
    FLastFiles := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'HEIGHT:', posicao) then
    FHeight := StrToInt(RetiraInfo(arquivo.Strings[posicao]));

  if BuscaChave(arquivo, 'WIDTH:', posicao) then
    FWidth := StrToInt(RetiraInfo(arquivo.Strings[posicao]));

  if BuscaChave(arquivo, 'SQLLITEDLL:', posicao) then
    FSQLLITEDLL := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'DB:', posicao) then
    FDB := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'CSVFOLDER:', posicao) then
    FCSVFOLDER := RetiraInfo(arquivo.Strings[posicao]);

  // Carrega os novos parâmetros:
  if BuscaChave(arquivo, 'EMPRESA:', posicao) then
    FEMPRESA := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'ENDERECO1:', posicao) then
    FENDERECO1 := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo, 'ENDERECO2:', posicao) then
    FENDERECO2 := RetiraInfo(arquivo.Strings[posicao]);
end;

procedure TSetMain.IdentificaArquivo(flag: boolean);
begin
  {$ifdef Darwin}
    FPath := GetAppConfigDir(false);
    if not(FileExists(FPATH)) then
      CreateDir(FPath);
  {$endif}
  {$IFDEF LINUX}
    FPath := GetAppConfigDir(false);
    if not(FileExists(FPATH)) then
      CreateDir(FPath);
  {$ENDIF}
  {$IFDEF WINDOWS}
    FPath := GetAppConfigDir(false);
    if not(FileExists(FPATH)) then
      CreateDir(FPath);
  {$ENDIF}

  if FileExists(FPath + filename) then
  begin
    arquivo.LoadFromFile(FPath + filename);
    CarregaContexto();
  end
  else
  begin
    Default();
    SalvaContexto(false);
  end;
end;

// Método construtor
constructor TSetMain.create();
begin
  arquivo := TStringList.Create();
  IdentificaArquivo(true);
end;

procedure TSetMain.SalvaContexto(flag: boolean);
begin
  arquivo.Clear;
  arquivo.Append('DEVICE:' + iif(ckdevice, '1', '0'));
  arquivo.Append('POSX:' + IntToStr(FPosX));
  arquivo.Append('POSY:' + IntToStr(FPosY));
  arquivo.Append('FIXAR:' + BoolToStr(FFixar));
  arquivo.Append('STAY:' + BoolToStr(FStay));
  arquivo.Append('LASTFILES:' + FLastFiles);
  arquivo.Append('HEIGHT:' + IntToStr(FHeight));
  arquivo.Append('WIDTH:' + IntToStr(FWidth));
  arquivo.Append('SQLLITEDLL:' + FSQLLITEDLL);
  arquivo.Append('CSVFOLDER:' + FCSVFOLDER);
  arquivo.Append('DB:' + FDB);
  // Grava os novos parâmetros:
  arquivo.Append('EMPRESA:' + FEMPRESA);
  arquivo.Append('ENDERECO1:' + FENDERECO1);
  arquivo.Append('ENDERECO2:' + FENDERECO2);

  arquivo.SaveToFile(FPath + filename);
end;

destructor TSetMain.destroy();
begin
  SalvaContexto(true);
  arquivo.Free;
  arquivo := nil;
end;

end.

