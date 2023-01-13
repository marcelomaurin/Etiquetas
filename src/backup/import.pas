unit Import;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, dmbase, funcoes, csvproducts;

type

  { TfrmImport }

  TfrmImport = class(TForm)
    btclose: TBitBtn;
    imgImportProducts: TImage;
    Label1: TLabel;
    procedure btcloseClick(Sender: TObject);
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
  close;
end;

procedure TfrmImport.imgImportProductsClick(Sender: TObject);
begin
  frmcsvproducts := Tcsvproducts.create(self);
  frmcsvproducts.showmodal;
  frmcsvproducts.free;
  frmcsvproducts := nil;
end;

end.

