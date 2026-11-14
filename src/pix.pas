unit pix;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Printers, ubarcodes, LCLIntf, LCLType;

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
procedure TfrmPIX.Button1Click(Sender: TObject);
begin
  ImprimirImagem;
end;

procedure TfrmPIX.FormShow(Sender: TObject);
begin
  // Atualiza o QR Code com o texto informado
  BarcodeQR1.Text := edStringPIX.Text;
end;

end.

