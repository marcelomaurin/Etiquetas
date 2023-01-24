unit MalaDireta;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Buttons, DBCtrls, StdCtrls, DBGrids, AnchorDockPanel, rxduallist, dmbase, DB;

type

  { TfrmMalaDireta }

  TfrmMalaDireta = class(TForm)
    DBGrid2: TDBGrid;
    DBNavigator2: TDBNavigator;
    DBNavigator3: TDBNavigator;
    dsendereco: TDataSource;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    dsendsel: TDataSource;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    pcMalaDireta: TPageControl;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Splitter1: TSplitter;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Wizzard: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private

  public

  end;

var
  frmMalaDireta: TfrmMalaDireta;

implementation

{$R *.lfm}

{ TfrmMalaDireta }

procedure TfrmMalaDireta.SpeedButton1Click(Sender: TObject);
begin
  close;
end;

procedure TfrmMalaDireta.FormCreate(Sender: TObject);
begin

end;

procedure TfrmMalaDireta.FormDestroy(Sender: TObject);
begin
 fdmbase.zendereco.close;
end;

procedure TfrmMalaDireta.FormShow(Sender: TObject);
begin
  if not fdmbase.zendereco.Active then
    fdmbase.zendereco.Open;
end;

end.

