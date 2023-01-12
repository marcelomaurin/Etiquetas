unit gondola;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, ticket, registro, setmain, config;



type

  { Tfrmgondola }

  Tfrmgondola = class(TForm)
    btConfig: TBitBtn;
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
  frmgondola: Tfrmgondola;

implementation

{$R *.lfm}

uses main;

{ Tfrmgondola }

procedure Tfrmgondola.Image1Click(Sender: TObject);
begin
  frmTicket := TfrmTicket.create(self);
  frmTicket.lbVersao.Caption:= floattostr(versao);
  frmticket.ShowModal;
  frmTicket.free;   frmTicket := TfrmTicket.create(self);
  frmTicket.lbVersao.Caption:= floattostr(versao);
  frmticket.ShowModal;
  frmTicket.free;
end;

procedure Tfrmgondola.Image2Click(Sender: TObject);
begin
  showmessage('Not yet');
end;

procedure Tfrmgondola.FormCreate(Sender: TObject);
begin
  lbver.Caption := 'Version '+FloatToStr(versao);
end;

procedure Tfrmgondola.btconfigClick(Sender: TObject);
begin
  frmconfig := Tfrmconfig.create(self);
  frmconfig.showmodal();
  frmconfig.free;
end;

procedure Tfrmgondola.FormDestroy(Sender: TObject);
begin

end;

end.

