unit etiquetasnovas;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, Grids,
  Spin, Graphics, Dialogs, ExtDlgs, Printers, PrintersDlgs, LCLType,
  RLReport, RLBarcode, RLConsts, RLTypes,
  setmain, aiposprinter, imp_generico, aiserial, imagefilters,
  tabelafinalidade, crudfinalidade, wizardimpressao;

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
    msCrachaFuncionario,    // 12: Varejo/Saúde - Crachá Funcionário / Operador c/ Foto (54x86 mm)
    msEnvioML150x100,       // 13: Logística/E-commerce - Etiqueta Tipo ML (150x100 mm)
    msRibbonPatrimonio,     // 14: Exclusiva Ribbon/Zebra - Patrimônio / Ativo Fixo (50x25 mm)
    msTerm80ComandaPedido,  // 15: Exclusiva Térmica 80 col - Comanda / Pedido Cozinha/Balcão
    msTerm80SenhaAtendimento,//16: Exclusiva Térmica 80 col - Senha / Ficha de Atendimento
    msTerm55SacolaDelivery, // 17: Exclusiva Térmica 55/58 mm - Sacola / Delivery Compacta
    msTerm55PrecoCorredor,  // 18: Exclusiva Térmica 55/58 mm - Preço Rápido de Corredor
    msTerm55ComandaCompacta,// 19: Exclusiva Térmica 55/58 mm - Comanda Resumida Portátil
    msTerm55SenhaPortatil   // 20: Exclusiva Térmica 55/58 mm - Senha / Ticket Portátil
  );

  TCamposSetoriais = array[0..7] of string;
  TCamposSetoriaisArray = array of TCamposSetoriais;

  { TfrmEtiquetasSetoriais }

  TfrmEtiquetasSetoriais = class(TForm)
  private
    FModo: TModoImpressoraEtiqueta;
    FModelo: TModeloEtiquetaSetorial;
    FSpec: TTabelaFinalidade;
    FSpecValido: Boolean;
    FLinhas: TListaLinhasTabela;
    FMarcados: array of Boolean;
    FIdEdicao: string;

    { Cabeçalho e Rodapé do Wizard }
    pnlTopo: TPanel;
    lblPassoTitulo: TLabel;
    lblPassoSub: TLabel;
    lblIndicador: TLabel;
    pnlRodape: TPanel;
    btnVoltar: TButton;
    btnAvancar: TButton;
    btnPreviaGrafica: TButton;
    btnImprimirGrafico: TButton;
    btnImprimirPOS: TButton;
    btnFechar: TButton;

    { Páginas do Wizard }
    pcWizard: TPageControl;
    tsPasso1: TTabSheet;
    tsPasso2: TTabSheet;
    tsPasso3: TTabSheet;

    { Passo 1: Impressora e Tamanho/Modelo }
    cbModoImpressora: TComboBox;
    cbModeloEtiqueta: TComboBox;
    lblDimensao: TLabel;
    lblModoResumo: TLabel;
    cbPortaPOS: TComboBox;
    edHostPOS: TEdit;
    seCopias: TSpinEdit;

    { Passo 2: Campos + CRUD + Seleção de Itens }
    pnlCrudTopo: TPanel;
    lblCampo: array[0..7] of TLabel;
    edCampo: array[0..7] of TEdit;
    btnGerarEANBalanca: TButton;
    btnFotoCracha: TButton;
    chkFotoPB: TCheckBox;
    FCaminhoFoto: string;
    pnlCrudBotoes: TPanel;
    btnCrudNovo: TButton;
    btnCrudSalvar: TButton;
    btnCrudExcluir: TButton;
    btnCrudCancelar: TButton;
    btnCrudAtualizar: TButton;
    btnCrudImportar: TButton;
    btnCrudExportar: TButton;
    pnlCrudGrade: TPanel;
    edFiltroCrud: TEdit;
    btnBuscarCrud: TButton;
    btnMarcarTodos: TButton;
    btnDesmarcarTodos: TButton;
    lblContagemCrud: TLabel;
    FGrid: TStringGrid;
    lblModoEmissao: TLabel;

    { Passo 3: Preview e Impressão }
    lblResumoPrevia: TLabel;
    mmoPrevia: TMemo;

    procedure AtualizarWizardUI;
    procedure CarregarTabelaCrud;
    procedure RenderizarGradeCrud;
    procedure AtualizarContagemCrud;
    procedure AlternarMarcacaoCrud(RowIdx: Integer);
    procedure CarregarLinhaParaEdicao(RowIdx: Integer);
    procedure MontarLoteImpressao(out Itens: TCamposSetoriaisArray;
      out Fotos: TStringArray);
    procedure AtualizarResumoPrevia;

    procedure VoltarClick(Sender: TObject);
    procedure AvancarClick(Sender: TObject);
    procedure FecharClick(Sender: TObject);
    procedure CrudNovoClick(Sender: TObject);
    procedure CrudSalvarClick(Sender: TObject);
    procedure CrudExcluirClick(Sender: TObject);
    procedure CrudCancelarClick(Sender: TObject);
    procedure CrudAtualizarClick(Sender: TObject);
    procedure CrudImportarClick(Sender: TObject);
    procedure CrudExportarClick(Sender: TObject);
    procedure BuscarCrudClick(Sender: TObject);
    procedure FiltroCrudKeyPress(Sender: TObject; var Key: Char);
    procedure MarcarTodosCrudClick(Sender: TObject);
    procedure DesmarcarTodosCrudClick(Sender: TObject);
    procedure GridCrudMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GridCrudDblClick(Sender: TObject);
    procedure GridCrudKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    procedure ImprimirItemGrafico(AModelo: TModeloEtiquetaSetorial;
      const C: TCamposSetoriais; const Foto: string; ApenasPrevia: Boolean);
    procedure ImprimirLotePOS(AModelo: TModeloEtiquetaSetorial;
      Modo: TModoImpressoraEtiqueta; const Itens: array of TCamposSetoriais);
    procedure ObterValoresBanco(out Valores: TStringArray);
    procedure PopularModelosCompativeis(AModo: TModoImpressoraEtiqueta; ModeloAlvo: TModeloEtiquetaSetorial);
    procedure AtualizarInterface(Sender: TObject);
    procedure GerarEANBalancaClick(Sender: TObject);
    procedure SelecionarFotoClick(Sender: TObject);
    procedure PreviaGraficaClick(Sender: TObject);
    procedure ImprimirGraficoClick(Sender: TObject);
    procedure ImprimirPOSClick(Sender: TObject);
  public
    constructor CreateSetorial(AOwner: TComponent;
      AModo: TModoImpressoraEtiqueta; AModelo: TModeloEtiquetaSetorial);
  end;

function ModeloCompativelComImpressora(AModo: TModoImpressoraEtiqueta;
  AModelo: TModeloEtiquetaSetorial): Boolean;
function ModeloUsaCrudLista(AModelo: TModeloEtiquetaSetorial): Boolean;
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
    'Varejo & Saúde: Crachá de Funcionário / Operador c/ Foto (54 x 86 mm)',
    'Logística & E-commerce: Etiqueta Tipo ML (150 x 100 mm)',
    'Ribbon / Zebra: Patrimônio e Ativo Fixo (50 x 25 mm)',
    'Térmica 80 col: Comanda / Pedido de Cozinha e Balcão (80 mm)',
    'Térmica 80 col: Senha / Ficha de Atendimento (80 mm)',
    'Térmica 55/58 mm: Sacola / Delivery Compacta (55 mm)',
    'Térmica 55/58 mm: Preço Rápido de Corredor (55 mm)',
    'Térmica 55/58 mm: Comanda Resumida Portátil (55 mm)',
    'Térmica 55/58 mm: Senha / Ticket Portátil (55 mm)'
  );

function ModeloCompativelComImpressora(AModo: TModoImpressoraEtiqueta;
  AModelo: TModeloEtiquetaSetorial): Boolean;
begin
  case AModo of
    miZebraRolo:
      Result := not (AModelo in [msTerm80ComandaPedido, msTerm80SenhaAtendimento,
        msTerm55SacolaDelivery, msTerm55PrecoCorredor,
        msTerm55ComandaCompacta, msTerm55SenhaPortatil]);
    miTermica80Col:
      Result := not (AModelo in [msLabLaminaBiopsia, msLabBolsaSangue,
        msRibbonPatrimonio, msTerm55SacolaDelivery, msTerm55PrecoCorredor,
        msTerm55ComandaCompacta, msTerm55SenhaPortatil]);
    miTermica40Col:
      Result := not (AModelo in [msLabLaminaBiopsia, msLabBolsaSangue,
        msLabTransporteBio, msEnvioML150x100, msRibbonPatrimonio,
        msTerm80ComandaPedido, msTerm80SenhaAtendimento]);
  else
    Result := True;
  end;
end;

function MM(V: Double): Integer;
begin
  Result := Round(V * ScreenPPI / 25.4);
end;

function ModeloUsaCrudLista(AModelo: TModeloEtiquetaSetorial): Boolean;
begin
  case AModelo of
    msLabTuboColeta,
    msLabLaminaBiopsia,
    msLabBolsaSangue,
    msLabTransporteBio,
    msMedFracionamento,
    msCrachaVisitanteHosp:
      Result := False; // Emissão 1 a 1: preenche o item na tela e gera a etiqueta diretamente
    msMedAvulsoPosologia,
    msMedSoroInfusao,
    msSupGondolaKg,
    msSupBalancaPadaria,
    msSupValidadeANVISA,
    msEnvioDespachoVolumes,
    msCrachaFuncionario:
      Result := True;  // Cadastro CRUD / lista de múltiplos itens
  else
    Result := True;
  end;
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
        msEnvioDespachoVolumes, msEnvioML150x100, msLabTransporteBio: H := 110.0;
        msMedSoroInfusao, msLabBolsaSangue: H := 75.0;
        else H := 55.0;
      end;
    end;
    miTermica40Col:
    begin
      W := 58.0;
      case AModelo of
        msEnvioDespachoVolumes, msEnvioML150x100, msLabTransporteBio: H := 85.0;
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
        msEnvioML150x100:       begin W := 150.0; H := 100.0; end;
        msRibbonPatrimonio:     begin W := 50.0;  H := 25.0;  end;
        else                    begin W := 80.0;  H := 50.0;  end;
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

    if (AModelo = msEnvioML150x100) and (AModo = miZebraRolo) then
    begin
      Borda := TRLDraw.Create(Result);
      Borda.Parent := Result;
      Borda.DrawKind := dkRectangle;
      Borda.SetBounds(MM(2.0), MM(2.0), MM(W - 4.0), MM(H - 4.0));

      AddLinha('ETIQUETA DE ENVIO · TIPO ML (150 x 100 mm)', 5.0, 4.5, 92.0, 10, True);
      AddLinha(C[5], 98.0, 4.5, 47.0, 9, True, True);

      Borda := TRLDraw.Create(Result);
      Borda.Parent := Result;
      Borda.DrawKind := dkRectangle;
      Borda.SetBounds(MM(2.0), MM(13.0), MM(W - 4.0), MM(0.5));

      AddLinha('DESTINATÁRIO', 5.0, 15.5, 88.0, 8, True);
      AddLinha(C[0], 5.0, 20.5, 88.0, 11, True);
      AddLinha(C[1], 5.0, 28.0, 88.0, 9, False);
      AddLinha(C[2], 5.0, 35.0, 88.0, 9, True);

      Borda := TRLDraw.Create(Result);
      Borda.Parent := Result;
      Borda.DrawKind := dkRectangle;
      Borda.SetBounds(MM(96.0), MM(15.0), MM(49.0), MM(46.0));
      AddLinha('ROTA / SERVIÇO', 98.0, 17.5, 45.0, 8, True, True);
      AddLinha(C[5], 98.0, 24.5, 45.0, 10, True, True);
      AddLinha(C[4], 98.0, 37.0, 45.0, 8, False, True);

      Borda := TRLDraw.Create(Result);
      Borda.Parent := Result;
      Borda.DrawKind := dkRectangle;
      Borda.SetBounds(MM(2.0), MM(43.5), MM(94.0), MM(0.5));

      AddLinha('REMETENTE', 5.0, 45.5, 88.0, 7, True);
      AddLinha(C[3], 5.0, 49.5, 88.0, 9, False);
      AddLinha(C[6], 5.0, 56.5, 88.0, 8, False);

      if Trim(C[7]) <> '' then
      begin
        AddBarras(C[7], 8.0, 66.0, W - 16.0, 20.0);
        AddLinha(C[7], 5.0, 88.0, W - 10.0, 10, True, True);
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
      msEnvioML150x100:       Cabecalho := 'ETIQUETA DE ENVIO - TIPO ML (150 x 100 mm)';
      msRibbonPatrimonio:     Cabecalho := 'PATRIMÔNIO / ATIVO FIXO';
      msTerm80ComandaPedido:  Cabecalho := 'COMANDA / PEDIDO (80 mm)';
      msTerm80SenhaAtendimento: Cabecalho := 'SENHA DE ATENDIMENTO (80 mm)';
      msTerm55SacolaDelivery: Cabecalho := 'ENTREGA / DELIVERY (55 mm)';
      msTerm55PrecoCorredor:  Cabecalho := 'PREÇO RÁPIDO (55 mm)';
      msTerm55ComandaCompacta: Cabecalho := 'COMANDA PORTÁTIL (55 mm)';
      msTerm55SenhaPortatil:  Cabecalho := 'SENHA / TICKET (55 mm)';
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
  I: Integer;
  L: TLabel;
begin
  inherited CreateNew(AOwner);
  FModo := AModo;
  FModelo := AModelo;
  FIdEdicao := '';
  Caption := 'Emissão de Etiquetas — Assistente em 3 Etapas';
  Position := poScreenCenter;
  BorderStyle := bsDialog;
  ClientWidth := 920;
  ClientHeight := 640;

  { Cabeçalho do Wizard }
  pnlTopo := TPanel.Create(Self);
  pnlTopo.Parent := Self;
  pnlTopo.Align := alTop;
  pnlTopo.Height := 62;
  pnlTopo.BevelOuter := bvLowered;
  pnlTopo.Color := $00F4EFEA;

  lblPassoTitulo := TLabel.Create(Self);
  lblPassoTitulo.Parent := pnlTopo;
  lblPassoTitulo.Font.Size := 12;
  lblPassoTitulo.Font.Style := [fsBold];
  lblPassoTitulo.SetBounds(16, 8, 760, 22);

  lblPassoSub := TLabel.Create(Self);
  lblPassoSub.Parent := pnlTopo;
  lblPassoSub.Font.Color := clGrayText;
  lblPassoSub.SetBounds(16, 34, 760, 18);

  lblIndicador := TLabel.Create(Self);
  lblIndicador.Parent := pnlTopo;
  lblIndicador.Font.Size := 11;
  lblIndicador.Font.Style := [fsBold];
  lblIndicador.Font.Color := clNavy;
  lblIndicador.Alignment := Classes.taRightJustify;
  lblIndicador.AutoSize := False;
  lblIndicador.SetBounds(800, 18, 100, 24);

  { Rodapé do Wizard }
  pnlRodape := TPanel.Create(Self);
  pnlRodape.Parent := Self;
  pnlRodape.Align := alBottom;
  pnlRodape.Height := 52;
  pnlRodape.BevelOuter := bvRaised;

  btnVoltar := TButton.Create(Self);
  btnVoltar.Parent := pnlRodape;
  btnVoltar.Caption := '< Voltar';
  btnVoltar.SetBounds(16, 11, 100, 30);
  btnVoltar.OnClick := @VoltarClick;

  btnAvancar := TButton.Create(Self);
  btnAvancar.Parent := pnlRodape;
  btnAvancar.Caption := 'Avançar >';
  btnAvancar.SetBounds(124, 11, 110, 30);
  btnAvancar.OnClick := @AvancarClick;

  btnPreviaGrafica := TButton.Create(Self);
  btnPreviaGrafica.Parent := pnlRodape;
  btnPreviaGrafica.Caption := 'Pré-visualizar (FortesReport)';
  btnPreviaGrafica.SetBounds(124, 11, 195, 30);
  btnPreviaGrafica.OnClick := @PreviaGraficaClick;

  btnImprimirGrafico := TButton.Create(Self);
  btnImprimirGrafico.Parent := pnlRodape;
  btnImprimirGrafico.Caption := 'Imprimir Gráfico (Windows)';
  btnImprimirGrafico.SetBounds(327, 11, 185, 30);
  btnImprimirGrafico.OnClick := @ImprimirGraficoClick;

  btnImprimirPOS := TButton.Create(Self);
  btnImprimirPOS.Parent := pnlRodape;
  btnImprimirPOS.Caption := 'Imprimir Direto (POS / ZPL)';
  btnImprimirPOS.SetBounds(520, 11, 185, 30);
  btnImprimirPOS.OnClick := @ImprimirPOSClick;

  btnFechar := TButton.Create(Self);
  btnFechar.Parent := pnlRodape;
  btnFechar.Caption := 'Fechar';
  btnFechar.SetBounds(808, 11, 96, 30);
  btnFechar.OnClick := @FecharClick;

  { PageControl do Wizard }
  pcWizard := TPageControl.Create(Self);
  pcWizard.Parent := Self;
  pcWizard.Align := alClient;
  pcWizard.ShowTabs := False;

  tsPasso1 := TTabSheet.Create(pcWizard);
  tsPasso1.PageControl := pcWizard;
  tsPasso1.Caption := 'Passo 1';

  tsPasso2 := TTabSheet.Create(pcWizard);
  tsPasso2.PageControl := pcWizard;
  tsPasso2.Caption := 'Passo 2';

  tsPasso3 := TTabSheet.Create(pcWizard);
  tsPasso3.PageControl := pcWizard;
  tsPasso3.Caption := 'Passo 3';

  { ================= PASSO 1: Impressora e Tamanho ================= }
  L := TLabel.Create(Self);
  L.Parent := tsPasso1;
  L.Caption := '1. Tipo de Impressora:';
  L.Font.Size := 10;
  L.Font.Style := [fsBold];
  L.SetBounds(28, 28, 380, 20);

  cbModoImpressora := TComboBox.Create(Self);
  cbModoImpressora.Parent := tsPasso1;
  cbModoImpressora.Style := csDropDownList;
  cbModoImpressora.SetBounds(28, 52, 410, 28);
  cbModoImpressora.Items.Add('Impressora Zebra / Ribbon (Rolo Adesivo)');
  cbModoImpressora.Items.Add('Impressora Térmica 80 Colunas (Bobina 80mm)');
  cbModoImpressora.Items.Add('Impressora Térmica 55 / 58 mm (40–55 col · Portátil)');
  cbModoImpressora.ItemIndex := Ord(AModo);
  cbModoImpressora.OnChange := @AtualizarInterface;

  L := TLabel.Create(Self);
  L.Parent := tsPasso1;
  L.Caption := '2. Modelo e Tamanho da Etiqueta:';
  L.Font.Size := 10;
  L.Font.Style := [fsBold];
  L.SetBounds(464, 28, 420, 20);

  cbModeloEtiqueta := TComboBox.Create(Self);
  cbModeloEtiqueta.Parent := tsPasso1;
  cbModeloEtiqueta.Style := csDropDownList;
  cbModeloEtiqueta.SetBounds(464, 52, 420, 28);
  PopularModelosCompativeis(AModo, AModelo);
  cbModeloEtiqueta.OnChange := @AtualizarInterface;

  lblDimensao := TLabel.Create(Self);
  lblDimensao.Parent := tsPasso1;
  lblDimensao.Font.Style := [fsBold];
  lblDimensao.SetBounds(28, 102, 856, 20);

  lblModoResumo := TLabel.Create(Self);
  lblModoResumo.Parent := tsPasso1;
  lblModoResumo.Font.Color := clNavy;
  lblModoResumo.SetBounds(28, 128, 856, 20);

  L := TLabel.Create(Self);
  L.Parent := tsPasso1;
  L.Caption := '3. Configurações de Saída e Cópias:';
  L.Font.Size := 10;
  L.Font.Style := [fsBold];
  L.SetBounds(28, 178, 400, 20);

  L := TLabel.Create(Self);
  L.Parent := tsPasso1;
  L.Caption := 'Porta Serial / USB (TAIPOSPrinter):';
  L.SetBounds(28, 210, 220, 18);
  cbPortaPOS := TComboBox.Create(Self);
  cbPortaPOS.Parent := tsPasso1;
  cbPortaPOS.SetBounds(28, 232, 160, 26);
  cbPortaPOS.Items.AddStrings(['COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM10']);
  cbPortaPOS.ItemIndex := 0;

  L := TLabel.Create(Self);
  L.Parent := tsPasso1;
  L.Caption := 'Ou IP Rede (Porta 9100, opcional):';
  L.SetBounds(268, 210, 230, 18);
  edHostPOS := TEdit.Create(Self);
  edHostPOS.Parent := tsPasso1;
  edHostPOS.SetBounds(268, 232, 200, 26);
  edHostPOS.Text := '';

  L := TLabel.Create(Self);
  L.Parent := tsPasso1;
  L.Caption := 'Cópias / Volumes por item:';
  L.SetBounds(508, 210, 200, 18);
  seCopias := TSpinEdit.Create(Self);
  seCopias.Parent := tsPasso1;
  seCopias.MinValue := 1;
  seCopias.MaxValue := 500;
  seCopias.Value := 1;
  seCopias.SetBounds(508, 232, 100, 26);

  { ================= PASSO 2: CRUD + Seleção de Itens ================= }
  pnlCrudTopo := TPanel.Create(Self);
  pnlCrudTopo.Parent := tsPasso2;
  pnlCrudTopo.Align := alTop;
  pnlCrudTopo.Height := 252;
  pnlCrudTopo.BevelOuter := bvNone;

  for I := 0 to 7 do
  begin
    lblCampo[I] := TLabel.Create(Self);
    lblCampo[I].Parent := pnlCrudTopo;
    lblCampo[I].SetBounds(14 + (I div 4) * 326, 8 + (I mod 4) * 52, 314, 16);
    edCampo[I] := TEdit.Create(Self);
    edCampo[I].Parent := pnlCrudTopo;
    edCampo[I].SetBounds(14 + (I div 4) * 326, 26 + (I mod 4) * 52, 314, 24);
  end;

  btnGerarEANBalanca := TButton.Create(Self);
  btnGerarEANBalanca.Parent := pnlCrudTopo;
  btnGerarEANBalanca.Caption := 'Calcular EAN-13 Balança (Prefixo 2)';
  btnGerarEANBalanca.SetBounds(14, 218, 240, 26);
  btnGerarEANBalanca.OnClick := @GerarEANBalancaClick;

  btnFotoCracha := TButton.Create(Self);
  btnFotoCracha.Parent := pnlCrudTopo;
  btnFotoCracha.Caption := 'Carregar Foto 3x4...';
  btnFotoCracha.SetBounds(264, 218, 160, 26);
  btnFotoCracha.OnClick := @SelecionarFotoClick;

  chkFotoPB := TCheckBox.Create(Self);
  chkFotoPB.Parent := pnlCrudTopo;
  chkFotoPB.Caption := 'Foto P&B térmica';
  chkFotoPB.Checked := True;
  chkFotoPB.SetBounds(434, 221, 140, 20);

  pnlCrudBotoes := TPanel.Create(Self);
  pnlCrudBotoes.Parent := pnlCrudTopo;
  pnlCrudBotoes.SetBounds(668, 8, 232, 236);
  pnlCrudBotoes.BevelOuter := bvLowered;

  btnCrudNovo := TButton.Create(Self);
  btnCrudNovo.Parent := pnlCrudBotoes;
  btnCrudNovo.Caption := 'Novo';
  btnCrudNovo.SetBounds(12, 10, 208, 30);
  btnCrudNovo.OnClick := @CrudNovoClick;

  btnCrudSalvar := TButton.Create(Self);
  btnCrudSalvar.Parent := pnlCrudBotoes;
  btnCrudSalvar.Caption := 'Salvar';
  btnCrudSalvar.SetBounds(12, 46, 208, 30);
  btnCrudSalvar.OnClick := @CrudSalvarClick;

  btnCrudExcluir := TButton.Create(Self);
  btnCrudExcluir.Parent := pnlCrudBotoes;
  btnCrudExcluir.Caption := 'Excluir';
  btnCrudExcluir.SetBounds(12, 82, 208, 30);
  btnCrudExcluir.OnClick := @CrudExcluirClick;

  btnCrudCancelar := TButton.Create(Self);
  btnCrudCancelar.Parent := pnlCrudBotoes;
  btnCrudCancelar.Caption := 'Cancelar';
  btnCrudCancelar.SetBounds(12, 118, 208, 30);
  btnCrudCancelar.OnClick := @CrudCancelarClick;

  btnCrudAtualizar := TButton.Create(Self);
  btnCrudAtualizar.Parent := pnlCrudBotoes;
  btnCrudAtualizar.Caption := 'Atualizar Lista';
  btnCrudAtualizar.SetBounds(12, 154, 208, 30);
  btnCrudAtualizar.OnClick := @CrudAtualizarClick;

  btnCrudImportar := TButton.Create(Self);
  btnCrudImportar.Parent := pnlCrudBotoes;
  btnCrudImportar.Caption := 'Importar CSV';
  btnCrudImportar.SetBounds(12, 194, 100, 28);
  btnCrudImportar.OnClick := @CrudImportarClick;

  btnCrudExportar := TButton.Create(Self);
  btnCrudExportar.Parent := pnlCrudBotoes;
  btnCrudExportar.Caption := 'Exportar CSV';
  btnCrudExportar.SetBounds(120, 194, 100, 28);
  btnCrudExportar.OnClick := @CrudExportarClick;

  pnlCrudGrade := TPanel.Create(Self);
  pnlCrudGrade.Parent := tsPasso2;
  pnlCrudGrade.Align := alClient;
  pnlCrudGrade.BevelOuter := bvNone;

  L := TLabel.Create(Self);
  L.Parent := pnlCrudGrade;
  L.Caption := 'Filtrar / Selecionar itens para impressão (clique em [X] para marcar, duplo clique para alterar):';
  L.Font.Style := [fsBold];
  L.SetBounds(14, 4, 620, 18);

  edFiltroCrud := TEdit.Create(Self);
  edFiltroCrud.Parent := pnlCrudGrade;
  edFiltroCrud.SetBounds(14, 24, 250, 24);
  edFiltroCrud.TextHint := 'Pesquisar (Enter)';
  edFiltroCrud.OnKeyPress := @FiltroCrudKeyPress;

  btnBuscarCrud := TButton.Create(Self);
  btnBuscarCrud.Parent := pnlCrudGrade;
  btnBuscarCrud.Caption := 'Buscar';
  btnBuscarCrud.SetBounds(270, 23, 74, 26);
  btnBuscarCrud.OnClick := @BuscarCrudClick;

  btnMarcarTodos := TButton.Create(Self);
  btnMarcarTodos.Parent := pnlCrudGrade;
  btnMarcarTodos.Caption := 'Marcar Todos';
  btnMarcarTodos.SetBounds(354, 23, 104, 26);
  btnMarcarTodos.OnClick := @MarcarTodosCrudClick;

  btnDesmarcarTodos := TButton.Create(Self);
  btnDesmarcarTodos.Parent := pnlCrudGrade;
  btnDesmarcarTodos.Caption := 'Desmarcar Todos';
  btnDesmarcarTodos.SetBounds(464, 23, 118, 26);
  btnDesmarcarTodos.OnClick := @DesmarcarTodosCrudClick;

  lblContagemCrud := TLabel.Create(Self);
  lblContagemCrud.Parent := pnlCrudGrade;
  lblContagemCrud.Font.Style := [fsBold];
  lblContagemCrud.Font.Color := clNavy;
  lblContagemCrud.SetBounds(592, 27, 308, 18);

  FGrid := TStringGrid.Create(Self);
  FGrid.Parent := pnlCrudGrade;
  FGrid.SetBounds(14, 54, 886, 200);
  FGrid.Anchors := [akLeft, akTop, akRight, akBottom];
  FGrid.Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect, goColSizing];
  FGrid.FixedCols := 0;
  FGrid.FixedRows := 1;
  FGrid.OnMouseDown := @GridCrudMouseDown;
  FGrid.OnDblClick := @GridCrudDblClick;
  FGrid.OnKeyDown := @GridCrudKeyDown;

  lblModoEmissao := TLabel.Create(Self);
  lblModoEmissao.Parent := tsPasso2;
  lblModoEmissao.Font.Size := 10;
  lblModoEmissao.Font.Style := [fsBold];
  lblModoEmissao.Font.Color := clNavy;
  lblModoEmissao.Caption := 'Modo 1 a 1: preencha os campos acima e clique em "Avançar >" para pré-visualizar e imprimir.';
  lblModoEmissao.SetBounds(14, 276, 880, 24);
  lblModoEmissao.Visible := False;

  { ================= PASSO 3: Preview e Impressão ================= }
  lblResumoPrevia := TLabel.Create(Self);
  lblResumoPrevia.Parent := tsPasso3;
  lblResumoPrevia.Font.Style := [fsBold];
  lblResumoPrevia.SetBounds(16, 12, 880, 20);
  lblResumoPrevia.Caption := 'Pré-visualização dos dados que serão impressos:';

  mmoPrevia := TMemo.Create(Self);
  mmoPrevia.Parent := tsPasso3;
  mmoPrevia.SetBounds(16, 38, 880, 466);
  mmoPrevia.Anchors := [akLeft, akTop, akRight, akBottom];
  mmoPrevia.ReadOnly := True;
  mmoPrevia.ScrollBars := ssBoth;
  mmoPrevia.Font.Name := 'Consolas';
  mmoPrevia.Font.Size := 10;

  pcWizard.ActivePageIndex := 0;
  AtualizarInterface(nil);
  AtualizarWizardUI;
end;

procedure TfrmEtiquetasSetoriais.ObterValoresBanco(out Valores: TStringArray);
var
  I, Total: Integer;
begin
  if FModelo = msCrachaFuncionario then
    Total := 9
  else
    Total := 8;
  SetLength(Valores, Total);
  for I := 0 to 7 do
    Valores[I] := Trim(edCampo[I].Text);
  if FModelo = msCrachaFuncionario then
    Valores[8] := FCaminhoFoto;
end;

procedure TfrmEtiquetasSetoriais.PopularModelosCompativeis(
  AModo: TModoImpressoraEtiqueta; ModeloAlvo: TModeloEtiquetaSetorial);
var
  M: TModeloEtiquetaSetorial;
  Idx, AlvoIdx: Integer;
begin
  cbModeloEtiqueta.Items.BeginUpdate;
  try
    cbModeloEtiqueta.Items.Clear;
    AlvoIdx := 0;
    for M := Low(TModeloEtiquetaSetorial) to High(TModeloEtiquetaSetorial) do
    begin
      if ModeloCompativelComImpressora(AModo, M) then
      begin
        Idx := cbModeloEtiqueta.Items.AddObject(NomesModelosSetoriais[M], TObject(PtrInt(Ord(M))));
        if M = ModeloAlvo then
          AlvoIdx := Idx;
      end;
    end;
    if cbModeloEtiqueta.Items.Count > 0 then
      cbModeloEtiqueta.ItemIndex := AlvoIdx;
  finally
    cbModeloEtiqueta.Items.EndUpdate;
  end;
end;

procedure TfrmEtiquetasSetoriais.AtualizarInterface(Sender: TObject);
var
  W, H: Double;
  UsaCrud: Boolean;
begin
  FModo := TModoImpressoraEtiqueta(cbModoImpressora.ItemIndex);
  if Sender = cbModoImpressora then
    PopularModelosCompativeis(FModo, FModelo);
  if (cbModeloEtiqueta.ItemIndex >= 0) and (cbModeloEtiqueta.ItemIndex < cbModeloEtiqueta.Items.Count) then
    FModelo := TModeloEtiquetaSetorial(PtrInt(cbModeloEtiqueta.Items.Objects[cbModeloEtiqueta.ItemIndex]));
  DimensoesPapelSetorial(FModo, FModelo, W, H);
  lblDimensao.Caption := Format('Dimensão configurada: %.1f x %.1f mm | Motor: FortesReport + TAIPOSPrinter', [W, H]);

  btnGerarEANBalanca.Visible := (FModelo = msSupBalancaPadaria);
  btnFotoCracha.Visible := (FModelo in [msCrachaVisitanteHosp, msCrachaFuncionario]);
  chkFotoPB.Visible := btnFotoCracha.Visible;

  UsaCrud := ModeloUsaCrudLista(FModelo);
  FIdEdicao := '';
  if UsaCrud then
  begin
    FSpecValido := ObterTabelaFinalidade(ChaveTabelaSetorial(Ord(FModelo)), FSpec);
    lblModoResumo.Caption := 'Modo: CRUD / Lista de múltiplos itens (Passo 2 terá cadastro, alteração e seleção para impressão).';
  end
  else
  begin
    FSpecValido := False;
    lblModoResumo.Caption := 'Modo: Emissão 1 a 1 (preenchimento direto do item no Passo 2, sem lista CRUD).';
  end;

  pnlCrudBotoes.Visible := UsaCrud;
  pnlCrudGrade.Visible := UsaCrud;
  lblModoEmissao.Visible := not UsaCrud;

  if UsaCrud then
    CarregarTabelaCrud;

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
    msEnvioML150x100:
    begin
      lblCampo[0].Caption := 'Destinatário / Comprador *';
      lblCampo[1].Caption := 'Endereço Completo (Rua, Nº, Complemento) *';
      lblCampo[2].Caption := 'Bairro, Cidade / UF e CEP *';
      lblCampo[3].Caption := 'Remetente / Loja *';
      lblCampo[4].Caption := 'Venda / Pedido / NF / Volume';
      lblCampo[5].Caption := 'Transportadora / Modalidade / Rota';
      lblCampo[6].Caption := 'Observação / Conteúdo';
      lblCampo[7].Caption := 'Código de Rastreio / Etiqueta (Barras) *';
      edCampo[0].Text := 'CARLOS EDUARDO SILVA';
      edCampo[1].Text := 'RUA DAS FLORES, 450 - SALA 12';
      edCampo[2].Text := 'CENTRO - SÃO PAULO / SP - CEP: 01001-000';
      if FSetMain.EMPRESA <> '' then
        edCampo[3].Text := FSetMain.EMPRESA
      else
        edCampo[3].Text := 'LOJA MODELO E-COMMERCE';
      edCampo[4].Text := 'Venda #200000918273 | NF: 004512 | Vol: 1/1';
      edCampo[5].Text := 'ENVIO RÁPIDO · ROTA SP-04';
      edCampo[6].Text := 'Conteúdo: Mercadoria Comercial';
      edCampo[7].Text := 'ML4829103948BR';
    end;
    msRibbonPatrimonio:
    begin
      lblCampo[0].Caption := 'Empresa / Instituição *';
      lblCampo[1].Caption := 'Descrição do Bem / Equipamento *';
      lblCampo[2].Caption := 'Setor / Localização';
      lblCampo[3].Caption := 'Responsável / Centro de Custo';
      lblCampo[4].Caption := 'Nº Série / Nota Fiscal';
      lblCampo[5].Caption := 'Data de Aquisição / Tombamento';
      lblCampo[6].Caption := 'Observação / Garantia';
      lblCampo[7].Caption := 'Nº do Patrimônio (Barras) *';
      if FSetMain.EMPRESA <> '' then
        edCampo[0].Text := FSetMain.EMPRESA
      else
        edCampo[0].Text := 'EMPRESA / ATIVO IMOBILIZADO';
      edCampo[1].Text := 'NOTEBOOK CORPORATIVO I7 16GB';
      edCampo[2].Text := 'TECNOLOGIA DA INFORMAÇÃO';
      edCampo[3].Text := 'CC 104 - INFRAESTRUTURA';
      edCampo[4].Text := 'SN: BR992014X | NF 1102';
      edCampo[5].Text := FormatDateTime('dd/mm/yyyy', Now);
      edCampo[6].Text := 'RIBBON RESINA - NÃO REMOVER';
      edCampo[7].Text := 'PAT001492';
    end;
    msTerm80ComandaPedido:
    begin
      lblCampo[0].Caption := 'Nº do Pedido / Mesa / Comanda *';
      lblCampo[1].Caption := 'Cliente / Atendente';
      lblCampo[2].Caption := 'Itens / Quantidades *';
      lblCampo[3].Caption := 'Adicionais / Observações de Preparo';
      lblCampo[4].Caption := 'Setor (Cozinha / Copa / Balcão)';
      lblCampo[5].Caption := 'Data e Hora do Pedido';
      lblCampo[6].Caption := 'Consumo Local / Viagem / Entrega';
      lblCampo[7].Caption := 'Código da Comanda (Barras)';
      edCampo[0].Text := 'COMANDA #048 - MESA 12';
      edCampo[1].Text := 'Cliente: MARIANA | Garçom: Lucas';
      edCampo[2].Text := '2x X-SALADA ARTESANAL + 1x SUCO LARANJA';
      edCampo[3].Text := 'OBS: SEM CEBOLA / GELO E LIMÃO';
      edCampo[4].Text := 'COZINHA QUENTE';
      edCampo[5].Text := FormatDateTime('dd/mm/yyyy hh:nn', Now);
      edCampo[6].Text := 'CONSUMO NO LOCAL';
      edCampo[7].Text := 'CMD00048';
    end;
    msTerm80SenhaAtendimento:
    begin
      lblCampo[0].Caption := 'Estabelecimento / Unidade *';
      lblCampo[1].Caption := 'Tipo de Atendimento *';
      lblCampo[2].Caption := 'Número da Senha *';
      lblCampo[3].Caption := 'Setor / Guichê';
      lblCampo[4].Caption := 'Data e Hora da Emissão';
      lblCampo[5].Caption := 'Observação / Fila';
      lblCampo[6].Caption := 'Orientação ao Usuário';
      lblCampo[7].Caption := 'Código de Chamada (Barras)';
      edCampo[0].Text := 'ATENDIMENTO AO CLIENTE / RECEPÇÃO';
      edCampo[1].Text := 'ATENDIMENTO PREFERENCIAL';
      edCampo[2].Text := 'SENHA: P-014';
      edCampo[3].Text := 'GUICHÊ 01 A 04 - TRIAGEM';
      edCampo[4].Text := FormatDateTime('dd/mm/yyyy hh:nn', Now);
      edCampo[5].Text := 'Aguarde ser chamado no painel';
      edCampo[6].Text := 'Tenha seu documento em mãos';
      edCampo[7].Text := 'SENHAP014';
    end;
    msTerm55SacolaDelivery:
    begin
      lblCampo[0].Caption := 'Loja / Restaurante *';
      lblCampo[1].Caption := 'Nome do Cliente *';
      lblCampo[2].Caption := 'Endereço / Referência *';
      lblCampo[3].Caption := 'Telefone / WhatsApp';
      lblCampo[4].Caption := 'Pedido / Volumes';
      lblCampo[5].Caption := 'Pagamento / Troco';
      lblCampo[6].Caption := 'Observação de Entrega';
      lblCampo[7].Caption := 'Código do Pedido (Barras)';
      edCampo[0].Text := 'DELIVERY EXPRESSO';
      edCampo[1].Text := 'CLIENTE: BRUNO OLIVEIRA';
      edCampo[2].Text := 'RUA SETE DE SETEMBRO, 89 - AP 21';
      edCampo[3].Text := 'FONE: (16) 99999-0000';
      edCampo[4].Text := 'PEDIDO #908 | SACOLA 1/1';
      edCampo[5].Text := 'PAGO ONLINE - NÃO COBRAR';
      edCampo[6].Text := 'ENTREGAR NA PORTARIA';
      edCampo[7].Text := 'DEL00908';
    end;
    msTerm55PrecoCorredor:
    begin
      lblCampo[0].Caption := 'Descrição Curta do Produto *';
      lblCampo[1].Caption := 'Unidade / Embalagem';
      lblCampo[2].Caption := 'Preço de Venda *';
      lblCampo[3].Caption := 'Preço Promocional / Clube';
      lblCampo[4].Caption := 'Validade da Oferta';
      lblCampo[5].Caption := 'Corredor / Seção';
      lblCampo[6].Caption := 'Código Interno / PLU';
      lblCampo[7].Caption := 'Código de Barras *';
      edCampo[0].Text := 'ARROZ TIPO 1 5KG';
      edCampo[1].Text := 'PACOTE 5 KG';
      edCampo[2].Text := 'R$ 26,90';
      edCampo[3].Text := 'CLUBE: R$ 23,90';
      edCampo[4].Text := 'OFERTA HOJE';
      edCampo[5].Text := 'CORREDOR 02';
      edCampo[6].Text := 'PLU 01204';
      edCampo[7].Text := '7891234500120';
    end;
    msTerm55ComandaCompacta:
    begin
      lblCampo[0].Caption := 'Nº da Comanda / Mesa *';
      lblCampo[1].Caption := 'Cliente';
      lblCampo[2].Caption := 'Itens / Observação *';
      lblCampo[3].Caption := 'Atendente';
      lblCampo[4].Caption := 'Data e Hora';
      lblCampo[5].Caption := 'Total / Status';
      lblCampo[6].Caption := 'Balcão / Mesa';
      lblCampo[7].Caption := 'Código da Comanda (Barras)';
      edCampo[0].Text := 'MESA 05 · #112';
      edCampo[1].Text := 'Cliente: Paulo';
      edCampo[2].Text := '1x Café Expresso + 2x Pão de Queijo';
      edCampo[3].Text := 'Atend.: Carla';
      edCampo[4].Text := FormatDateTime('dd/mm hh:nn', Now);
      edCampo[5].Text := 'TOTAL: R$ 18,50';
      edCampo[6].Text := 'BALCÃO';
      edCampo[7].Text := 'M05112';
    end;
    msTerm55SenhaPortatil:
    begin
      lblCampo[0].Caption := 'Unidade / Evento *';
      lblCampo[1].Caption := 'Senha / Ticket *';
      lblCampo[2].Caption := 'Categoria';
      lblCampo[3].Caption := 'Setor / Sala';
      lblCampo[4].Caption := 'Data e Hora';
      lblCampo[5].Caption := 'Observação';
      lblCampo[6].Caption := 'Validade';
      lblCampo[7].Caption := 'Código do Ticket (Barras)';
      edCampo[0].Text := 'PORTARIA / RECEPÇÃO';
      edCampo[1].Text := 'TICKET Nº 042';
      edCampo[2].Text := 'ATENDIMENTO GERAL';
      edCampo[3].Text := 'SALA 02';
      edCampo[4].Text := FormatDateTime('dd/mm/yyyy hh:nn', Now);
      edCampo[5].Text := 'Apresentar na entrada';
      edCampo[6].Text := 'Válido hoje';
      edCampo[7].Text := 'TCK0042';
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

procedure TfrmEtiquetasSetoriais.ImprimirItemGrafico(AModelo: TModeloEtiquetaSetorial;
  const C: TCamposSetoriais; const Foto: string; ApenasPrevia: Boolean);
var
  R: TRLReport;
begin
  R := CriarRelatorioSetorial(Self, FModo, AModelo, C, Foto, chkFotoPB.Checked);
  try
    R.PrintDialog := False;
    if ApenasPrevia then
      R.PreviewModal
    else
      R.Print;
  finally
    R.Free;
  end;
end;

procedure TfrmEtiquetasSetoriais.ImprimirLotePOS(AModelo: TModeloEtiquetaSetorial;
  Modo: TModoImpressoraEtiqueta; const Itens: array of TCamposSetoriais);
var
  PosPrinter: TAIPOSPrinter;
  I, J, TotalVol: Integer;
  LinhaVol: string;
begin
  TotalVol := Length(Itens);
  if TotalVol = 0 then Exit;

  PosPrinter := TAIPOSPrinter.Create(Self);
  try
    case Modo of
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
        'Use a saída gráfica para imprimir via driver do Windows.',
        mtWarning, [mbOK], 0);
      Exit;
    end;

    try
      for I := 0 to TotalVol - 1 do
      begin
        PosPrinter.AlignCenter;
        PosPrinter.SetBold(True);
        PosPrinter.PrintTextLine(NomesModelosSetoriais[AModelo]);
        PosPrinter.SetBold(False);
        PosPrinter.AlignLeft;
        for J := 0 to 6 do
        begin
          if Trim(Itens[I][J]) <> '' then
          begin
            if (AModelo = msEnvioDespachoVolumes) and (J = 5) and (TotalVol > 1) then
            begin
              LinhaVol := Format('VOLUME: %d/%d', [I + 1, TotalVol]);
              PosPrinter.SetBold(True);
              PosPrinter.PrintTextLine(LinhaVol);
              PosPrinter.SetBold(False);
            end
            else
              PosPrinter.PrintTextLine(Trim(Itens[I][J]));
          end;
        end;
        if Trim(Itens[I][7]) <> '' then
        begin
          PosPrinter.AlignCenter;
          PosPrinter.PrintBarcode(Trim(Itens[I][7]), 65, 2, 2);
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

procedure TfrmEtiquetasSetoriais.AtualizarWizardUI;
var
  Passo: Integer;
begin
  Passo := pcWizard.ActivePageIndex;
  lblIndicador.Caption := Format('%d / 3', [Passo + 1]);
  btnVoltar.Enabled := Passo > 0;
  btnAvancar.Visible := Passo < 2;
  btnPreviaGrafica.Visible := Passo = 2;
  btnImprimirGrafico.Visible := Passo = 2;
  btnImprimirPOS.Visible := Passo = 2;

  case Passo of
    0:
    begin
      lblPassoTitulo.Caption := 'Passo 1 de 3 — Impressora e Tamanho da Etiqueta';
      lblPassoSub.Caption := 'Selecione o tipo de impressora, o modelo/tamanho da etiqueta e a quantidade de cópias.';
    end;
    1:
    begin
      lblPassoTitulo.Caption := 'Passo 2 de 3 — Dados, Cadastro (CRUD) e Seleção de Itens';
      if ModeloUsaCrudLista(FModelo) then
        lblPassoSub.Caption := 'Cadastre, altere ou exclua registros e marque [X] os itens que serão impressos.'
      else
        lblPassoSub.Caption := 'Emissão 1 a 1: preencha os campos do item para gerar a etiqueta.';
    end;
    2:
    begin
      lblPassoTitulo.Caption := 'Passo 3 de 3 — Pré-visualização e Impressão';
      lblPassoSub.Caption := 'Confira os dados do lote e escolha pré-visualizar no FortesReport ou imprimir.';
      AtualizarResumoPrevia;
    end;
  end;
end;

procedure TfrmEtiquetasSetoriais.VoltarClick(Sender: TObject);
begin
  if pcWizard.ActivePageIndex > 0 then
  begin
    pcWizard.ActivePageIndex := pcWizard.ActivePageIndex - 1;
    AtualizarWizardUI;
  end;
end;

procedure TfrmEtiquetasSetoriais.AvancarClick(Sender: TObject);
var
  I, Marcados: Integer;
begin
  if pcWizard.ActivePageIndex = 1 then
  begin
    if ModeloUsaCrudLista(FModelo) then
    begin
      Marcados := 0;
      for I := 0 to High(FMarcados) do
        if FMarcados[I] then Inc(Marcados);
      if Marcados = 0 then
      begin
        if MessageDlg('Nenhum item marcado',
          'Nenhum item está marcado com [X] na grade.' + sLineBreak +
          'Deseja avançar usando os dados preenchidos nos campos acima?',
          mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
          Exit;
      end;
    end;
  end;

  if pcWizard.ActivePageIndex < 2 then
  begin
    pcWizard.ActivePageIndex := pcWizard.ActivePageIndex + 1;
    AtualizarWizardUI;
  end;
end;

procedure TfrmEtiquetasSetoriais.FecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmEtiquetasSetoriais.CarregarTabelaCrud;
begin
  SetLength(FLinhas, 0);
  SetLength(FMarcados, 0);
  if FSpecValido and (GConexaoFinalidade <> nil) and GConexaoFinalidade.Connected then
    FLinhas := CarregarRegistrosTabela(GConexaoFinalidade, FSpec, Trim(edFiltroCrud.Text));
  SetLength(FMarcados, Length(FLinhas));
  RenderizarGradeCrud;
end;

procedure TfrmEtiquetasSetoriais.RenderizarGradeCrud;
var
  I, J, ColsTotal: Integer;
begin
  ColsTotal := 2 + Length(FSpec.Campos);
  FGrid.ColCount := Max(2, ColsTotal);
  FGrid.RowCount := Max(2, Length(FLinhas) + 1);
  FGrid.Cells[0, 0] := 'Imp.';
  FGrid.ColWidths[0] := 42;
  FGrid.Cells[1, 0] := 'ID';
  FGrid.ColWidths[1] := 48;
  for J := 0 to High(FSpec.Campos) do
  begin
    FGrid.Cells[2 + J, 0] := FSpec.Campos[J].Rotulo;
    FGrid.ColWidths[2 + J] := 130;
  end;

  if Length(FLinhas) = 0 then
  begin
    for J := 0 to FGrid.ColCount - 1 do
      FGrid.Cells[J, 1] := '';
    FGrid.Cells[2, 1] := '(Nenhum registro na tabela)';
    AtualizarContagemCrud;
    Exit;
  end;

  for I := 0 to High(FLinhas) do
  begin
    if FMarcados[I] then
      FGrid.Cells[0, I + 1] := '[X]'
    else
      FGrid.Cells[0, I + 1] := '[ ]';
    FGrid.Cells[1, I + 1] := FLinhas[I].Id;
    for J := 0 to High(FSpec.Campos) do
    begin
      if J <= High(FLinhas[I].Valores) then
        FGrid.Cells[2 + J, I + 1] := FLinhas[I].Valores[J]
      else
        FGrid.Cells[2 + J, I + 1] := '';
    end;
  end;
  AtualizarContagemCrud;
end;

procedure TfrmEtiquetasSetoriais.AtualizarContagemCrud;
var
  I, Marcados: Integer;
begin
  Marcados := 0;
  for I := 0 to High(FMarcados) do
    if FMarcados[I] then Inc(Marcados);
  lblContagemCrud.Caption := Format('%d registro(s) | %d marcado(s) p/ imprimir',
    [Length(FLinhas), Marcados]);
end;

procedure TfrmEtiquetasSetoriais.AlternarMarcacaoCrud(RowIdx: Integer);
begin
  if (RowIdx < 0) or (RowIdx > High(FMarcados)) then Exit;
  FMarcados[RowIdx] := not FMarcados[RowIdx];
  if FMarcados[RowIdx] then
    FGrid.Cells[0, RowIdx + 1] := '[X]'
  else
    FGrid.Cells[0, RowIdx + 1] := '[ ]';
  AtualizarContagemCrud;
end;

procedure TfrmEtiquetasSetoriais.CarregarLinhaParaEdicao(RowIdx: Integer);
var
  J: Integer;
begin
  if (RowIdx < 0) or (RowIdx > High(FLinhas)) then Exit;
  FIdEdicao := FLinhas[RowIdx].Id;
  for J := 0 to 7 do
  begin
    if J <= High(FLinhas[RowIdx].Valores) then
      edCampo[J].Text := FLinhas[RowIdx].Valores[J]
    else
      edCampo[J].Text := '';
  end;
  if (FModelo = msCrachaFuncionario) and (Length(FLinhas[RowIdx].Valores) > 8) then
    FCaminhoFoto := FLinhas[RowIdx].Valores[8];
end;

procedure TfrmEtiquetasSetoriais.CrudNovoClick(Sender: TObject);
var
  I: Integer;
begin
  FIdEdicao := '';
  for I := 0 to 7 do
    edCampo[I].Text := '';
  FCaminhoFoto := '';
  if edCampo[0].CanFocus then
    edCampo[0].SetFocus;
end;

procedure TfrmEtiquetasSetoriais.CrudSalvarClick(Sender: TObject);
var
  Valores: TStringArray;
  Msg: string;
begin
  if (not FSpecValido) or (GConexaoFinalidade = nil) or (not GConexaoFinalidade.Connected) then
  begin
    MessageDlg('Banco de Dados', 'Banco de dados não conectado.', mtWarning, [mbOK], 0);
    Exit;
  end;
  ObterValoresBanco(Valores);
  try
    if FIdEdicao <> '' then
    begin
      AtualizarRegistroTabela(GConexaoFinalidade, FSpec, FIdEdicao, Valores);
      Msg := 'registro #' + FIdEdicao + ' atualizado';
    end
    else
      Msg := 'registro #' + IntToStr(InserirRegistroTabela(GConexaoFinalidade, FSpec, Valores)) + ' incluído';
    FIdEdicao := '';
    CarregarTabelaCrud;
    { Confirmação discreta, sem janela a cada gravação }
    lblContagemCrud.Caption := lblContagemCrud.Caption + ' | ' + Msg + ' às ' + FormatDateTime('hh:nn', Now);
  except
    on E: Exception do
      MessageDlg('Erro ao salvar', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TfrmEtiquetasSetoriais.CrudExcluirClick(Sender: TObject);
var
  RowIdx: Integer;
  IdAlvo: string;
begin
  RowIdx := FGrid.Row - 1;
  if (RowIdx < 0) or (RowIdx > High(FLinhas)) then
  begin
    MessageDlg('Excluir', 'Selecione um registro na grade.', mtInformation, [mbOK], 0);
    Exit;
  end;
  IdAlvo := FLinhas[RowIdx].Id;
  if MessageDlg('Confirmar Exclusão', 'Excluir o registro #' + IdAlvo + '?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  try
    ExcluirRegistroTabela(GConexaoFinalidade, FSpec, IdAlvo);
    if FIdEdicao = IdAlvo then FIdEdicao := '';
    CarregarTabelaCrud;
  except
    on E: Exception do
      MessageDlg('Erro ao excluir', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TfrmEtiquetasSetoriais.CrudCancelarClick(Sender: TObject);
begin
  FIdEdicao := '';
  AtualizarInterface(nil);
end;

procedure TfrmEtiquetasSetoriais.CrudAtualizarClick(Sender: TObject);
begin
  CarregarTabelaCrud;
end;

procedure TfrmEtiquetasSetoriais.CrudImportarClick(Sender: TObject);
begin
  if ExecutarImportarCSVDialog(Self, FSpec) then
    CarregarTabelaCrud;
end;

procedure TfrmEtiquetasSetoriais.CrudExportarClick(Sender: TObject);
begin
  ExecutarExportarCSVDialog(Self, FSpec);
end;

procedure TfrmEtiquetasSetoriais.BuscarCrudClick(Sender: TObject);
begin
  CarregarTabelaCrud;
end;

procedure TfrmEtiquetasSetoriais.FiltroCrudKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    CarregarTabelaCrud;
  end;
end;

procedure TfrmEtiquetasSetoriais.MarcarTodosCrudClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to High(FMarcados) do
  begin
    FMarcados[I] := True;
    FGrid.Cells[0, I + 1] := '[X]';
  end;
  AtualizarContagemCrud;
end;

procedure TfrmEtiquetasSetoriais.DesmarcarTodosCrudClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to High(FMarcados) do
  begin
    FMarcados[I] := False;
    FGrid.Cells[0, I + 1] := '[ ]';
  end;
  AtualizarContagemCrud;
end;

procedure TfrmEtiquetasSetoriais.GridCrudMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ACol, ARow: Integer;
begin
  FGrid.MouseToCell(X, Y, ACol, ARow);
  if (ARow >= 1) and (ACol = 0) then
    AlternarMarcacaoCrud(ARow - 1);
end;

procedure TfrmEtiquetasSetoriais.GridCrudDblClick(Sender: TObject);
begin
  if FGrid.Row >= 1 then
    CarregarLinhaParaEdicao(FGrid.Row - 1);
end;

procedure TfrmEtiquetasSetoriais.GridCrudKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_SPACE) and (FGrid.Row >= 1) then
  begin
    AlternarMarcacaoCrud(FGrid.Row - 1);
    Key := 0;
  end
  else if (Key = VK_RETURN) and (FGrid.Row >= 1) then
  begin
    CarregarLinhaParaEdicao(FGrid.Row - 1);
    Key := 0;
  end;
end;

procedure TfrmEtiquetasSetoriais.MontarLoteImpressao(
  out Itens: TCamposSetoriaisArray; out Fotos: TStringArray);
var
  I, J, K, Copias, Total, Idx: Integer;
  C: TCamposSetoriais;
  TemMarcado: Boolean;
begin
  Copias := Max(1, seCopias.Value);
  TemMarcado := False;
  if ModeloUsaCrudLista(FModelo) then
    for I := 0 to High(FMarcados) do
      if FMarcados[I] then
      begin
        TemMarcado := True;
        Break;
      end;

  if TemMarcado then
  begin
    Total := 0;
    for I := 0 to High(FMarcados) do
      if FMarcados[I] then Inc(Total, Copias);
    SetLength(Itens, Total);
    SetLength(Fotos, Total);
    Idx := 0;
    for I := 0 to High(FLinhas) do
    begin
      if not FMarcados[I] then Continue;
      for K := 0 to Copias - 1 do
      begin
        for J := 0 to 7 do
          if J <= High(FLinhas[I].Valores) then
            Itens[Idx][J] := Trim(FLinhas[I].Valores[J])
          else
            Itens[Idx][J] := '';
        if (FModelo = msEnvioDespachoVolumes) and (Copias > 1) then
          Itens[Idx][5] := Format('VOLUME: %d/%d (Lote de %d volumes)', [K + 1, Copias, Copias]);
        if (FModelo = msCrachaFuncionario) and (Length(FLinhas[I].Valores) > 8) and (FLinhas[I].Valores[8] <> '') then
          Fotos[Idx] := FLinhas[I].Valores[8]
        else
          Fotos[Idx] := FCaminhoFoto;
        Inc(Idx);
      end;
    end;
  end
  else
  begin
    for J := 0 to 7 do
      C[J] := Trim(edCampo[J].Text);
    SetLength(Itens, Copias);
    SetLength(Fotos, Copias);
    for K := 0 to Copias - 1 do
    begin
      Itens[K] := C;
      if (FModelo = msEnvioDespachoVolumes) and (Copias > 1) then
        Itens[K][5] := Format('VOLUME: %d/%d (Lote de %d volumes)', [K + 1, Copias, Copias]);
      Fotos[K] := FCaminhoFoto;
    end;
  end;
end;

procedure TfrmEtiquetasSetoriais.AtualizarResumoPrevia;
var
  Itens: TCamposSetoriaisArray;
  Fotos: TStringArray;
  I, J, Limite: Integer;
  W, H: Double;
begin
  MontarLoteImpressao(Itens, Fotos);
  DimensoesPapelSetorial(FModo, FModelo, W, H);
  mmoPrevia.Lines.BeginUpdate;
  try
    mmoPrevia.Lines.Clear;
    mmoPrevia.Lines.Add('====================================================================');
    mmoPrevia.Lines.Add('IMPRESSORA : ' + cbModoImpressora.Text);
    mmoPrevia.Lines.Add('MODELO     : ' + NomesModelosSetoriais[FModelo]);
    mmoPrevia.Lines.Add(Format('DIMENSÃO   : %.1f x %.1f mm', [W, H]));
    mmoPrevia.Lines.Add(Format('CÓPIAS/ITEM: %d | TOTAL DE ETIQUETAS: %d', [seCopias.Value, Length(Itens)]));
    mmoPrevia.Lines.Add('====================================================================');
    mmoPrevia.Lines.Add('');
    Limite := Min(High(Itens), 49);
    for I := 0 to Limite do
    begin
      mmoPrevia.Lines.Add(Format('--- Etiqueta #%d ---', [I + 1]));
      for J := 0 to 7 do
        if Trim(Itens[I][J]) <> '' then
          mmoPrevia.Lines.Add('  ' + lblCampo[J].Caption + ': ' + Itens[I][J]);
      if (FModelo in [msCrachaVisitanteHosp, msCrachaFuncionario]) and (Fotos[I] <> '') then
        mmoPrevia.Lines.Add('  Foto: ' + ExtractFileName(Fotos[I]));
      mmoPrevia.Lines.Add('');
    end;
    if Length(Itens) > 50 then
      mmoPrevia.Lines.Add(Format('... e mais %d etiqueta(s) no lote.', [Length(Itens) - 50]));
  finally
    mmoPrevia.Lines.EndUpdate;
  end;
end;

procedure TfrmEtiquetasSetoriais.PreviaGraficaClick(Sender: TObject);
var
  Itens: TCamposSetoriaisArray;
  Fotos: TStringArray;
begin
  MontarLoteImpressao(Itens, Fotos);
  if Length(Itens) = 0 then Exit;
  ImprimirItemGrafico(FModelo, Itens[0], Fotos[0], True);
end;

procedure TfrmEtiquetasSetoriais.ImprimirGraficoClick(Sender: TObject);
var
  Itens: TCamposSetoriaisArray;
  Fotos: TStringArray;
  I: Integer;
  Dlg: TPrintDialog;
begin
  MontarLoteImpressao(Itens, Fotos);
  if Length(Itens) = 0 then Exit;
  Dlg := TPrintDialog.Create(Self);
  try
    if not Dlg.Execute then Exit;
  finally
    Dlg.Free;
  end;
  try
    for I := 0 to High(Itens) do
      ImprimirItemGrafico(FModelo, Itens[I], Fotos[I], False);
    ShowMessage(Format('%d etiqueta(s) enviada(s) para impressão.', [Length(Itens)]));
  except
    on E: Exception do
      MessageDlg('Etiqueta Setorial', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TfrmEtiquetasSetoriais.ImprimirPOSClick(Sender: TObject);
var
  Itens: TCamposSetoriaisArray;
  Fotos: TStringArray;
begin
  MontarLoteImpressao(Itens, Fotos);
  if Length(Itens) = 0 then Exit;
  try
    ImprimirLotePOS(FModelo, FModo, Itens);
  except
    on E: Exception do
      MessageDlg('Etiqueta Setorial', E.Message, mtError, [mbOK], 0);
  end;
end;

end.
