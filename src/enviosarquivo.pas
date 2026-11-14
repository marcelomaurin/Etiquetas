unit enviosarquivo;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, zipper;

const LimiteEtiqueta = 32 * 1024 * 1024;

type
  TArquivoEnvio = class
  private
    FSaida: TMemoryStream;
    procedure CriarStream(Sender: TObject; var Stream: TStream; Item: TFullZipFileEntry);
    procedure FecharStream(Sender: TObject; var Stream: TStream; Item: TFullZipFileEntry);
  public
    class function Aceito(const Nome: string): Boolean;
    class procedure ListarZIP(const Caminho: string; Lista: TStrings);
    procedure Carregar(const Caminho, EntradaZIP: string; Destino: TStream);
    class function Formato(Dados: TStream): string;
  end;

implementation

type
  TStreamEtiqueta = class(TMemoryStream)
    function Write(const Buffer; Count: LongInt): LongInt; override;
  end;

function TStreamEtiqueta.Write(const Buffer; Count: LongInt): LongInt;
begin
  if (Count < 0) or (Position + Count > LimiteEtiqueta) then
    raise Exception.Create('Arquivo descompactado maior que 32 MB.');
  Result := inherited Write(Buffer, Count);
end;

class function TArquivoEnvio.Aceito(const Nome: string): Boolean;
var E: string;
begin
  E := LowerCase(ExtractFileExt(Nome));
  Result := (E = '.pdf') or (E = '.zpl') or (E = '.txt') or (E = '.prn');
end;

class procedure TArquivoEnvio.ListarZIP(const Caminho: string; Lista: TStrings);
var Z: TUnZipper; I: Integer;
begin
  Lista.Clear;
  Z := TUnZipper.Create;
  try
    Z.FileName := Caminho;
    Z.Examine;
    if Z.Entries.Count > 2000 then raise Exception.Create('ZIP com excesso de entradas.');
    for I := 0 to Z.Entries.Count - 1 do
      if Aceito(Z.Entries[I].ArchiveFileName) and not Z.Entries[I].IsDirectory
        and (Z.Entries[I].Size <= LimiteEtiqueta) then
        Lista.Add(Z.Entries[I].ArchiveFileName);
  finally
    Z.Free;
  end;
end;

procedure TArquivoEnvio.CriarStream(Sender: TObject; var Stream: TStream; Item: TFullZipFileEntry);
begin
  if Item.Size > LimiteEtiqueta then raise Exception.Create('Arquivo maior que 32 MB.');
  { Extract to memory only: archive paths are never written to the filesystem. }
  FSaida := TStreamEtiqueta.Create;
  Stream := FSaida;
end;

procedure TArquivoEnvio.FecharStream(Sender: TObject; var Stream: TStream; Item: TFullZipFileEntry);
begin
  Stream := nil; // owned by Carregar, including when decompression fails
end;

procedure TArquivoEnvio.Carregar(const Caminho, EntradaZIP: string; Destino: TStream);
var Z: TUnZipper; F: TFileStream; L: TStringList;
begin
  Destino.Size := 0;
  Destino.Position := 0;
  if LowerCase(ExtractFileExt(Caminho)) = '.zip' then
  begin
    if not Aceito(EntradaZIP) then raise Exception.Create('Selecione um PDF ou arquivo ZPL do ZIP.');
    Z := TUnZipper.Create;
    L := TStringList.Create;
    FSaida := nil;
    try
      L.Add(EntradaZIP);
      Z.OnCreateStream := @CriarStream;
      Z.OnDoneStream := @FecharStream;
      Z.UnZipFiles(Caminho, L);
      if not Assigned(FSaida) then raise Exception.Create('Arquivo não encontrado no ZIP.');
      if FSaida.Size > LimiteEtiqueta then raise Exception.Create('Arquivo maior que 32 MB.');
      FSaida.Position := 0;
      Destino.CopyFrom(FSaida, FSaida.Size);
    finally
      FSaida.Free;
      FSaida := nil;
      L.Free;
      Z.Free;
    end;
  end
  else
  begin
    if not Aceito(Caminho) then raise Exception.Create('Use PDF, ZPL, TXT ou ZIP.');
    F := TFileStream.Create(Caminho, fmOpenRead or fmShareDenyWrite);
    try
      if F.Size > LimiteEtiqueta then raise Exception.Create('Arquivo maior que 32 MB.');
      Destino.CopyFrom(F, F.Size);
    finally
      F.Free;
    end;
  end;
  Destino.Position := 0;
  Formato(Destino);
end;

class function TArquivoEnvio.Formato(Dados: TStream): string;
var S: RawByteString;
begin
  if (Dados.Size = 0) or (Dados.Size > LimiteEtiqueta) then
    raise Exception.Create('Arquivo vazio ou maior que 32 MB.');
  SetLength(S, Dados.Size);
  Dados.Position := 0;
  Dados.ReadBuffer(S[1], Length(S));
  Dados.Position := 0;
  if Copy(S, 1, 5) = '%PDF-' then Exit('PDF');
  if (Pos('^XA', S) > 0) and (Pos('^XZ', S) > Pos('^XA', S)) then Exit('ZPL');
  raise Exception.Create('Conteúdo inválido. Importe o PDF original ou um arquivo com comandos ZPL (^XA ... ^XZ).');
end;

end.
