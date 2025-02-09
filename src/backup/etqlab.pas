unit etqlab;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Buttons, DBCtrls, StdCtrls, DBGrids, Menus, ubarcodes, AnchorDockPanel,
  Printers, LCLIntf, LCLType,
  rxduallist, dmbase, DB, setmain;

type

  { Tfrmetqlab }

  Tfrmetqlab = class(TForm)
    BarcodeEAN1: TBarcodeEAN;
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
    Image6: TImage;
    Image7: TImage;
    Label1: TLabel;
    Label10: TLabel;
    lbLinha01: TLabel;
    lbNome: TLabel;
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
    procedure btAddtoPrint2Click(Sender: TObject);
    procedure btAddtoPrintClick(Sender: TObject);
    procedure btDeleteClick(Sender: TObject);
    procedure btSelecionaClick(Sender: TObject);
    procedure dseletqlabDataChange(Sender: TObject; Field: TField);
    procedure dseletqlabStateChange(Sender: TObject);
    procedure dsetqlabDataChange(Sender: TObject; Field: TField);
    procedure FormCreate(Sender: TObject);
    procedure Image3Click(Sender: TObject);
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
  fdmbase.zseletqlab.close();
  fdmbase.zseletqlab.open;
  dsetqlab.dataset.close();
  dsetqlab.dataset.open();
end;


procedure Tfrmetqlab.Image3Click(Sender: TObject);
var
  bmp: TBitmap;
  ScreenDC: HDC;
  ControlRect: TRect;
  ScreenPos: TPoint;
begin
  // Cria um bitmap com as mesmas dimensões do componente Image7
  bmp := TBitmap.Create;
  try
    bmp.Width := Image7.Width;
    bmp.Height := Image7.Height;

    // Obtém a posição do componente Image7 na tela
    ScreenPos := Image7.ClientToScreen(Point(0, 0));
    ControlRect := Rect(ScreenPos.X, ScreenPos.Y,
                        ScreenPos.X + Image7.Width,
                        ScreenPos.Y + Image7.Height);

    // Captura o conteúdo da área correspondente na tela
    ScreenDC := GetDC(0);  // Obtém o DC da tela inteira
    try
      BitBlt(bmp.Canvas.Handle, 0, 0, bmp.Width, bmp.Height,
             ScreenDC, ControlRect.Left, ControlRect.Top, SRCCOPY);
    finally
      ReleaseDC(0, ScreenDC);
    end;

    // Envia o bitmap capturado para a impressora padrão
    Printer.BeginDoc;
    try
      // Desenha o bitmap no canvas da impressora
      Printer.Canvas.Draw(0, 0, bmp);
    finally
      Printer.EndDoc;
    end;
  finally
    bmp.Free;
  end;
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

procedure Tfrmetqlab.btAddtoPrint2Click(Sender: TObject);
begin

  if(dsetqlab.dataset.RecordCount<>0) then
  begin
      pcMalaDireta.ActivePage := tsTagType;
  end
  else
  begin
    ShowMessage('Select at least one address for shipping');
  end;
end;

procedure Tfrmetqlab.btAddtoPrintClick(Sender: TObject);
begin
  Pesquisar();
end;

procedure Tfrmetqlab.btDeleteClick(Sender: TObject);
begin
  //Insere o registro
  if((dsetqlab.DataSet.Active) and (dsetqlab.DataSet.Active)) then
  begin
    dsetqlab.DataSet.Delete;
  end;
end;

procedure Tfrmetqlab.btSelecionaClick(Sender: TObject);
begin
  //Copiando registro
  if (dsetqlab.DataSet.Active) then
  begin
       fdmbase.NewSelEtqlab();
  end;
end;

procedure Tfrmetqlab.dseletqlabDataChange(Sender: TObject; Field: TField);
begin
  if(dseletqlab.DataSet.Active) then
  begin
      lbnome.Caption:= dseletqlab.DataSet.FieldByName('rotulo01').asstring;
      lbLinha01.Caption:= dseletqlab.DataSet.FieldByName('rotulo02').asstring;
      BarcodeEAN1.Text := dseletqlab.DataSet.FieldByName('barcode').asstring;
  end;
end;

procedure Tfrmetqlab.dseletqlabStateChange(Sender: TObject);
begin

end;

procedure Tfrmetqlab.dsetqlabDataChange(Sender: TObject; Field: TField);
begin

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

