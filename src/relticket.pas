unit relticket;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, RLReport, RLBarcode,
  ubarcodes, dmbase;

type

  { Tfrmrelticket }

  Tfrmrelticket = class(TForm)
    RLProductDesc: TRLLabel;
    RLDetailProd: TRLLabel;
    RLDetail01: TRLLabel;
    RLDetail02: TRLLabel;
    rlPrice: TRLLabel;
    RLReport1: TRLReport;
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
  frmrelticket: Tfrmrelticket;

implementation

{$R *.lfm}

{ Tfrmrelticket }

procedure Tfrmrelticket.rlproductnameAfterPrint(Sender: TObject);
begin

end;

procedure Tfrmrelticket.SetProductDesc(value: String);
begin
  FProductDesc:=value;
end;

procedure Tfrmrelticket.SetDetailProd(value: String);
begin
  FDetailProd := value;
end;

procedure Tfrmrelticket.SetDetail01(value: String);
begin
  FDetail01 := value;
end;

procedure Tfrmrelticket.SetDetail02(value: String);
begin
  FDetail02 := value;
end;

procedure Tfrmrelticket.SetPrice(value: string);
begin
  FPrice := value;
end;

procedure Tfrmrelticket.PrintItem();
begin
    RLProductDesc.Caption:= FProductDesc;
    RLDetailProd.Caption:= FDetailProd;
    RLDetail01.Caption:= FDetail01;
    RLDetail02.Caption:= FDetail02;
    rlPrice.Caption:= FPrice;
    RLReport1.PrintDialog := false;
    RLReport1.Print;
end;

end.

