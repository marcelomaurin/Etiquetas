unit qrdesenho;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, Types, Graphics, ubarcodes;

type
  TQRCodeImpressao = class(TBarcodeQR)
  public
    procedure DesenharLegivel(ACanvas: TCanvas; const Area: TRect);
  end;

implementation

procedure TQRCodeImpressao.DesenharLegivel(ACanvas: TCanvas; const Area: TRect);
var TotalW, TotalH, W, H, TW, TH, B, Espaco, Fator, X, Y: Integer;
begin
  RecommendedSymbolSize := False;
  Margin := 0;
  Generate;
  if FErrorCode > 2 then raise Exception.Create(ErrorString);
  CalcSize(1, TotalW, TotalH, W, H, TW, TH, B, Espaco);
  if W <= 0 then raise Exception.Create('QR Code vazio.');
  { Four white modules on every side, integral pixels per module. }
  Fator := (Area.Right - Area.Left) div (W + 8);
  if Fator < 3 then
    raise Exception.Create('Link muito longo para este tamanho. Use um link mais curto ou aumente a etiqueta.');
  Scale := Fator;
  Generate; // also invalidates cached rendering after resizing
  X := Area.Left + ((Area.Right - Area.Left) - W * Fator) div 2;
  Y := Area.Top + ((Area.Bottom - Area.Top) - H * Fator) div 2;
  PaintOnCanvas(ACanvas, Rect(X, Y, X + W * Fator, Y + H * Fator));
end;

end.
