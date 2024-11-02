unit MalaDireta;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Buttons, DBCtrls, StdCtrls, DBGrids, Menus, AnchorDockPanel, rxduallist,
  dmbase, DB;

type

  { TfrmMalaDireta }

  TfrmMalaDireta = class(TForm)
    btAddtoPrint: TSpeedButton;
    btAddtoPrint1: TSpeedButton;
    DBGrid2: TDBGrid;
    DBNavigator3: TDBNavigator;
    dsendereco: TDataSource;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    dsendsel: TDataSource;
    edPesqNome: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
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
    PopupMenu1: TPopupMenu;
    SpeedButton1: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Splitter1: TSplitter;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Wizzard: TTabSheet;
    procedure btAddtoPrintClick(Sender: TObject);
    procedure edPesqNomeKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private

  public
     procedure Pesquisar();
  end;

var
  frmMalaDireta: TfrmMalaDireta;

implementation

{$R *.lfm}

{ TfrmMalaDireta }

procedure TfrmMalaDireta.SpeedButton1Click(Sender: TObject);
begin

end;

procedure TfrmMalaDireta.Pesquisar();
begin


   if(edPesqNome.text ='') then
   begin
     fdmbase.zEndereco.close;
     fdmbase.zEndereco.Filtered:=false;
     fdmbase.zEndereco.Filter:= '';
     fdmbase.zEndereco.open;
   end
   else
   begin
     fdmbase.zEndereco.close;
     fdmbase.zEndereco.Filtered:=true;
     fdmbase.zEndereco.Filter:= ' Nome like '+QuotedStr(edPesqNome.text);
     fdmbase.zEndereco.open;
   end;

end;

procedure TfrmMalaDireta.FormCreate(Sender: TObject);
begin

end;

procedure TfrmMalaDireta.btAddtoPrintClick(Sender: TObject);
begin
  Pesquisar();
end;

procedure TfrmMalaDireta.edPesqNomeKeyPress(Sender: TObject; var Key: char);
begin
  if(key=#13) then
  be
end;

procedure TfrmMalaDireta.FormDestroy(Sender: TObject);
begin
 fdmbase.zendereco.close;
end;

procedure TfrmMalaDireta.FormShow(Sender: TObject);
begin
   Pesquisar();
end;

end.

