unit pulseira;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, Math, Forms, Controls, StdCtrls, Graphics, Dialogs,
  Spin, Printers, PrintersDlgs, RLReport, RLBarcode, RLConsts, RLTypes,
  ExtCtrls, tabelafinalidade, crudfinalidade, wizardimpressao;

type
  TPulseiraDados = record
    Bebe, Mae, Identificador, DataNascimento, HoraNascimento: string;
    InicioMM, AreaMM: Double;
  end;

  TfrmPulseira = class(TForm)
  private
    Bebe, Mae, Identificador, DataNascimento, HoraNascimento: TEdit;
    Inicio, Area: TFloatSpinEdit;
    FPainelBanco: TPainelBancoFinalidade;
    procedure ExecutarWizardPulseira(const OpcaoPapel: TOpcaoPapelWizard;
      Modo: TModoImpressaoWizard; Repeticoes: Integer;
      const Registros: TListaLinhasTabela; ApenasPrevia: Boolean);
    procedure CarregarValoresBanco(const Valores: array of string);
    procedure ObterValoresBanco(out Valores: TStringArray);
    procedure Visualizar(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

procedure ValidarPulseira(const D: TPulseiraDados);
function CriarRelatorioPulseira(AOwner: TComponent;
  const D: TPulseiraDados): TRLReport;

implementation

function MM(Value: Double): Integer;
begin
  Result := Round(Value * ScreenPPI / 25.4);
end;

procedure ValidarPulseira(const D: TPulseiraDados);
var I, Dia, Mes, Ano, Hora, Minuto: Integer; DT: TDateTime;
begin
  if Trim(D.Mae) = '' then
    raise Exception.Create('Informe o nome da mãe.');
  if (Length(D.Identificador) < 1) or (Length(D.Identificador) > 24) then
    raise Exception.Create('Informe um identificador de 1 a 24 caracteres.');
  for I := 1 to Length(D.Identificador) do
    if not (D.Identificador[I] in ['A'..'Z', 'a'..'z', '0'..'9', '-', '.', '/']) then
      raise Exception.Create('No identificador use letras sem acento, números, hífen, ponto ou barra.');
  Dia := StrToIntDef(Copy(D.DataNascimento, 1, 2), 0);
  Mes := StrToIntDef(Copy(D.DataNascimento, 4, 2), 0);
  Ano := StrToIntDef(Copy(D.DataNascimento, 7, 4), 0);
  if (Length(D.DataNascimento) <> 10) or
    (Copy(D.DataNascimento, 3, 1) <> '/') or
    (Copy(D.DataNascimento, 6, 1) <> '/') or
    not TryEncodeDate(Ano, Mes, Dia, DT) then
    raise Exception.Create('Informe uma data válida: dd/mm/aaaa.');
  if D.HoraNascimento <> '' then
  begin
    Hora := StrToIntDef(Copy(D.HoraNascimento, 1, 2), -1);
    Minuto := StrToIntDef(Copy(D.HoraNascimento, 4, 2), -1);
    if (Length(D.HoraNascimento) <> 5) or
      (Copy(D.HoraNascimento, 3, 1) <> ':') or (Hora < 0) or (Minuto < 0) or
      not TryEncodeTime(Hora, Minuto, 0, 0, DT) then
      raise Exception.Create('Informe uma hora válida: hh:mm, ou deixe em branco.');
  end;
  if (D.InicioMM < 0) or (D.AreaMM < 60) or
    (D.InicioMM + D.AreaMM > 285.03) then
    raise Exception.Create('A área deve ter pelo menos 60 mm e caber no comprimento de 285,03 mm.');
end;

function CriarRelatorioPulseira(AOwner: TComponent;
  const D: TPulseiraDados): TRLReport;
var Codigo: TRLBarcode; Nome, Nascimento: string;
  procedure Linha(const Texto: string; Y: Double; Tamanho: Integer; Negrito: Boolean);
  var L: TRLLabel;
  begin
    L := TRLLabel.Create(Result);
    L.Parent := Result;
    L.Font.Name := 'Arial';
    L.Font.Size := Tamanho;
    L.Font.Color := clBlack;
    if Negrito then L.Font.Style := [fsBold];
    L.AutoSize := True;
    L.Caption := Texto;
    L.Left := MM(D.InicioMM);
    L.Top := MM(Y);
    if L.Width > MM(D.AreaMM) then
      raise Exception.Create('O texto não cabe na área de impressão. Aumente a área útil.');
  end;
begin
  ValidarPulseira(D);
  Result := TRLReport.Create(AOwner);
  try
    Result.PageSetup.PaperSize := fpCustom;
    Result.PageSetup.PaperWidth := 25;
    Result.PageSetup.PaperHeight := 285.03;
    Result.PageSetup.Orientation := poLandscape;
    Result.Margins.LeftMargin := 0;
    Result.Margins.RightMargin := 0;
    Result.Margins.TopMargin := 0;
    Result.Margins.BottomMargin := 0;
    Result.PrintDialog := True;
    Nome := Trim(D.Bebe);
    if Nome = '' then Nome := 'RN de ' + Trim(D.Mae);
    Linha(Nome, 1.5, 8, True);
    Linha('Mãe: ' + Trim(D.Mae), 5, 7, False);
    Nascimento := 'Nascimento: ' + D.DataNascimento;
    if D.HoraNascimento <> '' then
      Nascimento := Nascimento + '  ' + D.HoraNascimento;
    Linha(Nascimento, 8.5, 7, False);
    Codigo := TRLBarcode.Create(Result);
    Codigo.Parent := Result;
    Codigo.BarcodeType := bcCode128B;
    Codigo.Module := 1;
    Codigo.ShowText := boNone;
    Codigo.Margins.LeftMargin := 3;
    Codigo.Margins.RightMargin := 3;
    Codigo.Caption := D.Identificador;
    Codigo.Left := MM(D.InicioMM);
    Codigo.Top := MM(12);
    Codigo.Height := MM(7);
    if Codigo.Width > MM(D.AreaMM) then
      raise Exception.Create('O código de barras não cabe. Aumente a área útil.');
    Linha('ID: ' + D.Identificador, 20, 7, False);
  except
    Result.Free;
    raise;
  end;
end;

constructor TfrmPulseira.Create(AOwner: TComponent);
var Botao: TButton;
  function Campo(const Titulo: string; Y: Integer): TEdit;
  var L: TLabel;
  begin
    L := TLabel.Create(Self); L.Parent := Self;
    L.Caption := Titulo; L.SetBounds(20, Y, 530, 20);
    Result := TEdit.Create(Self); Result.Parent := Self;
    Result.SetBounds(20, Y + 23, 530, 28);
  end;
  function Medida(const Titulo: string; X: Integer; Valor: Double): TFloatSpinEdit;
  var L: TLabel;
  begin
    L := TLabel.Create(Self); L.Parent := Self;
    L.Caption := Titulo; L.SetBounds(X, 340, 255, 20);
    Result := TFloatSpinEdit.Create(Self); Result.Parent := Self;
    Result.DecimalPlaces := 2; Result.MinValue := 0; Result.MaxValue := 285.03;
    Result.Value := Valor; Result.SetBounds(X, 365, 245, 28);
  end;
begin
  inherited CreateNew(AOwner);
  Caption := 'Pulseira de bebê — Zebra — 25 × 285,03 mm';
  Position := poScreenCenter;
  BorderStyle := bsDialog;
  ClientWidth := 570; ClientHeight := 604;
  Bebe := Campo('Nome do bebê (em branco: RN de + nome da mãe)', 15);
  Mae := Campo('Nome da mãe *', 80);
  Identificador := Campo('Identificador / atendimento * (até 24 caracteres)', 145);
  Identificador.MaxLength := 24;
  DataNascimento := Campo('Data de nascimento * (dd/mm/aaaa)', 210);
  HoraNascimento := Campo('Hora de nascimento (hh:mm, opcional)', 275);
  Inicio := Medida('Início da impressão (mm)', 20, 10);
  Area := Medida('Comprimento da área útil (mm)', 295, 110);
  FPainelBanco := TPainelBancoFinalidade.Create(Self);
  FPainelBanco.Parent := Self;
  FPainelBanco.SetBounds(20, 405, 530, 100);
  FPainelBanco.OnCarregarValores := @CarregarValoresBanco;
  FPainelBanco.OnObterValores := @ObterValoresBanco;
  FPainelBanco.DefinirFinalidade('pulseira');
  with TLabel.Create(Self) do begin
    Parent := Self; WordWrap := True;
    SetBounds(20, 512, 530, 42);
    Caption := 'Térmica branca, uma cor. Use o driver Zebra já utilizado no sistema, papel 25 × 285,03 mm e escala 100%. Ajuste a área útil à pulseira.';
  end;
  Botao := TButton.Create(Self); Botao.Parent := Self;
  Botao.Caption := 'Pré-visualizar / imprimir';
  Botao.SetBounds(290, 560, 260, 30); Botao.OnClick := @Visualizar;
end;

procedure TfrmPulseira.CarregarValoresBanco(const Valores: array of string);
begin
  if Length(Valores) > 0 then Bebe.Text := Valores[0];
  if Length(Valores) > 1 then Mae.Text := Valores[1];
  if Length(Valores) > 2 then Identificador.Text := Valores[2];
  if Length(Valores) > 3 then DataNascimento.Text := Valores[3];
  if Length(Valores) > 4 then HoraNascimento.Text := Valores[4];
  if (Length(Valores) > 5) and (Trim(Valores[5]) <> '') then
    Inicio.Value := StrToFloatDef(StringReplace(Valores[5], ',', '.', [rfReplaceAll]), Inicio.Value);
  if (Length(Valores) > 6) and (Trim(Valores[6]) <> '') then
    Area.Value := StrToFloatDef(StringReplace(Valores[6], ',', '.', [rfReplaceAll]), Area.Value);
end;

procedure TfrmPulseira.ObterValoresBanco(out Valores: TStringArray);
begin
  SetLength(Valores, 7);
  Valores[0] := Trim(Bebe.Text);
  Valores[1] := Trim(Mae.Text);
  Valores[2] := Trim(Identificador.Text);
  Valores[3] := Trim(DataNascimento.Text);
  Valores[4] := Trim(HoraNascimento.Text);
  Valores[5] := FormatFloat('0.00', Inicio.Value);
  Valores[6] := FormatFloat('0.00', Area.Value);
end;

procedure TfrmPulseira.ExecutarWizardPulseira(const OpcaoPapel: TOpcaoPapelWizard;
  Modo: TModoImpressaoWizard; Repeticoes: Integer;
  const Registros: TListaLinhasTabela; ApenasPrevia: Boolean);
var
  Itens: array of TPulseiraDados;
  I, Qtd: Integer;
  Relatorio: TRLReport;
  Dlg: TPrintDialog;
  function ConverterLinha(const L: TLinhaTabela): TPulseiraDados;
  begin
    if Length(L.Valores) > 0 then Result.Bebe := Trim(L.Valores[0]) else Result.Bebe := '';
    if Length(L.Valores) > 1 then Result.Mae := Trim(L.Valores[1]) else Result.Mae := '';
    if Length(L.Valores) > 2 then Result.Identificador := Trim(L.Valores[2]) else Result.Identificador := '';
    if Length(L.Valores) > 3 then Result.DataNascimento := Trim(L.Valores[3]) else Result.DataNascimento := '';
    if Length(L.Valores) > 4 then Result.HoraNascimento := Trim(L.Valores[4]) else Result.HoraNascimento := '';
    if (Length(L.Valores) > 5) and (Trim(L.Valores[5]) <> '') then
      Result.InicioMM := StrToFloatDef(StringReplace(L.Valores[5], ',', '.', [rfReplaceAll]), Inicio.Value)
    else
      Result.InicioMM := Inicio.Value;
    if (Length(L.Valores) > 6) and (Trim(L.Valores[6]) <> '') then
      Result.AreaMM := StrToFloatDef(StringReplace(L.Valores[6], ',', '.', [rfReplaceAll]), Area.Value)
    else
      Result.AreaMM := Area.Value;
  end;
begin
  if Modo = miwUmRegistroNVezes then
  begin
    Qtd := Max(1, Repeticoes);
    SetLength(Itens, Qtd);
    for I := 0 to Qtd - 1 do
      Itens[I] := ConverterLinha(Registros[0]);
  end
  else
  begin
    Qtd := Length(Registros);
    SetLength(Itens, Qtd);
    for I := 0 to Qtd - 1 do
      Itens[I] := ConverterLinha(Registros[I]);
  end;
  if Length(Itens) = 0 then Exit;

  try
    if ApenasPrevia then
    begin
      Relatorio := CriarRelatorioPulseira(Self, Itens[0]);
      try
        Relatorio.PrintDialog := False;
        Relatorio.PreviewModal;
      finally
        Relatorio.Free;
      end;
      Exit;
    end;

    Dlg := TPrintDialog.Create(Self);
    try
      if not Dlg.Execute then Exit;
    finally
      Dlg.Free;
    end;

    for I := 0 to High(Itens) do
    begin
      Relatorio := CriarRelatorioPulseira(Self, Itens[I]);
      try
        Relatorio.PrintDialog := False;
        Relatorio.Print;
      finally
        Relatorio.Free;
      end;
    end;
    ShowMessage(Format('%d pulseira(s) enviada(s) para impressão.', [Length(Itens)]));
  except
    on E: Exception do
      MessageDlg('Pulseira', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TfrmPulseira.Visualizar(Sender: TObject);
var
  Opcoes: TOpcoesPapelWizard;
  ValoresAtuais: TStringArray;
  Wiz: TfrmWizardImpressao;
begin
  SetLength(Opcoes, 1);
  Opcoes[0].Codigo := 'pulseira';
  Opcoes[0].Descricao := 'Pulseira Neonatal Zebra (25 x 285,03 mm)';
  Opcoes[0].ChaveFinalidade := 'pulseira';
  ObterValoresBanco(ValoresAtuais);
  Wiz := TfrmWizardImpressao.CreateWizard(Self, 'pulseira', Opcoes, 0, ValoresAtuais, 1);
  try
    Wiz.OnExecutarImpressao := @ExecutarWizardPulseira;
    Wiz.ShowModal;
  finally
    Wiz.Free;
  end;
  if Assigned(FPainelBanco) then
    FPainelBanco.AtualizarLista;
end;

end.
