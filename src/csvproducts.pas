unit csvproducts;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  ExtCtrls, dmbase, setmain;

type

  { Tfrmcsvproducts }

  Tfrmcsvproducts = class(TForm)
    edCSV: TFileNameEdit;
    Image1: TImage;
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
  private

  public

  end;

var
  frmcsvproducts: Tfrmcsvproducts;

implementation

{$R *.lfm}

{ Tfrmcsvproducts }

procedure Tfrmcsvproducts.Image1Click(Sender: TObject);
begin
  if (fdmBase = nil) then
  begin
    fdmBase := TdmBase.create(self);
  end;
  fdmBase.opendb;
  fdmBase.ImportCVSReport(edCSV.text);
  FSetMain.CSVFOLDER := edCSV.text;
  fdmBase.closedb();

  FSetMain.SalvaContexto(false);
  close;
end;

procedure Tfrmcsvproducts.FormShow(Sender: TObject);
begin
    edCSV.Text:=  FSetMain.CSVFOLDER;
end;

end.

