unit csvendereco;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  ExtCtrls,dmbase ,setmain;

type

  { TfrmcsvEndereco }

  TfrmcsvEndereco = class(TForm)
    edCSV: TFileNameEdit;
    Image1: TImage;
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
  private

  public

  end;

var
  frmcsvEndereco: TfrmcsvEndereco;

implementation

{$R *.lfm}

{ TfrmcsvEndereco }

procedure TfrmcsvEndereco.FormShow(Sender: TObject);
begin
    edCSV.Text:=  FSetMain.CSVFOLDER;
end;

procedure TfrmcsvEndereco.Image1Click(Sender: TObject);
begin
  self.Cursor:= crHourGlass;
  if (fdmBase = nil) then
  begin
    fdmBase := TdmBase.create(self);
  end;
  fdmBase.opendb;
  fdmBase.ImportCVSReport(csv_Endereco, edCSV.text);
  FSetMain.CSVFOLDER := edCSV.text;
  fdmBase.closedb();
  self.Cursor:=  crArrow;
  FSetMain.SalvaContexto(false);
  close;
end;

end.

