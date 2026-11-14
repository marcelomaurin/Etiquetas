unit qrmidia;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, StdCtrls, ExtCtrls,
  ExtDlgs, Dialogs, Spin, Printers, PrintersDlgs, ubarcodes, URIParser, LCLIntf, LCLType,
  qrdesenho;

type
  TfrmQRMidia = class(TForm)
  private
    FTipo: Integer;
    FLink, FTitulo, FChamada: TEdit;
    FTexto: TMemo;
    FFinalidade, FFundo, FFormato: TComboBox;
    FLargura, FAltura: TSpinEdit;
    FPreview: TImage;
    FImagem, FArte: TPicture;
    FQR: TQRCodeImpressao;
    FImprimir, FSalvar: TButton;
    FAviso: TLabel;
    FErro: string;
    FAtualizando: Boolean;
    function PastaFundos: string;
    procedure Atualizar(Sender: TObject);
    procedure FinalidadeChange(Sender: TObject);
    procedure FormatoChange(Sender: TObject);
    procedure FundoChange(Sender: TObject);
    procedure CarregarImagem(Sender: TObject);
    procedure RemoverImagem(Sender: TObject);
    procedure Imprimir(Sender: TObject);
    procedure Salvar(Sender: TObject);
    procedure AbrirLink(Sender: TObject);
    procedure Desenhar(B: TBitmap);
    procedure Validar;
  public
    constructor CreateParaImpressora(AOwner: TComponent; Tipo: Integer);
    destructor Destroy; override;
    procedure CarregarImagemArquivo(const Caminho: string);
  end;

implementation

const
  PontosMM = 8; // 203 dpi: native resolution of common thermal printers.
  ArquivosFundos: array[1..4] of string = ('saude-clinica.png', 'saude-laboratorio.png',
    'varejo-mercado.png', 'varejo-loja.png');

constructor TfrmQRMidia.CreateParaImpressora(AOwner: TComponent; Tipo: Integer);
var
  Campos: TScrollBox;
  Direita, Rodape: TPanel;
  Y: Integer;
  procedure Legenda(const S: string);
  var L: TLabel;
  begin
    L := TLabel.Create(Self);
    L.Parent := Campos;
    L.SetBounds(20, Y, 350, 22);
    L.Caption := S;
    Inc(Y, 24);
  end;
  function Entrada: TEdit;
  begin
    Result := TEdit.Create(Self);
    Result.Parent := Campos;
    Result.SetBounds(20, Y, 350, 30);
    Result.OnChange := @Atualizar;
    Inc(Y, 44);
  end;
  function Lista: TComboBox;
  begin
    Result := TComboBox.Create(Self);
    Result.Parent := Campos;
    Result.SetBounds(20, Y, 350, 30);
    Result.Style := csDropDownList;
    Inc(Y, 44);
  end;
  function Botao(Pai: TWinControl; const S: string; X, Topo, W: Integer;
    Evento: TNotifyEvent): TButton;
  begin
    Result := TButton.Create(Self);
    Result.Parent := Pai;
    Result.SetBounds(X, Topo, W, 34);
    Result.Caption := S;
    Result.OnClick := Evento;
  end;
begin
  inherited CreateNew(AOwner, 1);
  FAtualizando := True;
  FTipo := Tipo;
  Caption := 'Manuais e vídeos · QR Code';
  Position := poOwnerFormCenter;
  SetBounds(0, 0, 1020, 780);
  Constraints.MinWidth := 820;
  Constraints.MinHeight := 600;
  Width := Min(Width, Screen.WorkAreaWidth);
  Height := Min(Height, Screen.WorkAreaHeight);
  Font.Name := 'Segoe UI';
  Font.Size := 10;
  Color := $FAF8F5;
  FImagem := TPicture.Create;
  FArte := TPicture.Create;
  FQR := TQRCodeImpressao.Create(Self);
  FQR.Visible := False;
  Campos := TScrollBox.Create(Self);
  Campos.Parent := Self;
  Campos.Align := alLeft;
  Campos.Width := 406;
  Campos.BorderStyle := bsNone;
  Campos.HorzScrollBar.Visible := False;
  Rodape := TPanel.Create(Self);
  Rodape.Parent := Self;
  Rodape.Align := alBottom;
  Rodape.Height := 100;
  Rodape.BevelOuter := bvNone;
  Direita := TPanel.Create(Self);
  Direita.Parent := Self;
  Direita.Align := alClient;
  Direita.BevelOuter := bvNone;
  Direita.BorderSpacing.Around := 20;
  Direita.Color := $EDE8E1;
  FPreview := TImage.Create(Self);
  FPreview.Parent := Direita;
  FPreview.Align := alClient;
  FPreview.Proportional := True;
  FPreview.Stretch := True;
  FPreview.Center := True;
  FPreview.Name := 'PreviaEtiqueta';
  FImprimir := Botao(Rodape, 'Escolher impressora e imprimir', 20, 50, 245, @Imprimir);
  FSalvar := Botao(Rodape, 'Salvar imagem PNG', 277, 50, 160, @Salvar);
  Botao(Rodape, 'Visualizar link', 449, 50, 140, @AbrirLink);
  FAviso := TLabel.Create(Self);
  FAviso.Parent := Rodape;
  FAviso.SetBounds(20, 4, 930, 42);
  FAviso.Anchors := [akLeft, akRight, akTop];
  FAviso.AutoSize := False;
  FAviso.WordWrap := True;
  Y := 20;
  Legenda('Conteúdo do QR Code');
  FFinalidade := Lista;
  FFinalidade.Items.AddStrings(['Manual / instruções', 'Vídeo / tutorial', 'Saúde / orientações', 'Livre / divulgação']);
  FFinalidade.ItemIndex := 0;
  FFinalidade.OnChange := @FinalidadeChange;
  Legenda('Link público do manual, vídeo ou página');
  FLink := Entrada;
  FLink.Name := 'LinkConteudo';
  FLink.Text := '';
  FLink.TextHint := 'https://...';
  FLink.MaxLength := 1200;
  Legenda('Título');
  FTitulo := Entrada;
  FTitulo.MaxLength := 120;
  FTitulo.Text := 'Manual de instruções';
  Legenda('Texto de apoio (opcional)');
  FTexto := TMemo.Create(Self);
  FTexto.Name := 'TextoApoio';
  FTexto.Clear;
  FTexto.Parent := Campos;
  FTexto.SetBounds(20, Y, 350, 88);
  FTexto.ScrollBars := ssVertical;
  FTexto.MaxLength := 600;
  FTexto.OnChange := @Atualizar;
  Inc(Y, 102);
  Legenda('Chamada abaixo do QR Code');
  FChamada := Entrada;
  FChamada.MaxLength := 80;
  FChamada.Text := 'Aponte a câmera e acesse o manual';
  Legenda('Fundo ilustrado');
  FFundo := Lista;
  FFundo.Items.AddStrings(['Sem fundo ilustrado', 'Saúde · clínica', 'Saúde · laboratório',
    'Varejo · supermercado', 'Varejo · loja e entregas']);
  FFundo.ItemIndex := 0;
  FFundo.OnChange := @FundoChange;
  Botao(Campos, 'Adicionar imagem / logo', 20, Y, 222, @CarregarImagem);
  Botao(Campos, 'Remover', 250, Y, 120, @RemoverImagem);
  Inc(Y, 50);
  Legenda('Formato de impressão');
  FFormato := Lista;
  FFormato.Items.Add('Etiqueta / cartão');
  if FTipo = 3 then FFormato.Items.Add('Cartaz A4');
  FFormato.ItemIndex := 0;
  FFormato.OnChange := @FormatoChange;
  Legenda('Largura x altura em mm');
  FLargura := TSpinEdit.Create(Self);
  FLargura.Parent := Campos;
  FLargura.SetBounds(20, Y, 164, 30);
  FLargura.MinValue := 40;
  case FTipo of
    0: begin FLargura.MaxValue := 104; FLargura.Value := 100; end;
    1: begin FLargura.MaxValue := 72; FLargura.Value := 72; end;
    2: begin FLargura.MaxValue := 48; FLargura.Value := 48; end;
    3: begin FLargura.MaxValue := 190; FLargura.Value := 90; end;
  end;
  FLargura.OnChange := @Atualizar;
  FAltura := TSpinEdit.Create(Self);
  FAltura.Parent := Campos;
  FAltura.SetBounds(200, Y, 170, 30);
  FAltura.MinValue := 80;
  FAltura.MaxValue := 277;
  FAltura.Value := 120;
  FAltura.OnChange := @Atualizar;
  FAtualizando := False;
  Atualizar(Self);
end;

destructor TfrmQRMidia.Destroy;
begin
  FImagem.Free;
  FArte.Free;
  inherited Destroy;
end;

function TfrmQRMidia.PastaFundos: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'background' + PathDelim + 'qrcode' + PathDelim;
  if not DirectoryExists(Result) then
    Result := ExpandFileName(ExtractFilePath(Application.ExeName) + '..' + PathDelim + 'background' + PathDelim + 'qrcode' + PathDelim);
end;

procedure TfrmQRMidia.Validar;
var U: TURI; S: string;
begin
  FErro := '';
  S := Trim(FLink.Text);
  U := ParseURI(S);
  if not ((LowerCase(U.Protocol) = 'https') or (LowerCase(U.Protocol) = 'http'))
    or (U.Host = '') or (Pos(' ', S) > 0) or (Pos(#9, S) > 0) then
    FErro := 'Informe um link completo começando com https:// ou http://.';
  if Trim(FTitulo.Text) = '' then FErro := 'Informe um título para a etiqueta.';
end;

procedure TfrmQRMidia.Desenhar(B: TBitmap);
var
  W, H, M, Y, AltTexto, Lado, Reserva, IW, IH, QX, LogoW, LogoH: Integer;
  R: TRect;
  Escala: Double;
  function Texto(const S: string; Tam, Limite: Integer; Negrito: Boolean): Integer;
  var Flags: LongInt; Medida, Destino: TRect;
  begin
    if Trim(S) = '' then Exit(0);
    B.Canvas.Font.Height := -Tam;
    B.Canvas.Font.Style := [];
    if Negrito then B.Canvas.Font.Style := [fsBold];
    Flags := DT_CENTER or DT_WORDBREAK or DT_NOPREFIX;
    Medida := Rect(M, Y, W-M, Y + 1);
    DrawText(B.Canvas.Handle, PChar(S), Length(S), Medida, Flags or DT_CALCRECT);
    Result := Medida.Bottom - Medida.Top;
    if (Result > Limite) or (Medida.Right > W-M) then
    begin
      FErro := 'O texto não cabe neste formato. Reduza o texto ou aumente a altura da etiqueta.';
      Result := Limite;
    end;
    Destino := Rect(M, Y, W-M, Y+Result);
    B.Canvas.Brush.Style := bsClear;
    DrawText(B.Canvas.Handle, PChar(S), Length(S), Destino, Flags);
    B.Canvas.Brush.Style := bsSolid;
  end;
begin
  W := FLargura.Value * PontosMM;
  H := FAltura.Value * PontosMM;
  M := 4 * PontosMM;
  B.SetSize(W, H);
  B.Canvas.Brush.Color := clWhite;
  B.Canvas.FillRect(0, 0, W, H);
  B.Canvas.Font.Name := 'Arial';
  B.Canvas.Font.Color := clBlack;
  Y := M;
  { Artwork stays separate from the QR symbol and its white quiet zone. }
  if Assigned(FArte.Graphic) and not FArte.Graphic.Empty then
  begin
    Reserva := Min(H div 4, 35 * PontosMM);
    Escala := Min((W-2*M) / FArte.Width, Reserva / FArte.Height);
    IW := Round(FArte.Width * Escala);
    IH := Round(FArte.Height * Escala);
    B.Canvas.StretchDraw(Rect((W-IW) div 2, Y, (W+IW) div 2, Y+IH), FArte.Graphic);
    if Assigned(FImagem.Graphic) and not FImagem.Graphic.Empty then
    begin
      Escala := Min((IW * 0.42) / FImagem.Width, (IH * 0.8) / FImagem.Height);
      LogoW := Round(FImagem.Width * Escala);
      LogoH := Round(FImagem.Height * Escala);
      QX := (W-IW) div 2 + Round(IW * 0.05);
      B.Canvas.StretchDraw(Rect(QX, Y+(IH-LogoH) div 2, QX+LogoW,
        Y+(IH+LogoH) div 2), FImagem.Graphic);
    end;
    Inc(Y, IH + 2 * PontosMM);
  end
  else if Assigned(FImagem.Graphic) and not FImagem.Graphic.Empty then
  begin
    Reserva := Min(H div 4, 35 * PontosMM);
    Escala := Min((W-2*M) / FImagem.Width, Reserva / FImagem.Height);
    IW := Round(FImagem.Width * Escala);
    IH := Round(FImagem.Height * Escala);
    B.Canvas.StretchDraw(Rect((W-IW) div 2, Y, (W+IW) div 2, Y+IH), FImagem.Graphic);
    Inc(Y, IH + 2 * PontosMM);
  end;
  Inc(Y, Texto(FTitulo.Text, 5 * PontosMM, 18 * PontosMM, True) + 2 * PontosMM);
  Inc(Y, Texto(FTexto.Text, 3 * PontosMM, H div 5, False) + 2 * PontosMM);
  B.Canvas.Font.Height := -3 * PontosMM;
  R := Rect(M, 0, W-M, 1);
  DrawText(B.Canvas.Handle, PChar(FChamada.Text), Length(FChamada.Text), R,
    DT_CENTER or DT_WORDBREAK or DT_NOPREFIX or DT_CALCRECT);
  AltTexto := R.Bottom - R.Top;
  Lado := Min(W - 2*M, H - Y - AltTexto - M - 2*PontosMM);
  if Lado < 28 * PontosMM then
  begin
    FErro := 'Espaço insuficiente para o QR Code. Aumente a altura, remova a imagem ou reduza o texto.';
    Exit;
  end;
  if Trim(FLink.Text) <> '' then
  begin
    FQR.Text := Trim(FLink.Text);
    QX := (W-Lado) div 2;
    FQR.DesenharLegivel(B.Canvas, Rect(QX, Y, QX+Lado, Y+Lado));
  end;
  Inc(Y, Lado + 2*PontosMM);
  Texto(FChamada.Text, 3 * PontosMM, H-Y-M, False);
end;

procedure TfrmQRMidia.Atualizar(Sender: TObject);
var B: TBitmap;
begin
  if FAtualizando then Exit;
  Validar;
  B := TBitmap.Create;
  try
    try
      Desenhar(B);
      FPreview.Picture.Assign(B);
    except
      on E: Exception do FErro := 'Não foi possível gerar o QR Code: ' + E.Message;
    end;
  finally
    B.Free;
  end;
  FImprimir.Enabled := FErro = '';
  FSalvar.Enabled := FErro = '';
  FAviso.Font.Color := $392B21;
  if FErro <> '' then
  begin
    FAviso.Caption := FErro;
    FAviso.Font.Color := clMaroon;
  end
  else
    FAviso.Caption := 'Prévia · ' + IntToStr(FLargura.Value) + ' x ' + IntToStr(FAltura.Value)
      + ' mm. O QR abre o link informado; o arquivo ou vídeo deve estar disponível nesse endereço.';
end;

procedure TfrmQRMidia.FinalidadeChange(Sender: TObject);
const
  Titulos: array[0..3] of string = ('Manual de instruções', 'Assista ao vídeo', 'Orientações de saúde', 'Saiba mais');
  Chamadas: array[0..3] of string = ('Aponte a câmera e acesse o manual', 'Aponte a câmera e veja o tutorial',
    'Aponte a câmera e leia as orientações', 'Aponte a câmera e descubra');
begin
  FAtualizando := True;
  FTitulo.Text := Titulos[FFinalidade.ItemIndex];
  FChamada.Text := Chamadas[FFinalidade.ItemIndex];
  FAtualizando := False;
  Atualizar(Self);
end;

procedure TfrmQRMidia.FormatoChange(Sender: TObject);
begin
  FAtualizando := True;
  if FFormato.ItemIndex = 1 then
  begin
    FLargura.Value := 190;
    FAltura.Value := 277;
  end
  else
  begin
    FLargura.Value := 90;
    FAltura.Value := 120;
  end;
  FAtualizando := False;
  Atualizar(Self);
end;

procedure TfrmQRMidia.FundoChange(Sender: TObject);
var Caminho: string;
begin
  if FFundo.ItemIndex = 0 then FArte.Clear
  else
  begin
    Caminho := PastaFundos + ArquivosFundos[FFundo.ItemIndex];
    if not FileExists(Caminho) then
    begin
      ShowMessage('Fundo não encontrado: ' + Caminho);
      Exit;
    end;
    FArte.LoadFromFile(Caminho);
  end;
  Atualizar(Self);
end;

procedure TfrmQRMidia.CarregarImagem(Sender: TObject);
var D: TOpenPictureDialog;
begin
  D := TOpenPictureDialog.Create(Self);
  try
    if not D.Execute then Exit;
    try
      CarregarImagemArquivo(D.FileName);
    except
      on E: Exception do ShowMessage('Não foi possível abrir a imagem: ' + E.Message);
    end;
  finally
    D.Free;
  end;
end;

procedure TfrmQRMidia.CarregarImagemArquivo(const Caminho: string);
begin
  FImagem.LoadFromFile(Caminho);
  Atualizar(Self);
end;

procedure TfrmQRMidia.RemoverImagem(Sender: TObject);
begin
  FImagem.Clear;
  Atualizar(Self);
end;

procedure TfrmQRMidia.AbrirLink(Sender: TObject);
begin
  Validar;
  if FErro <> '' then ShowMessage(FErro)
  else OpenURL(Trim(FLink.Text));
end;

procedure TfrmQRMidia.Salvar(Sender: TObject);
var D: TSaveDialog; PNG: TPortableNetworkGraphic;
begin
  Atualizar(Self);
  if FErro <> '' then Exit;
  D := TSaveDialog.Create(Self);
  PNG := TPortableNetworkGraphic.Create;
  try
    D.Filter := 'Imagem PNG|*.png';
    D.DefaultExt := 'png';
    D.FileName := 'manual-qrcode.png';
    D.Options := D.Options + [ofOverwritePrompt];
    if D.Execute then
    begin
      PNG.Assign(FPreview.Picture.Bitmap);
      PNG.SaveToFile(D.FileName);
    end;
  finally
    PNG.Free;
    D.Free;
  end;
end;

procedure TfrmQRMidia.Imprimir(Sender: TObject);
var D: TPrintDialog; W, H: Integer;
begin
  Atualizar(Self);
  if FErro <> '' then Exit;
  D := TPrintDialog.Create(Self);
  try
    D.Options := [poPrintToFile];
    if not D.Execute then Exit;
    W := Round(FLargura.Value * Printer.XDPI / 25.4);
    H := Round(FAltura.Value * Printer.YDPI / 25.4);
    if (W > Printer.PageWidth) or (H > Printer.PageHeight) then
    begin
      ShowMessage('O formato excede a área imprimível. Ajuste o papel nas propriedades da impressora ou reduza as dimensões.');
      Exit;
    end;
    Printer.Title := FTitulo.Text;
    Printer.BeginDoc;
    try
      Printer.Canvas.StretchDraw(Rect(0, 0, W, H), FPreview.Picture.Bitmap);
      Printer.EndDoc;
    except
      Printer.Abort;
      raise;
    end;
  finally
    D.Free;
  end;
end;

end.
