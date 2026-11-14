unit main;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  ExtCtrls, ComCtrls, Buttons, setmain, dmbase, registro, config, gondola, import,
  maladireta, etqlab, pix, pulseira, etiquetasmedicas, etfarm,
  etiquetasnovas, etiquetaspimaco, inicio, qrmidia, mercadolivre;

const
  versao = '0120';

type

  { TfrmMain }

  TfrmMain = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    imgMalaDireta: TImage;
    imgZebra: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbVersion: TLabel;
    MainMenu1: TMainMenu;
    miDespachoMedico: TMenuItem;
    miExameMedico: TMenuItem;
    miCadFarm: TMenuItem;
    miPulseira: TMenuItem;
    miImport: TMenuItem;
    miconfig: TMenuItem;
    misetup: TMenuItem;
    miexit: TMenuItem;
    PageControl1: TPageControl;
    PageControl2: TPageControl;
    PageControl3: TPageControl;
    PageControl4: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    StatusBar1: TStatusBar;
    TabSheet1: TTabSheet;
    TabSheet10: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TabSheet8: TTabSheet;
    TabSheet9: TTabSheet;
    tsPrinter: TTabSheet;
    tbSobre: TTabSheet;
    tbThermal: TTabSheet;
    tbZebra: TTabSheet;
    tsHospitalSupply: TTabSheet;
    LabelPulseira: TLabel;
    LabelPulseiraInfo: TLabel;
    btnPulseiraZebra: TBitBtn;
    btnCadFarm: TBitBtn;
    LabelDespacho: TLabel;
    imgDespachoMedico: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image4Click(Sender: TObject);
    procedure imgDespachoMedicoClick(Sender: TObject);
    procedure Image5Click(Sender: TObject);
    procedure Image7Click(Sender: TObject);
    procedure imgMalaDiretaClick(Sender: TObject);
    procedure imgProductsClick(Sender: TObject);
    procedure imgZebraClick(Sender: TObject);
    procedure miexitClick(Sender: TObject);
    procedure miDespachoMedicoClick(Sender: TObject);
    procedure miExameMedicoClick(Sender: TObject);
    procedure miCadFarmClick(Sender: TObject);
    procedure miPulseiraClick(Sender: TObject);
    procedure miImportClick(Sender: TObject);
    procedure misetupClick(Sender: TObject);
  private
    FInicio: TInicio;
    tbThermal40: TTabSheet;
    procedure AbrirModeloInicio(Sender: TObject);
    procedure AlternarInicio(Sender: TObject);
    procedure ConfigurarMenuEAbasPorImpressora;
    procedure AbrirSetorialTag(Sender: TObject);
    procedure AbrirPimacoTag(Sender: TObject);
    procedure SelecionarAbaImpressoraClick(Sender: TObject);
  public
    aplicacao : string;
    procedure Config();
    procedure PesquisaMalaDireta();
    procedure PesquisaEtqLaboratorio();
    procedure PIXBRAZIL();
    procedure AbrirEtiquetaSetorial(AModo: TModoImpressoraEtiqueta; AModelo: TModeloEtiquetaSetorial);
    procedure AbrirEtiquetaPimaco(AFinalidade: TFinalidadePimaco; AModelo: TModeloPimaco = pmA4255);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.AbrirEtiquetaSetorial(AModo: TModoImpressoraEtiqueta;
  AModelo: TModeloEtiquetaSetorial);
var
  Janela: TfrmEtiquetasSetoriais;
begin
  Janela := TfrmEtiquetasSetoriais.CreateSetorial(Self, AModo, AModelo);
  try
    Janela.ShowModal;
  finally
    Janela.Free;
  end;
end;

procedure TfrmMain.AbrirEtiquetaPimaco(AFinalidade: TFinalidadePimaco;
  AModelo: TModeloPimaco);
var
  Janela: TfrmEtiquetasPimaco;
begin
  Janela := TfrmEtiquetasPimaco.CreateComFinalidade(Self, AFinalidade, AModelo);
  try
    Janela.ShowModal;
  finally
    Janela.Free;
  end;
end;

procedure TfrmMain.AbrirSetorialTag(Sender: TObject);
var
  Cod, ModoInt, ModeloInt: Integer;
begin
  Cod := TComponent(Sender).Tag;
  ModoInt := Cod div 100;
  ModeloInt := Cod mod 100;
  AbrirEtiquetaSetorial(TModoImpressoraEtiqueta(ModoInt), TModeloEtiquetaSetorial(ModeloInt));
end;

procedure TfrmMain.AbrirPimacoTag(Sender: TObject);
var
  Cod, FinInt, ModInt: Integer;
begin
  Cod := TComponent(Sender).Tag;
  FinInt := Cod div 100;
  ModInt := Cod mod 100;
  AbrirEtiquetaPimaco(TFinalidadePimaco(FinInt), TModeloPimaco(ModInt));
end;

procedure TfrmMain.SelecionarAbaImpressoraClick(Sender: TObject);
begin
  if Assigned(FInicio) then
  begin
    FInicio.SelecionarImpressora(TComponent(Sender).Tag - 1);
    FInicio.Visible := True;
    Panel1.Visible := False;
    Panel2.Visible := False;
    Exit;
  end;
  case TComponent(Sender).Tag of
    1: PageControl1.ActivePage := tbZebra;
    2: PageControl1.ActivePage := tbThermal;
    3: if Assigned(tbThermal40) then PageControl1.ActivePage := tbThermal40;
    4: PageControl1.ActivePage := tsPrinter;
  end;
end;

procedure TfrmMain.AbrirModeloInicio(Sender: TObject);
var
  Codigo: Integer;
  QR: TfrmQRMidia;
  ML: TfrmMercadoLivre;
begin
  Codigo := TComponent(Sender).Tag;
  case Codigo of
    1000:
      begin
        QR := TfrmQRMidia.CreateParaImpressora(Self, FInicio.TipoImpressora);
        try QR.ShowModal; finally QR.Free; end;
      end;
    1001: miPulseiraClick(Sender);
    1002:
      begin
        ML := TfrmMercadoLivre.CreateParaImpressora(Self, FInicio.TipoImpressora);
        try ML.ShowModal; finally ML.Free; end;
      end;
  else
    if FInicio.TipoImpressora = 3 then
      AbrirEtiquetaPimaco(TFinalidadePimaco(Codigo div 100), TModeloPimaco(Codigo mod 100))
    else
      AbrirEtiquetaSetorial(TModoImpressoraEtiqueta(FInicio.TipoImpressora), TModeloEtiquetaSetorial(Codigo));
  end;
end;

procedure TfrmMain.AlternarInicio(Sender: TObject);
begin
  FInicio.Visible := not FInicio.Visible;
  Panel1.Visible := not FInicio.Visible;
  Panel2.Visible := not FInicio.Visible;
end;

procedure TfrmMain.ConfigurarMenuEAbasPorImpressora;
  function AddItemSetorial(Pai: TMenuItem; const Titulo: string;
    AModo: TModoImpressoraEtiqueta; AModelo: TModeloEtiquetaSetorial): TMenuItem;
  begin
    Result := TMenuItem.Create(Self);
    Result.Caption := Titulo;
    Result.Tag := Ord(AModo) * 100 + Ord(AModelo);
    Result.OnClick := @AbrirSetorialTag;
    Pai.Add(Result);
  end;

  function AddItemPimaco(Pai: TMenuItem; const Titulo: string;
    AFinalidade: TFinalidadePimaco; AModelo: TModeloPimaco): TMenuItem;
  begin
    Result := TMenuItem.Create(Self);
    Result.Caption := Titulo;
    Result.Tag := Ord(AFinalidade) * 100 + Ord(AModelo);
    Result.OnClick := @AbrirPimacoTag;
    Pai.Add(Result);
  end;

  procedure CriarBotaoSetorial(ParentCtrl: TWinControl; const Titulo: string;
    X, Y, W, H: Integer; AModo: TModoImpressoraEtiqueta; AModelo: TModeloEtiquetaSetorial);
  var
    B: TBitBtn;
  begin
    B := TBitBtn.Create(Self);
    B.Parent := ParentCtrl;
    B.Caption := Titulo;
    B.SetBounds(X, Y, W, H);
    B.Tag := Ord(AModo) * 100 + Ord(AModelo);
    B.OnClick := @AbrirSetorialTag;
  end;

  procedure CriarBotaoPimaco(ParentCtrl: TWinControl; const Titulo: string;
    X, Y, W, H: Integer; AFinalidade: TFinalidadePimaco; AModelo: TModeloPimaco);
  var
    B: TBitBtn;
  begin
    B := TBitBtn.Create(Self);
    B.Parent := ParentCtrl;
    B.Caption := Titulo;
    B.SetBounds(X, Y, W, H);
    B.Tag := Ord(AFinalidade) * 100 + Ord(AModelo);
    B.OnClick := @AbrirPimacoTag;
  end;

  procedure PopularMenuImpressora(MenuImp: TMenuItem; AModo: TModoImpressoraEtiqueta);
  begin
    AddItemSetorial(MenuImp, 'Supermercado: Gôndola Preço + Kg/Litro', AModo, msSupGondolaKg);
    AddItemSetorial(MenuImp, 'Supermercado: Balança Padaria/Açougue (EAN-13)', AModo, msSupBalancaPadaria);
    AddItemSetorial(MenuImp, 'Supermercado/Saúde: Validade ANVISA RDC 216', AModo, msSupValidadeANVISA);
    AddItemSetorial(MenuImp, 'Laboratório: Tubo de Coleta / Vacutainer', AModo, msLabTuboColeta);
    AddItemSetorial(MenuImp, 'Laboratório: Lâmina de Biópsia / Citologia', AModo, msLabLaminaBiopsia);
    AddItemSetorial(MenuImp, 'Laboratório: Bolsa de Sangue / Hemoterapia', AModo, msLabBolsaSangue);
    AddItemSetorial(MenuImp, 'Laboratório: Transporte Biológico UN 3373', AModo, msLabTransporteBio);
    AddItemSetorial(MenuImp, 'Farmácia: Medicamento Avulso / Posologia', AModo, msMedAvulsoPosologia);
    AddItemSetorial(MenuImp, 'Farmácia Hospitalar: Dose Unitária / Fracionamento', AModo, msMedFracionamento);
    AddItemSetorial(MenuImp, 'Hospitalar: Rótulo de Soro / Infusão EV', AModo, msMedSoroInfusao);
    AddItemSetorial(MenuImp, 'Logística: Envio e Despacho de Produtos (Volumes)', AModo, msEnvioDespachoVolumes);
    AddItemSetorial(MenuImp, 'Crachá: Visitante / Acompanhante Hospitalar', AModo, msCrachaVisitanteHosp);
    AddItemSetorial(MenuImp, 'Crachá: Funcionário / Operador c/ Foto IA', AModo, msCrachaFuncionario);
  end;

var
  miZebraMenu, miTerm80Menu, miTerm40Menu, miLaserPimacoMenu: TMenuItem;
  pnlAtalhosImp: TGroupBox;
  BImp: TBitBtn;
  LInfo40: TLabel;
begin
  Caption := 'Etiquetas Maurinsoft — Supermercados, Varejo, Hospitais e Laboratórios (v' + versao + ')';

  // Renomeia as abas principais por tipo de impressora
  tbSobre.Caption := 'Sobre';
  tbZebra.Caption := '1. Zebra (Rolo)';
  tbThermal.Caption := '2. Térmica 80 Col (80mm)';
  tsPrinter.Caption := '4. Laser / Jato (Pimaco A4)';

  // Cria a 3ª aba de impressora: Térmica 40 Colunas (Maquininha de Cartão 58mm)
  tbThermal40 := TTabSheet.Create(PageControl1);
  tbThermal40.PageControl := PageControl1;
  tbThermal40.Caption := '3. Térmica 40 Col (Maquininha)';

  LInfo40 := TLabel.Create(Self);
  LInfo40.Parent := tbThermal40;
  LInfo40.Font.Style := [fsBold];
  LInfo40.SetBounds(16, 14, 500, 20);
  LInfo40.Caption := 'Impressora Térmica 40 Colunas / 58mm (Tipo Maquininha de Cartão / Portátil)';

  CriarBotaoSetorial(tbThermal40, 'Supermercado: Preço Rápido / Gôndola 58mm', 16, 44, 245, 36, miTermica40Col, msSupGondolaKg);
  CriarBotaoSetorial(tbThermal40, 'Supermercado: Padaria/Açougue EAN-13 58mm', 275, 44, 245, 36, miTermica40Col, msSupBalancaPadaria);
  CriarBotaoSetorial(tbThermal40, 'Validade ANVISA RDC 216 (40 Colunas)', 16, 88, 245, 36, miTermica40Col, msSupValidadeANVISA);
  CriarBotaoSetorial(tbThermal40, 'Farmácia: Medicamento Avulso / Posologia', 275, 88, 245, 36, miTermica40Col, msMedAvulsoPosologia);
  CriarBotaoSetorial(tbThermal40, 'Hospital: Dose Unitária / Beira-Leito', 16, 132, 245, 36, miTermica40Col, msMedFracionamento);
  CriarBotaoSetorial(tbThermal40, 'Hospital: Rótulo de Soro / Infusão 58mm', 275, 132, 245, 36, miTermica40Col, msMedSoroInfusao);
  CriarBotaoSetorial(tbThermal40, 'Laboratório: Amostra / Coleta Portátil', 16, 176, 245, 36, miTermica40Col, msLabTuboColeta);
  CriarBotaoSetorial(tbThermal40, 'Logística: Etiqueta Sacola / Despacho 58mm', 275, 176, 245, 36, miTermica40Col, msEnvioDespachoVolumes);
  CriarBotaoSetorial(tbThermal40, 'Portaria: Crachá Visitante / Acompanhante', 16, 220, 245, 36, miTermica40Col, msCrachaVisitanteHosp);
  CriarBotaoSetorial(tbThermal40, 'Crachá Funcionário / Operador 58mm', 275, 220, 245, 36, miTermica40Col, msCrachaFuncionario);

  // Adiciona os novos botões nas sub-abas de 1. Zebra (tbZebra)
  TabSheet7.Caption := 'Supermercado / Varejo';
  TabSheet8.Caption := 'Laboratório';
  tsHospitalSupply.Caption := 'Hospital & Farmácia';
  TabSheet9.Caption := 'Despacho & Crachás';

  CriarBotaoSetorial(TabSheet7, 'Gôndola Preço + Kg/Litro (100x35)', 250, 24, 260, 36, miZebraRolo, msSupGondolaKg);
  CriarBotaoSetorial(TabSheet7, 'Balança Padaria/Açougue EAN-13 (60x40)', 250, 68, 260, 36, miZebraRolo, msSupBalancaPadaria);
  CriarBotaoSetorial(TabSheet7, 'Validade ANVISA RDC 216 (50x30)', 250, 112, 260, 36, miZebraRolo, msSupValidadeANVISA);

  CriarBotaoSetorial(TabSheet8, 'Tubo de Coleta / Vacutainer', 250, 200, 260, 34, miZebraRolo, msLabTuboColeta);
  CriarBotaoSetorial(TabSheet8, 'Lâmina Biópsia / Patologia (25x15)', 250, 240, 260, 34, miZebraRolo, msLabLaminaBiopsia);
  CriarBotaoSetorial(TabSheet8, 'Bolsa de Sangue / Hemoterapia (100x70)', 250, 280, 260, 34, miZebraRolo, msLabBolsaSangue);
  CriarBotaoSetorial(TabSheet8, 'Transporte Biológico UN 3373 (100x100)', 250, 320, 260, 34, miZebraRolo, msLabTransporteBio);

  CriarBotaoSetorial(tsHospitalSupply, 'Medicamento Avulso / Posologia (60x40)', 20, 140, 245, 36, miZebraRolo, msMedAvulsoPosologia);
  CriarBotaoSetorial(tsHospitalSupply, 'Dose Unitária / Fracionamento (40x30)', 275, 140, 245, 36, miZebraRolo, msMedFracionamento);
  CriarBotaoSetorial(tsHospitalSupply, 'Rótulo de Soro / Infusão EV (80x50)', 20, 184, 245, 36, miZebraRolo, msMedSoroInfusao);
  CriarBotaoSetorial(tsHospitalSupply, 'Crachá Visitante / Acompanhante (80x50)', 275, 184, 245, 36, miZebraRolo, msCrachaVisitanteHosp);

  CriarBotaoSetorial(TabSheet9, 'Despacho Produtos Multi-Volumes (100x150)', 250, 24, 265, 36, miZebraRolo, msEnvioDespachoVolumes);
  CriarBotaoSetorial(TabSheet9, 'Crachá Visitante / Acompanhante (80x50)', 250, 68, 265, 36, miZebraRolo, msCrachaVisitanteHosp);
  CriarBotaoSetorial(TabSheet9, 'Crachá Funcionário c/ Foto IA (54x86)', 250, 112, 265, 36, miZebraRolo, msCrachaFuncionario);

  // Adiciona os novos botões nas sub-abas de 2. Térmica 80 Colunas (tbThermal)
  TabSheet5.Caption := 'Supermercado 80 Col';
  TabSheet4.Caption := 'Saúde & Lab 80 Col';
  TabSheet6.Caption := 'Despacho & Crachás 80 Col';

  CriarBotaoSetorial(TabSheet5, 'Gôndola / Promoção 80 Colunas', 20, 24, 245, 36, miTermica80Col, msSupGondolaKg);
  CriarBotaoSetorial(TabSheet5, 'Comanda / Balança Padaria EAN-13', 275, 24, 245, 36, miTermica80Col, msSupBalancaPadaria);
  CriarBotaoSetorial(TabSheet5, 'Validade ANVISA RDC 216 (80mm)', 20, 68, 245, 36, miTermica80Col, msSupValidadeANVISA);

  CriarBotaoSetorial(TabSheet4, 'Medicamento Avulso / Posologia 80mm', 248, 86, 260, 34, miTermica80Col, msMedAvulsoPosologia);
  CriarBotaoSetorial(TabSheet4, 'Dose Unitária / Fracionamento 80mm', 248, 126, 260, 34, miTermica80Col, msMedFracionamento);
  CriarBotaoSetorial(TabSheet4, 'Rótulo de Soro / Infusão EV 80mm', 248, 166, 260, 34, miTermica80Col, msMedSoroInfusao);
  CriarBotaoSetorial(TabSheet4, 'Tubo / Comprovante Exame Lab 80mm', 248, 206, 260, 34, miTermica80Col, msLabTuboColeta);

  CriarBotaoSetorial(TabSheet6, 'Despacho / Expedição 80 Colunas', 20, 24, 245, 36, miTermica80Col, msEnvioDespachoVolumes);
  CriarBotaoSetorial(TabSheet6, 'Transporte Biológico UN 3373 (80mm)', 275, 24, 245, 36, miTermica80Col, msLabTransporteBio);
  CriarBotaoSetorial(TabSheet6, 'Crachá Visitante / Acompanhante 80mm', 20, 68, 245, 36, miTermica80Col, msCrachaVisitanteHosp);
  CriarBotaoSetorial(TabSheet6, 'Crachá Funcionário / Operador 80mm', 275, 68, 245, 36, miTermica80Col, msCrachaFuncionario);

  // Adiciona os novos botões nas sub-abas de 4. Laser / Jato de Tinta - Pimaco (tsPrinter)
  TabSheet1.Caption := 'Supermercado (Pimaco/A4)';
  TabSheet10.Caption := 'Saúde & Lab (Pimaco)';
  TabSheet3.Caption := 'Despacho (Pimaco)';
  TabSheet2.Caption := 'Crachás (Pimaco)';

  Image6.Cursor := crHandPoint;
  Image6.OnClick := @AbrirPimacoTag;
  Image6.Tag := Ord(fpSupermercado) * 100 + Ord(pmCartazA4);

  CriarBotaoPimaco(TabSheet1, 'Pimaco A4255 (27/folha) - Gôndola/Preço', 210, 40, 300, 36, fpSupermercado, pmA4255);
  CriarBotaoPimaco(TabSheet1, 'Pimaco A4251 (65/folha) - Código Barras EAN', 210, 84, 300, 36, fpSupermercado, pmA4251);
  CriarBotaoPimaco(TabSheet1, 'Pimaco Carta 6180 (30/folha) - Preços', 210, 128, 300, 36, fpSupermercado, pmCarta6180);
  CriarBotaoPimaco(TabSheet1, 'Pimaco A4255 - Validade ANVISA RDC 216', 210, 172, 300, 36, fpValidadeANVISA, pmA4255);
  CriarBotaoPimaco(TabSheet1, 'Cartaz de Oferta Supermercado A4 Inteiro', 210, 216, 300, 36, fpSupermercado, pmCartazA4);

  CriarBotaoPimaco(TabSheet10, 'Pimaco A4248 (96/folha) - Lâminas / Micro-tubos', 20, 24, 480, 36, fpLaboratorio, pmA4248);
  CriarBotaoPimaco(TabSheet10, 'Pimaco A4251 (65/folha) - Tubos de Coleta Lab', 20, 68, 480, 36, fpLaboratorio, pmA4251);
  CriarBotaoPimaco(TabSheet10, 'Pimaco A4260 (21/folha) - Medicamento Avulso / Posologia', 20, 112, 480, 36, fpMedicamento, pmA4260);
  CriarBotaoPimaco(TabSheet10, 'Pimaco A4262 (14/folha) - Rótulo Soro / Farmácia Hospitalar', 20, 156, 480, 36, fpMedicamento, pmA4262);

  CriarBotaoPimaco(TabSheet3, 'Pimaco A4268 (4/folha) - Despacho e Envio de Produtos', 180, 24, 330, 38, fpDespacho, pmA4268);
  CriarBotaoPimaco(TabSheet3, 'Pimaco A4260 (21/folha) - Mala Direta / Endereçamento', 180, 72, 330, 38, fpDespacho, pmA4260);
  CriarBotaoPimaco(TabSheet3, 'Pimaco Carta 6182 (14/folha) - Expedição / Envelopes', 180, 120, 330, 38, fpDespacho, pmCarta6182);

  CriarBotaoPimaco(TabSheet2, 'Pimaco A4263 (10/folha) - Crachá Visitante / Acompanhante', 20, 24, 480, 40, fpCracha, pmA4263);
  CriarBotaoPimaco(TabSheet2, 'Pimaco A4263 (10/folha) - Crachá Funcionário c/ Foto IA', 20, 74, 480, 40, fpCracha, pmA4263);

  // Painel rápido no topo de Panel1 para alternar entre as 4 impressoras
  pnlAtalhosImp := TGroupBox.Create(Self);
  pnlAtalhosImp.Parent := Panel1;
  pnlAtalhosImp.Caption := 'Selecionar Tipo de Impressora';
  pnlAtalhosImp.SetBounds(8, 412, 290, 115);

  BImp := TBitBtn.Create(Self);
  BImp.Parent := pnlAtalhosImp;
  BImp.Caption := '1. Zebra (Rolo)';
  BImp.Tag := 1;
  BImp.SetBounds(8, 6, 132, 38);
  BImp.OnClick := @SelecionarAbaImpressoraClick;

  BImp := TBitBtn.Create(Self);
  BImp.Parent := pnlAtalhosImp;
  BImp.Caption := '2. Térmica 80 Col';
  BImp.Tag := 2;
  BImp.SetBounds(148, 6, 132, 38);
  BImp.OnClick := @SelecionarAbaImpressoraClick;

  BImp := TBitBtn.Create(Self);
  BImp.Parent := pnlAtalhosImp;
  BImp.Caption := '3. Maquininha 40c';
  BImp.Tag := 3;
  BImp.SetBounds(8, 50, 132, 38);
  BImp.OnClick := @SelecionarAbaImpressoraClick;

  BImp := TBitBtn.Create(Self);
  BImp.Parent := pnlAtalhosImp;
  BImp.Caption := '4. Laser / Pimaco';
  BImp.Tag := 4;
  BImp.SetBounds(148, 50, 132, 38);
  BImp.OnClick := @SelecionarAbaImpressoraClick;

  // Menus no topo separados pelas 4 impressoras
  miZebraMenu := TMenuItem.Create(Self);
  miZebraMenu.Caption := '1. Impressora Zebra (Rolo)';
  PopularMenuImpressora(miZebraMenu, miZebraRolo);
  MainMenu1.Items.Insert(1, miZebraMenu);

  miTerm80Menu := TMenuItem.Create(Self);
  miTerm80Menu.Caption := '2. Térmica 80 Colunas (PDV)';
  PopularMenuImpressora(miTerm80Menu, miTermica80Col);
  MainMenu1.Items.Insert(2, miTerm80Menu);

  miTerm40Menu := TMenuItem.Create(Self);
  miTerm40Menu.Caption := '3. Térmica 40 Col (Maquininha)';
  PopularMenuImpressora(miTerm40Menu, miTermica40Col);
  MainMenu1.Items.Insert(3, miTerm40Menu);

  miLaserPimacoMenu := TMenuItem.Create(Self);
  miLaserPimacoMenu.Caption := '4. Laser / Jato (Pimaco A4)';
  AddItemPimaco(miLaserPimacoMenu, 'Pimaco A4255 (27/folha) — Supermercado / Gôndola', fpSupermercado, pmA4255);
  AddItemPimaco(miLaserPimacoMenu, 'Pimaco A4251 (65/folha) — Preço / Código EAN-13', fpSupermercado, pmA4251);
  AddItemPimaco(miLaserPimacoMenu, 'Pimaco A4255 (27/folha) — Validade ANVISA RDC 216', fpValidadeANVISA, pmA4255);
  AddItemPimaco(miLaserPimacoMenu, 'Cartaz de Oferta Supermercado A4 (Folha Inteira)', fpSupermercado, pmCartazA4);
  AddItemPimaco(miLaserPimacoMenu, 'Pimaco A4248 (96/folha) — Lâminas / Micro-tubos Lab', fpLaboratorio, pmA4248);
  AddItemPimaco(miLaserPimacoMenu, 'Pimaco A4251 (65/folha) — Tubos de Coleta Laboratorial', fpLaboratorio, pmA4251);
  AddItemPimaco(miLaserPimacoMenu, 'Pimaco A4260 (21/folha) — Medicamento Avulso / Posologia', fpMedicamento, pmA4260);
  AddItemPimaco(miLaserPimacoMenu, 'Pimaco A4262 (14/folha) — Rótulo de Soro / Infusão', fpMedicamento, pmA4262);
  AddItemPimaco(miLaserPimacoMenu, 'Pimaco A4268 (4/folha) — Envio e Despacho de Produtos', fpDespacho, pmA4268);
  AddItemPimaco(miLaserPimacoMenu, 'Pimaco A4263 (10/folha) — Crachá Visitante / Funcionário c/ Foto', fpCracha, pmA4263);
  AddItemPimaco(miLaserPimacoMenu, 'Pimaco Carta 6180 (30/folha) — Uso Geral 3 Colunas', fpSupermercado, pmCarta6180);
  MainMenu1.Items.Insert(4, miLaserPimacoMenu);
end;

procedure TfrmMain.miDespachoMedicoClick(Sender: TObject);
var Janela: TfrmEtiquetasMedicas;
begin
  Janela := TfrmEtiquetasMedicas.CreateModelo(Self, emDespacho);
  try Janela.ShowModal; finally Janela.Free; end;
end;

procedure TfrmMain.miExameMedicoClick(Sender: TObject);
var Janela: TfrmEtiquetasMedicas;
begin
  Janela := TfrmEtiquetasMedicas.CreateModelo(Self, emExame);
  try Janela.ShowModal; finally Janela.Free; end;
end;

procedure TfrmMain.miCadFarmClick(Sender: TObject);
var Janela: Tfrmetfarm;
begin
  Janela := Tfrmetfarm.Create(Self);
  try Janela.ShowModal; finally Janela.Free; end;
end;

procedure TfrmMain.miPulseiraClick(Sender: TObject);
var Janela: TfrmPulseira;
begin
  Janela := TfrmPulseira.Create(Self);
  try Janela.ShowModal; finally Janela.Free; end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  MenuLayout, MenuImpressoras, MenuFerramentas, Item, Atalho: TMenuItem;
  I: Integer;
begin
  aplicacao := Application.ExeName;
  FSetMain := TSetMain.create();
  fdmBase := TdmBase.create(self);
  fdmBase.opendb();
  StatusBar1.Panels[0].Text:= FSetMain.db;
  StatusBar1.Panels[1].Text:= FSetMain.SQLLITEDLL;
  PageControl1.ActivePage := tbZebra;

  left := FSetMain.posx;
  top := FSetMain.posy;
  frmRegistrar := TfrmRegistrar.Create(self);
  frmRegistrar.Identifica();
  lbVersion.Caption:= versao;

  // Garantir eventos e interatividade na aba Zebra > Laboratory Supply
  Image4.Enabled := True;
  Image4.Cursor := crHandPoint;
  Image4.OnClick := @Image4Click;
  Image4.BringToFront;
  Label14.Cursor := crHandPoint;
  Label14.OnClick := @Image4Click;

  if Assigned(imgDespachoMedico) then
  begin
    imgDespachoMedico.Enabled := True;
    imgDespachoMedico.Cursor := crHandPoint;
    imgDespachoMedico.OnClick := @imgDespachoMedicoClick;
    imgDespachoMedico.BringToFront;
  end;
  if Assigned(LabelDespacho) then
  begin
    LabelDespacho.Cursor := crHandPoint;
    LabelDespacho.OnClick := @imgDespachoMedicoClick;
  end;

  ConfigurarMenuEAbasPorImpressora;
  MenuImpressoras := TMenuItem.Create(Self);
  MenuImpressoras.Caption := 'Impressoras';
  for I := 1 to 4 do
  begin
    Item := MainMenu1.Items[1];
    MainMenu1.Items.Remove(Item);
    MenuImpressoras.Add(Item);
    Atalho := TMenuItem.Create(Self);
    Atalho.Caption := 'Ver modelos no início';
    Atalho.Tag := I;
    Atalho.OnClick := @SelecionarAbaImpressoraClick;
    Item.Insert(0, Atalho);
  end;
  MainMenu1.Items.Insert(1, MenuImpressoras);
  MenuFerramentas := TMenuItem.Create(Self);
  MenuFerramentas.Caption := 'Ferramentas';
  MainMenu1.Items.Remove(miCadFarm);
  MenuFerramentas.Add(miCadFarm);
  MainMenu1.Items.Remove(miPulseira);
  MenuFerramentas.Add(miPulseira);
  MainMenu1.Items.Remove(miDespachoMedico);
  MenuFerramentas.Add(miDespachoMedico);
  MainMenu1.Items.Remove(miExameMedico);
  MenuFerramentas.Add(miExameMedico);
  MainMenu1.Items.Insert(2, MenuFerramentas);
  Panel1.Visible := False;
  Panel2.Visible := False;
  Constraints.MinWidth := 760;
  Constraints.MinHeight := 600;
  Width := 1120;
  Height := 820;
  if Width > Screen.WorkAreaWidth then Width := Screen.WorkAreaWidth;
  if Height > Screen.WorkAreaHeight then Height := Screen.WorkAreaHeight;
  FInicio := TInicio.Create(Self);
  FInicio.AoAbrirModelo := @AbrirModeloInicio;
  FInicio.Parent := Self;
  FInicio.Align := alClient;
  FInicio.SelecionarImpressora(0);
  MenuLayout := TMenuItem.Create(Self);
  MenuLayout.Caption := 'Alternar início / tela clássica';
  MenuLayout.OnClick := @AlternarInicio;
  miconfig.Add(MenuLayout);
  miconfig.Caption := 'Configurações';
  misetup.Caption := 'Preferências';
  miImport.Caption := 'Importar dados';
  miexit.Caption := 'Sair';
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  frmRegistrar.free;
  fdmBase.closedb();
  fdmBase.free();
  FSetMain.posx := left ;
  FSetMain.posy := top;
  FSetMain.SalvaContexto(false);
  FSetMain.free;
end;

procedure TfrmMain.Image1Click(Sender: TObject);
begin
  Image2Click(Sender);
end;

procedure TfrmMain.Image2Click(Sender: TObject);
begin
  frmgondola := tfrmgondola.create(self);
  frmgondola.showmodal();
  frmgondola.Free;
end;

procedure TfrmMain.Image4Click(Sender: TObject);
begin
  miExameMedicoClick(Sender);
end;

procedure TfrmMain.imgDespachoMedicoClick(Sender: TObject);
begin
  miDespachoMedicoClick(Sender);
end;

procedure TfrmMain.Image5Click(Sender: TObject);
begin
  PesquisaEtqLaboratorio();
end;

procedure TfrmMain.Image7Click(Sender: TObject);
begin
  PIXBRAZIL();
end;

procedure TfrmMain.imgMalaDiretaClick(Sender: TObject);
begin
  PesquisaMalaDireta();
end;

procedure TfrmMain.imgProductsClick(Sender: TObject);
begin
  Image2Click(Sender);
end;

procedure TfrmMain.imgZebraClick(Sender: TObject);
begin
  PageControl1.ActivePage := tbZebra;
end;

procedure TfrmMain.miexitClick(Sender: TObject);
begin
  close;
end;

procedure TfrmMain.miImportClick(Sender: TObject);
begin
  frmImport := tfrmimport.create(self);
  frmImport.showmodal();
  frmImport.free;
  frmImport := nil;
end;

procedure TfrmMain.misetupClick(Sender: TObject);
begin
  config();
end;

procedure TfrmMain.Config();
begin
  frmconfig := Tfrmconfig.create(self);
  frmconfig.showmodal();
  frmconfig.free;
  frmconfig := nil;
end;

procedure TfrmMain.PesquisaMalaDireta();
begin
  frmmaladireta := tfrmmaladireta.create(self);
  frmmaladireta.showmodal();
  frmmaladireta.Free;
  frmmaladireta := nil;
end;

procedure TfrmMain.PesquisaEtqLaboratorio();
begin
  frmetqlab := Tfrmetqlab.create(self);
  frmetqlab.showmodal();
  frmetqlab.free;
  frmetqlab := nil;
end;

procedure TfrmMain.PIXBRAZIL();
begin
  frmPIX := TfrmPIX.create(self);
  frmPIX.showmodal();
  frmPIX.free;
  frmPIX := nil;
end;

end.
