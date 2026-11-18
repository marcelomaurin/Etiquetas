unit etiquetaspimaco;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, StdCtrls, ExtCtrls, Spin, Graphics,
  Dialogs, ExtDlgs, Printers, PrintersDlgs, DB, RLReport, RLBarcode, RLConsts, RLTypes,
  dmbase, setmain, imagefilters, tabelafinalidade, crudfinalidade, wizardimpressao;

type
  TModeloPimaco = (
    pmA4248,     // A4 - 96 etq (31,0 x 17,0 mm) - 6 col x 16 lin
    pmA4251,     // A4 - 65 etq (38,1 x 21,2 mm) - 5 col x 13 lin
    pmA4255,     // A4 - 27 etq (63,5 x 31,0 mm) - 3 col x 9 lin
    pmA4260,     // A4 - 21 etq (63,5 x 38,1 mm) - 3 col x 7 lin
    pmA4262,     // A4 - 14 etq (99,0 x 38,1 mm) - 2 col x 7 lin
    pmA4263,     // A4 - 10 etq (99,0 x 55,8 mm) - 2 col x 5 lin
    pmA4268,     // A4 -  4 etq (99,0 x 139,0 mm) - 2 col x 2 lin
    pmCarta6180, // Carta - 30 etq (66,7 x 25,4 mm) - 3 col x 10 lin
    pmCarta6182, // Carta - 14 etq (101,6 x 33,9 mm) - 2 col x 7 lin
    pmCartazA4,  // Cartaz Oferta A4 (190,0 x 277,0 mm) - 1 col x 1 lin
    pmA4ML150x100// Papel A4 Exclusivo - 2 etq Tipo ML (150,0 x 100,0 mm) - 1 col x 2 lin
  );

  TFinalidadePimaco = (
    fpSupermercado,   // Gôndola, preço, kg/L, EAN
    fpValidadeANVISA, // Padaria, açougue, validade RDC 216
    fpLaboratorio,    // Tubos de coleta, lâminas, amostras
    fpMedicamento,    // Medicamento avulso, posologia, dose unitária
    fpDespacho,       // Envio e despacho de produtos / logística
    fpCracha,         // Crachás de visitantes, acompanhantes e funcionários
    fpAvisoA4         // Exclusivo A4: Aviso / Identificação de Caixa e Prateleira
  );

  TSpecPimaco = record
    Nome: string;
    PapelW, PapelH: Double;
    Colunas, Linhas: Integer;
    MargemEsq, MargemTopo: Double;
    LarguraEtq, AlturaEtq: Double;
    PassoH, PassoV: Double;
  end;

  TDadosPimaco = record
    Modelo: TModeloPimaco;
    Finalidade: TFinalidadePimaco;
    LinhaInicial, ColunaInicial, Quantidade: Integer;
    UsarBancoSelecionado: Boolean;
    Linha1, Linha2, Linha3, Linha4, Linha5, CodigoBarras: string;
    CaminhoFoto: string;
    FotoPB: Boolean;
  end;

  { TfrmEtiquetasPimaco }

  TfrmEtiquetasPimaco = class(TForm)
  private
    cbModelo: TComboBox;
    cbFinalidade: TComboBox;
    lblInfoModelo: TLabel;
    seLinhaIni: TSpinEdit;
    seColunaIni: TSpinEdit;
    seQuantidade: TSpinEdit;
    chkUsarBanco: TCheckBox;
    lblCampo: array[0..5] of TLabel;
    edCampo: array[0..5] of TEdit;
    pnlFoto: TPanel;
    imgFotoOrig: TImage;
    imgFotoProc: TImage;
    chkFotoPB: TCheckBox;
    btnCarregarFoto: TButton;
    FCaminhoFoto: string;
    FPainelBanco: TPainelBancoFinalidade;
    procedure ExecutarWizardPimaco(const OpcaoPapel: TOpcaoPapelWizard;
      Modo: TModoImpressaoWizard; Repeticoes: Integer;
      const Registros: TListaLinhasTabela; ApenasPrevia: Boolean);
    procedure CarregarValoresBanco(const Valores: array of string);
    procedure ObterValoresBanco(out Valores: TStringArray);
    procedure AtualizarCampos(Sender: TObject);
    procedure AtualizarLimitesPosicao(Sender: TObject);
    procedure CarregarFotoClick(Sender: TObject);
    procedure ProcessarFotoPreview;
    procedure VisualizarClick(Sender: TObject);
  public
    constructor CreateComFinalidade(AOwner: TComponent;
      AFinalidade: TFinalidadePimaco; AModelo: TModeloPimaco = pmA4255);
  end;

function ObterSpecPimaco(AModelo: TModeloPimaco): TSpecPimaco;
function CriarRelatorioPimaco(AOwner: TComponent; const D: TDadosPimaco): TRLReport;

implementation

const
  SpecsPimaco: array[TModeloPimaco] of TSpecPimaco = (
    (Nome: 'Pimaco A4248 (A4 - 96 etq: 31,0 x 17,0 mm - 6x16 - Micro-tubos/Lâminas/Preços)';
     PapelW: 210.0; PapelH: 297.0; Colunas: 6; Linhas: 16;
     MargemEsq: 7.0; MargemTopo: 12.5; LarguraEtq: 31.0; AlturaEtq: 17.0; PassoH: 33.0; PassoV: 17.0),
    (Nome: 'Pimaco A4251 / A4351 (A4 - 65 etq: 38,1 x 21,2 mm - 5x13 - Tubos Coleta/Dose Unit./EAN)';
     PapelW: 210.0; PapelH: 297.0; Colunas: 5; Linhas: 13;
     MargemEsq: 4.7; MargemTopo: 10.7; LarguraEtq: 38.1; AlturaEtq: 21.2; PassoH: 40.6; PassoV: 21.2),
    (Nome: 'Pimaco A4255 / A4355 (A4 - 27 etq: 63,5 x 31,0 mm - 3x9 - Gôndola/Validade/Amostras)';
     PapelW: 210.0; PapelH: 297.0; Colunas: 3; Linhas: 9;
     MargemEsq: 7.2; MargemTopo: 9.0; LarguraEtq: 63.5; AlturaEtq: 31.0; PassoH: 66.0; PassoV: 31.0),
    (Nome: 'Pimaco A4260 / A4360 (A4 - 21 etq: 63,5 x 38,1 mm - 3x7 - Posologia/Varejo/Mala Direta)';
     PapelW: 210.0; PapelH: 297.0; Colunas: 3; Linhas: 7;
     MargemEsq: 7.2; MargemTopo: 15.1; LarguraEtq: 63.5; AlturaEtq: 38.1; PassoH: 66.0; PassoV: 38.1),
    (Nome: 'Pimaco A4262 / A4362 (A4 - 14 etq: 99,0 x 38,1 mm - 2x7 - Soro Hospitalar/Prontuário)';
     PapelW: 210.0; PapelH: 297.0; Colunas: 2; Linhas: 7;
     MargemEsq: 4.5; MargemTopo: 15.1; LarguraEtq: 99.0; AlturaEtq: 38.1; PassoH: 101.5; PassoV: 38.1),
    (Nome: 'Pimaco A4263 / A4363 (A4 - 10 etq: 99,0 x 55,8 mm - 2x5 - Crachás Visitante/Funcionário)';
     PapelW: 210.0; PapelH: 297.0; Colunas: 2; Linhas: 5;
     MargemEsq: 4.5; MargemTopo: 9.0; LarguraEtq: 99.0; AlturaEtq: 55.8; PassoH: 101.5; PassoV: 55.8),
    (Nome: 'Pimaco A4268 / A4368 (A4 - 4 etq: 99,0 x 139,0 mm - 2x2 - Despacho/Envio/Biológico)';
     PapelW: 210.0; PapelH: 297.0; Colunas: 2; Linhas: 2;
     MargemEsq: 4.5; MargemTopo: 9.5; LarguraEtq: 99.0; AlturaEtq: 139.0; PassoH: 101.5; PassoV: 139.0),
    (Nome: 'Pimaco Carta 6180 / 6080 (Carta - 30 etq: 66,7 x 25,4 mm - 3x10 - Preço/Laboratório)';
     PapelW: 215.9; PapelH: 279.4; Colunas: 3; Linhas: 10;
     MargemEsq: 4.8; MargemTopo: 12.7; LarguraEtq: 66.7; AlturaEtq: 25.4; PassoH: 69.8; PassoV: 25.4),
    (Nome: 'Pimaco Carta 6182 / 6082 (Carta - 14 etq: 101,6 x 33,9 mm - 2x7 - Endereçamento/Saúde)';
     PapelW: 215.9; PapelH: 279.4; Colunas: 2; Linhas: 7;
     MargemEsq: 4.0; MargemTopo: 21.1; LarguraEtq: 101.6; AlturaEtq: 33.9; PassoH: 104.0; PassoV: 33.9),
    (Nome: 'Cartaz Promocional Supermercado A4 (Folha Inteira 210 x 297 mm - Oferta Gôndola)';
     PapelW: 210.0; PapelH: 297.0; Colunas: 1; Linhas: 1;
     MargemEsq: 10.0; MargemTopo: 10.0; LarguraEtq: 190.0; AlturaEtq: 277.0; PassoH: 190.0; PassoV: 277.0),
    (Nome: 'Folha A4 Exclusiva · Etiqueta Tipo ML (A4 - 2 etq: 150,0 x 100,0 mm - 1x2)';
     PapelW: 210.0; PapelH: 297.0; Colunas: 1; Linhas: 2;
     MargemEsq: 30.0; MargemTopo: 38.5; LarguraEtq: 150.0; AlturaEtq: 100.0; PassoH: 150.0; PassoV: 120.0)
  );

function MM(V: Double): Integer;
begin
  Result := Round(V * ScreenPPI / 25.4);
end;

function IfThenStr(Cond: Boolean; const VTrue, VFalse: string): string;
begin
  if Cond then Result := VTrue else Result := VFalse;
end;

function ObterSpecPimaco(AModelo: TModeloPimaco): TSpecPimaco;
begin
  Result := SpecsPimaco[AModelo];
end;

procedure DesenharCelulaPimaco(Report: TRLReport; const Spec: TSpecPimaco;
  const D: TDadosPimaco; X, Y: Double; const L1, L2, L3, L4, L5, Cod: string;
  IndiceVolume, TotalVolumes: Integer);
var
  W, H, AltBarra, TopTexto: Double;
  FonteTit, FonteSub, FontePreco: Integer;
  Borda: TRLDraw;
  Img: TRLImage;
  ImgTempIn, ImgTempOut: TImage;
  FiltroCinza: TGrayscaleFilter;
  FiltroContraste: TBrightnessContrastFilter;
  TextoL1, TextoL2, TextoL3, TextoL4, TextoL5: string;

  procedure CriarLabel(const Txt: string; OffX, OffY, MaxW: Double; TamFonte: Integer;
    Negrito: Boolean = False; AlinharCentro: Boolean = False);
  var
    L: TRLLabel;
  begin
    if Trim(Txt) = '' then Exit;
    L := TRLLabel.Create(Report);
    L.Parent := Report;
    L.Font.Name := 'Arial';
    L.Font.Size := TamFonte;
    L.Font.Color := clBlack;
    if Negrito then L.Font.Style := [fsBold];
    L.AutoSize := False;
    L.Left := MM(X + OffX);
    L.Top := MM(Y + OffY);
    L.Width := MM(MaxW);
    L.Height := MM(TamFonte * 0.48 + 1.6);
    if AlinharCentro then
      L.Alignment := taCenter;
    L.Caption := Trim(Txt);
  end;

  procedure CriarBarras(const CodigoStr: string; OffX, OffY, MaxW, AltMM: Double);
  var
    B: TRLBarcode;
    J: Integer;
    ParNum: Boolean;
  begin
    if Trim(CodigoStr) = '' then Exit;
    for J := 1 to Length(CodigoStr) do
      if not (CodigoStr[J] in ['A'..'Z', 'a'..'z', '0'..'9', '-', '.', '/']) then
        Exit;
    B := TRLBarcode.Create(Report);
    B.Parent := Report;
    ParNum := (Length(CodigoStr) mod 2 = 0);
    for J := 1 to Length(CodigoStr) do
      ParNum := ParNum and (CodigoStr[J] in ['0'..'9']);
    if ParNum then B.BarcodeType := bcCode128C else B.BarcodeType := bcCode128B;
    B.Module := 1;
    B.ShowText := boNone;
    B.Caption := Trim(CodigoStr);
    B.Left := MM(X + OffX);
    B.Top := MM(Y + OffY);
    B.Height := MM(AltMM);
    if B.Width > MM(MaxW) then
      B.Width := MM(MaxW);
  end;

begin
  W := Spec.LarguraEtq;
  H := Spec.AlturaEtq;
  TextoL1 := L1;
  TextoL2 := L2;
  TextoL3 := L3;
  TextoL4 := L4;
  TextoL5 := L5;

  if D.Modelo = pmCartazA4 then
  begin
    Borda := TRLDraw.Create(Report);
    Borda.Parent := Report;
    Borda.DrawKind := dkRectangle;
    Borda.Pen.Width := 3;
    Borda.SetBounds(MM(X), MM(Y), MM(W), MM(H));

    if D.Finalidade = fpAvisoA4 then
      CriarLabel('AVISO / IDENTIFICAÇÃO A4', 5, 14, W - 10, 28, True, True)
    else
      CriarLabel('OFERTA ESPECIAL', 5, 10, W - 10, 34, True, True);
    CriarLabel(TextoL1, 8, 45, W - 16, 26, True, True);
    CriarLabel(TextoL2, 8, 72, W - 16, 16, False, True);
    CriarLabel(TextoL4, 8, 115, W - 16, 68, True, True);
    CriarLabel(TextoL3, 8, 195, W - 16, 16, True, True);
    CriarLabel(TextoL5, 8, 215, W - 16, 12, False, True);
    if Trim(Cod) <> '' then
    begin
      CriarBarras(Cod, 45, 235, W - 90, 22);
      CriarLabel(Cod, 10, 260, W - 20, 11, False, True);
    end;
    Exit;
  end;

  if H <= 18.0 then
  begin
    FonteTit := 6;
    FonteSub := 5;
    CriarLabel(TextoL1, 1.2, 0.8, W - 2.4, FonteTit, True);
    CriarLabel(TextoL2 + ' ' + TextoL4, 1.2, 4.0, W - 2.4, FonteSub, False);
    if Trim(Cod) <> '' then
    begin
      CriarBarras(Cod, 1.2, 7.2, W - 2.4, 5.2);
      CriarLabel(Cod, 1.2, 12.8, W - 2.4, 5, False);
    end
    else
      CriarLabel(TextoL3, 1.2, 8.0, W - 2.4, FonteSub, False);
    Exit;
  end;

  if H <= 26.0 then
  begin
    FonteTit := 7;
    FonteSub := 6;
    FontePreco := 9;
    CriarLabel(TextoL1, 1.5, 1.0, W - 3.0, FonteTit, True);
    if D.Finalidade = fpSupermercado then
    begin
      CriarLabel(TextoL2, 1.5, 4.8, W * 0.55, FonteSub, False);
      CriarLabel(TextoL3, 1.5, 8.0, W * 0.55, FonteSub, False);
      CriarLabel(TextoL4, W * 0.52, 4.8, W * 0.45, FontePreco, True);
    end
    else
    begin
      CriarLabel(TextoL2, 1.5, 4.8, W - 3.0, FonteSub, False);
      CriarLabel(TextoL3 + ' ' + TextoL4, 1.5, 8.0, W - 3.0, FonteSub, False);
    end;
    if Trim(Cod) <> '' then
    begin
      CriarBarras(Cod, 1.5, 11.5, W - 3.0, 5.5);
      CriarLabel(Cod, 1.5, 17.3, W - 3.0, 6, False);
    end;
    Exit;
  end;

  if H <= 40.0 then
  begin
    FonteTit := 8;
    FonteSub := 7;
    FontePreco := 11;
    case D.Finalidade of
      fpSupermercado:
      begin
        CriarLabel(TextoL1, 2.0, 1.5, W - 4.0, FonteTit, True);
        CriarLabel(TextoL2, 2.0, 6.0, W - 4.0, FonteSub, False);
        CriarLabel(TextoL3, 2.0, 10.0, W * 0.55, FonteSub, False);
        CriarLabel(TextoL4, W * 0.50, 9.0, W * 0.46, FontePreco, True);
        if Trim(Cod) <> '' then
        begin
          CriarBarras(Cod, 2.0, 15.5, W - 4.0, 8.5);
          CriarLabel(Cod + '  ' + TextoL5, 2.0, 25.0, W - 4.0, 6, False);
        end;
      end;
      fpValidadeANVISA:
      begin
        CriarLabel('CONTROLE DE VALIDADE - ANVISA', 2.0, 1.2, W - 4.0, 6, True);
        CriarLabel('PRODUTO: ' + TextoL1, 2.0, 4.8, W - 4.0, FonteTit, True);
        CriarLabel('MANIPULAÇÃO: ' + TextoL2, 2.0, 9.2, W - 4.0, FonteSub, False);
        CriarLabel('VALIDADE: ' + TextoL3, 2.0, 13.2, W - 4.0, FonteTit, True);
        CriarLabel('CONSERV.: ' + TextoL4, 2.0, 17.5, W - 4.0, FonteSub, False);
        CriarLabel('RESP.: ' + TextoL5, 2.0, 21.2, W - 4.0, FonteSub, False);
        if Trim(Cod) <> '' then
          CriarBarras(Cod, 2.0, 24.8, W - 4.0, 5.0);
      end;
      fpMedicamento:
      begin
        CriarLabel('FARMÁCIA / MEDICAMENTO AVULSO', 2.0, 1.2, W - 4.0, 6, True);
        CriarLabel(TextoL1, 2.0, 4.5, W - 4.0, FonteTit, True);
        CriarLabel('Posologia: ' + TextoL2, 2.0, 8.8, W - 4.0, FonteSub, False);
        CriarLabel('Lote/Val: ' + TextoL3 + ' | ' + TextoL4, 2.0, 12.8, W - 4.0, FonteSub, False);
        CriarLabel(TextoL5, 2.0, 16.5, W - 4.0, 6, True);
        if Trim(Cod) <> '' then
        begin
          CriarBarras(Cod, 2.0, 20.2, W - 4.0, 6.5);
          CriarLabel(Cod, 2.0, 27.2, W - 4.0, 6, False);
        end;
      end;
      else
      begin
        CriarLabel(TextoL1, 2.0, 1.5, W - 4.0, FonteTit, True);
        CriarLabel(TextoL2, 2.0, 6.0, W - 4.0, FonteSub, False);
        CriarLabel(TextoL3, 2.0, 10.0, W - 4.0, FonteSub, False);
        CriarLabel(TextoL4 + ' ' + TextoL5, 2.0, 14.0, W - 4.0, FonteSub, False);
        if Trim(Cod) <> '' then
        begin
          CriarBarras(Cod, 2.0, 18.5, W - 4.0, 7.0);
          CriarLabel(Cod, 2.0, 26.0, W - 4.0, 6, False);
        end;
      end;
    end;
    Exit;
  end;

  // Etiquetas médias e grandes (Crachás 99x55.8 mm e Despacho 99x139 mm)
  Borda := TRLDraw.Create(Report);
  Borda.Parent := Report;
  Borda.DrawKind := dkRectangle;
  Borda.SetBounds(MM(X + 1.0), MM(Y + 1.0), MM(W - 2.0), MM(H - 2.0));

  if D.Finalidade = fpCracha then
  begin
    TopTexto := 3.0;
    if (D.CaminhoFoto <> '') and FileExists(D.CaminhoFoto) then
    begin
      Img := TRLImage.Create(Report);
      Img.Parent := Report;
      Img.Stretch := True;
      Img.SetBounds(MM(X + 3.0), MM(Y + 4.0), MM(22.0), MM(28.0));
      ImgTempIn := TImage.Create(nil);
      ImgTempOut := TImage.Create(nil);
      FiltroCinza := TGrayscaleFilter.Create(nil);
      FiltroContraste := TBrightnessContrastFilter.Create(nil);
      try
        ImgTempIn.Picture.LoadFromFile(D.CaminhoFoto);
        if D.FotoPB then
        begin
          FiltroCinza.InputImage := ImgTempIn;
          FiltroCinza.OutputImage := ImgTempOut;
          FiltroCinza.Apply;
          FiltroContraste.InputImage := ImgTempOut;
          FiltroContraste.OutputImage := ImgTempOut;
          FiltroContraste.Contrast := 1.25;
          FiltroContraste.Apply;
          Img.Picture.Assign(ImgTempOut.Picture);
        end
        else
          Img.Picture.Assign(ImgTempIn.Picture);
      finally
        FiltroContraste.Free;
        FiltroCinza.Free;
        ImgTempOut.Free;
        ImgTempIn.Free;
      end;
      CriarLabel(TextoL1, 27.0, 4.0, W - 30.0, 10, True);
      CriarLabel(TextoL2, 27.0, 10.5, W - 30.0, 11, True);
      CriarLabel(TextoL3, 27.0, 17.5, W - 30.0, 8, False);
      CriarLabel(TextoL4, 27.0, 23.0, W - 30.0, 8, False);
      CriarLabel(TextoL5, 27.0, 28.5, W - 30.0, 8, True);
    end
    else
    begin
      CriarLabel(TextoL1, 4.0, 3.5, W - 8.0, 11, True, True);
      CriarLabel(TextoL2, 4.0, 10.5, W - 8.0, 12, True, True);
      CriarLabel(TextoL3, 4.0, 18.0, W - 8.0, 9, False, True);
      CriarLabel(TextoL4, 4.0, 24.0, W - 8.0, 8, False, True);
      CriarLabel(TextoL5, 4.0, 29.5, W - 8.0, 8, True, True);
    end;
    if Trim(Cod) <> '' then
    begin
      AltBarra := 10.0;
      CriarBarras(Cod, 8.0, H - 18.0, W - 16.0, AltBarra);
      CriarLabel('ID: ' + Cod, 4.0, H - 6.8, W - 8.0, 7, False, True);
    end;
  end
  else if (D.Finalidade = fpDespacho) and (H >= 100.0) then
  begin
    CriarLabel('DESPACHO / EXPEDIÇÃO DE PRODUTOS', 4.0, 4.0, W - 8.0, 11, True);
    CriarLabel('REMETENTE: ' + TextoL1, 4.0, 12.0, W - 8.0, 8, False);
    CriarLabel('DESTINATÁRIO:', 4.0, 20.0, W - 8.0, 9, True);
    CriarLabel(TextoL2, 4.0, 26.0, W - 8.0, 12, True);
    CriarLabel(TextoL3, 4.0, 34.0, W - 8.0, 9, False);
    CriarLabel('CEP / CIDADE: ' + TextoL4, 4.0, 42.0, W - 8.0, 10, True);
    CriarLabel(Format('VOLUME: %d / %d   |   %s', [IndiceVolume, TotalVolumes, TextoL5]),
      4.0, 52.0, W - 8.0, 10, True);
    if Trim(Cod) <> '' then
    begin
      CriarBarras(Cod, 6.0, 64.0, W - 12.0, 18.0);
      CriarLabel('PEDIDO / NF / RASTREIO: ' + Cod, 4.0, 84.0, W - 8.0, 9, True);
    end;
  end
  else
  begin
    CriarLabel(TextoL1, 4.0, 4.0, W - 8.0, 10, True);
    CriarLabel(TextoL2, 4.0, 11.0, W - 8.0, 9, False);
    CriarLabel(TextoL3, 4.0, 17.5, W - 8.0, 9, False);
    CriarLabel(TextoL4, 4.0, 24.0, W - 8.0, 9, True);
    CriarLabel(TextoL5, 4.0, 30.5, W - 8.0, 8, False);
    if Trim(Cod) <> '' then
    begin
      CriarBarras(Cod, 4.0, H - 17.0, W - 8.0, 9.5);
      CriarLabel(Cod, 4.0, H - 6.8, W - 8.0, 7, False);
    end;
  end;
end;

function CriarRelatorioPimaco(AOwner: TComponent; const D: TDadosPimaco): TRLReport;
var
  Spec: TSpecPimaco;
  SlotInicial, CapacidadeFolha, TotalItens, I, SlotAtual, Lin, Col: Integer;
  PosX, PosY: Double;
  L1, L2, L3, L4, L5, Cod: string;
  UsouBanco: Boolean;
  SpecTab: TTabelaFinalidade;
  LinhasTab: TListaLinhasTabela;
  DadosItem: TDadosPimaco;
  function ValCampo(const Linha: TLinhaTabela; Idx: Integer): string;
  begin
    if Idx <= High(Linha.Valores) then
      Result := Linha.Valores[Idx]
    else
      Result := '';
  end;
begin
  Spec := ObterSpecPimaco(D.Modelo);
  CapacidadeFolha := Spec.Colunas * Spec.Linhas;
  SlotInicial := (D.LinhaInicial - 1) * Spec.Colunas + (D.ColunaInicial - 1);
  if (SlotInicial < 0) or (SlotInicial >= CapacidadeFolha) then
    raise Exception.Create('A posição inicial (linha/coluna) excede a capacidade da folha Pimaco selecionada.');
  if D.Quantidade < 1 then
    raise Exception.Create('Informe uma quantidade positiva de etiquetas.');

  Result := TRLReport.Create(AOwner);
  try
    Result.PageSetup.PaperSize := fpCustom;
    Result.PageSetup.Orientation := poPortrait;
    Result.PageSetup.PaperWidth := Spec.PapelW;
    Result.PageSetup.PaperHeight := Spec.PapelH;
    Result.Margins.LeftMargin := 0;
    Result.Margins.TopMargin := 0;
    Result.Margins.RightMargin := 0;
    Result.Margins.BottomMargin := 0;
    Result.PrintDialog := True;

    UsouBanco := False;
    if D.UsarBancoSelecionado and Assigned(fdmBase) then
    begin
      if fdmBase.zcon.Connected and ObterTabelaFinalidade(ChaveTabelaPimaco(Ord(D.Finalidade)), SpecTab) then
      begin
        LinhasTab := CarregarRegistrosTabela(fdmBase.zcon, SpecTab, '');
        if Length(LinhasTab) > 0 then
        begin
          UsouBanco := True;
          SlotAtual := SlotInicial;
          for I := High(LinhasTab) downto 0 do
          begin
            if SlotAtual >= CapacidadeFolha then Break;
            Lin := SlotAtual div Spec.Colunas;
            Col := SlotAtual mod Spec.Colunas;
            PosX := Spec.MargemEsq + Col * Spec.PassoH;
            PosY := Spec.MargemTopo + Lin * Spec.PassoV;
            DadosItem := D;
            if (D.Finalidade = fpCracha) and (ValCampo(LinhasTab[I], 6) <> '') then
              DadosItem.CaminhoFoto := ValCampo(LinhasTab[I], 6);
            DesenharCelulaPimaco(Result, Spec, DadosItem, PosX, PosY,
              ValCampo(LinhasTab[I], 0), ValCampo(LinhasTab[I], 1),
              ValCampo(LinhasTab[I], 2), ValCampo(LinhasTab[I], 3),
              ValCampo(LinhasTab[I], 4), ValCampo(LinhasTab[I], 5), 1, 1);
            Inc(SlotAtual);
          end;
        end;
      end;

      if (not UsouBanco) and (D.Finalidade = fpSupermercado) and fdmBase.zselproduct.Active and (not fdmBase.zselproduct.IsEmpty) then
      begin
        UsouBanco := True;
        SlotAtual := SlotInicial;
        fdmBase.zselproduct.First;
        while (not fdmBase.zselproduct.EOF) and (SlotAtual < CapacidadeFolha) do
        begin
          Lin := SlotAtual div Spec.Colunas;
          Col := SlotAtual mod Spec.Colunas;
          PosX := Spec.MargemEsq + Col * Spec.PassoH;
          PosY := Spec.MargemTopo + Lin * Spec.PassoV;
          L1 := fdmBase.zselproduct.FieldByName('productDesc').AsString;
          L2 := fdmBase.zselproduct.FieldByName('productDetail').AsString;
          L3 := fdmBase.zselproduct.FieldByName('Detail01').AsString;
          L4 := fdmBase.zselproduct.FieldByName('price').AsString;
          L5 := '';
          Cod := fdmBase.zselproduct.FieldByName('Detail02').AsString;
          DesenharCelulaPimaco(Result, Spec, D, PosX, PosY, L1, L2, L3, L4, L5, Cod, 1, 1);
          Inc(SlotAtual);
          fdmBase.zselproduct.Next;
        end;
      end
      else if (D.Finalidade = fpLaboratorio) and fdmBase.zseletqlab.Active and (not fdmBase.zseletqlab.IsEmpty) then
      begin
        UsouBanco := True;
        SlotAtual := SlotInicial;
        fdmBase.zseletqlab.First;
        while (not fdmBase.zseletqlab.EOF) and (SlotAtual < CapacidadeFolha) do
        begin
          Lin := SlotAtual div Spec.Colunas;
          Col := SlotAtual mod Spec.Colunas;
          PosX := Spec.MargemEsq + Col * Spec.PassoH;
          PosY := Spec.MargemTopo + Lin * Spec.PassoV;
          L1 := fdmBase.zseletqlab.FieldByName('rotulo01').AsString;
          L2 := fdmBase.zseletqlab.FieldByName('rotulo02').AsString;
          L3 := FormatDateTime('dd/mm/yyyy hh:nn', Now);
          L4 := '';
          L5 := '';
          Cod := fdmBase.zseletqlab.FieldByName('barcode').AsString;
          DesenharCelulaPimaco(Result, Spec, D, PosX, PosY, L1, L2, L3, L4, L5, Cod, 1, 1);
          Inc(SlotAtual);
          fdmBase.zseletqlab.Next;
        end;
      end
      else if (D.Finalidade = fpDespacho) and fdmBase.zselendereco.Active and (not fdmBase.zselendereco.IsEmpty) then
      begin
        UsouBanco := True;
        SlotAtual := SlotInicial;
        fdmBase.zselendereco.First;
        while (not fdmBase.zselendereco.EOF) and (SlotAtual < CapacidadeFolha) do
        begin
          Lin := SlotAtual div Spec.Colunas;
          Col := SlotAtual mod Spec.Colunas;
          PosX := Spec.MargemEsq + Col * Spec.PassoH;
          PosY := Spec.MargemTopo + Lin * Spec.PassoV;
          L1 := FSetMain.EMPRESA;
          L2 := fdmBase.zselendereco.FieldByName('Nome').AsString;
          L3 := fdmBase.zselendereco.FieldByName('Logradouro').AsString + ' - ' + fdmBase.zselendereco.FieldByName('Bairro').AsString;
          L4 := fdmBase.zselendereco.FieldByName('CEP').AsString + ' - ' + fdmBase.zselendereco.FieldByName('Cidade').AsString;
          L5 := fdmBase.zselendereco.FieldByName('Referencia').AsString;
          Cod := fdmBase.zselendereco.FieldByName('BARCODE').AsString;
          DesenharCelulaPimaco(Result, Spec, D, PosX, PosY, L1, L2, L3, L4, L5, Cod, 1, 1);
          Inc(SlotAtual);
          fdmBase.zselendereco.Next;
        end;
      end;
    end;

    if not UsouBanco then
    begin
      if Trim(D.Linha1) = '' then
        raise Exception.Create('Preencha ao menos o primeiro campo principal da etiqueta.');
      TotalItens := D.Quantidade;
      if SlotInicial + TotalItens > CapacidadeFolha then
        TotalItens := CapacidadeFolha - SlotInicial;
      for I := 0 to TotalItens - 1 do
      begin
        SlotAtual := SlotInicial + I;
        Lin := SlotAtual div Spec.Colunas;
        Col := SlotAtual mod Spec.Colunas;
        PosX := Spec.MargemEsq + Col * Spec.PassoH;
        PosY := Spec.MargemTopo + Lin * Spec.PassoV;
        DesenharCelulaPimaco(Result, Spec, D, PosX, PosY,
          D.Linha1, D.Linha2, D.Linha3, D.Linha4, D.Linha5, D.CodigoBarras,
          I + 1, TotalItens);
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

{ TfrmEtiquetasPimaco }

constructor TfrmEtiquetasPimaco.CreateComFinalidade(AOwner: TComponent;
  AFinalidade: TFinalidadePimaco; AModelo: TModeloPimaco);
var
  M: TModeloPimaco;
  I: Integer;
  L: TLabel;
  BtnImprimir: TButton;
begin
  inherited CreateNew(AOwner);
  Caption := 'Impressoras Convencionais — Exclusivo Papel A4 / Carta (Laser / Jato de Tinta)';
  Position := poScreenCenter;
  BorderStyle := bsDialog;
  ClientWidth := 840;
  ClientHeight := 648;

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := 'Modelo de Folha Pimaco / Papel (Laser ou Jato de Tinta):';
  L.Font.Style := [fsBold];
  L.SetBounds(20, 14, 480, 18);

  cbModelo := TComboBox.Create(Self);
  cbModelo.Parent := Self;
  cbModelo.Style := csDropDownList;
  cbModelo.SetBounds(20, 34, 520, 26);
  for M := Low(TModeloPimaco) to High(TModeloPimaco) do
    cbModelo.Items.Add(SpecsPimaco[M].Nome);
  cbModelo.ItemIndex := Ord(AModelo);
  cbModelo.OnChange := @AtualizarLimitesPosicao;

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := 'Finalidade / Setor da Etiqueta:';
  L.Font.Style := [fsBold];
  L.SetBounds(555, 14, 245, 18);

  cbFinalidade := TComboBox.Create(Self);
  cbFinalidade.Parent := Self;
  cbFinalidade.Style := csDropDownList;
  cbFinalidade.SetBounds(555, 34, 245, 26);
  cbFinalidade.Items.Add('Supermercado / Varejo (Preço/EAN)');
  cbFinalidade.Items.Add('Validade / Padaria (ANVISA RDC 216)');
  cbFinalidade.Items.Add('Laboratório (Tubos / Lâminas / Exames)');
  cbFinalidade.Items.Add('Medicamento Avulso / Posologia');
  cbFinalidade.Items.Add('Envio e Despacho de Produtos');
  cbFinalidade.Items.Add('Crachás (Visitante / Hospital / Varejo)');
  cbFinalidade.Items.Add('Aviso / Identificação A4 (Exclusivo Papel A4)');
  cbFinalidade.ItemIndex := Ord(AFinalidade);
  cbFinalidade.OnChange := @AtualizarCampos;

  lblInfoModelo := TLabel.Create(Self);
  lblInfoModelo.Parent := Self;
  lblInfoModelo.SetBounds(20, 68, 780, 18);

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := 'Linha inicial na folha:';
  L.SetBounds(20, 96, 130, 18);
  seLinhaIni := TSpinEdit.Create(Self);
  seLinhaIni.Parent := Self;
  seLinhaIni.MinValue := 1;
  seLinhaIni.Value := 1;
  seLinhaIni.SetBounds(150, 92, 65, 26);

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := 'Coluna inicial:';
  L.SetBounds(235, 96, 95, 18);
  seColunaIni := TSpinEdit.Create(Self);
  seColunaIni.Parent := Self;
  seColunaIni.MinValue := 1;
  seColunaIni.Value := 1;
  seColunaIni.SetBounds(330, 92, 65, 26);

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := 'Qtd. de etiquetas:';
  L.SetBounds(415, 96, 115, 18);
  seQuantidade := TSpinEdit.Create(Self);
  seQuantidade.Parent := Self;
  seQuantidade.MinValue := 1;
  seQuantidade.MaxValue := 96;
  seQuantidade.Value := 10;
  seQuantidade.SetBounds(530, 92, 75, 26);

  chkUsarBanco := TCheckBox.Create(Self);
  chkUsarBanco.Parent := Self;
  chkUsarBanco.Caption := 'Usar fila selecionada no banco (se houver)';
  chkUsarBanco.SetBounds(620, 95, 260, 22);

  for I := 0 to 5 do
  begin
    lblCampo[I] := TLabel.Create(Self);
    lblCampo[I].Parent := Self;
    lblCampo[I].SetBounds(20, 132 + I * 56, 510, 18);
    edCampo[I] := TEdit.Create(Self);
    edCampo[I].Parent := Self;
    edCampo[I].SetBounds(20, 152 + I * 56, 510, 26);
  end;

  pnlFoto := TPanel.Create(Self);
  pnlFoto.Parent := Self;
  pnlFoto.BevelOuter := bvLowered;
  pnlFoto.SetBounds(555, 132, 245, 330);

  L := TLabel.Create(Self);
  L.Parent := pnlFoto;
  L.Caption := 'Foto do Crachá (Filtro IA CHATGPT):';
  L.Font.Style := [fsBold];
  L.SetBounds(10, 8, 225, 18);

  imgFotoOrig := TImage.Create(Self);
  imgFotoOrig.Parent := pnlFoto;
  imgFotoOrig.Visible := False;

  imgFotoProc := TImage.Create(Self);
  imgFotoProc.Parent := pnlFoto;
  imgFotoProc.Stretch := True;
  imgFotoProc.Center := True;
  imgFotoProc.SetBounds(52, 32, 140, 175);

  chkFotoPB := TCheckBox.Create(Self);
  chkFotoPB.Parent := pnlFoto;
  chkFotoPB.Caption := 'Filtro P&B + Contraste (imagefilters)';
  chkFotoPB.Checked := True;
  chkFotoPB.SetBounds(12, 218, 220, 22);
  chkFotoPB.OnChange := @AtualizarCampos;

  btnCarregarFoto := TButton.Create(Self);
  btnCarregarFoto.Parent := pnlFoto;
  btnCarregarFoto.Caption := 'Selecionar Foto 3x4...';
  btnCarregarFoto.SetBounds(22, 250, 200, 30);
  btnCarregarFoto.OnClick := @CarregarFotoClick;

  FPainelBanco := TPainelBancoFinalidade.Create(Self);
  FPainelBanco.Parent := Self;
  FPainelBanco.SetBounds(20, 474, 800, 72);
  FPainelBanco.OnCarregarValores := @CarregarValoresBanco;
  FPainelBanco.OnObterValores := @ObterValoresBanco;

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.WordWrap := True;
  L.SetBounds(20, 554, 520, 42);
  L.Caption := 'Dica: Você pode reaproveitar folhas Pimaco já iniciadas informando a Linha e Coluna inicial da primeira etiqueta disponível na folha.';

  BtnImprimir := TButton.Create(Self);
  BtnImprimir.Parent := Self;
  BtnImprimir.Caption := 'Pré-visualizar / Imprimir Folha Pimaco';
  BtnImprimir.SetBounds(560, 598, 260, 36);
  BtnImprimir.OnClick := @VisualizarClick;

  AtualizarLimitesPosicao(nil);
  AtualizarCampos(nil);
end;

procedure TfrmEtiquetasPimaco.CarregarValoresBanco(const Valores: array of string);
var
  I: Integer;
begin
  for I := 0 to 5 do
  begin
    if I <= High(Valores) then
      edCampo[I].Text := Valores[I]
    else
      edCampo[I].Text := '';
  end;
  if (TFinalidadePimaco(cbFinalidade.ItemIndex) = fpCracha) and (Length(Valores) > 6) then
  begin
    FCaminhoFoto := Valores[6];
    ProcessarFotoPreview;
  end;
end;

procedure TfrmEtiquetasPimaco.ObterValoresBanco(out Valores: TStringArray);
var
  I, Total: Integer;
begin
  if TFinalidadePimaco(cbFinalidade.ItemIndex) = fpCracha then
    Total := 7
  else
    Total := 6;
  SetLength(Valores, Total);
  for I := 0 to 5 do
    Valores[I] := Trim(edCampo[I].Text);
  if TFinalidadePimaco(cbFinalidade.ItemIndex) = fpCracha then
    Valores[6] := FCaminhoFoto;
end;

procedure TfrmEtiquetasPimaco.AtualizarLimitesPosicao(Sender: TObject);
var
  Spec: TSpecPimaco;
begin
  Spec := ObterSpecPimaco(TModeloPimaco(cbModelo.ItemIndex));
  seLinhaIni.MaxValue := Spec.Linhas;
  if seLinhaIni.Value > Spec.Linhas then seLinhaIni.Value := 1;
  seColunaIni.MaxValue := Spec.Colunas;
  if seColunaIni.Value > Spec.Colunas then seColunaIni.Value := 1;
  seQuantidade.MaxValue := Spec.Colunas * Spec.Linhas;
  if seQuantidade.Value > seQuantidade.MaxValue then
    seQuantidade.Value := seQuantidade.MaxValue;
  lblInfoModelo.Caption := Format('Grade da folha: %d coluna(s) x %d linha(s) = %d etiqueta(s) por folha (%0.1f x %0.1f mm cada).',
    [Spec.Colunas, Spec.Linhas, Spec.Colunas * Spec.Linhas, Spec.LarguraEtq, Spec.AlturaEtq]);
end;

procedure TfrmEtiquetasPimaco.AtualizarCampos(Sender: TObject);
var
  Fin: TFinalidadePimaco;
begin
  Fin := TFinalidadePimaco(cbFinalidade.ItemIndex);
  pnlFoto.Visible := (Fin = fpCracha);
  if Assigned(FPainelBanco) then
    FPainelBanco.DefinirFinalidade(ChaveTabelaPimaco(Ord(Fin)));
  case Fin of
    fpSupermercado:
    begin
      lblCampo[0].Caption := 'Descrição do Produto *';
      lblCampo[1].Caption := 'Marca / Detalhe / Peso líquido';
      lblCampo[2].Caption := 'Preço por Kg / Litro (ex.: R$ 29,90/kg)';
      lblCampo[3].Caption := 'Preço de Venda em Destaque * (ex.: R$ 14,95)';
      lblCampo[4].Caption := 'Unidade / Observação de Oferta (ex.: UN / CX)';
      lblCampo[5].Caption := 'Código de Barras EAN-13 / PLU';
      if edCampo[0].Text = '' then
      begin
        edCampo[0].Text := 'CAFÉ TORRADO E MOÍDO 500G';
        edCampo[1].Text := 'Pacote 500g - Tradicional';
        edCampo[2].Text := 'Preço/kg: R$ 39,80';
        edCampo[3].Text := 'R$ 19,90';
        edCampo[4].Text := 'OFERTA';
        edCampo[5].Text := '7891234567895';
      end;
    end;
    fpValidadeANVISA:
    begin
      lblCampo[0].Caption := 'Produto Manipulado / Fracionado *';
      lblCampo[1].Caption := 'Data/Hora de Manipulação ou Abertura *';
      lblCampo[2].Caption := 'Data/Hora de Validade *';
      lblCampo[3].Caption := 'Conservação (ex.: Refrigerado 2°C a 8°C)';
      lblCampo[4].Caption := 'Responsável / Setor (Padaria, Açougue, Nutrição)';
      lblCampo[5].Caption := 'Lote / Código Interno (código de barras opcional)';
      edCampo[0].Text := 'PEITO DE PERU FATIADO';
      edCampo[1].Text := FormatDateTime('dd/mm/yyyy hh:nn', Now);
      edCampo[2].Text := FormatDateTime('dd/mm/yyyy hh:nn', Now + 3);
      edCampo[3].Text := 'REFRIGERADO ATÉ 5°C';
      edCampo[4].Text := 'Setor Frios / Padaria';
      edCampo[5].Text := 'LOTE202611';
    end;
    fpLaboratorio:
    begin
      lblCampo[0].Caption := 'Nome do Paciente *';
      lblCampo[1].Caption := 'Exame / Material Biológico (ex.: Hemograma - EDTA) *';
      lblCampo[2].Caption := 'Data e Hora da Coleta';
      lblCampo[3].Caption := 'Convênio / Bancada / Tubo';
      lblCampo[4].Caption := 'Médico Solicitante / Origem';
      lblCampo[5].Caption := 'Nº da Amostra / Atendimento (Código de Barras) *';
      edCampo[0].Text := 'MARIA APARECIDA SOUZA';
      edCampo[1].Text := 'HEMOGRAMA COMPLETO - SANGUE EDTA';
      edCampo[2].Text := FormatDateTime('dd/mm/yyyy hh:nn', Now);
      edCampo[3].Text := 'TUBO ROXO / BANCADA HEMATOLOGIA';
      edCampo[4].Text := 'AMB. CENTRAL';
      edCampo[5].Text := '202611140098';
    end;
    fpMedicamento:
    begin
      lblCampo[0].Caption := 'Medicamento / Princípio Ativo + Concentração *';
      lblCampo[1].Caption := 'Posologia / Modo de Usar (ex.: 1 comp. de 8/8h)';
      lblCampo[2].Caption := 'Lote e Fabricante';
      lblCampo[3].Caption := 'Validade (mm/aaaa ou dd/mm/aaaa)';
      lblCampo[4].Caption := 'Alerta / Farmacêutico Responsável (CRF)';
      lblCampo[5].Caption := 'Código de Barras / Rastreabilidade Unitária *';
      edCampo[0].Text := 'AMOXICILINA 500MG CÁPSULA';
      edCampo[1].Text := 'Tomar 01 cápsula a cada 08 horas por 07 dias';
      edCampo[2].Text := 'Lote: L88421';
      edCampo[3].Text := 'Val: 12/2027';
      edCampo[4].Text := 'USO SOB PRESCRIÇÃO - CRF/SP 12345';
      edCampo[5].Text := '7896543210128';
    end;
    fpDespacho:
    begin
      lblCampo[0].Caption := 'Remetente / Unidade Expedidora *';
      lblCampo[1].Caption := 'Destinatário / Cliente / Hospital *';
      lblCampo[2].Caption := 'Endereço de Entrega (Logradouro, Nº, Bairro) *';
      lblCampo[3].Caption := 'CEP e Cidade / UF *';
      lblCampo[4].Caption := 'Nota Fiscal / Conservação / Observações';
      lblCampo[5].Caption := 'Código de Rastreio / Pedido (Código de Barras) *';
      edCampo[0].Text := IfThenStr(FSetMain.EMPRESA <> '', FSetMain.EMPRESA, 'CENTRAL DE DISTRIBUIÇÃO MAURINSOFT');
      edCampo[1].Text := 'HOSPITAL SANTA CASA / ALMOXARIFADO';
      edCampo[2].Text := 'AV. INDEPENDÊNCIA, 1500 - CENTRO';
      edCampo[3].Text := '14010-000 - RIBEIRÃO PRETO / SP';
      edCampo[4].Text := 'NF 004512 - FRÁGIL';
      edCampo[5].Text := 'PED2026004512';
    end;
    fpCracha:
    begin
      lblCampo[0].Caption := 'Categoria no Topo * (ex.: VISITANTE / ACOMPANHANTE / COLABORADOR)';
      lblCampo[1].Caption := 'Nome Completo / Nome de Guerra *';
      lblCampo[2].Caption := 'Setor / Cargo OU Paciente / Quarto / Leito *';
      lblCampo[3].Caption := 'Documento (CPF / RG / Matrícula)';
      lblCampo[4].Caption := 'Empresa / Ala Hospitalar / Validade do Acesso';
      lblCampo[5].Caption := 'Código de Acesso / Matrícula (Código de Barras)';
      edCampo[0].Text := 'VISITANTE / ACOMPANHANTE';
      edCampo[1].Text := 'CARLOS EDUARDO FERREIRA';
      edCampo[2].Text := 'ALA SUL - QUARTO 304 - LEITO B';
      edCampo[3].Text := 'DOC: 345.678.901-00';
      edCampo[4].Text := 'ACESSO VÁLIDO EM: ' + FormatDateTime('dd/mm/yyyy', Now);
      edCampo[5].Text := 'VIS20260304';
      ProcessarFotoPreview;
    end;
    fpAvisoA4:
    begin
      lblCampo[0].Caption := 'Título Principal do Aviso / Caixa *';
      lblCampo[1].Caption := 'Setor / Subtítulo';
      lblCampo[2].Caption := 'Descrição / Instrução';
      lblCampo[3].Caption := 'Destaque / Identificação *';
      lblCampo[4].Caption := 'Responsável / Data';
      lblCampo[5].Caption := 'Código de Barras (Opcional)';
      edCampo[0].Text := 'IDENTIFICAÇÃO DE CAIXA / PALETE';
      edCampo[1].Text := 'ALMOXARIFADO CENTRAL - SETOR B';
      edCampo[2].Text := 'MANTER EM LOCAL SECO E AREJADO';
      edCampo[3].Text := 'CORREDOR 03 · PRATELEIRA A';
      edCampo[4].Text := 'Conferido em ' + FormatDateTime('dd/mm/yyyy', Now);
      edCampo[5].Text := 'CX20260301';
    end;
  end;
end;

procedure TfrmEtiquetasPimaco.CarregarFotoClick(Sender: TObject);
var
  Dlg: TOpenPictureDialog;
begin
  Dlg := TOpenPictureDialog.Create(Self);
  try
    if Dlg.Execute then
    begin
      FCaminhoFoto := Dlg.FileName;
      ProcessarFotoPreview;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmEtiquetasPimaco.ProcessarFotoPreview;
var
  FiltroCinza: TGrayscaleFilter;
  FiltroContraste: TBrightnessContrastFilter;
begin
  if (FCaminhoFoto = '') or (not FileExists(FCaminhoFoto)) then Exit;
  imgFotoOrig.Picture.LoadFromFile(FCaminhoFoto);
  if chkFotoPB.Checked then
  begin
    FiltroCinza := TGrayscaleFilter.Create(Self);
    FiltroContraste := TBrightnessContrastFilter.Create(Self);
    try
      FiltroCinza.InputImage := imgFotoOrig;
      FiltroCinza.OutputImage := imgFotoProc;
      FiltroCinza.Apply;
      FiltroContraste.InputImage := imgFotoProc;
      FiltroContraste.OutputImage := imgFotoProc;
      FiltroContraste.Contrast := 1.25;
      FiltroContraste.Apply;
    finally
      FiltroContraste.Free;
      FiltroCinza.Free;
    end;
  end
  else
    imgFotoProc.Picture.Assign(imgFotoOrig.Picture);
end;

procedure TfrmEtiquetasPimaco.ExecutarWizardPimaco(
  const OpcaoPapel: TOpcaoPapelWizard; Modo: TModoImpressaoWizard;
  Repeticoes: Integer; const Registros: TListaLinhasTabela; ApenasPrevia: Boolean);
var
  D: TDadosPimaco;
  Spec: TSpecPimaco;
  ItensExpandidos: TListaLinhasTabela;
  I, TotalItens, PosLista, SlotAtual, Capacidade, Offset, QtdPagina: Integer;
  R: TRLReport;
  Dlg: TPrintDialog;
  DadosItem: TDadosPimaco;
  PosX, PosY: Double;
  Lin, Col: Integer;
  function ValCampo(const Linha: TLinhaTabela; Idx: Integer): string;
  begin
    if Idx <= High(Linha.Valores) then Result := Linha.Valores[Idx] else Result := '';
  end;
begin
  D.Modelo := TModeloPimaco(StrToIntDef(OpcaoPapel.Codigo, cbModelo.ItemIndex));
  if Ord(D.Modelo) <> cbModelo.ItemIndex then
  begin
    cbModelo.ItemIndex := Ord(D.Modelo);
    AtualizarLimitesPosicao(nil);
  end;
  D.Finalidade := TFinalidadePimaco(cbFinalidade.ItemIndex);
  D.LinhaInicial := seLinhaIni.Value;
  D.ColunaInicial := seColunaIni.Value;
  D.Quantidade := seQuantidade.Value;
  D.UsarBancoSelecionado := False;
  D.CaminhoFoto := FCaminhoFoto;
  D.FotoPB := chkFotoPB.Checked;

  if Modo = miwUmRegistroNVezes then
  begin
    TotalItens := Max(1, Repeticoes);
    SetLength(ItensExpandidos, TotalItens);
    for I := 0 to TotalItens - 1 do
      ItensExpandidos[I] := Registros[0];
  end
  else
  begin
    TotalItens := Length(Registros);
    ItensExpandidos := Registros;
  end;

  if TotalItens = 0 then Exit;
  Spec := ObterSpecPimaco(D.Modelo);
  Capacidade := Spec.Colunas * Spec.Linhas;
  Offset := (D.LinhaInicial - 1) * Spec.Colunas + (D.ColunaInicial - 1);
  if (Offset < 0) or (Offset >= Capacidade) then
  begin
    MessageDlg('Etiquetas Pimaco / A4', 'Posição inicial excede a capacidade da folha.', mtWarning, [mbOK], 0);
    Exit;
  end;

  if not ApenasPrevia then
  begin
    Dlg := TPrintDialog.Create(Self);
    try
      if not Dlg.Execute then Exit;
    finally
      Dlg.Free;
    end;
  end;

  PosLista := 0;
  try
    while PosLista < TotalItens do
    begin
      QtdPagina := Min(Capacidade - Offset, TotalItens - PosLista);
      R := TRLReport.Create(Self);
      try
        R.PageSetup.PaperSize := fpCustom;
        R.PageSetup.Orientation := poPortrait;
        R.PageSetup.PaperWidth := Spec.PapelW;
        R.PageSetup.PaperHeight := Spec.PapelH;
        R.Margins.LeftMargin := 0;
        R.Margins.TopMargin := 0;
        R.Margins.RightMargin := 0;
        R.Margins.BottomMargin := 0;
        R.PrintDialog := False;

        for I := 0 to QtdPagina - 1 do
        begin
          SlotAtual := Offset + I;
          Lin := SlotAtual div Spec.Colunas;
          Col := SlotAtual mod Spec.Colunas;
          PosX := Spec.MargemEsq + Col * Spec.PassoH;
          PosY := Spec.MargemTopo + Lin * Spec.PassoV;
          DadosItem := D;
          if (D.Finalidade = fpCracha) and (ValCampo(ItensExpandidos[PosLista + I], 6) <> '') then
            DadosItem.CaminhoFoto := ValCampo(ItensExpandidos[PosLista + I], 6);
          DesenharCelulaPimaco(R, Spec, DadosItem, PosX, PosY,
            ValCampo(ItensExpandidos[PosLista + I], 0),
            ValCampo(ItensExpandidos[PosLista + I], 1),
            ValCampo(ItensExpandidos[PosLista + I], 2),
            ValCampo(ItensExpandidos[PosLista + I], 3),
            ValCampo(ItensExpandidos[PosLista + I], 4),
            ValCampo(ItensExpandidos[PosLista + I], 5),
            PosLista + I + 1, TotalItens);
        end;

        if ApenasPrevia then
        begin
          R.PreviewModal;
          Break;
        end
        else
          R.Print;
      finally
        R.Free;
      end;

      Inc(PosLista, QtdPagina);
      Offset := 0;
    end;
    if not ApenasPrevia then
      ShowMessage(Format('%d etiqueta(s) enviada(s) para impressão.', [TotalItens]));
  except
    on E: Exception do
      MessageDlg('Etiquetas Pimaco / A4', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TfrmEtiquetasPimaco.VisualizarClick(Sender: TObject);
var
  Opcoes: TOpcoesPapelWizard;
  M: TModeloPimaco;
  ValoresAtuais: TStringArray;
  Wiz: TfrmWizardImpressao;
begin
  SetLength(Opcoes, Ord(High(TModeloPimaco)) + 1);
  for M := Low(TModeloPimaco) to High(TModeloPimaco) do
  begin
    Opcoes[Ord(M)].Codigo := IntToStr(Ord(M));
    Opcoes[Ord(M)].Descricao := SpecsPimaco[M].Nome;
    Opcoes[Ord(M)].ChaveFinalidade := ChaveTabelaPimaco(cbFinalidade.ItemIndex);
  end;
  ObterValoresBanco(ValoresAtuais);
  Wiz := TfrmWizardImpressao.CreateWizard(Self, ChaveTabelaPimaco(cbFinalidade.ItemIndex),
    Opcoes, cbModelo.ItemIndex, ValoresAtuais, seQuantidade.Value);
  try
    Wiz.OnExecutarImpressao := @ExecutarWizardPimaco;
    Wiz.ShowModal;
  finally
    Wiz.Free;
  end;
  if Assigned(FPainelBanco) then
    FPainelBanco.AtualizarLista;
end;

end.
