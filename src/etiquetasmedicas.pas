unit etiquetasmedicas;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, Forms, Controls, StdCtrls, Graphics, Dialogs,
  Printers, RLReport, RLBarcode, RLConsts, RLTypes;

type
  TModeloMedico = (emDespacho, emExame);
  TCamposMedicos = array[0..11] of string;
  TfrmEtiquetasMedicas = class(TForm)
  private
    FModelo: TModeloMedico;
    FCampos: array[0..11] of TEdit;
    procedure Visualizar(Sender: TObject);
  public
    constructor CreateModelo(AOwner: TComponent; Modelo: TModeloMedico);
  end;

function RelatorioMedico(AOwner: TComponent; Modelo: TModeloMedico;
  const Campos: TCamposMedicos): TRLReport;

implementation

const
  TitulosDespacho: array[0..11] of string = (
    'Remetente *', 'Endereço do remetente *', 'Destinatário *',
    'Endereço de entrega e complemento *', 'Cidade / UF *', 'CEP *',
    'Pedido / remessa (código de barras) *', 'Volume atual *', 'Total de volumes *',
    'Conservação (opcional)', 'Observações de transporte (opcional)',
    'Conteúdo / referência (opcional)');
  TitulosExame: array[0..3] of string = ('Nome do paciente *',
    'Exame / material *', 'Identificador da amostra (código de barras) *',
    'Coleta (dd/mm/aaaa hh:mm, opcional)');

function MM(V: Double): Integer;
begin
  Result := Round(V * ScreenPPI / 25.4);
end;

procedure ValidarColeta(const S: string);
var DT: TDateTime; D, M, A, H, N: Integer;
begin
  if S = '' then Exit;
  D := StrToIntDef(Copy(S, 1, 2), 0);
  M := StrToIntDef(Copy(S, 4, 2), 0);
  A := StrToIntDef(Copy(S, 7, 4), 0);
  H := StrToIntDef(Copy(S, 12, 2), -1);
  N := StrToIntDef(Copy(S, 15, 2), -1);
  if (Length(S) <> 16) or (Copy(S, 3, 1) <> '/') or
    (Copy(S, 6, 1) <> '/') or (Copy(S, 11, 1) <> ' ') or
    (Copy(S, 14, 1) <> ':') or (H < 0) or (N < 0) or
    not TryEncodeDate(A, M, D, DT) or not TryEncodeTime(H, N, 0, 0, DT) then
    raise Exception.Create('Informe a coleta em dd/mm/aaaa hh:mm, ou deixe em branco.');
end;

function RelatorioMedico(AOwner: TComponent; Modelo: TModeloMedico;
  const Campos: TCamposMedicos): TRLReport;
var C: TCamposMedicos; I, Volume, Total: Integer; Codigo, CEP: string;
  procedure Bloco(const Texto, Campo: string; X, Y, Largura, Passo: Double;
    Fonte, MaxLinhas: Integer; Negrito: Boolean = False);
  var L: TRLLabel; Resto, Palavra, Linha, Tentativa: string; P, Numero: Integer;
    function NovaLinha: TRLLabel;
    begin
      Result := TRLLabel.Create(RelatorioMedico);
      Result.Parent := RelatorioMedico;
      Result.Font.Name := 'Arial'; Result.Font.Size := Fonte;
      Result.Font.Color := clBlack;
      if Negrito then Result.Font.Style := [fsBold];
      Result.AutoSize := True;
      Result.Left := MM(X); Result.Top := MM(Y + (Numero - 1) * Passo);
    end;
  begin
    Resto := Trim(Texto);
    if Resto = '' then Exit;
    Numero := 1; Linha := ''; L := NovaLinha;
    while Resto <> '' do
    begin
      P := Pos(' ', Resto);
      if P = 0 then begin Palavra := Resto; Resto := ''; end
      else begin Palavra := Copy(Resto, 1, P - 1); Delete(Resto, 1, P); Resto := TrimLeft(Resto); end;
      if Linha = '' then Tentativa := Palavra else Tentativa := Linha + ' ' + Palavra;
      L.Caption := Tentativa;
      if L.Width > MM(Largura) then
      begin
        L.Caption := Linha;
        if (Linha = '') or (Numero >= MaxLinhas) then
          raise Exception.Create('O campo "' + Campo + '" não cabe no modelo. Revise o conteúdo; nada foi impresso.');
        Inc(Numero); L := NovaLinha;
        L.Caption := Palavra;
        if L.Width > MM(Largura) then
          raise Exception.Create('Uma palavra do campo "' + Campo + '" ultrapassa a largura da etiqueta.');
        Linha := Palavra;
      end
      else Linha := Tentativa;
    end;
  end;
  procedure Barras(X, Y, Largura, Altura: Double);
  var B: TRLBarcode; Numerico: Boolean; J: Integer;
  begin
    B := TRLBarcode.Create(Result); B.Parent := Result;
    Numerico := (Length(Codigo) mod 2 = 0);
    for J := 1 to Length(Codigo) do
      Numerico := Numerico and (Codigo[J] in ['0'..'9']);
    if Numerico then B.BarcodeType := bcCode128C else B.BarcodeType := bcCode128B;
    B.Module := 1; B.ShowText := boNone;
    B.Margins.LeftMargin := 3; B.Margins.RightMargin := 3;
    B.Caption := Codigo;
    B.Left := MM(X); B.Top := MM(Y); B.Height := MM(Altura);
    if B.Width > MM(Largura) then
      raise Exception.Create('O identificador é longo demais para o código de barras deste modelo. Use um identificador mais curto; no modelo 51 × 25, prefira números em quantidade par.');
  end;
begin
  for I := 0 to High(C) do C[I] := Trim(Campos[I]);
  if Modelo = emDespacho then
  begin
    for I := 0 to 8 do if C[I] = '' then
      raise Exception.Create('Preencha: ' + TitulosDespacho[I]);
    Volume := StrToIntDef(C[7], 0); Total := StrToIntDef(C[8], 0);
    if (Volume < 1) or (Total < Volume) then
      raise Exception.Create('O volume deve ser positivo e não pode ultrapassar o total.');
    CEP := StringReplace(C[5], '-', '', [rfReplaceAll]);
    if Length(CEP) <> 8 then raise Exception.Create('Informe o CEP com oito números.');
    for I := 1 to Length(CEP) do if not (CEP[I] in ['0'..'9']) then
      raise Exception.Create('Informe o CEP com oito números.');
    Codigo := C[6];
  end
  else
  begin
    for I := 0 to 2 do if C[I] = '' then
      raise Exception.Create('Preencha: ' + TitulosExame[I]);
    ValidarColeta(C[3]); Codigo := C[2];
  end;
  for I := 1 to Length(Codigo) do
    if not (Codigo[I] in ['A'..'Z', 'a'..'z', '0'..'9', '-', '.', '/']) then
      raise Exception.Create('No identificador use letras sem acento, números, hífen, ponto ou barra.');
  if Length(Codigo) > 40 then raise Exception.Create('Identificador muito longo (máximo 40 caracteres).');
  Result := TRLReport.Create(AOwner);
  try
    Result.PageSetup.PaperSize := fpCustom;
    Result.PageSetup.Orientation := poPortrait;
    if Modelo = emDespacho then begin
      Result.PageSetup.PaperWidth := 100; Result.PageSetup.PaperHeight := 150;
    end else begin
      Result.PageSetup.PaperWidth := 51; Result.PageSetup.PaperHeight := 25;
    end;
    Result.Margins.LeftMargin := 0; Result.Margins.RightMargin := 0;
    Result.Margins.TopMargin := 0; Result.Margins.BottomMargin := 0;
    Result.PrintDialog := True;
    if Modelo = emExame then
    begin
      Bloco(C[0], 'Paciente', 2, 1, 47, 3, 7, 2, True);
      Bloco(C[1], 'Exame / material', 2, 7, 47, 3, 7, 1);
      if C[3] <> '' then Bloco('Col.: ' + C[3], 'Coleta', 2, 10, 47, 3, 6, 1);
      Barras(2, 13, 47, 6);
      Bloco(Codigo, 'Identificador', 2, 20, 47, 3, 7, 1);
    end
    else
    begin
      Bloco('DESPACHO', 'Título', 5, 5, 90, 5, 14, 1, True);
      Bloco('Produtos médicos e laboratoriais', 'Subtítulo', 5, 12, 90, 4, 9, 1);
      Bloco('REMETENTE', 'Título', 5, 21, 90, 4, 8, 1, True);
      Bloco(C[0], 'Remetente', 5, 26, 90, 4, 9, 1);
      Bloco(C[1], 'Endereço do remetente', 5, 31, 90, 4, 8, 2);
      Bloco('DESTINATÁRIO', 'Título', 5, 43, 90, 4, 9, 1, True);
      Bloco(C[2], 'Destinatário', 5, 49, 90, 5, 11, 2, True);
      Bloco(C[3], 'Endereço de entrega', 5, 61, 90, 4.5, 10, 3);
      Bloco(C[4], 'Cidade / UF', 5, 76, 90, 4, 10, 1);
      Bloco('CEP: ' + Copy(CEP, 1, 5) + '-' + Copy(CEP, 6, 3), 'CEP', 5, 82, 90, 5, 12, 1, True);
      Bloco('Volume: ' + IntToStr(Volume) + '/' + IntToStr(Total), 'Volume', 5, 91, 90, 4, 10, 1, True);
      Barras(5, 99, 90, 13);
      Bloco('Remessa: ' + Codigo, 'Remessa', 5, 113, 90, 4, 9, 1);
      Bloco(C[11], 'Conteúdo / referência', 5, 121, 90, 4, 8, 1);
      if C[9] <> '' then Bloco('Conservação: ' + C[9], 'Conservação', 5, 127, 90, 4, 8, 2);
      Bloco(C[10], 'Observações', 5, 137, 90, 4, 8, 2);
    end;
  except Result.Free; raise; end;
end;

constructor TfrmEtiquetasMedicas.CreateModelo(AOwner: TComponent; Modelo: TModeloMedico);
var I, Ultimo, Coluna, Linha: Integer; L: TLabel; B: TButton;
begin
  inherited CreateNew(AOwner);
  FModelo := Modelo;
  Position := poScreenCenter; BorderStyle := bsDialog;
  if Modelo = emDespacho then begin
    Caption := 'Despacho médico e laboratorial — 100 × 150 mm';
    ClientWidth := 820; ClientHeight := 505; Ultimo := 11;
  end else begin
    Caption := 'Exame laboratorial — 51 × 25 mm';
    ClientWidth := 550; ClientHeight := 370; Ultimo := 3;
  end;
  for I := 0 to Ultimo do
  begin
    if Modelo = emDespacho then begin Coluna := I div 6; Linha := I mod 6; end
    else begin Coluna := 0; Linha := I; end;
    L := TLabel.Create(Self); L.Parent := Self;
    if Modelo = emDespacho then L.Caption := TitulosDespacho[I] else L.Caption := TitulosExame[I];
    L.SetBounds(20 + Coluna * 400, 15 + Linha * 64, 380, 20);
    FCampos[I] := TEdit.Create(Self); FCampos[I].Parent := Self;
    if Modelo = emDespacho then FCampos[I].Width := 380 else FCampos[I].Width := 510;
    FCampos[I].Left := L.Left; FCampos[I].Top := L.Top + 22;
    FCampos[I].MaxLength := 300;
  end;
  if Modelo = emDespacho then begin FCampos[7].Text := '1'; FCampos[8].Text := '1'; end;
  L := TLabel.Create(Self); L.Parent := Self; L.WordWrap := True;
  L.SetBounds(20, ClientHeight - 105, ClientWidth - 40, 58);
  if Modelo = emDespacho then
    L.Caption := 'Etiqueta própria de despacho. Informe conservação e observações conforme o produto. Selecione papel 100 × 150 mm na impressora, em escala 100%.'
  else L.Caption := 'Papel 51 × 25 mm, escala 100%. Use identificador curto; números em quantidade par ocupam menos espaço no código de barras. Os dados são usados somente nesta impressão.';
  B := TButton.Create(Self); B.Parent := Self;
  B.Caption := 'Pré-visualizar / imprimir';
  B.SetBounds(ClientWidth - 280, ClientHeight - 42, 260, 30);
  B.OnClick := @Visualizar;
end;

procedure TfrmEtiquetasMedicas.Visualizar(Sender: TObject);
var C: TCamposMedicos; I: Integer; R: TRLReport;
begin
  for I := 0 to High(C) do if Assigned(FCampos[I]) then C[I] := Trim(FCampos[I].Text) else C[I] := '';
  try
    R := RelatorioMedico(Self, FModelo, C);
    try R.PreviewModal; finally R.Free; end;
  except on E: Exception do MessageDlg('Etiqueta', E.Message, mtError, [mbOK], 0); end;
end;

end.
