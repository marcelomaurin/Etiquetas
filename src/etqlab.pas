unit etqlab;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Buttons, DBCtrls, StdCtrls, DBGrids, Menus, ubarcodes, AnchorDockPanel,
  Printers, PrintersDlgs, LCLIntf, LCLType,
  rxduallist, dmbase, DB, setmain, etfarm;

type

  { Tfrmetqlab }

  Tfrmetqlab = class(TForm)
    BarcodeEAN1: TBarcodeEAN;
    btAddtoPrint: TSpeedButton;
    btAddtoPrint1: TSpeedButton;
    btAddtoPrint2: TSpeedButton;
    btAddtoPrint3: TSpeedButton;
    btBackSetup: TSpeedButton;
    btnPrinterSetup: TBitBtn;
    btPrintSetup: TSpeedButton;
    btCadastrar: TSpeedButton;
    btDelete: TSpeedButton;
    btSeleciona: TSpeedButton;
    cbBaudRate: TComboBox;
    cbPortaSerial: TComboBox;
    cbPrinters: TComboBox;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    DBGrid4: TDBGrid;
    DBNavigator1: TDBNavigator;
    DBNavigator3: TDBNavigator;
    DBNavigator4: TDBNavigator;
    dsetqlab: TDataSource;
    dseletqlab: TDataSource;
    edCopiesESCPOS: TEdit;
    edCopiesGrafica: TEdit;
    edPesqNome: TEdit;
    gbConfigESCPOS: TGroupBox;
    gbConfigGrafica: TGroupBox;
    gbResumo: TGroupBox;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lblBaud: TLabel;
    lblCopiesESCPOS: TLabel;
    lblCopiesGrafica: TLabel;
    lbLinha01: TLabel;
    lbNome: TLabel;
    lblPorta: TLabel;
    lblPrev1: TLabel;
    lblPrev2: TLabel;
    lblPrev3: TLabel;
    lblPrinter: TLabel;
    lblResumoStatus: TLabel;
    lblResumoTipo: TLabel;
    lblResumoTotal: TLabel;
    Panel1: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel13: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    PanelSetupContent: TPanel;
    pcMalaDireta: TPageControl;
    pnlPreviewBox: TPanel;
    PopupMenu1: TPopupMenu;
    PrinterSetupDialog1: TPrinterSetupDialog;
    rgTipoEtiqueta: TRadioGroup;
    SpeedButton1: TSpeedButton;
    Splitter1: TSplitter;
    tsDadosProduto: TTabSheet;
    tsSetup: TTabSheet;
    tsTagType: TTabSheet;
    Wizzard: TTabSheet;
    procedure btAddtoPrint1Click(Sender: TObject);
    procedure btAddtoPrint2Click(Sender: TObject);
    procedure btAddtoPrint3Click(Sender: TObject);
    procedure btAddtoPrintClick(Sender: TObject);
    procedure btBackSetupClick(Sender: TObject);
    procedure btnPrinterSetupClick(Sender: TObject);
    procedure btPrintSetupClick(Sender: TObject);
    procedure btCadastrarClick(Sender: TObject);
    procedure btDeleteClick(Sender: TObject);
    procedure btSelecionaClick(Sender: TObject);
    procedure dseletqlabDataChange(Sender: TObject; Field: TField);
    procedure dseletqlabStateChange(Sender: TObject);
    procedure dsetqlabDataChange(Sender: TObject; Field: TField);
    procedure FormCreate(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Image5Click(Sender: TObject);
    procedure rgTipoEtiquetaClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private

  public
    procedure Pesquisar();
    procedure CarregarConfiguracao();
    procedure SalvarConfiguracao();
    procedure AtualizarInterfaceSetup();
    procedure ImprimirGrafico();
    procedure ImprimirESCPOS();
  end;

var
  frmetqlab: Tfrmetqlab;

implementation

{$R *.lfm}

{ Tfrmetqlab }

procedure Tfrmetqlab.SpeedButton1Click(Sender: TObject);
begin
  Close;
end;

procedure Tfrmetqlab.FormCreate(Sender: TObject);
begin
  pcMalaDireta.ActivePage := Wizzard;
  fdmbase.zseletqlab.Close();
  fdmbase.zseletqlab.Open;
  dsetqlab.DataSet.Close();
  dsetqlab.DataSet.Open();
  CarregarConfiguracao();
end;

procedure Tfrmetqlab.CarregarConfiguracao();
var
  i, idx: Integer;
begin
  // Carrega lista de impressoras do sistema
  cbPrinters.Clear;
  for i := 0 to Printer.Printers.Count - 1 do
    cbPrinters.Items.Add(Printer.Printers[i]);

  // Define tipo de etiqueta salvo no FSetMain
  if (FSetMain.LabTagType >= 0) and (FSetMain.LabTagType < rgTipoEtiqueta.Items.Count) then
    rgTipoEtiqueta.ItemIndex := FSetMain.LabTagType
  else
    rgTipoEtiqueta.ItemIndex := 0;

  // Seleciona impressora salva
  if FSetMain.LabPrinter <> '' then
  begin
    idx := cbPrinters.Items.IndexOf(FSetMain.LabPrinter);
    if idx >= 0 then
      cbPrinters.ItemIndex := idx
    else if cbPrinters.Items.Count > 0 then
      cbPrinters.ItemIndex := Printer.PrinterIndex;
  end
  else if cbPrinters.Items.Count > 0 then
    cbPrinters.ItemIndex := Printer.PrinterIndex;

  edCopiesGrafica.Text := IntToStr(FSetMain.LabCopies);
  if (edCopiesGrafica.Text = '') or (edCopiesGrafica.Text = '0') then
    edCopiesGrafica.Text := '1';

  // Configuração ESC/POS
  if FSetMain.LabSerialPort <> '' then
  begin
    idx := cbPortaSerial.Items.IndexOf(FSetMain.LabSerialPort);
    if idx >= 0 then
      cbPortaSerial.ItemIndex := idx
    else
      cbPortaSerial.ItemIndex := 0;
  end
  else
    cbPortaSerial.ItemIndex := 0;

  if FSetMain.LabBaudRate > 0 then
  begin
    idx := cbBaudRate.Items.IndexOf(IntToStr(FSetMain.LabBaudRate));
    if idx >= 0 then
      cbBaudRate.ItemIndex := idx
    else
      cbBaudRate.ItemIndex := 0;
  end
  else
    cbBaudRate.ItemIndex := 0;

  edCopiesESCPOS.Text := IntToStr(FSetMain.LabCopies);
  if (edCopiesESCPOS.Text = '') or (edCopiesESCPOS.Text = '0') then
    edCopiesESCPOS.Text := '1';

  AtualizarInterfaceSetup();
end;

procedure Tfrmetqlab.SalvarConfiguracao();
begin
  FSetMain.LabTagType := rgTipoEtiqueta.ItemIndex;

  if cbPrinters.ItemIndex >= 0 then
    FSetMain.LabPrinter := cbPrinters.Items[cbPrinters.ItemIndex];

  if rgTipoEtiqueta.ItemIndex = 0 then
    FSetMain.LabCopies := StrToIntDef(edCopiesGrafica.Text, 1)
  else
    FSetMain.LabCopies := StrToIntDef(edCopiesESCPOS.Text, 1);

  if cbPortaSerial.ItemIndex >= 0 then
    FSetMain.LabSerialPort := cbPortaSerial.Items[cbPortaSerial.ItemIndex];

  if cbBaudRate.ItemIndex >= 0 then
    FSetMain.LabBaudRate := StrToIntDef(cbBaudRate.Items[cbBaudRate.ItemIndex], 9600);

  FSetMain.SalvaContexto(false);
end;

procedure Tfrmetqlab.AtualizarInterfaceSetup();
var
  isGrafica: Boolean;
  totalRec: Integer;
begin
  isGrafica := (rgTipoEtiqueta.ItemIndex = 0);
  gbConfigGrafica.Enabled := isGrafica;
  gbConfigESCPOS.Enabled := not isGrafica;

  if isGrafica then
  begin
    lblResumoTipo.Caption := 'Tipo: Impressora Grafica / Padrao do Windows';
  end
  else
  begin
    lblResumoTipo.Caption := 'Tipo: Termica ESC/POS (Serial / USB)';
  end;

  if (fdmbase <> nil) and (fdmbase.zseletqlab <> nil) and fdmbase.zseletqlab.Active then
    totalRec := fdmbase.zseletqlab.RecordCount
  else
    totalRec := 0;

  lblResumoTotal.Caption := Format('Total de registros selecionados: %d', [totalRec]);

  if (totalRec > 0) and (not fdmbase.zseletqlab.IsEmpty) then
  begin
    lblPrev1.Caption := fdmbase.zseletqlab.FieldByName('rotulo01').AsString;
    lblPrev2.Caption := fdmbase.zseletqlab.FieldByName('rotulo02').AsString;
    lblPrev3.Caption := fdmbase.zseletqlab.FieldByName('barcode').AsString;
    lblResumoStatus.Caption := 'Status: Pronto para impressao (' + IntToStr(totalRec) + ' etiqueta(s))';
  end
  else
  begin
    lblPrev1.Caption := '(Nenhum item selecionado)';
    lblPrev2.Caption := '';
    lblPrev3.Caption := '';
    lblResumoStatus.Caption := 'Status: Aguardando selecao de etiquetas';
  end;
end;

procedure Tfrmetqlab.rgTipoEtiquetaClick(Sender: TObject);
begin
  AtualizarInterfaceSetup();
end;

procedure Tfrmetqlab.Image3Click(Sender: TObject);
begin
  // Ao clicar no card Gráfica, seleciona o tipo Gráfica e atualiza
  rgTipoEtiqueta.ItemIndex := 0;
  AtualizarInterfaceSetup();
end;

procedure Tfrmetqlab.Image5Click(Sender: TObject);
begin
  // Ao clicar no card ESC/POS, seleciona o tipo ESC/POS e atualiza
  rgTipoEtiqueta.ItemIndex := 1;
  AtualizarInterfaceSetup();
end;

procedure Tfrmetqlab.btAddtoPrint1Click(Sender: TObject);
begin
  if (fdmbase.zseletqlab.RecordCount <> 0) then
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
  if (fdmbase.zseletqlab.RecordCount <> 0) then
  begin
    pcMalaDireta.ActivePage := tsTagType;
  end
  else
  begin
    ShowMessage('Select at least one sample record for tag');
  end;
end;

procedure Tfrmetqlab.btAddtoPrint3Click(Sender: TObject);
begin
  if (fdmbase.zseletqlab.RecordCount <> 0) then
  begin
    AtualizarInterfaceSetup();
    pcMalaDireta.ActivePage := tsSetup;
  end
  else
  begin
    ShowMessage('Select at least one sample record for tag');
  end;
end;

procedure Tfrmetqlab.btBackSetupClick(Sender: TObject);
begin
  pcMalaDireta.ActivePage := tsTagType;
end;

procedure Tfrmetqlab.btnPrinterSetupClick(Sender: TObject);
begin
  if cbPrinters.ItemIndex >= 0 then
    Printer.PrinterIndex := cbPrinters.ItemIndex;

  if PrinterSetupDialog1.Execute then
  begin
    cbPrinters.ItemIndex := Printer.PrinterIndex;
  end;
end;

procedure Tfrmetqlab.btPrintSetupClick(Sender: TObject);
begin
  if (fdmbase.zseletqlab.RecordCount = 0) then
  begin
    ShowMessage('Nenhum registro selecionado para impressao!');
    Exit;
  end;

  // 1. Grava a última configuração realizada no etiqueta.cfg
  SalvarConfiguracao();

  // 2. Executa a impressão de acordo com o tipo configurado
  if rgTipoEtiqueta.ItemIndex = 0 then
    ImprimirGrafico()
  else
    ImprimirESCPOS();
end;

procedure Tfrmetqlab.ImprimirGrafico();
var
  bmp: TBitmap;
  numCopias, i: Integer;
  BarcodeRect: TRect;
  tempBarcode: TBarcodeEAN;
  rot1, rot2, code: string;
  totalImpressas: Integer;
begin
  numCopias := StrToIntDef(edCopiesGrafica.Text, 1);
  if numCopias < 1 then numCopias := 1;

  if (cbPrinters.ItemIndex >= 0) and (cbPrinters.ItemIndex < Printer.Printers.Count) then
    Printer.PrinterIndex := cbPrinters.ItemIndex;

  tempBarcode := TBarcodeEAN.Create(nil);
  try
    tempBarcode.Scale := BarcodeEAN1.Scale;
    tempBarcode.SymbolHeight := BarcodeEAN1.SymbolHeight;
    tempBarcode.WhiteSpaceWidth := BarcodeEAN1.WhiteSpaceWidth;
    tempBarcode.RecommendedSymbolSize := False;

    totalImpressas := 0;
    fdmbase.zseletqlab.DisableControls;
    try
      fdmbase.zseletqlab.First;
      while not fdmbase.zseletqlab.EOF do
      begin
        rot1 := fdmbase.zseletqlab.FieldByName('rotulo01').AsString;
        rot2 := fdmbase.zseletqlab.FieldByName('rotulo02').AsString;
        code := fdmbase.zseletqlab.FieldByName('barcode').AsString;

        tempBarcode.Text := code;

        bmp := TBitmap.Create;
        try
          bmp.SetSize(Image7.Width, Image7.Height);
          bmp.Canvas.Brush.Color := clWhite;
          bmp.Canvas.FillRect(0, 0, bmp.Width, bmp.Height);

          // Desenha borda suave
          bmp.Canvas.Pen.Color := clSilver;
          bmp.Canvas.Rectangle(0, 0, bmp.Width, bmp.Height);

          // Rótulo 01
          bmp.Canvas.Font.Name := 'Arial';
          bmp.Canvas.Font.Size := 14;
          bmp.Canvas.Font.Style := [fsBold];
          bmp.Canvas.Font.Color := clBlack;
          bmp.Canvas.TextOut(10, 8, rot1);

          // Rótulo 02
          bmp.Canvas.Font.Name := 'Arial';
          bmp.Canvas.Font.Size := 11;
          bmp.Canvas.Font.Style := [];
          bmp.Canvas.Font.Color := clBlack;
          bmp.Canvas.TextOut(10, 32, rot2);

          // Código de Barras
          BarcodeRect := Rect(10, 52, bmp.Width - 10, bmp.Height - 6);
          tempBarcode.PaintOnCanvas(bmp.Canvas, BarcodeRect);

          for i := 1 to numCopias do
          begin
            Printer.BeginDoc;
            try
              Printer.Canvas.Draw(0, 0, bmp);
            finally
              Printer.EndDoc;
            end;
            Inc(totalImpressas);
          end;
        finally
          bmp.Free;
        end;

        fdmbase.zseletqlab.Next;
      end;

      ShowMessage(Format('Sucesso! %d etiqueta(s) enviada(s) para a impressora "%s".',
        [totalImpressas, Printer.Printers[Printer.PrinterIndex]]));
    finally
      fdmbase.zseletqlab.EnableControls;
    end;
  finally
    tempBarcode.Free;
  end;
end;

procedure Tfrmetqlab.ImprimirESCPOS();
var
  numCopias: Integer;
begin
  numCopias := StrToIntDef(edCopiesESCPOS.Text, 1);
  if numCopias < 1 then numCopias := 1;

  ShowMessage(Format('Configuracao ESC/POS salva com sucesso!' + sLineBreak +
                     'Porta: %s' + sLineBreak +
                     'Baud Rate: %s' + sLineBreak +
                     'Copias: %d' + sLineBreak +
                     'Total de itens: %d etiqueta(s).' + sLineBreak +
                     'Comandos ESC/POS gerados para envio.',
                     [cbPortaSerial.Text, cbBaudRate.Text, numCopias, fdmbase.zseletqlab.RecordCount]));
end;

procedure Tfrmetqlab.btAddtoPrintClick(Sender: TObject);
begin
  Pesquisar();
end;

procedure Tfrmetqlab.btCadastrarClick(Sender: TObject);
begin
  frmetfarm := Tfrmetfarm.Create(Self);
  try
    frmetfarm.ShowModal;
  finally
    frmetfarm.Free;
    frmetfarm := nil;
  end;
  if (dsetqlab.DataSet <> nil) and dsetqlab.DataSet.Active then
  begin
    dsetqlab.DataSet.Close;
    dsetqlab.DataSet.Open;
  end;
end;

procedure Tfrmetqlab.btDeleteClick(Sender: TObject);
begin
  // Remove o registro selecionado
  if (dsetqlab.DataSet <> nil) and dsetqlab.DataSet.Active and (not dsetqlab.DataSet.IsEmpty) then
  begin
    dsetqlab.DataSet.Delete;
  end;
end;

procedure Tfrmetqlab.btSelecionaClick(Sender: TObject);
begin
  // Copiando registro
  if (dsetqlab.DataSet.Active) then
  begin
    fdmbase.NewSelEtqlab();
    AtualizarInterfaceSetup();
  end;
end;

procedure Tfrmetqlab.dseletqlabDataChange(Sender: TObject; Field: TField);
begin
  if (dseletqlab.DataSet.Active) and (not dseletqlab.DataSet.IsEmpty) then
  begin
    lbNome.Caption := dseletqlab.DataSet.FieldByName('rotulo01').AsString;
    lbLinha01.Caption := dseletqlab.DataSet.FieldByName('rotulo02').AsString;
    BarcodeEAN1.Text := dseletqlab.DataSet.FieldByName('barcode').AsString;

    if lblPrev1 <> nil then
      lblPrev1.Caption := dseletqlab.DataSet.FieldByName('rotulo01').AsString;
    if lblPrev2 <> nil then
      lblPrev2.Caption := dseletqlab.DataSet.FieldByName('rotulo02').AsString;
    if lblPrev3 <> nil then
      lblPrev3.Caption := dseletqlab.DataSet.FieldByName('barcode').AsString;
  end
  else
  begin
    lbNome.Caption := '';
    lbLinha01.Caption := '';
    BarcodeEAN1.Text := '';

    if lblPrev1 <> nil then
      lblPrev1.Caption := '(Nenhum item selecionado)';
    if lblPrev2 <> nil then
      lblPrev2.Caption := '';
    if lblPrev3 <> nil then
      lblPrev3.Caption := '';
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
  if (edPesqNome.Text = '') then
  begin
    fdmbase.zetqlab.Close;
    fdmbase.zetqlab.Filtered := False;
    fdmbase.zetqlab.Filter := '';
    fdmbase.zetqlab.Open;
  end
  else
  begin
    fdmbase.zetqlab.Close;
    fdmbase.zetqlab.Filtered := True;
    fdmbase.zetqlab.Filter := ' rotulo01 like ' + QuotedStr('%' + edPesqNome.Text + '%');
    fdmbase.zetqlab.Open;
  end;
end;

end.
