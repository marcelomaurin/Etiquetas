unit mercadolivre;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, ExtCtrls, Dialogs,
  Printers, PrintersDlgs, LCLIntf, enviosarquivo
  {$IFDEF WINDOWS}, Windows, WinSpool{$ENDIF};

type
  TfrmMercadoLivre = class(TForm)
  private
    FTipo: Integer;
    FCaminho, FTemporarios: TStringList;
    FArquivo: TArquivoEnvio;
    FDados: TMemoryStream;
    FLista: TListBox;
    FStatus: TLabel;
    FResumo: TMemo;
    FAcao: TButton;
    procedure Importar(Sender: TObject);
    procedure Selecionar(Sender: TObject);
    procedure Executar(Sender: TObject);
    procedure Ajuda(Sender: TObject);
  public
    constructor CreateParaImpressora(AOwner: TComponent; Tipo: Integer);
    destructor Destroy; override;
  end;

implementation

constructor TfrmMercadoLivre.CreateParaImpressora(AOwner: TComponent; Tipo: Integer);
var L: TLabel; B: TButton; P: TPanel;
begin
  inherited CreateNew(AOwner, 1);
  Caption := 'Mercado Livre · importar etiqueta de envio';
  Position := poOwnerFormCenter;
  SetBounds(0, 0, 820, 660);
  Constraints.MinWidth := 720;
  Constraints.MinHeight := 600;
  Font.Name := 'Segoe UI';
  Font.Size := 10;
  Color := $FAF8F5;
  FTipo := Tipo;
  FArquivo := TArquivoEnvio.Create;
  FDados := TMemoryStream.Create;
  FCaminho := TStringList.Create;
  FTemporarios := TStringList.Create;
  P := TPanel.Create(Self);
  P.Parent := Self;
  P.Align := alTop;
  P.Height := 190;
  P.BevelOuter := bvNone;
  L := TLabel.Create(Self);
  L.Parent := P;
  L.SetBounds(24, 20, 740, 34);
  L.Font.Size := 19;
  L.Font.Style := [fsBold];
  L.Caption := 'Importe a etiqueta original da sua venda';
  L := TLabel.Create(Self);
  L.Parent := P;
  L.AutoSize := False;
  L.WordWrap := True;
  L.SetBounds(24, 65, 730, 70);
  L.Caption := '1. Baixe a etiqueta nas vendas do Mercado Livre.' + LineEnding
    + '2. Importe o PDF ou o ZIP / ZPL / TXT da impressora térmica.' + LineEnding
    + '3. Abra o PDF para imprimir ou envie o ZPL para uma Zebra compatível.';
  B := TButton.Create(Self);
  B.Parent := P;
  B.SetBounds(24, 143, 220, 34);
  B.Caption := 'Importar arquivo de etiqueta';
  B.OnClick := @Importar;
  B := TButton.Create(Self);
  B.Parent := P;
  B.SetBounds(256, 143, 230, 34);
  B.Caption := 'Instruções do Mercado Livre';
  B.OnClick := @Ajuda;
  P := TPanel.Create(Self);
  P.Parent := Self;
  P.Align := alBottom;
  P.Height := 124;
  P.BevelOuter := bvNone;
  FStatus := TLabel.Create(Self);
  FStatus.Parent := P;
  FStatus.SetBounds(24, 8, 740, 60);
  FStatus.AutoSize := False;
  FStatus.WordWrap := True;
  FStatus.Caption := 'Nenhum arquivo importado. Etiqueta de envio Brasil: normalmente 100 x 150 mm. '
    + 'Bobinas de 58 / 80 mm não comportam esse formato; use uma Zebra de 100 mm ou PDF em A4.';
  FAcao := TButton.Create(Self);
  FAcao.Parent := P;
  FAcao.SetBounds(24, 78, 300, 34);
  FAcao.Caption := 'Selecione uma etiqueta';
  FAcao.Enabled := False;
  FAcao.OnClick := @Executar;
  FLista := TListBox.Create(Self);
  FLista.Parent := Self;
  FLista.Align := alLeft;
  FLista.Width := 300;
  FLista.BorderSpacing.Around := 20;
  FLista.OnClick := @Selecionar;
  FResumo := TMemo.Create(Self);
  FResumo.Parent := Self;
  FResumo.Align := alClient;
  FResumo.BorderSpacing.Around := 20;
  FResumo.ReadOnly := True;
  FResumo.ScrollBars := ssAutoBoth;
  FResumo.Lines.Text := 'PDF: abre no leitor de PDF instalado para conferir e imprimir.' + LineEnding + LineEnding
    + 'ZPL: mantém os comandos originais e envia à impressora escolhida, sem redesenhar a etiqueta.' + LineEnding + LineEnding
    + 'ZIP: lista os PDFs e arquivos de etiqueta; selecione a etiqueta, não a lista de postagem.' + LineEnding + LineEnding
    + 'A importação usa arquivos já baixados. Não conecta sua conta nem gera frete ou rastreamento.';
end;

destructor TfrmMercadoLivre.Destroy;
begin
  { PDF viewers may read lazily; retain the temporary PDF until OS temp cleanup. }
  FTemporarios.Free;
  FCaminho.Free;
  FDados.Free;
  FArquivo.Free;
  inherited Destroy;
end;

procedure TfrmMercadoLivre.Importar(Sender: TObject);
var D: TOpenDialog;
begin
  D := TOpenDialog.Create(Self);
  try
    D.Filter := 'Etiquetas Mercado Livre|*.pdf;*.zip;*.zpl;*.txt;*.prn';
    if not D.Execute then Exit;
    FAcao.Enabled := False;
    FDados.Clear;
    FLista.Clear;
    FCaminho.Clear;
    FCaminho.Add(D.FileName);
    try
      if LowerCase(ExtractFileExt(D.FileName)) = '.zip' then
        TArquivoEnvio.ListarZIP(D.FileName, FLista.Items)
      else FLista.Items.Add(ExtractFileName(D.FileName));
      if FLista.Count = 0 then raise Exception.Create('O ZIP não contém etiquetas PDF, ZPL ou TXT compatíveis.');
      FLista.ItemIndex := 0;
      Selecionar(Self);
    except
      on E: Exception do FStatus.Caption := 'Não foi possível importar: ' + E.Message;
    end;
  finally
    D.Free;
  end;
end;

procedure TfrmMercadoLivre.Selecionar(Sender: TObject);
var Formato, Entrada: string;
begin
  FAcao.Enabled := False;
  if (FLista.ItemIndex < 0) or (FCaminho.Count = 0) then Exit;
  Entrada := FLista.Items[FLista.ItemIndex];
  try
    FArquivo.Carregar(FCaminho[0], Entrada, FDados);
    Formato := TArquivoEnvio.Formato(FDados);
    if Formato = 'PDF' then
    begin
      FResumo.Lines.Text := Entrada + LineEnding + LineEnding
        + 'PDF original pronto para abrir no leitor instalado.' + LineEnding + LineEnding
        + 'No leitor, confira todas as páginas, escolha a impressora e mantenha a escala original (100%). '
        + 'Configure o papel conforme o documento. Uma PLP ou resumo do ZIP não substitui a etiqueta de envio.';
      FAcao.Caption := 'Abrir PDF para conferir e imprimir';
      FAcao.Enabled := True;
    end
    else
    begin
      FResumo.Lines.Text := Entrada + LineEnding + LineEnding
        + 'Etiqueta térmica original pronta para uma impressora Zebra compatível com ZPL.' + LineEnding + LineEnding
        + 'O arquivo será enviado inteiro, com os códigos de rastreamento e o tamanho originais.' + LineEnding + LineEnding
        + 'Configure o rolo e calibre a impressora conforme a etiqueta baixada. No Brasil, o formato padrão de envio é 100 x 150 mm.'
        + LineEnding + LineEnding + 'Para conferir uma prévia visual no computador, importe a versão PDF da etiqueta.';
      FAcao.Caption := 'Enviar ZPL à impressora Zebra';
      FAcao.Enabled := FTipo = 0;
    end;
    FStatus.Caption := Formato + ' importado · ' + IntToStr(FDados.Size) + ' bytes · conteúdo original preservado.';
    if (Formato = 'ZPL') and (FTipo <> 0) then
      FStatus.Caption := 'ZPL requer Zebra compatível. Volte ao início e selecione Zebra / rolo, ou importe a versão PDF.';
  except
    on E: Exception do
    begin
      FDados.Clear;
      FResumo.Clear;
      FStatus.Caption := E.Message;
    end;
  end;
end;

procedure TfrmMercadoLivre.Executar(Sender: TObject);
var
  Caminho: string;
  D: TPrintDialog;
  {$IFDEF WINDOWS}
  H: THandle;
  Doc: DOC_INFO_1W;
  Nome: UnicodeString;
  Enviado, Posicao: DWORD;
  {$ENDIF}
begin
  if not FAcao.Enabled then Exit;
  if TArquivoEnvio.Formato(FDados) = 'PDF' then
  begin
    Caminho := SysUtils.GetTempFileName(GetTempDir(False), 'mle');
    if not RenameFile(Caminho, Caminho + '.pdf') then
      raise Exception.Create('Não foi possível preparar o PDF temporário.');
    Caminho := Caminho + '.pdf';
    FDados.SaveToFile(Caminho);
    FTemporarios.Add(Caminho);
    if not OpenDocument(Caminho) then ShowMessage('Não foi possível abrir o PDF. Instale ou configure um leitor de PDF.');
    Exit;
  end;
  if FTipo <> 0 then Exit;
  {$IFDEF WINDOWS}
  D := TPrintDialog.Create(Self);
  try
    if not D.Execute then Exit;
    Nome := UTF8Decode(Printer.Printers[Printer.PrinterIndex]);
    if not OpenPrinterW(PWideChar(Nome), @H, nil) then RaiseLastOSError;
    try
      FillChar(Doc, SizeOf(Doc), 0);
      Doc.pDocName := 'Etiqueta Mercado Livre';
      Doc.pDatatype := 'RAW';
      if StartDocPrinterW(H, 1, @Doc) = 0 then RaiseLastOSError;
      try
        if not StartPagePrinter(H) then RaiseLastOSError;
        Posicao := 0;
        while Posicao < FDados.Size do
        begin
          if not WritePrinter(H, PByte(FDados.Memory) + Posicao, FDados.Size - Posicao, @Enviado) then RaiseLastOSError;
          if Enviado = 0 then raise Exception.Create('A impressora não recebeu os dados.');
          Inc(Posicao, Enviado);
        end;
        if not EndPagePrinter(H) then RaiseLastOSError;
        if not EndDocPrinter(H) then RaiseLastOSError;
      except
        AbortPrinter(H);
        raise;
      end;
    finally
      ClosePrinter(H);
    end;
    FStatus.Caption := 'Etiqueta enviada à fila de impressão: ' + UTF8Encode(Nome);
  finally
    D.Free;
  end;
  {$ELSE}
  ShowMessage('Envio direto ZPL disponível no Windows. Use a versão PDF neste sistema.');
  {$ENDIF}
end;

procedure TfrmMercadoLivre.Ajuda(Sender: TObject);
begin
  OpenURL('https://vendedores.mercadolivre.com.br/aprender/nota/como-imprimir-as-etiquetas-de-envios?guideKeyId=GE80');
end;

end.
