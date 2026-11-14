unit etiquetasnovas;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Spin, Graphics,
  Dialogs, ExtDlgs, Printers, RLReport, RLBarcode, RLConsts, RLTypes,
  setmain, aiposprinter, imp_generico, aiserial, imagefilters;

type
  TModoImpressoraEtiqueta = (
    miZebraRolo,     // Impressora tipo Zebra / Rolo Adesivo (ZPL/EPL ou Driver Windows)
    miTermica80Col,  // Impressora Térmica Comum 80 Colunas (Bobina 80mm PDV)
    miTermica40Col   // Impressora Térmica 40 Colunas / 58mm (Tipo Maquininha de Cartão)
  );

  TModeloEtiquetaSetorial = (
    msLabTuboColeta,        // 0: Laboratório - Tubo de Coleta / Vacutainer (30x15 ou 51x25 mm)
    msLabLaminaBiopsia,     // 1: Laboratório - Lâmina de Biópsia / Citologia (25x15 mm)
    msLabBolsaSangue,       // 2: Laboratório - Bolsa de Sangue / Hemocomponentes (100x70 mm)
    msLabTransporteBio,     // 3: Laboratório - Transporte Biológico UN 3373 (100x100 mm)
    msMedAvulsoPosologia,   // 4: Farmácia - Medicamento Avulso / Posologia (60x40 mm)
    msMedFracionamento,     // 5: Farmácia Hospitalar - Dose Unitária / Fracionamento (40x30 mm)
    msMedSoroInfusao,       // 6: Hospital - Rótulo de Soro / Infusão Endovenosa (80x50 mm)
    msSupGondolaKg,         // 7: Supermercado - Gôndola com Preço/Kg e Oferta (100x35 mm)
    msSupBalancaPadaria,    // 8: Supermercado - Balança Padaria/Açougue/Frios EAN-13 (60x40 mm)
    msSupValidadeANVISA,    // 9: Supermercado/Saúde - Validade ANVISA RDC 216 (50x30 mm)
    msEnvioDespachoVolumes, // 10: Logística - Envio e Despacho de Produtos (100x150 mm)
    msCrachaVisitanteHosp,  // 11: Hospital - Crachá Visitante / Acompanhante (80x50 mm)
    msCrachaFuncionario     // 12: Varejo/Saúde - Crachá Funcionário / Operador c/ Foto (54x86 mm)
  );

  TCamposSetoriais = array[0..7] of string;

  { TfrmEtiquetasSetoriais }

  TfrmEtiquetasSetoriais = class(TForm)
  private
    FModo: TModoImpressoraEtiqueta;
    FModelo: TModeloEtiquetaSetorial;
    cbModoImpressora: TComboBox;
    cbModeloEtiqueta: TComboBox;
    lblDimensao: TLabel;
    lblCampo: array[0..7] of TLabel;
    edCampo: array[0..7] of TEdit;
    seCopias: TSpinEdit;
    cbPortaPOS: TComboBox;
    edHostPOS: TEdit;
    btnGerarEANBalanca: TButton;
    btnFotoCracha: TButton;
    chkFotoPB: TCheckBox;
    FCaminhoFoto: string;
    procedure AtualizarInterface(Sender: TObject);
    procedure GerarEANBalancaClick(Sender: TObject);
    procedure SelecionarFotoClick(Sender: TObject);
    procedure VisualizarGraficoClick(Sender: TObject);
    procedure EnviarPOSDiretoClick(Sender: TObject);
  public
    constructor CreateSetorial(AOwner: TComponent;
      AModo: TModoImpressoraEtiqueta; AModelo: TModeloEtiquetaSetorial);
  end;

function CalcularEAN13Balanca(const CodigoPLU: string; ValorOuPeso: Double): string;
function CriarRelatorioSetorial(AOwner: TComponent;
  AModo: TModoImpressoraEtiqueta; AModelo: TModeloEtiquetaSetorial;
  const C: TCamposSetoriais; const CaminhoFoto: string = '';
  FotoPB: Boolean = True): TRLReport;

implementation

const
  NomesModelosSetoriais: array[TModeloEtiquetaSetorial] of string = (
    'Laboratório: Tubo de Coleta / Vacutainer (30 x 15 mm / 51 x 25 mm)',
    'Laboratório: Lâmina de Biópsia / Patologia / Citologia (25 x 15 mm)',
    'Laboratório / Hemoterapia: Bolsa de Sangue / Hemocomponentes (100 x 70 mm)',
    'Laboratório: Transporte Material Biológico UN 3373 (100 x 100 mm)',
    'Farmácia: Medicamento Avulso / Posologia / Receituário (60 x 40 mm)',
    'Farmácia Hospitalar: Unitarização / Dose Unitária (40 x 30 mm)',
    'Hospitalar: Rótulo de Soro / Infusão Endovenosa (80 x 50 mm)',
    'Supermercado: Gôndola Preço + Preço por Kg/Litro / Oferta (100 x 35 mm)',
    'Supermercado: Balança Padaria / Açougue / Frios EAN-13 (60 x 40 mm)',
    'Supermercado & Saúde: Controle de Validade ANVISA RDC 216 (50 x 30 mm)',
    'Logística & Varejo: Envio e Despacho de Produtos (100 x 150 mm)',
    'Hospitalar: Crachá de Visitante / Acompanhante (80 x 50 mm)',
    'Varejo & Saúde: Crachá de Funcionário / Operador c/ Foto (54 x 86 mm)'
  );

function MM(V: Double): Integer;
begin
  Result := Round(V * ScreenPPI / 25.4);
end;

function CalcularEAN13Balanca(const CodigoPLU: string; ValorOuPeso: Double): string;
var
  PLU, ValorInt, Base12: string;
  I, Soma, Digito, PesoMult: Integer;
begin
  PLU := Trim(CodigoPLU);
  while Length(PLU) < 5 do PLU := '0' + PLU;
  if Length(PLU) > 5 then PLU := Copy(PLU, 1, 5);
  ValorInt := Format('%.5d', [Round(Abs(ValorOuPeso) * 100) mod 100000]);
  Base12 := '2' + PLU + ValorInt;
  Soma := 0;
  for I := 1 to 12 do
  begin
    if (I mod 2) = 0 then PesoMult := 3 else PesoMult := 1;
    Soma := Soma + StrToIntDef(Base12[I], 0) * PesoMult;
  end;
  Digito := (10 - (Soma mod 10)) mod 10;
  Result := Base12 + IntToStr(Digito);
end;

procedure DimensoesPapelSetorial(AModo: TModoImpressoraEtiqueta;
  AModelo: TModeloEtiquetaSetorial; out W, H: Double);
begin
  case AModo of
    miTermica80Col:
    begin
      W := 80.0;
      case AModelo of
        msEnvioDespachoVolumes, msLabTransporteBio: H := 110.0;
        msMedSoroInfusao, msLabBolsaSangue: H := 75.0;
        else H := 55.0;
      end;
    end;
    miTermica40Col:
    begin
      W := 58.0;
      case AModelo of
        msEnvioDespachoVolumes, msLabTransporteBio: H := 85.0;
        else H := 45.0;
      end;
    end;
    else // miZebraRolo
    begin
      case AModelo of
        msLabTuboColeta:        begin W := 51.0;  H := 25.0;  end;
        msLabLaminaBiopsia:     begin W := 25.0;  H := 15.0;  end;
        msLabBolsaSangue:       begin W := 100.0; H := 70.0;  end;
        msLabTransporteBio:     begin W := 100.0; H := 100.0; end;
        msMedAvulsoPosologia:   begin W := 60.0;  H := 40.0;  end;
        msMedFracionamento:     begin W := 40.0;  H := 30.0;  end;
        msMedSoroInfusao:       begin W := 80.0;  H := 50.0;  end;
        msSupGondolaKg:         begin W := 100.0; H := 35.0;  end;
        msSupBalancaPadaria:    begin W := 60.0;  H := 40.0;  end;
        msSupValidadeANVISA:    begin W := 50.0;  H := 30.0;  end;
        msEnvioDespachoVolumes: begin W := 100.0; H := 150.0; end;
        msCrachaVisitanteHosp:  begin W := 80.0;  H := 50.0;  end;
        msCrachaFuncionario:    begin W := 54.0;  H := 86.0;  end;
      end;
    end;
  end;
end;

function CriarRelatorioSetorial(AOwner: TComponent;
  AModo: TModoImpressoraEtiqueta; AModelo: TModeloEtiquetaSetorial;
  const C: TCamposSetoriais; const CaminhoFoto: string;
  FotoPB: Boolean): TRLReport;
var
  W, H, YPos, Passo, AltBarra: Double;
  FTitle, FBody: Integer;
  Borda: TRLDraw;
  Img: TRLImage;
  ImgIn, ImgOut: TImage;
  FiltroCinza: TGrayscaleFilter;
  FiltroContraste: TBrightnessContrastFilter;
  Cabecalho: string;

  procedure AddLinha(const Txt: string; X, Y, MaxW: Double; Tam: Integer;
    Bold: Boolean = False; Center: Boolean = False);
  var
    L: TRLLabel;
  begin
    if Trim(Txt) = '' then Exit;
    L := TRLLabel.Create(Result);
    L.Parent := Result;
    L.Font.Name := 'Arial';
    L.Font.Size := Tam;
    L.Font.Color := clBlack;
    if Bold then L.Font.Style := [fsBold];
    L.AutoSize := False;
    L.Left := MM(X);
    L.Top := MM(Y);
    L.Width := MM(MaxW);
    L.Height := MM(Tam * 0.46 + 1.5);
    if Center then L.Alignment := taCenter;
    L.Caption := Trim(Txt);
  end;

  procedure AddBarras(const Codigo: string; X, Y, MaxW, Alt: Double);
  var
    B: TRLBarcode;
    J: Integer;
    ParNum: Boolean;
  begin
    if Trim(Codigo) = '' then Exit;
    for J := 1 to Length(Codigo) do
      if not (Codigo[J] in ['A'..'Z', 'a'..'z', '0'..'9', '-', '.', '/']) then
        Exit;
    B := TRLBarcode.Create(Result);
    B.Parent := Result;
    ParNum := (Length(Codigo) mod 2 = 0);
    for J := 1 to Length(Codigo) do
      ParNum := ParNum and (Codigo[J] in ['0'..'9']);
    if ParNum then B.BarcodeType := bcCode128C else B.BarcodeType := bcCode128B;
    B.Module := 1;
    B.ShowText := boNone;
    B.Caption := Trim(Codigo);
    B.Left := MM(X);
    B.Top := MM(Y);
    B.Height := MM(Alt);
    if B.Width > MM(MaxW) then
      B.Width := MM(MaxW);
  end;

begin
  if Trim(C[0]) = '' then
    raise Exception.Create('Preencha ao menos o primeiro campo obrigatório da etiqueta.');

  DimensoesPapelSetorial(AModo, AModelo, W, H);
  Result := TRLReport.Create(AOwner);
  try
    Result.PageSetup.PaperSize := fpCustom;
    Result.PageSetup.Orientation := poPortrait;
    Result.PageSetup.PaperWidth := W;
    Result.PageSetup.PaperHeight := H;
    Result.Margins.LeftMargin := 0;
    Result.Margins.TopMargin := 0;
    Result.Margins.RightMargin := 0;
    Result.Margins.BottomMargin := 0;
    Result.PrintDialog := True;

    if (AModelo = msLabLaminaBiopsia) and (AModo = miZebraRolo) then
    begin
      AddLinha(C[0], 1.0, 0.8, W - 2.0, 6, True);
      AddLinha(C[1], 1.0, 3.6, W - 2.0, 5, False);
      AddLinha(C[2], 1.0, 6.2, W - 2.0, 5, False);
      if Trim(C[7]) <> '' then
      begin
        AddBarras(C[7], 1.0, 8.6, W - 2.0, 4.0);
        AddLinha(C[7], 1.0, 12.8, W - 2.0, 5, False);
      end;
      Exit;
    end;

    if (AModelo = msCrachaFuncionario) and (AModo = miZebraRolo) then
    begin
      Borda := TRLDraw.Create(Result);
      Borda.Parent := Result;
      Borda.DrawKind := dkRectangle;
      Borda.SetBounds(MM(1.5), MM(1.5), MM(W - 3.0), MM(H - 3.0));
      AddLinha(C[0], 3.0, 3.5, W - 6.0, 8, True, True);
      if (CaminhoFoto <> '') and FileExists(CaminhoFoto) then
      begin
        Img := TRLImage.Create(Result);
        Img.Parent := Result;
        Img.Stretch := True;
        Img.SetBounds(MM((W - 24.0) / 2), MM(10.0), MM(24.0), MM(30.0));
        ImgIn := TImage.Create(nil);
        ImgOut := TImage.Create(nil);
        FiltroCinza := TGrayscaleFilter.Create(nil);
        FiltroContraste := TBrightnessContrastFilter.Create(nil);
        try
          ImgIn.Picture.LoadFromFile(CaminhoFoto);
          if FotoPB then
          begin
            FiltroCinza.InputImage := ImgIn;
            FiltroCinza.OutputImage := ImgOut;
            FiltroCinza.Apply;
            FiltroContraste.InputImage := ImgOut;
            FiltroContraste.OutputImage := ImgOut;
            FiltroContraste.Contrast := 1.25;
            FiltroContraste.Apply;
            Img.Picture.Assign(ImgOut.Picture);
          end
          else
            Img.Picture.Assign(ImgIn.Picture);
        finally
          FiltroContraste.Free;
          FiltroCinza.Free;
          ImgOut.Free;
          ImgIn.Free;
        end;
      end;
      AddLinha(C[1], 3.0, 42.0, W - 6.0, 10, True, True);
      AddLinha(C[2], 3.0, 48.0, W - 6.0, 8, True, True);
      AddLinha(C[3], 3.0, 53.5, W - 6.0, 7, False, True);
      AddLinha(C[4], 3.0, 58.5, W - 6.0, 7, False, True);
      if Trim(C[7]) <> '' then
      begin
        AddBarras(C[7], 5.0, 65.0, W - 10.0, 12.0);
        AddLinha(C[7], 3.0, 78.5, W - 6.0, 7, False, True);
      end;
      Exit;
    end;

    case AModelo of
      msLabTuboColeta:        Cabecalho := 'LABORATÓRIO - AMOSTRA / TUBO';
      msLabLaminaBiopsia:     Cabecalho := 'PATOLOGIA / BIÓPSIA';
      msLabBolsaSangue:       Cabecalho := 'HEMOTERAPIA - BOLSA DE SANGUE';
      msLabTransporteBio:     Cabecalho := 'SUBSTÂNCIA BIOLÓGICA CAT. B - UN 3373';
      msMedAvulsoPosologia:   Cabecalho := 'FARMÁCIA - ORIENTAÇÃO E POSOLOGIA';
      msMedFracionamento:     Cabecalho := 'DOSE UNITÁRIA / FRACIONAMENTO';
      msMedSoroInfusao:       Cabecalho := 'CONTROLE DE SORO / INFUSÃO EV';
      msSupGondolaKg:         Cabecalho := 'OFERTA / PREÇO DE GÔNDOLA';
      msSupBalancaPadaria:    Cabecalho := 'PADARIA / AÇOUGUE / PERECÍVEIS';
      msSupValidadeANVISA:    Cabecalho := 'VALIDADE ANVISA RDC 216';
      msEnvioDespachoVolumes: Cabecalho := 'EXPEDIÇÃO E DESPACHO DE PRODUTOS';
      msCrachaVisitanteHosp:  Cabecalho := 'CONTROLE DE ACESSO / VISITANTE';
      msCrachaFuncionario:    Cabecalho := 'IDENTIFICAÇÃO FUNCIONAL';
    end;

    if H <= 32.0 then
    begin
      FTitle := 7;
      FBody := 6;
      Passo := 3.4;
      AltBarra := 6.0;
    end
    else if H <= 55.0 then
    begin
      FTitle := 8;
      FBody := 7;
      Passo := 4.4;
      AltBarra := 8.5;
    end
    else
    begin
      FTitle := 10;
      FBody := 9;
      Passo := 6.0;
      AltBarra := 13.0;
    end;

    YPos := 2.0;
    AddLinha(Cabecalho, 2.5, YPos, W - 5.0, FTitle, True, (AModo <> miZebraRolo));
    YPos := YPos + Passo + 0.5;
    AddLinha(C[0], 2.5, YPos, W - 5.0, FTitle + 1, True);
    YPos := YPos + Passo + 0.5;
    if Trim(C[1]) <> '' then begin AddLinha(C[1], 2.5, YPos, W - 5.0, FBody, False); YPos := YPos + Passo; end;
    if Trim(C[2]) <> '' then begin AddLinha(C[2], 2.5, YPos, W - 5.0, FBody, True);  YPos := YPos + Passo; end;
    if Trim(C[3]) <> '' then begin AddLinha(C[3], 2.5, YPos, W - 5.0, FBody, False); YPos := YPos + Passo; end;
    if Trim(C[4]) <> '' then begin AddLinha(C[4], 2.5, YPos, W - 5.0, FBody, False); YPos := YPos + Passo; end;
    if Trim(C[5]) <> '' then begin AddLinha(C[5], 2.5, YPos, W - 5.0, FBody, True);  YPos := YPos + Passo; end;
    if Trim(C[6]) <> '' then begin AddLinha(C[6], 2.5, YPos, W - 5.0, FBody, False); YPos := YPos + Passo; end;

    if Trim(C[7]) <> '' then
    begin
      if YPos + AltBarra + 4.5 > H then
        YPos := H - AltBarra - 4.5;
      AddBarras(C[7], 2.5, YPos, W - 5.0, AltBarra);
      AddLinha(C[7], 2.5, YPos + AltBarra + 0.5, W - 5.0, FBody, False, True);
    end;
  except
    Result.Free;
    raise;
  end;
end;

{ TfrmEtiquetasSetoriais }

constructor TfrmEtiquetasSetoriais.CreateSetorial(AOwner: TComponent;
  AModo: TModoImpressoraEtiqueta; AModelo: TModeloEtiquetaSetorial);
var
  M: TModeloEtiquetaSetorial;
  I: Integer;
  L: TLabel;
  BtnGrafico, BtnPOS: TButton;
begin
  inherited CreateNew(AOwner);
  FModo := AModo;
  FModelo := AModelo;
  Caption := 'Emissão de Etiquetas — Saúde, Higiene, Supermercado, Despacho e Crachás';
  Position := poScreenCenter;
  BorderStyle := bsDialog;
  ClientWidth := 820;
  ClientHeight := 555;

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := '1. Tipo de Impressora Selecionada:';
  L.Font.Style := [fsBold];
  L.SetBounds(20, 14, 280, 18);

  cbModoImpressora := TComboBox.Create(Self);
  cbModoImpressora.Parent := Self;
  cbModoImpressora.Style := csDropDownList;
  cbModoImpressora.SetBounds(20, 34, 340, 26);
  cbModoImpressora.Items.Add('Impressora Tipo Zebra / Etiquetadora de Rolo');
  cbModoImpressora.Items.Add('Impressora Térmica Comum 80 Colunas (Bobina 80mm)');
  cbModoImpressora.Items.Add('Impressora Térmica 40 Colunas / 58mm (Maquininha)');
  cbModoImpressora.ItemIndex := Ord(AModo);
  cbModoImpressora.OnChange := @AtualizarInterface;

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := '2. Modelo de Etiqueta (Saúde, Supermercado, Logística ou Crachá):';
  L.Font.Style := [fsBold];
  L.SetBounds(380, 14, 420, 18);

  cbModeloEtiqueta := TComboBox.Create(Self);
  cbModeloEtiqueta.Parent := Self;
  cbModeloEtiqueta.Style := csDropDownList;
  cbModeloEtiqueta.SetBounds(380, 34, 420, 26);
  for M := Low(TModeloEtiquetaSetorial) to High(TModeloEtiquetaSetorial) do
    cbModeloEtiqueta.Items.Add(NomesModelosSetoriais[M]);
  cbModeloEtiqueta.ItemIndex := Ord(AModelo);
  cbModeloEtiqueta.OnChange := @AtualizarInterface;

  lblDimensao := TLabel.Create(Self);
  lblDimensao.Parent := Self;
  lblDimensao.SetBounds(20, 68, 780, 18);

  for I := 0 to 7 do
  begin
    lblCampo[I] := TLabel.Create(Self);
    lblCampo[I].Parent := Self;
    lblCampo[I].SetBounds(20 + (I div 4) * 400, 96 + (I mod 4) * 64, 380, 18);
    edCampo[I] := TEdit.Create(Self);
    edCampo[I].Parent := Self;
    edCampo[I].SetBounds(20 + (I div 4) * 400, 116 + (I mod 4) * 64, 380, 26);
  end;

  btnGerarEANBalanca := TButton.Create(Self);
  btnGerarEANBalanca.Parent := Self;
  btnGerarEANBalanca.Caption := 'Calcular EAN-13 de Balança (Prefixo 2)';
  btnGerarEANBalanca.SetBounds(20, 360, 280, 28);
  btnGerarEANBalanca.OnClick := @GerarEANBalancaClick;

  btnFotoCracha := TButton.Create(Self);
  btnFotoCracha.Parent := Self;
  btnFotoCracha.Caption := 'Carregar Foto 3x4 para Crachá...';
  btnFotoCracha.SetBounds(315, 360, 230, 28);
  btnFotoCracha.OnClick := @SelecionarFotoClick;

  chkFotoPB := TCheckBox.Create(Self);
  chkFotoPB.Parent := Self;
  chkFotoPB.Caption := 'Otimizar foto P&B para térmica (imagefilters CHATGPT)';
  chkFotoPB.Checked := True;
  chkFotoPB.SetBounds(560, 364, 250, 22);

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := 'Porta Serial / USB (TAIPOSPrinter):';
  L.SetBounds(20, 408, 200, 18);
  cbPortaPOS := TComboBox.Create(Self);
  cbPortaPOS.Parent := Self;
  cbPortaPOS.SetBounds(20, 428, 120, 26);
  cbPortaPOS.Items.AddStrings(['COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM10']);
  cbPortaPOS.ItemIndex := 0;

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := 'Ou IP Rede (Porta 9100, opcional):';
  L.SetBounds(160, 408, 200, 18);
  edHostPOS := TEdit.Create(Self);
  edHostPOS.Parent := Self;
  edHostPOS.SetBounds(160, 428, 160, 26);
  edHostPOS.Text := '';

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Caption := 'Quantidade / Volumes:';
  L.SetBounds(340, 408, 140, 18);
  seCopias := TSpinEdit.Create(Self);
  seCopias.Parent := Self;
  seCopias.MinValue := 1;
  seCopias.MaxValue := 500;
  seCopias.Value := 1;
  seCopias.SetBounds(340, 428, 80, 26);

  BtnGrafico := TButton.Create(Self);
  BtnGrafico.Parent := Self;
  BtnGrafico.Caption := 'Pré-visualizar / Imprimir Gráfico (Driver Windows)';
  BtnGrafico.SetBounds(20, 490, 380, 38);
  BtnGrafico.OnClick := @VisualizarGraficoClick;

  BtnPOS := TButton.Create(Self);
  BtnPOS.Parent := Self;
  BtnPOS.Caption := 'Imprimir Direto via TAIPOSPrinter (ESC/POS ou ZPL)';
  BtnPOS.SetBounds(420, 490, 380, 38);
  BtnPOS.OnClick := @EnviarPOSDiretoClick;

  AtualizarInterface(nil);
end;

procedure TfrmEtiquetasSetoriais.AtualizarInterface(Sender: TObject);
var
  W, H: Double;
begin
  FModo := TModoImpressoraEtiqueta(cbModoImpressora.ItemIndex);
  FModelo := TModeloEtiquetaSetorial(cbModeloEtiqueta.ItemIndex);
  DimensoesPapelSetorial(FModo, FModelo, W, H);
  lblDimensao.Caption := Format('Dimensão configurada para este modo: %.1f x %.1f mm | Motor: FortesReport + TAIPOSPrinter (CHATGPT)', [W, H]);

  btnGerarEANBalanca.Visible := (FModelo = msSupBalancaPadaria);
  btnFotoCracha.Visible := (FModelo in [msCrachaVisitanteHosp, msCrachaFuncionario]);
  chkFotoPB.Visible := btnFotoCracha.Visible;

  case FModelo of
    msLabTuboColeta:
    begin
      lblCampo[0].Caption := 'Nome do Paciente *';
      lblCampo[1].Caption := 'Data de Nascimento / Idade / Sexo';
      lblCampo[2].Caption := 'Exame / Material (ex.: Hemograma - Sangue EDTA) *';
      lblCampo[3].Caption := 'Tubo / Tampa e Bancada (ex.: Tampa Roxa - Hematologia)';
      lblCampo[4].Caption := 'Data e Hora da Coleta';
      lblCampo[5].Caption := 'Unidade / Leito / Origem';
      lblCampo[6].Caption := 'Observação Clínica (Jejum / Urgência)';
      lblCampo[7].Caption := 'Nº da Amostra / Código de Barras *';
      edCampo[0].Text := 'JOÃO CARLOS MENDES';
      edCampo[1].Text := 'DN: 14/05/1982 (44a) - M';
      edCampo[2].Text := 'HEMOGRAMA + GLICEMIA';
      edCampo[3].Text := 'TUBO EDTA ROXO - BANCADA 01';
      edCampo[4].Text := FormatDateTime('dd/mm/yyyy hh:nn', Now);
      edCampo[5].Text := 'UTI ADULTO - LEITO 04';
      edCampo[6].Text := 'ROTINA / URGENTE';
      edCampo[7].Text := '2026111401';
    end;
    msLabLaminaBiopsia:
    begin
      lblCampo[0].Caption := 'Nº do Bloco / Lâmina *';
      lblCampo[1].Caption := 'Iniciais do Paciente + Prontuário *';
      lblCampo[2].Caption := 'Topografia / Peça Anatômica (ex.: Antro Gástrico)';
      lblCampo[3].Caption := 'Coloração (ex.: H&E / Giemsa)';
      lblCampo[4].Caption := 'Data do Processamento';
      lblCampo[5].Caption := 'Patologista Responsável';
      lblCampo[6].Caption := 'Fragmento / Corte (ex.: Corte 1/3)';
      lblCampo[7].Caption := 'Código Compacto da Lâmina (Barras) *';
      edCampo[0].Text := 'AP-26-04912';
      edCampo[1].Text := 'M.A.S. #9921';
      edCampo[2].Text := 'BIÓPSIA GÁSTRICA (H&E)';
      edCampo[3].Text := 'H&E';
      edCampo[4].Text := FormatDateTime('dd/mm/yyyy', Now);
      edCampo[5].Text := 'DR. ROBERTO';
      edCampo[6].Text := 'CORTE 1/2';
      edCampo[7].Text := '26049121';
    end;
    msLabBolsaSangue:
    begin
      lblCampo[0].Caption := 'Grupo Sanguíneo ABO / Fator Rh em Destaque *';
      lblCampo[1].Caption := 'Hemocomponente (ex.: Concentrado de Hemácias) *';
      lblCampo[2].Caption := 'Volume (ml) e Anticoagulante (CPDA-1 / SAG-M)';
      lblCampo[3].Caption := 'Data da Coleta e Data de Validade *';
      lblCampo[4].Caption := 'Sorologia / Testes Imuno-hematológicos';
      lblCampo[5].Caption := 'Paciente Receptor / Prova Cruzada (se reservada)';
      lblCampo[6].Caption := 'Temperatura de Conservação (ex.: 2°C a 6°C)';
      lblCampo[7].Caption := 'Nº da Bolsa / ISBT (Código de Barras) *';
      edCampo[0].Text := 'TIPO: O POSITIVO (O Rh+)';
      edCampo[1].Text := 'CONCENTRADO DE HEMÁCIAS DESLEUCOCITADO';
      edCampo[2].Text := 'Volume: 310 ml | Solução SAG-M';
      edCampo[3].Text := 'Coleta: 10/11/2026 | Validade: 22/12/2026';
      edCampo[4].Text := 'SOROLOGIA NÃO REAGENTE - LIBERADA';
      edCampo[5].Text := 'RESERVA: CENTRO CIRÚRGICO SALA 02';
      edCampo[6].Text := 'CONSERVAR ENTRE 2°C E 6°C';
      edCampo[7].Text := 'BS2026008914';
    end;
    msLabTransporteBio:
    begin
      lblCampo[0].Caption := 'Classificação ONU / ANVISA *';
      lblCampo[1].Caption := 'Laboratório / Unidade Remetente *';
      lblCampo[2].Caption := 'Laboratório Central / Destinatário *';
      lblCampo[3].Caption := 'Faixa de Temperatura Exigida *';
      lblCampo[4].Caption := 'Quantidade e Tipo de Amostras no Malote';
      lblCampo[5].Caption := 'Responsável pelo Envio e Data/Hora';
      lblCampo[6].Caption := 'Telefone de Emergência 24h';
      lblCampo[7].Caption := 'Código do Malote / Lacre (Código de Barras) *';
      edCampo[0].Text := 'UN 3373 - SUBSTÂNCIA BIOLÓGICA CATEGORIA B';
      edCampo[1].Text := 'POSTO DE COLETA UNIDADE NORTE';
      edCampo[2].Text := 'LABORATÓRIO CENTRAL DE ANÁLISES CLÍNICAS';
      edCampo[3].Text := 'REFRIGERADO: 2°C A 8°C (GELO RECICLÁVEL)';
      edCampo[4].Text := '24 TUBOS (SORO / EDTA / CITRATO)';
      edCampo[5].Text := 'Envio: ' + FormatDateTime('dd/mm/yyyy hh:nn', Now);
      edCampo[6].Text := 'EMERGÊNCIA: 0800-770-3373';
      edCampo[7].Text := 'MAL2026111409';
    end;
    msMedAvulsoPosologia:
    begin
      lblCampo[0].Caption := 'Medicamento + Concentração *';
      lblCampo[1].Caption := 'Nome do Paciente';
      lblCampo[2].Caption := 'Posologia / Instrução de Uso *';
      lblCampo[3].Caption := 'Horários Sugeridos da Medicação';
      lblCampo[4].Caption := 'Lote e Data de Validade';
      lblCampo[5].Caption := 'Advertências / Conservação';
      lblCampo[6].Caption := 'Farmacêutico Responsável (CRF)';
      lblCampo[7].Caption := 'Código de Barras / EAN do Medicamento';
      edCampo[0].Text := 'DIPIRONA MONOIDRATADA 500MG';
      edCampo[1].Text := 'Paciente: ANA PAULA RIBEIRO';
      edCampo[2].Text := 'Tomar 01 comprimido de 6 em 6 horas se dor ou febre';
      edCampo[3].Text := 'Horários: 06:00 - 12:00 - 18:00 - 00:00';
      edCampo[4].Text := 'Lote: DP9021 | Validade: 08/2028';
      edCampo[5].Text := 'Conservar em temp. ambiente (15°C a 30°C)';
      edCampo[6].Text := 'Farm. Resp.: Dra. Camila - CRF/SP 44512';
      edCampo[7].Text := '7891058001234';
    end;
    msMedFracionamento:
    begin
      lblCampo[0].Caption := 'Princípio Ativo (DCB) + Dose *';
      lblCampo[1].Caption := 'Forma Farmacêutica e Via (ex.: Comp. - Via Oral) *';
      lblCampo[2].Caption := 'Lote Original e Fabricante *';
      lblCampo[3].Caption := 'Validade após Fracionamento *';
      lblCampo[4].Caption := 'Classificação / Alerta (ex.: ALTA VIGILÂNCIA - MAV)';
      lblCampo[5].Caption := 'Farmácia / Responsável pela Unitarização';
      lblCampo[6].Caption := 'Registro MS / ANVISA';
      lblCampo[7].Caption := 'Código Unitário de Rastreabilidade (Barras) *';
      edCampo[0].Text := 'CLORIDRATO DE TRAMADOL 50MG';
      edCampo[1].Text := 'CÁPSULA - VIA ORAL';
      edCampo[2].Text := 'Lote: TR4410 - Lab. Genérico';
      edCampo[3].Text := 'Val. Frac.: 05/2027';
      edCampo[4].Text := 'ALERTA: MEDICAMENTO CONTROLADO';
      edCampo[5].Text := 'FARMÁCIA HOSPITALAR CENTRAL';
      edCampo[6].Text := 'MS: 1.0235.0881';
      edCampo[7].Text := '000501234599';
    end;
    msMedSoroInfusao:
    begin
      lblCampo[0].Caption := 'Nome do Paciente + Prontuário *';
      lblCampo[1].Caption := 'Unidade / Quarto / Leito *';
      lblCampo[2].Caption := 'Solução Base (ex.: Soro Fisiológico 0,9% 500ml) *';
      lblCampo[3].Caption := 'Aditivos / Medicamentos Diluídos';
      lblCampo[4].Caption := 'Velocidade de Infusão / Gotejamento (ml/h ou gts/min) *';
      lblCampo[5].Caption := 'Início e Término Previsto da Infusão';
      lblCampo[6].Caption := 'Preparado por (COREN) / Prescritor (CRM)';
      lblCampo[7].Caption := 'Código da Prescrição / Checagem Beira-Leito *';
      edCampo[0].Text := 'PACIENTE: JOSÉ ROBERTO ALMEIDA (#45901)';
      edCampo[1].Text := 'INTERNAÇÃO 3º ANDAR - QUARTO 312 - LEITO A';
      edCampo[2].Text := 'SORO FISIOLÓGICO 0,9% - 500 ML';
      edCampo[3].Text := '+ KCl 19,1% (10ml) + NaCl 20% (10ml)';
      edCampo[4].Text := 'VAZÃO: 62,5 ml/h (Bomba de Infusão - 8 horas)';
      edCampo[5].Text := 'Início: 14:00h  |  Término: 22:00h';
      edCampo[6].Text := 'Enf. Marcos (COREN 192831)';
      edCampo[7].Text := 'PRESC20269912';
    end;
    msSupGondolaKg:
    begin
      lblCampo[0].Caption := 'Descrição do Produto na Gôndola *';
      lblCampo[1].Caption := 'Marca / Categoria / Embalagem';
      lblCampo[2].Caption := 'Preço de Venda em Destaque *';
      lblCampo[3].Caption := 'Preço por Quilo / Litro / 100g (Lei de Precificação) *';
      lblCampo[4].Caption := 'Preço Atacado / Clube (Opcional)';
      lblCampo[5].Caption := 'Código Interno (PLU) e Data';
      lblCampo[6].Caption := 'Corredor / Prateleira / Fornecedor';
      lblCampo[7].Caption := 'Código de Barras EAN-13 *';
      edCampo[0].Text := 'AZEITE DE OLIVA EXTRA VIRGEM 500ML';
      edCampo[1].Text := 'Importado - Acidez máx. 0,5%';
      edCampo[2].Text := 'POR: R$ 34,90';
      edCampo[3].Text := 'Preço por Litro: R$ 69,80 / L';
      edCampo[4].Text := 'Leve 3+ un. por R$ 32,90 cada';
      edCampo[5].Text := 'PLU: 04512 | ' + FormatDateTime('dd/mm/yyyy', Now);
      edCampo[6].Text := 'CORREDOR 04 - MERCEARIA';
      edCampo[7].Text := '7894900011517';
    end;
    msSupBalancaPadaria:
    begin
      lblCampo[0].Caption := 'Produto (Padaria / Açougue / Frios / Hortifruti) *';
      lblCampo[1].Caption := 'Código PLU (5 dígitos p/ EAN de Balança) *';
      lblCampo[2].Caption := 'Peso Líquido (kg) e Preço por Kg';
      lblCampo[3].Caption := 'Valor Total a Pagar (R$) *';
      lblCampo[4].Caption := 'Data de Embalagem e Data de Validade *';
      lblCampo[5].Caption := 'Ingredientes / Alergênicos Obrigatórios';
      lblCampo[6].Caption := 'Conservação (ex.: Manter resfriado até 7°C)';
      lblCampo[7].Caption := 'Código EAN-13 de Balança (Prefixo 2) *';
      edCampo[0].Text := 'PÃO FRANCÊS / QUEIJO PRATO FATIADO';
      edCampo[1].Text := '00145';
      edCampo[2].Text := 'Peso: 0,350 kg   x   R$ 49,90/kg';
      edCampo[3].Text := 'TOTAL: R$ 17,47';
      edCampo[4].Text := 'Emb.: ' + FormatDateTime('dd/mm/yyyy', Now) + ' | Val.: ' + FormatDateTime('dd/mm/yyyy', Now + 5);
      edCampo[5].Text := 'ALÉRGICOS: CONTÉM DERIVADOS DE LEITE E TRIGO. CONTÉM GLÚTEN.';
      edCampo[6].Text := 'Manter resfriado de 2°C a 8°C';
      edCampo[7].Text := CalcularEAN13Balanca('00145', 17.47);
    end;
    msSupValidadeANVISA:
    begin
      lblCampo[0].Caption := 'Alimento / Insumo Manipulado ou Aberto *';
      lblCampo[1].Caption := 'Data e Hora da Abertura / Manipulação *';
      lblCampo[2].Caption := 'Data e Hora Limite de Validade *';
      lblCampo[3].Caption := 'Método de Conservação (Refrigerado / Congelado / Ambiente) *';
      lblCampo[4].Caption := 'Setor (Padaria, Rotisseria, Nutrição Hospitalar)';
      lblCampo[5].Caption := 'Responsável pela Manipulação *';
      lblCampo[6].Caption := 'Lote Original / SIF';
      lblCampo[7].Caption := 'Código de Controle Interno (Barras)';
      edCampo[0].Text := 'MOLHO DE TOMATE ARTESANAL (ABERTO)';
      edCampo[1].Text := 'Abertura: ' + FormatDateTime('dd/mm/yyyy hh:nn', Now);
      edCampo[2].Text := 'VALIDADE: ' + FormatDateTime('dd/mm/yyyy hh:nn', Now + 3);
      edCampo[3].Text := 'REFRIGERADO ATÉ 4°C (RDC 216 ANVISA)';
      edCampo[4].Text := 'COZINHA CENTRAL / PADARIA';
      edCampo[5].Text := 'Resp.: FERNANDA LIMA';
      edCampo[6].Text := 'Lote Orig.: L202699';
      edCampo[7].Text := 'VAL20261117';
    end;
    msEnvioDespachoVolumes:
    begin
      lblCampo[0].Caption := 'Destinatário / Cliente / Filial *';
      lblCampo[1].Caption := 'Endereço Completo de Entrega *';
      lblCampo[2].Caption := 'Bairro, Cidade / UF e CEP *';
      lblCampo[3].Caption := 'Remetente / Centro de Distribuição *';
      lblCampo[4].Caption := 'Nota Fiscal, Pedido e Transportadora / Rota';
      lblCampo[5].Caption := 'Volume Atual / Total de Volumes *';
      lblCampo[6].Caption := 'Cuidados no Transporte (Frágil / Termolábil / Perecível)';
      lblCampo[7].Caption := 'Código da Remessa / Chave NF (Código de Barras) *';
      edCampo[0].Text := 'DEST.: SUPERMERCADO & FARMÁCIA CENTRAL LTDA';
      edCampo[1].Text := 'AV. BRASIL, 2500 - GALPÃO 03 - DISTRITO INDUSTRIAL';
      edCampo[2].Text := 'CEP: 14000-000 - RIBEIRÃO PRETO / SP';
      edCampo[3].Text := 'REM.: ' + FSetMain.EMPRESA;
      edCampo[4].Text := 'NF: 0098412 | Pedido: #77410 | Rota: Expresso Sul';
      edCampo[5].Text := 'VOLUME: 1/1';
      edCampo[6].Text := 'ATENÇÃO: CARGA FRÁGIL - NÃO EMPILHAR MAIS DE 4 CAIXAS';
      edCampo[7].Text := 'REM20260098412';
    end;
    msCrachaVisitanteHosp:
    begin
      lblCampo[0].Caption := 'Tipo de Credencial * (VISITANTE / ACOMPANHANTE / PRESTADOR)';
      lblCampo[1].Caption := 'Nome Completo do Visitante / Acompanhante *';
      lblCampo[2].Caption := 'Documento (CPF / RG) e Telefone';
      lblCampo[3].Caption := 'Paciente Visitado *';
      lblCampo[4].Caption := 'Unidade / Ala / Quarto / Leito Autorizado *';
      lblCampo[5].Caption := 'Data e Hora de Entrada / Validade';
      lblCampo[6].Caption := 'Portaria / Recepcionista';
      lblCampo[7].Caption := 'Código da Credencial para Baixa na Saída (Barras) *';
      edCampo[0].Text := 'ACOMPANHANTE HOSPITALAR';
      edCampo[1].Text := 'LUCIA HELENA DE OLIVEIRA';
      edCampo[2].Text := 'RG: 22.333.444-5';
      edCampo[3].Text := 'Paciente: PEDRO HENRIQUE DE OLIVEIRA';
      edCampo[4].Text := 'ALA PEDIÁTRICA - QUARTO 205 - LEITO 01';
      edCampo[5].Text := 'Entrada: ' + FormatDateTime('dd/mm/yyyy hh:nn', Now);
      edCampo[6].Text := 'Portaria Principal - Turno Diurno';
      edCampo[7].Text := 'ACOMP20262051';
    end;
    msCrachaFuncionario:
    begin
      lblCampo[0].Caption := 'Nome da Empresa / Hospital / Supermercado *';
      lblCampo[1].Caption := 'Nome de Guerra (em destaque no Crachá) *';
      lblCampo[2].Caption := 'Cargo / Função *';
      lblCampo[3].Caption := 'Nome Completo do Colaborador';
      lblCampo[4].Caption := 'Setor / Matrícula / Registro Profissional (CRM/COREN/CRF)';
      lblCampo[5].Caption := 'Tipo Sanguíneo / Admissão';
      lblCampo[6].Caption := 'Nível de Acesso';
      lblCampo[7].Caption := 'Matrícula / Crachá PDV (Código de Barras) *';
      edCampo[0].Text := 'REDE SAÚDE & SUPERMERCADOS';
      edCampo[1].Text := 'DR. RAFAEL / OPERADOR 01';
      edCampo[2].Text := 'FARMACÊUTICO / SUPERVISOR';
      edCampo[3].Text := 'Rafael Augusto Martins';
      edCampo[4].Text := 'Matrícula: 004821 | Setor: Atendimento';
      edCampo[5].Text := 'Admissão: 01/02/2024';
      edCampo[6].Text := 'ACESSO AUTORIZADO';
      edCampo[7].Text := 'MAT004821';
    end;
  end;
end;

procedure TfrmEtiquetasSetoriais.GerarEANBalancaClick(Sender: TObject);
var
  ValorTexto: string;
  ValorNum: Double;
begin
  ValorTexto := StringReplace(edCampo[3].Text, 'TOTAL:', '', [rfReplaceAll, rfIgnoreCase]);
  ValorTexto := StringReplace(ValorTexto, 'R$', '', [rfReplaceAll, rfIgnoreCase]);
  ValorTexto := StringReplace(Trim(ValorTexto), ',', '.', [rfReplaceAll]);
  ValorNum := StrToFloatDef(ValorTexto, 10.00);
  edCampo[7].Text := CalcularEAN13Balanca(edCampo[1].Text, ValorNum);
  ShowMessage('Código EAN-13 de Balança calculado com dígito verificador: ' + edCampo[7].Text);
end;

procedure TfrmEtiquetasSetoriais.SelecionarFotoClick(Sender: TObject);
var
  Dlg: TOpenPictureDialog;
begin
  Dlg := TOpenPictureDialog.Create(Self);
  try
    if Dlg.Execute then
    begin
      FCaminhoFoto := Dlg.FileName;
      ShowMessage('Foto selecionada para o crachá: ' + ExtractFileName(FCaminhoFoto));
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmEtiquetasSetoriais.VisualizarGraficoClick(Sender: TObject);
var
  C: TCamposSetoriais;
  I: Integer;
  R: TRLReport;
begin
  for I := 0 to 7 do C[I] := Trim(edCampo[I].Text);
  if (FModelo = msEnvioDespachoVolumes) and (seCopias.Value > 1) then
    C[5] := Format('VOLUME: 1/%d (Lote de %d volumes)', [seCopias.Value, seCopias.Value]);
  try
    R := CriarRelatorioSetorial(Self, FModo, FModelo, C, FCaminhoFoto, chkFotoPB.Checked);
    try
      R.PreviewModal;
    finally
      R.Free;
    end;
  except
    on E: Exception do
      MessageDlg('Etiqueta Setorial', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TfrmEtiquetasSetoriais.EnviarPOSDiretoClick(Sender: TObject);
var
  PosPrinter: TAIPOSPrinter;
  I, J, TotalVol: Integer;
  LinhaVol: string;
begin
  if Trim(edCampo[0].Text) = '' then
  begin
    MessageDlg('Atenção', 'Preencha ao menos o primeiro campo obrigatório.', mtWarning, [mbOK], 0);
    Exit;
  end;

  PosPrinter := TAIPOSPrinter.Create(Self);
  try
    case FModo of
      miZebraRolo:
      begin
        PosPrinter.PrinterModel := pmElginL42DT;
        PosPrinter.Protocol := ppZpl;
      end;
      miTermica80Col:
      begin
        PosPrinter.PrinterModel := pmElginI9;
        PosPrinter.Protocol := ppEscPos;
      end;
      miTermica40Col:
      begin
        PosPrinter.PrinterModel := pmQR203;
        PosPrinter.Protocol := ppEscPos;
      end;
    end;

    if Trim(edHostPOS.Text) <> '' then
    begin
      PosPrinter.InterfaceType := piEthernet;
      PosPrinter.Host := Trim(edHostPOS.Text);
      PosPrinter.Port := 9100;
    end
    else
    begin
      PosPrinter.InterfaceType := piSerial;
      PosPrinter.DeviceName := TAISerialModem.NormalizeDeviceName(cbPortaPOS.Text);
      PosPrinter.SerialBaud := 9600;
    end;

    if not PosPrinter.OpenConnection then
    begin
      MessageDlg('Envio Direto TAIPOSPrinter',
        'Não foi possível abrir comunicação direta com a impressora (' +
        PosPrinter.LastError + ').' + sLineBreak +
        'Use o botão "Pré-visualizar / Imprimir Gráfico" para imprimir via driver do Windows.',
        mtWarning, [mbOK], 0);
      Exit;
    end;

    TotalVol := seCopias.Value;
    try
      for I := 1 to TotalVol do
      begin
        PosPrinter.AlignCenter;
        PosPrinter.SetBold(True);
        PosPrinter.PrintTextLine(NomesModelosSetoriais[FModelo]);
        PosPrinter.SetBold(False);
        PosPrinter.AlignLeft;
        for J := 0 to 6 do
        begin
          if Trim(edCampo[J].Text) <> '' then
          begin
            if (FModelo = msEnvioDespachoVolumes) and (J = 5) then
            begin
              LinhaVol := Format('VOLUME: %d/%d', [I, TotalVol]);
              PosPrinter.SetBold(True);
              PosPrinter.PrintTextLine(LinhaVol);
              PosPrinter.SetBold(False);
            end
            else
              PosPrinter.PrintTextLine(Trim(edCampo[J].Text));
          end;
        end;
        if Trim(edCampo[7].Text) <> '' then
        begin
          PosPrinter.AlignCenter;
          PosPrinter.PrintBarcode(Trim(edCampo[7].Text), 65, 2, 2);
        end;
        PosPrinter.PrintTextLine('');
        PosPrinter.CutPaper;
      end;
    finally
      PosPrinter.CloseConnection;
    end;

    ShowMessage(Format('Sucesso! %d etiqueta(s) enviada(s) via TAIPOSPrinter.', [TotalVol]));
  finally
    PosPrinter.Free;
  end;
end;

end.
