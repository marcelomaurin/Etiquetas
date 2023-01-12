unit main;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  ExtCtrls, ComCtrls, setmain, dmbase, registro, config, gondola;

const
  versao = 1.3 ;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    Image2: TImage;
    imgZebra: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lbVersion: TLabel;
    MainMenu1: TMainMenu;
    miconfig: TMenuItem;
    misetup: TMenuItem;
    miexit: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    TabSheet1: TTabSheet;
    tbZebra: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure imgZebraClick(Sender: TObject);
    procedure miexitClick(Sender: TObject);
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

procedure TfrmMain.Image2Click(Sender: TObject);
begin
  frmgondola := tfrmgondola.create(self);
  frmgondola.showmodal();
  frmgondola.Free;
end;

procedure TfrmMain.imgZebraClick(Sender: TObject);
begin
   tbZebra.Show;
end;

procedure TfrmMain.miexitClick(Sender: TObject);
begin
  close;
end;

procedure TfrmMain.misetupClick(Sender: TObject);
begin
  frmconfig := Tfrmconfig.create(self);
  frmconfig.showmodal();
  frmconfig.free;
end;

end.

