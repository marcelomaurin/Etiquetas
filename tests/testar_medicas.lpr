program testar_medicas;
{$mode objfpc}{$H+}
uses Interfaces, Forms, SysUtils, Graphics, Types, RLReport, etiquetasmedicas;
procedure Imagem(R: TRLReport; const Nome: string);
var B: TBitmap; P: TPortableNetworkGraphic;
begin
  B := TBitmap.Create; P := TPortableNetworkGraphic.Create;
  try
    B.SetSize(R.Width * 3, R.Height * 3);
    B.Canvas.Brush.Color := clWhite; B.Canvas.FillRect(0,0,B.Width,B.Height);
    R.Pages[0].PaintTo(B.Canvas, Rect(0,0,B.Width,B.Height));
    P.Assign(B); P.SaveToFile(ExtractFilePath(ParamStr(0)) + Nome + '.png');
  finally P.Free; B.Free; end;
end;
var C: TCamposMedicos; R: TRLReport; I: Integer;
begin
  Application.Initialize;
  for I := 0 to High(C) do C[I] := '';
  C[0] := 'PACIENTE TESTE DA SILVA'; C[1] := 'HEMOGRAMA / SANGUE';
  C[2] := '123456789012'; C[3] := '25/09/2026 14:10';
  R := RelatorioMedico(nil, emExame, C);
  try
    if not R.Prepare then Halt(1);
    if R.Pages.PageCount <> 1 then Halt(2);
    Imagem(R, 'exame-teste');
    WriteLn('Exame: ',R.Width,' x ',R.Height,', uma pagina');
  finally R.Free; end;
  C[2] := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  try R := RelatorioMedico(nil, emExame, C); R.Free; Halt(6);
  except on E: Exception do WriteLn('Codigo excessivo rejeitado'); end;
  C[2] := '123456789012'; C[0] := StringOfChar('W', 150);
  try R := RelatorioMedico(nil, emExame, C); R.Free; Halt(7);
  except on E: Exception do WriteLn('Texto excessivo rejeitado sem truncar'); end;
  C[0] := 'PACIENTE TESTE';
  C[3] := '31/02/2026 25:00';
  try R := RelatorioMedico(nil, emExame, C); R.Free; Halt(3);
  except on E: Exception do WriteLn('Coleta invalida rejeitada'); end;
  C[0] := 'LABORATORIO TESTE'; C[1] := 'RUA TESTE, 123 - SAO PAULO/SP';
  C[2] := 'DESTINATARIO TESTE'; C[3] := 'AVENIDA TESTE, 456 - SALA 10';
  C[4] := 'SAO PAULO / SP'; C[5] := '01001-000'; C[6] := 'REM123456';
  C[7] := '1'; C[8] := '2'; C[9] := 'CONFORME PRODUTO'; C[10] := 'DADOS FICTICIOS';
  C[11] := 'REFERENCIA TESTE';
  R := RelatorioMedico(nil, emDespacho, C);
  try
    if not R.Prepare then Halt(4);
    if R.Pages.PageCount <> 1 then Halt(5);
    Imagem(R, 'despacho-teste');
    WriteLn('Despacho: ',R.Width,' x ',R.Height,', uma pagina');
  finally R.Free; end;
end.
