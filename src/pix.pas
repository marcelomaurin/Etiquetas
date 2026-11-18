unit pix;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Printers, PrintersDlgs, ubarcodes, LCLIntf, LCLType, tabelafinalidade, crudfinalidade, wizardimpressao;

type
  { TfrmPIX }
  TfrmPIX = class(TForm)
    BarcodeQR1: TBarcodeQR;
    Button1: TButton;
    edStringPIX: TEdit;
    imgpix: TImage;
    Label1: TLabel;
    procedure edStringPIXChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FPainelBanco: TPainelBancoFinalidade;
    procedure ExecutarWizardPIX(const OpcaoPapel: TOpcaoPapelWizard;
      Modo: TModoImpressaoWizard; Repeticoes: Integer;
      const Registros: TListaLinhasTabela; ApenasPrevia: Boolean);
    procedure CarregarValoresBanco(const Valores: array of string);
    procedure ObterValoresBanco(out Valores: TStringArray);
  public
    { Public declarations }
    function CalcCRC16(const s: AnsiString): string;
    procedure ImprimirImagem;
  end;

var
  frmPIX: TfrmPIX;

implementation

{$R *.lfm}

{======================================================================
 Função: CalcCRC16
 Descrição: Calcula o CRC16/CCITT-FALSE para uma string (payload)
======================================================================}
function TfrmPIX.CalcCRC16(const s: AnsiString): string;
var
  i, j: Integer;
  crc: Word;
begin
  crc := $FFFF;
  for i := 1 to Length(s) do
  begin
    crc := crc xor (Ord(s[i]) shl 8);
    for j := 1 to 8 do
    begin
      if (crc and $8000) <> 0 then
        crc := (crc shl 1) xor $1021
      else
        crc := crc shl 1;
    end;
  end;
  crc := crc and $FFFF;
  Result := UpperCase(IntToHex(crc, 4));
end;

{======================================================================
 Procedimento: ImprimirImagem
 Descrição: Captura a área visível do componente imgpix (fundo e QR Code)
            e envia a imagem capturada para a impressora padrão.
======================================================================}
procedure TfrmPIX.ImprimirImagem;
var
  bmp: TBitmap;
  QRRect: TRect;
begin
  bmp := TBitmap.Create;
  try
    bmp.SetSize(imgpix.Width, imgpix.Height);
    bmp.Canvas.Brush.Color := clWhite;
    bmp.Canvas.FillRect(0, 0, bmp.Width, bmp.Height);
    if Assigned(imgpix.Picture) and Assigned(imgpix.Picture.Graphic) and (not imgpix.Picture.Graphic.Empty) then
      bmp.Canvas.StretchDraw(Rect(0, 0, bmp.Width, bmp.Height), imgpix.Picture.Graphic);

    QRRect := Rect(BarcodeQR1.Left - imgpix.Left,
                   BarcodeQR1.Top - imgpix.Top,
                   BarcodeQR1.Left - imgpix.Left + BarcodeQR1.Width,
                   BarcodeQR1.Top - imgpix.Top + BarcodeQR1.Height);
    BarcodeQR1.PaintOnCanvas(bmp.Canvas, QRRect);

    Printer.BeginDoc;
    try
      Printer.Canvas.Draw(0, 0, bmp);
    finally
      Printer.EndDoc;
    end;
  finally
    bmp.Free;
  end;
end;

{======================================================================
 Evento: edStringPIXChange
 Descrição: Atualiza o QR Code com base no texto digitado e realiza a
            impressão (print screen) da área do imgpix.
======================================================================}
procedure TfrmPIX.edStringPIXChange(Sender: TObject);
begin
  // Atualiza o QR Code com o texto informado
  BarcodeQR1.Text := edStringPIX.Text;


end;

{======================================================================
 Evento: Button1Click
 Descrição: Permite disparar a impressão manualmente, se necessário.
======================================================================}
procedure TfrmPIX.ExecutarWizardPIX(const OpcaoPapel: TOpcaoPapelWizard;
  Modo: TModoImpressaoWizard; Repeticoes: Integer;
  const Registros: TListaLinhasTabela; ApenasPrevia: Boolean);
var
  Itens: TListaLinhasTabela;
  I, Qtd: Integer;
  Dlg: TPrintDialog;
  bmp: TBitmap;
  QRRect: TRect;
begin
  if Modo = miwUmRegistroNVezes then
  begin
    Qtd := Max(1, Repeticoes);
    SetLength(Itens, Qtd);
    for I := 0 to Qtd - 1 do Itens[I] := Registros[0];
  end
  else
    Itens := Registros;

  if Length(Itens) = 0 then Exit;

  if ApenasPrevia then
  begin
    CarregarValoresBanco(Itens[0].Valores);
    ShowMessage('Prévia do QR Code PIX atualizada na janela.');
    Exit;
  end;

  Dlg := TPrintDialog.Create(Self);
  try
    if not Dlg.Execute then Exit;
  finally
    Dlg.Free;
  end;

  bmp := TBitmap.Create;
  try
    bmp.SetSize(imgpix.Width, imgpix.Height);
    QRRect := Rect(BarcodeQR1.Left - imgpix.Left,
                   BarcodeQR1.Top - imgpix.Top,
                   BarcodeQR1.Left - imgpix.Left + BarcodeQR1.Width,
                   BarcodeQR1.Top - imgpix.Top + BarcodeQR1.Height);
    Printer.Title := 'QR Code PIX';
    Printer.BeginDoc;
    try
      for I := 0 to High(Itens) do
      begin
        CarregarValoresBanco(Itens[I].Valores);
        bmp.Canvas.Brush.Color := clWhite;
        bmp.Canvas.FillRect(0, 0, bmp.Width, bmp.Height);
        if Assigned(imgpix.Picture) and Assigned(imgpix.Picture.Graphic) and (not imgpix.Picture.Graphic.Empty) then
          bmp.Canvas.StretchDraw(Rect(0, 0, bmp.Width, bmp.Height), imgpix.Picture.Graphic);
        BarcodeQR1.PaintOnCanvas(bmp.Canvas, QRRect);
        if I > 0 then
          Printer.NewPage;
        Printer.Canvas.Draw(0, 0, bmp);
      end;
      Printer.EndDoc;
    except
      Printer.Abort;
      raise;
    end;
    ShowMessage(Format('%d etiqueta(s) PIX enviada(s) para impressão.', [Length(Itens)]));
  finally
    bmp.Free;
  end;
end;

procedure TfrmPIX.Button1Click(Sender: TObject);
var
  Opcoes: TOpcoesPapelWizard;
  ValoresAtuais: TStringArray;
  Wiz: TfrmWizardImpressao;
begin
  SetLength(Opcoes, 1);
  Opcoes[0].Codigo := 'pix';
  Opcoes[0].Descricao := 'Etiqueta QR Code PIX';
  Opcoes[0].ChaveFinalidade := 'pix';
  ObterValoresBanco(ValoresAtuais);
  Wiz := TfrmWizardImpressao.CreateWizard(Self, 'pix', Opcoes, 0, ValoresAtuais, 1);
  try
    Wiz.OnExecutarImpressao := @ExecutarWizardPIX;
    Wiz.ShowModal;
  finally
    Wiz.Free;
  end;
  if Assigned(FPainelBanco) then
    FPainelBanco.AtualizarLista;
end;

procedure TfrmPIX.FormShow(Sender: TObject);
begin
  if not Assigned(FPainelBanco) then
  begin
    ClientWidth := 540;
    ClientHeight := 604;
    FPainelBanco := TPainelBancoFinalidade.Create(Self);
    FPainelBanco.Parent := Self;
    FPainelBanco.SetBounds(16, 492, 508, 100);
    FPainelBanco.OnCarregarValores := @CarregarValoresBanco;
    FPainelBanco.OnObterValores := @ObterValoresBanco;
    FPainelBanco.DefinirFinalidade('pix');
  end
  else
    FPainelBanco.AtualizarLista;
  // Atualiza o QR Code com o texto informado
  BarcodeQR1.Text := edStringPIX.Text;
end;

procedure TfrmPIX.CarregarValoresBanco(const Valores: array of string);
begin
  if Length(Valores) > 1 then
    edStringPIX.Text := Valores[1]
  else if Length(Valores) > 0 then
    edStringPIX.Text := Valores[0];
  BarcodeQR1.Text := edStringPIX.Text;
end;

procedure TfrmPIX.ObterValoresBanco(out Valores: TStringArray);
begin
  SetLength(Valores, 2);
  Valores[0] := Copy(Trim(edStringPIX.Text), 1, 40);
  Valores[1] := Trim(edStringPIX.Text);
end;

end.

