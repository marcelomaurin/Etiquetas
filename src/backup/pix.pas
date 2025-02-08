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
  ScreenDC: HDC;
  ControlRect: TRect;
  ScreenPos: TPoint;
begin
  // Cria um bitmap com as mesmas dimensões do componente imgpix
  bmp := TBitmap.Create;
  try
    bmp.Width := imgpix.Width;
    bmp.Height := imgpix.Height;

    // Obtém a posição do componente na tela
    ScreenPos := imgpix.ClientToScreen(Point(0, 0));
    ControlRect := Rect(ScreenPos.X, ScreenPos.Y,
                        ScreenPos.X + imgpix.Width,
                        ScreenPos.Y + imgpix.Height);

    // Captura o conteúdo da área correspondente na tela
    ScreenDC := GetDC(0);  // Obtém o DC da tela inteira
    try
      BitBlt(bmp.Canvas.Handle, 0, 0, bmp.Width, bmp.Height,
             ScreenDC, ControlRect.Left, ControlRect.Top, SRCCOPY);
    finally
      ReleaseDC(0, ScreenDC);
    end;

    // Envia o bitmap capturado para a impressora padrão
    Printer.BeginDoc;
    try
      // Desenha o bitmap no canvas da impressora.
      // Se necessário, ajuste a posição ou escalonamento.
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

