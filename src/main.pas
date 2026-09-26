unit main;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  ExtCtrls, ComCtrls, Buttons, setmain, dmbase, registro, config, gondola, import,
  maladireta, etqlab, pix, pulseira, etiquetasmedicas, etfarm;

const
  versao = '0111';

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

  public
    aplicacao : string;
    procedure Config();
    procedure PesquisaMalaDireta();
    procedure PesquisaEtqLaboratorio();
    procedure PIXBRAZIL();
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

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
begin
  aplicacao := Application.ExeName;
  FSetMain := TSetMain.create();
  fdmBase := TdmBase.create(self);
  fdmBase.opendb();
  StatusBar1.Panels[0].Text:= FSetMain.db;
  StatusBar1.Panels[1].Text:= FSetMain.SQLLITEDLL;
  PageControl1.ActivePage := tbSobre;

  left := FSetMain.posx;
  top := FSetMain.posy;
  //FSetMain.CarregaContexto();
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
   //dmbase.tbProducts.open;

end;

procedure TfrmMain.Image2Click(Sender: TObject);
begin
  frmgondola := tfrmgondola.create(self);
  frmgondola.showmodal();
  frmgondola.Free;
end;

procedure TfrmMain.Image4Click(Sender: TObject);
begin
  // Zebra -> Laboratory Supply: Exame Laboratorial (51 x 25)
  miExameMedicoClick(Sender);
end;

procedure TfrmMain.imgDespachoMedicoClick(Sender: TObject);
begin
  // Zebra -> Laboratory Supply: Despacho Médico (100 x 150)
  miDespachoMedicoClick(Sender);
end;

procedure TfrmMain.Image5Click(Sender: TObject);
begin
  // Thermal Printer -> Laboratory Supply: Etiquetas de Laboratório e Farmácia
  PesquisaEtqLaboratorio();
end;

procedure TfrmMain.Image7Click(Sender: TObject);
begin
  PIXBRAZIL();
end;

procedure TfrmMain.imgMalaDiretaClick(Sender: TObject);
begin
     PesquisaMalaDireta();
     //Showmessage('Not yet');

end;

procedure TfrmMain.imgProductsClick(Sender: TObject);
begin
  showmessage('Not yet!');
end;

procedure TfrmMain.imgZebraClick(Sender: TObject);
begin
   tbZebra.Show;
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

