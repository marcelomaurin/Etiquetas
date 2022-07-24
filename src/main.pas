unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ticket, registro, setmain, config, dmbase;

const
  versao = 1.1 ;

type

  { Tfrmmain }

  Tfrmmain = class(TForm)
    btconfig: TButton;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lbver: TLabel;
    procedure btconfigClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
  private

  public

  end;

var
  frmmain: Tfrmmain;

implementation

{$R *.lfm}

{ Tfrmmain }

procedure Tfrmmain.Image1Click(Sender: TObject);
begin
  frmTicket := TfrmTicket.create(self);
  frmticket.ShowModal;
  frmTicket.free;
end;

procedure Tfrmmain.Image2Click(Sender: TObject);
begin

end;

procedure Tfrmmain.FormCreate(Sender: TObject);
begin
  FSetMain := TSetMain.create();
  fdmBase := TdmBase.create(self);

  left := FSetMain.posx;
  top := FSetMain.posy;
  //FSetMain.CarregaContexto();
  frmRegistrar := TfrmRegistrar.Create(self);
  frmRegistrar.Identifica();
  lbver.Caption := 'Version '+FloatToStr(versao);


end;

procedure Tfrmmain.btconfigClick(Sender: TObject);
begin
  frmconfig := Tfrmconfig.create(self);
  frmconfig.showmodal();
  frmconfig.free;
end;

procedure Tfrmmain.FormDestroy(Sender: TObject);
begin
  FSetMain.posx :=   left ;
  FSetMain.posy := top;
  frmRegistrar.free;
  fdmBase.free();
  FSetMain.SalvaContexto(false);
  FSetMain.free;

end;

end.

