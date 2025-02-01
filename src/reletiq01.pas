unit reletiq01;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, RLReport, RLBarcode;

type

  { Tfrmreletiq01 }

  Tfrmreletiq01 = class(TForm)
    RLBARCODE: TRLBarcode;
    RLDraw1: TRLDraw;
    RLDraw2: TRLDraw;
    RLTOADDRESS01: TRLLabel;
    RLLabel1: TRLLabel;
    RLTitulo: TRLLabel;
    RLTOADDRESS2: TRLLabel;
    RLFROM: TRLLabel;
    RLFROMADDRESS1: TRLLabel;
    RLFROMADDRESS2: TRLLabel;
    RLToName: TRLLabel;
    RLRepGondola02: TRLReport;
    RLFROMName: TRLLabel;
  private

  public

  end;

var
  frmreletiq01: Tfrmreletiq01;

implementation

{$R *.lfm}

end.

