unit MalaDireta;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Buttons, DBCtrls, StdCtrls, DBGrids, AnchorDockPanel, rxduallist, dmbase;

type

  { TfrmMalaDireta }

  TfrmMalaDireta = class(TForm)
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    DBNavigator1: TDBNavigator;
    DBNavigator2: TDBNavigator;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    pcMalaDireta: TPageControl;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Splitter1: TSplitter;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Wizzard: TTabSheet;
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

end.

