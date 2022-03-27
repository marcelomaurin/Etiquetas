unit ticket;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids,
  ComCtrls, ExtCtrls, DBGrids, DBCtrls, Buttons, Menus, relticket, DB,
  ZConnection, dmbase;

type

  { TfrmTicket }

  TfrmTicket = class(TForm)
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
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    mnInsert: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    popInsert: TPopupMenu;
    SpeedButton2: TSpeedButton;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    btSearch: TToggleBox;
    procedure btSearchChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure mnInsertClick(Sender: TObject);
    procedure TabSheet1Show(Sender: TObject);
  private

  public

  end;

var
  frmTicket: TfrmTicket;

implementation

{$R *.lfm}

{ TfrmTicket }

procedure TfrmTicket.Label7Click(Sender: TObject);
begin

end;

procedure TfrmTicket.mnInsertClick(Sender: TObject);
begin
  Fdmbase.newsel();
end;

procedure TfrmTicket.TabSheet1Show(Sender: TObject);
begin

end;

procedure TfrmTicket.Image2Click(Sender: TObject);
begin
  frmrelticket.PrintItem();
end;

procedure TfrmTicket.btSearchChange(Sender: TObject);
begin
  fdmBase.product();
end;

procedure TfrmTicket.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  fdmBase.closedb;
  fdmbase.Free();
end;

procedure TfrmTicket.FormCreate(Sender: TObject);
begin
  fdmbase := TdmBase.create(self);
  fdmBase.opendb;
end;

end.

