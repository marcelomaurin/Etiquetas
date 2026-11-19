unit saidaimpressora;

{ Painel compartilhado de configuração de saída para o TAIPOSPrinter.

  Primeiro o usuário escolhe o protocolo de comunicação (TPrinterProtocol,
  unit imp_generico). Conforme o protocolo, o painel mostra somente os campos
  necessários:
    - ppNative ("Padrão Windows")  -> lista das impressoras instaladas;
    - ESC/POS, ZPL, EPL, TSPL      -> tipo de conexão (TPrinterInterface):
        piSerial   -> porta COM e velocidade;
        piEthernet -> IP/host e porta TCP (padrão 9100). }

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Controls, StdCtrls, ExtCtrls, Spin, Dialogs, Printers,
  aiposprinter, imp_generico, aiserial;

type
  TArrayProtocolos = array of TPrinterProtocol;

  { TPainelSaidaImpressora }

  TPainelSaidaImpressora = class(TPanel)
  private
    FProtocolos: TArrayProtocolos;
    FOnChange: TNotifyEvent;
    FAtualizando: Boolean;
    lblProtocolo: TLabel;
    cbProtocolo: TComboBox;
    lblConexao: TLabel;
    cbConexao: TComboBox;
    lblPortaSerial: TLabel;
    cbPortaSerial: TComboBox;
    lblVelocidade: TLabel;
    cbVelocidade: TComboBox;
    lblHost: TLabel;
    edHost: TEdit;
    lblPortaTcp: TLabel;
    sePortaTcp: TSpinEdit;
    lblImpressora: TLabel;
    cbImpressora: TComboBox;
    function GetProtocolo: TPrinterProtocol;
    procedure SetProtocolo(AValue: TPrinterProtocol);
    function GetConexao: TPrinterInterface;
    function GetPortaSerial: string;
    function GetVelocidade: Integer;
    function GetHost: string;
    function GetPortaTcp: Integer;
    function GetImpressoraWindows: string;
    procedure CamposChange(Sender: TObject);
    procedure Reorganizar;
    procedure Posicionar(ALabel: TLabel; AControl: TControl; var X: Integer);
    function CriarLabel(const ACaption: string): TLabel;
  public
    constructor Create(AOwner: TComponent); override;
    { Define quais protocolos aparecem no combo (na ordem informada). }
    procedure DefinirProtocolos(const AProtocolos: array of TPrinterProtocol);
    procedure CarregarImpressorasWindows;
    { Valida os campos do protocolo escolhido; mostra a mensagem e foca o campo. }
    function Validar: Boolean;
    { Seleciona no objeto Printer (LCL) a impressora escolhida no Padrão Windows. }
    function AplicarImpressoraWindows: Boolean;
    { Copia protocolo, conexão e parâmetros para o componente. }
    procedure ConfigurarPOS(APos: TAIPOSPrinter);
    function Descricao: string;

    property Protocolo: TPrinterProtocol read GetProtocolo write SetProtocolo;
    property Conexao: TPrinterInterface read GetConexao;
    property PortaSerial: string read GetPortaSerial;
    property Velocidade: Integer read GetVelocidade;
    property Host: string read GetHost;
    property PortaTcp: Integer read GetPortaTcp;
    property ImpressoraWindows: string read GetImpressoraWindows;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

function NomeProtocolo(AProtocolo: TPrinterProtocol): string;
function EnderecoIPv4Valido(const AValor: string): Boolean;

implementation

const
  ALTURA_LABEL = 18;
  TOPO_CONTROLE = 22;
  ESPACO = 16;

function NomeProtocolo(AProtocolo: TPrinterProtocol): string;
begin
  case AProtocolo of
    ppNative: Result := 'Padrão Windows (driver instalado)';
    ppEscPos: Result := 'ESC/POS (térmica de bobina)';
    ppZpl:    Result := 'ZPL (Zebra)';
    ppEpl:    Result := 'EPL (Zebra / Eltron)';
    ppTspl:   Result := 'TSPL (TSC / Argox / Elgin)';
  else
    Result := 'Protocolo ' + IntToStr(Ord(AProtocolo));
  end;
end;

function EnderecoIPv4Valido(const AValor: string): Boolean;
var
  Partes: TStringArray;
  I, N: Integer;
begin
  Result := False;
  Partes := AValor.Split(['.']);
  if Length(Partes) <> 4 then Exit;
  for I := 0 to 3 do
  begin
    if (Partes[I] = '') or (Length(Partes[I]) > 3) then Exit;
    if not TryStrToInt(Partes[I], N) then Exit;
    if (N < 0) or (N > 255) then Exit;
  end;
  Result := True;
end;

function SomenteDigitosEPontos(const S: string): Boolean;
var
  C: Char;
begin
  Result := S <> '';
  for C in S do
    if not (C in ['0'..'9', '.']) then Exit(False);
end;

{ TPainelSaidaImpressora }

constructor TPainelSaidaImpressora.Create(AOwner: TComponent);
var
  I: Integer;
begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  Caption := '';
  Height := 52;
  Width := 720;

  lblProtocolo := CriarLabel('Protocolo de comunicação:');
  cbProtocolo := TComboBox.Create(Self);
  cbProtocolo.Parent := Self;
  cbProtocolo.Style := csDropDownList;
  cbProtocolo.Width := 230;
  cbProtocolo.OnChange := @CamposChange;

  lblConexao := CriarLabel('Conexão:');
  cbConexao := TComboBox.Create(Self);
  cbConexao.Parent := Self;
  cbConexao.Style := csDropDownList;
  cbConexao.Width := 150;
  cbConexao.Items.Add('Serial / USB-Serial');   // piSerial
  cbConexao.Items.Add('Rede TCP/IP');           // piEthernet
  cbConexao.ItemIndex := 0;
  cbConexao.OnChange := @CamposChange;

  lblPortaSerial := CriarLabel('Porta COM:');
  cbPortaSerial := TComboBox.Create(Self);
  cbPortaSerial.Parent := Self;
  cbPortaSerial.Width := 100;
  for I := 1 to 20 do
    cbPortaSerial.Items.Add('COM' + IntToStr(I));
  cbPortaSerial.ItemIndex := 0;

  lblVelocidade := CriarLabel('Velocidade (baud):');
  cbVelocidade := TComboBox.Create(Self);
  cbVelocidade.Parent := Self;
  cbVelocidade.Style := csDropDownList;
  cbVelocidade.Width := 120;
  cbVelocidade.Items.AddStrings(['9600', '19200', '38400', '57600', '115200']);
  cbVelocidade.ItemIndex := 0; // padrão do componente: 9600

  lblHost := CriarLabel('IP / host da impressora:');
  edHost := TEdit.Create(Self);
  edHost.Parent := Self;
  edHost.Width := 170;
  edHost.TextHint := 'ex.: 192.168.0.50';

  lblPortaTcp := CriarLabel('Porta TCP:');
  sePortaTcp := TSpinEdit.Create(Self);
  sePortaTcp.Parent := Self;
  sePortaTcp.Width := 90;
  sePortaTcp.MinValue := 1;
  sePortaTcp.MaxValue := 65535;
  sePortaTcp.Value := 9100;

  lblImpressora := CriarLabel('Impressora instalada no Windows:');
  cbImpressora := TComboBox.Create(Self);
  cbImpressora.Parent := Self;
  cbImpressora.Style := csDropDownList;
  cbImpressora.Width := 360;

  DefinirProtocolos([ppNative, ppEscPos, ppZpl, ppEpl, ppTspl]);
  CarregarImpressorasWindows;
  Reorganizar;
end;

function TPainelSaidaImpressora.CriarLabel(const ACaption: string): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.Parent := Self;
  Result.Caption := ACaption;
  Result.AutoSize := False;
  Result.Height := ALTURA_LABEL;
end;

procedure TPainelSaidaImpressora.DefinirProtocolos(
  const AProtocolos: array of TPrinterProtocol);
var
  I: Integer;
  Atual: TPrinterProtocol;
  TinhaAtual: Boolean;
begin
  TinhaAtual := cbProtocolo.ItemIndex >= 0;
  if TinhaAtual then
    Atual := GetProtocolo
  else
    Atual := ppNative;
  SetLength(FProtocolos, Length(AProtocolos));
  FAtualizando := True;
  try
    cbProtocolo.Items.Clear;
    for I := 0 to High(AProtocolos) do
    begin
      FProtocolos[I] := AProtocolos[I];
      cbProtocolo.Items.Add(NomeProtocolo(AProtocolos[I]));
    end;
    cbProtocolo.ItemIndex := 0;
    if TinhaAtual then
      for I := 0 to High(FProtocolos) do
        if FProtocolos[I] = Atual then
          cbProtocolo.ItemIndex := I;
  finally
    FAtualizando := False;
  end;
  { Um único protocolo (ex.: Convencional/A4 = só Padrão Windows): combo fixo. }
  cbProtocolo.Enabled := Length(FProtocolos) > 1;
  Reorganizar;
end;

procedure TPainelSaidaImpressora.CarregarImpressorasWindows;
var
  Padrao: Integer;
begin
  cbImpressora.Items.Clear;
  Padrao := -1;
  TAIPOSPrinter.ListInstalledPrinters(cbImpressora.Items);
  Padrao := cbImpressora.Items.IndexOf(TAIPOSPrinter.DefaultPrinterName);
  if (Padrao < 0) or (Padrao >= cbImpressora.Items.Count) then
    Padrao := Ord(cbImpressora.Items.Count > 0) - 1;
  cbImpressora.ItemIndex := Padrao;
end;

function TPainelSaidaImpressora.GetProtocolo: TPrinterProtocol;
begin
  if (cbProtocolo.ItemIndex >= 0) and (cbProtocolo.ItemIndex <= High(FProtocolos)) then
    Result := FProtocolos[cbProtocolo.ItemIndex]
  else
    Result := ppNative;
end;

procedure TPainelSaidaImpressora.SetProtocolo(AValue: TPrinterProtocol);
var
  I: Integer;
begin
  for I := 0 to High(FProtocolos) do
    if FProtocolos[I] = AValue then
    begin
      FAtualizando := True;
      try
        cbProtocolo.ItemIndex := I;
      finally
        FAtualizando := False;
      end;
      Reorganizar;
      Exit;
    end;
end;

function TPainelSaidaImpressora.GetConexao: TPrinterInterface;
begin
  if cbConexao.ItemIndex = 1 then
    Result := piEthernet
  else
    Result := piSerial;
end;

function TPainelSaidaImpressora.GetPortaSerial: string;
begin
  Result := UpperCase(Trim(cbPortaSerial.Text));
end;

function TPainelSaidaImpressora.GetVelocidade: Integer;
begin
  Result := StrToIntDef(cbVelocidade.Text, 9600);
end;

function TPainelSaidaImpressora.GetHost: string;
begin
  Result := Trim(edHost.Text);
end;

function TPainelSaidaImpressora.GetPortaTcp: Integer;
begin
  Result := sePortaTcp.Value;
end;

function TPainelSaidaImpressora.GetImpressoraWindows: string;
begin
  if cbImpressora.ItemIndex >= 0 then
    Result := cbImpressora.Items[cbImpressora.ItemIndex]
  else
    Result := '';
end;

procedure TPainelSaidaImpressora.CamposChange(Sender: TObject);
begin
  if FAtualizando then Exit;
  Reorganizar;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TPainelSaidaImpressora.Posicionar(ALabel: TLabel; AControl: TControl;
  var X: Integer);
begin
  ALabel.Visible := True;
  AControl.Visible := True;
  ALabel.SetBounds(X, 0, AControl.Width, ALTURA_LABEL);
  AControl.Left := X;
  AControl.Top := TOPO_CONTROLE;
  X := X + AControl.Width + ESPACO;
end;

procedure TPainelSaidaImpressora.Reorganizar;
var
  X: Integer;
  Nativo: Boolean;
begin
  DisableAlign;
  try
    lblConexao.Visible := False;     cbConexao.Visible := False;
    lblPortaSerial.Visible := False; cbPortaSerial.Visible := False;
    lblVelocidade.Visible := False;  cbVelocidade.Visible := False;
    lblHost.Visible := False;        edHost.Visible := False;
    lblPortaTcp.Visible := False;    sePortaTcp.Visible := False;
    lblImpressora.Visible := False;  cbImpressora.Visible := False;

    X := 0;
    Posicionar(lblProtocolo, cbProtocolo, X);
    Nativo := GetProtocolo = ppNative;
    if Nativo then
      Posicionar(lblImpressora, cbImpressora, X)
    else
    begin
      Posicionar(lblConexao, cbConexao, X);
      if GetConexao = piSerial then
      begin
        Posicionar(lblPortaSerial, cbPortaSerial, X);
        Posicionar(lblVelocidade, cbVelocidade, X);
      end
      else
      begin
        Posicionar(lblHost, edHost, X);
        Posicionar(lblPortaTcp, sePortaTcp, X);
      end;
    end;
    Width := Max(X - ESPACO, 1);
  finally
    EnableAlign;
  end;
end;

function TPainelSaidaImpressora.Validar: Boolean;

  function Falha(const Msg: string; AControl: TWinControl): Boolean;
  begin
    MessageDlg('Configuração de saída', Msg, mtWarning, [mbOK], 0);
    if AControl.CanFocus then
      AControl.SetFocus;
    Result := False;
  end;

var
  P: string;
begin
  Result := True;
  if GetProtocolo = ppNative then
  begin
    if cbImpressora.ItemIndex < 0 then
      Exit(Falha('Nenhuma impressora instalada no Windows foi encontrada.' + sLineBreak +
        'Instale a impressora ou escolha outro protocolo de comunicação.', cbProtocolo));
    Exit;
  end;

  if GetConexao = piSerial then
  begin
    P := GetPortaSerial;
    if P = '' then
      Exit(Falha('Informe a porta serial da impressora (ex.: COM3).', cbPortaSerial));
    if (Copy(P, 1, 3) = 'COM') and (StrToIntDef(Copy(P, 4, MaxInt), 0) <= 0) then
      Exit(Falha('Porta serial inválida: "' + P + '". Use o formato COM1, COM2...', cbPortaSerial));
  end
  else
  begin
    if GetHost = '' then
      Exit(Falha('Informe o IP da impressora na rede (ex.: 192.168.0.50).', edHost));
    if SomenteDigitosEPontos(GetHost) and not EnderecoIPv4Valido(GetHost) then
      Exit(Falha('IP inválido: "' + GetHost + '". Use quatro números de 0 a 255 separados por ponto.', edHost));
  end;
end;

function TPainelSaidaImpressora.AplicarImpressoraWindows: Boolean;
begin
  Result := False;
  if cbImpressora.ItemIndex < 0 then Exit;
  try
    Printer.PrinterIndex := Printer.Printers.IndexOf(GetImpressoraWindows);
    Result := Printer.PrinterIndex >= 0;
  except
    Result := False;
  end;
end;

procedure TPainelSaidaImpressora.ConfigurarPOS(APos: TAIPOSPrinter);
begin
  APos.Protocol := GetProtocolo;
  if GetProtocolo = ppNative then
  begin
    { Padrão Windows do componente: impressora instalada escolhida pelo nome. }
    APos.PrinterName := GetImpressoraWindows;
    Exit;
  end;
  APos.InterfaceType := GetConexao;
  if GetConexao = piSerial then
  begin
    APos.DeviceName := TAISerialModem.NormalizeDeviceName(GetPortaSerial);
    APos.SerialBaud := GetVelocidade;
  end
  else
  begin
    APos.Host := GetHost;
    APos.Port := GetPortaTcp;
  end;
end;

function TPainelSaidaImpressora.Descricao: string;
begin
  Result := NomeProtocolo(GetProtocolo);
  if GetProtocolo = ppNative then
    Result := Result + ' · ' + GetImpressoraWindows
  else if GetConexao = piSerial then
    Result := Result + Format(' · serial %s a %d baud', [GetPortaSerial, GetVelocidade])
  else
    Result := Result + Format(' · rede %s:%d', [GetHost, GetPortaTcp]);
end;

end.
