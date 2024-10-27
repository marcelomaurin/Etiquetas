unit Import;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, dmbase, funcoes, csvproducts, csvendereco;

type

  { TfrmImport }

  TfrmImport = class(TForm)
    btAddtoPrint1: TSpeedButton;
    imgImportProducts: TImage;
    imgImportProducts1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    procedure btAddtoPrint1Click(Sender: TObject);
    procedure btcloseClick(Sender: TObject);
    procedure imgImportProducts1Click(Sender: TObject);
    procedure imgImportProductsClick(Sender: TObject);
  private

  public

  end;

var
  frmImport: TfrmImport;

implementation

{$R *.lfm}

{ TfrmImport }

procedure TfrmImport.btcloseClick(Sender: TObject);
begin

end;

procedure TfrmImport.btAddtoPrint1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmImport.imgImportProducts1Click(Sender: TObject);
begin
  self.Cursor:= crHourGlass;
  frmcsvendereco := TfrmcsvEndereco.create(self);
  self.Cursor:=  crArrow;
  frmcsvendereco.showmodal;
  frmcsvendereco.free;
  frmcsvendereco := nil;
end;

procedure TfrmImport.imgImportProductsClick(Sender: TObject);
begin
  frmcsvproducts := Tfrmcsvproducts.create(self);
  frmcsvproducts.showmodal;
  frmcsvproducts.free;
  frmcsvproducts := nil;
end;

end.

