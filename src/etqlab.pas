unit etqlab;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Buttons, DBCtrls, StdCtrls, DBGrids, Menus, AnchorDockPanel, rxduallist,
  dmbase, DB, setmain;

type

  { Tfrmetqlab }

  Tfrmetqlab = class(TForm)
    btAddtoPrint: TSpeedButton;
    btAddtoPrint1: TSpeedButton;
    btAddtoPrint2: TSpeedButton;
    btDelete: TSpeedButton;
    btSeleciona: TSpeedButton;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    DBGrid4: TDBGrid;
    DBNavigator1: TDBNavigator;
    DBNavigator3: TDBNavigator;
    DBNavigator4: TDBNavigator;
    dsetqlab: TDataSource;
    dseletqlab: TDataSource;
    edPesqNome: TEdit;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Panel1: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    pcMalaDireta: TPageControl;
    PopupMenu1: TPopupMenu;
    SpeedButton1: TSpeedButton;
    Splitter1: TSplitter;
    tsDadosProduto: TTabSheet;
    tsTagType: TTabSheet;
    Wizzard: TTabSheet;
    procedure btAddtoPrint1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private

  public
        procedure Pesquisar();
  end;

var
  frmetqlab: Tfrmetqlab;

implementation

{$R *.lfm}

{ Tfrmetqlab }

procedure Tfrmetqlab.SpeedButton1Click(Sender: TObject);
begin
    close;
end;

procedure Tfrmetqlab.FormCreate(Sender: TObject);
begin
  pcMalaDireta.ActivePage := Wizzard;
  fdmbase.zseletqlab();
  fdmbase.zseletqlab.open;
end;

procedure Tfrmetqlab.btAddtoPrint1Click(Sender: TObject);
begin
  if(fdmbase.zseletqlab.RecordCount<>0) then
  begin
      pcMalaDireta.ActivePage := tsDadosProduto;
  end
  else
  begin
    ShowMessage('Select at least one sample record for tag');
  end;
end;

procedure Tfrmetqlab.Pesquisar();
begin
   if(edPesqNome.text ='') then
   begin
     fdmbase.zetqlab.close;
     fdmbase.zetqlab.Filtered:=false;
     fdmbase.zetqlab.Filter:= '';
     fdmbase.zetqlab.open;
   end
   else
   begin
     fdmbase.zetqlab.close;
     fdmbase.zetqlab.Filtered:=true;
     fdmbase.zetqlab.Filter:= ' rotulo01 like '+QuotedStr(edPesqNome.text);
     fdmbase.zetqlab.open;
   end;
end;

end.

