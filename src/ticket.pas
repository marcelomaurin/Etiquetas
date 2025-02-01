unit ticket;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids,
  ComCtrls, ExtCtrls, DBGrids, DBCtrls, Buttons, Menus, PrintersDlgs, relticket,
  relticket02, DB, csvdataset, ZConnection, dmbase;

type

  { TfrmTicket }

  TfrmTicket = class(TForm)
    btDelAll1: TSpeedButton;
    btPrint: TSpeedButton;
    DBGrid2: TDBGrid;
    dsselproduct: TDataSource;
    DBNavigator1: TDBNavigator;
    DBNavigator2: TDBNavigator;
    dsproduct: TDataSource;
    DBGrid1: TDBGrid;
    edcode: TEdit;
    edDescription: TEdit;
    edFamily: TEdit;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    lbVersao: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    miSel: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    popInsert: TPopupMenu;
    PrinterSetupDialog1: TPrinterSetupDialog;
    btAddtoPrint: TSpeedButton;
    btDelAll: TSpeedButton;
    tsSearch: TTabSheet;
    TabSheet2: TTabSheet;
    tsPrint: TTabSheet;
    TabSheet4: TTabSheet;
    btSearch: TToggleBox;
    procedure btDelAll1Click(Sender: TObject);
    procedure btDelAllClick(Sender: TObject);
    procedure btPrintClick(Sender: TObject);
    procedure btSearchChange(Sender: TObject);
    procedure DBNavigator1Click(Sender: TObject; Button: TDBNavButtonType);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure miSelClick(Sender: TObject);
    procedure mnInsertClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure btAddtoPrintClick(Sender: TObject);
    procedure tsSearchShow(Sender: TObject);
  private

  public
    procedure AddtoPrint();
    procedure DelAllSelect();
    procedure printing();
  end;

var
  frmTicket: TfrmTicket;

implementation

{$R *.lfm}

{ TfrmTicket }

procedure TfrmTicket.Label7Click(Sender: TObject);
begin

end;

procedure TfrmTicket.miSelClick(Sender: TObject);
begin
  Fdmbase.NewSel();
end;

procedure TfrmTicket.mnInsertClick(Sender: TObject);
begin
end;

procedure TfrmTicket.SpeedButton2Click(Sender: TObject);
begin

end;

procedure TfrmTicket.btAddtoPrintClick(Sender: TObject);
begin
  Fdmbase.NewSel();
end;

procedure TfrmTicket.tsSearchShow(Sender: TObject);
begin

end;

procedure TfrmTicket.AddtoPrint();
begin
  //Fdmbase.NewIns();
  dsselproduct.DataSet.Insert;
end;

procedure TfrmTicket.DelAllSelect();
begin
  fdmbase.delallselectproducts();
end;

procedure TfrmTicket.printing();
begin
  if (frmrelticket = nil) then
  begin
    frmrelticket := Tfrmrelticket.create(self);
  end;
  fdmBase.zselproduct.First;
  while not fdmBase.zselproduct.EOF do
  begin
        frmrelticket.ProductDesc  := fdmBase.zselproduct.FieldByName('productDesc').asstring;
        frmrelticket.DetailProd   := fdmBase.zselproduct.FieldByName('productDetail').asstring;
        frmrelticket.Detail01     := fdmBase.zselproduct.FieldByName('Detail01').asstring;
        frmrelticket.Detail02     :=  fdmBase.zselproduct.FieldByName('Detail02').asstring;
        frmrelticket.price        :=  fdmBase.zselproduct.FieldByName('price').asstring;

        frmrelticket.PrintItem();
        fdmBase.zselproduct.Next;
  end;
  frmrelticket.Free;
  frmrelticket := nil;
  DelAllSelect();
end;

procedure TfrmTicket.Image2Click(Sender: TObject);
begin
     printing();
end;

procedure TfrmTicket.Image3Click(Sender: TObject);
begin
  if (frmrelticket02 = nil) then
  begin
    frmrelticket02 := Tfrmrelticket02.create(self);
  end;
  fdmBase.zselproduct.First;
  while not fdmBase.zselproduct.EOF do
  begin
        frmrelticket02.ProductDesc  := fdmBase.zselproduct.FieldByName('productDesc').asstring;
        frmrelticket02.DetailProd   := fdmBase.zselproduct.FieldByName('productDetail').asstring;
        frmrelticket02.Detail01     := fdmBase.zselproduct.FieldByName('Detail01').asstring;
        frmrelticket02.Detail02     :=  fdmBase.zselproduct.FieldByName('Detail02').asstring;
        frmrelticket02.price        :=  fdmBase.zselproduct.FieldByName('price').asstring;

        frmrelticket02.PrintItem();
        fdmBase.zselproduct.Next;
  end;
  frmrelticket02.Free;
  frmrelticket02 := nil
end;

procedure TfrmTicket.btSearchChange(Sender: TObject);
begin
  fdmBase.product();
end;

procedure TfrmTicket.btDelAllClick(Sender: TObject);
begin
  DelAllSelect();
end;

procedure TfrmTicket.btPrintClick(Sender: TObject);
begin
  printing();
end;

procedure TfrmTicket.btDelAll1Click(Sender: TObject);
begin
  PageControl1.ActivePage := tsPrint;
end;

procedure TfrmTicket.DBNavigator1Click(Sender: TObject; Button: TDBNavButtonType
  );
begin

end;

procedure TfrmTicket.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  fdmBase.closedb;
  //fdmbase.Free();
end;

procedure TfrmTicket.FormCreate(Sender: TObject);
begin
  //fdmbase := TdmBase.create(self);
  PageControl1.ActivePage := tsSearch;
  fdmBase.opendb;
end;

procedure TfrmTicket.Image1Click(Sender: TObject);
begin
  PrinterSetupDialog1.Execute;
end;

end.

