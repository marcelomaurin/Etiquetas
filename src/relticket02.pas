unit relticket02;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, RLReport, RLBarcode,
  ubarcodes, dmbase;

type

  { Tfrmrelticket02 }

  Tfrmrelticket02 = class(TForm)
    RLDetail02: TRLBarcode;
    RLProductDesc: TRLLabel;
    RLDetailProd: TRLLabel;
    RLDetail01: TRLLabel;
    rlPrice: TRLLabel;
    RLRepGondola02: TRLReport;
    procedure rlproductnameAfterPrint(Sender: TObject);
  private
    FProductDesc : string;
    FDetailProd : string;
    FDetail01 : string;
    FDetail02 : string;
    FPrice : String;
    Procedure SetProductDesc(value: String);
    Procedure SetDetailProd(value : String);
    Procedure SetDetail01(value : String);
    Procedure SetDetail02(value : String);
    Procedure SetPrice(value: string);

  public
    procedure PrintItem();
    property ProductDesc : String read FProductDesc write SetProductDesc;
    property DetailProd : string read FDetailProd write SetDetailProd;
    property Detail01 : string read FDetail01 write SetDetail01;
    property Detail02 : string read FDetail02 write SetDetail02;
    property Price : string read FPrice write SetPrice;

  end;

var
  frmrelticket02: Tfrmrelticket02;

implementation

{$R *.lfm}

{ Tfrmrelticket02 }

procedure Tfrmrelticket02.rlproductnameAfterPrint(Sender: TObject);
begin

end;

procedure Tfrmrelticket02.SetProductDesc(value: String);
begin
  FProductDesc:=value;
end;

procedure Tfrmrelticket02.SetDetailProd(value: String);
begin
  FDetailProd := value;
end;

procedure Tfrmrelticket02.SetDetail01(value: String);
begin
  FDetail01 := value;
end;

procedure Tfrmrelticket02.SetDetail02(value: String);
begin
  FDetail02 := value;
end;

procedure Tfrmrelticket02.SetPrice(value: string);
begin
  FPrice := value;
end;

procedure Tfrmrelticket02.PrintItem();
begin
    RLProductDesc.Caption:= FProductDesc;
    RLDetailProd.Caption:= FDetailProd;
    RLDetail01.Caption:= FDetail01;
    RLDetail02.Caption:= FDetail02;
    rlPrice.Caption:= FPrice;
    RLRepGondola02.PrintDialog := false;
    //RLRepGondola02.Print;
    //RLRepGondola02.Print;
    RLRepGondola02.Preview();
end;

end.

