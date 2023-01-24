unit main;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  ExtCtrls, ComCtrls, setmain, dmbase, registro, config, gondola, import,
  maladireta;

const
  versao = 1.6 ;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    imgMalaDireta: TImage;
    imgProducts: TImage;
    imgZebra: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
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
    miImport: TMenuItem;
    miconfig: TMenuItem;
    misetup: TMenuItem;
    miexit: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    tsProducts: TTabSheet;
    tbZebra: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure imgMalaDiretaClick(Sender: TObject);
    procedure imgProductsClick(Sender: TObject);
    procedure imgZebraClick(Sender: TObject);
    procedure miexitClick(Sender: TObject);
    procedure miImportClick(Sender: TObject);
    procedure misetupClick(Sender: TObject);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FSetMain := TSetMain.create();
  fdmBase := TdmBase.create(self);
  fdmB
  left := FSetMain.posx;
  top := FSetMain.posy;
  //FSetMain.CarregaContexto();
  frmRegistrar := TfrmRegistrar.Create(self);
  frmRegistrar.Identifica();
  lbVersion.Caption:= floattostr(versao);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  frmRegistrar.free;
  fdmBase.free();
  FSetMain.posx := left ;
  FSetMain.posy := top;
  FSetMain.SalvaContexto(false);
  FSetMain.free;
end;

procedure TfrmMain.Image1Click(Sender: TObject);
begin
   tsProducts.Show;
end;

procedure TfrmMain.Image2Click(Sender: TObject);
begin
  frmgondola := tfrmgondola.create(self);
  frmgondola.showmodal();
  frmgondola.Free;
end;

procedure TfrmMain.imgMalaDiretaClick(Sender: TObject);
begin
  frmmaladireta := tfrmmaladireta.create(self);
  frmmaladireta.showmodal();
  frmmaladireta.Free;

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
  frmconfig := Tfrmconfig.create(self);
  frmconfig.showmodal();
  frmconfig.free;
end;

end.

