unit inicio;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, StdCtrls, ExtCtrls,
  LCLType, LazUTF8;

type
  { Native, keyboard-accessible illustrated cards. No external image files. }
  TCartaoInicio = class(TCustomControl)
  private
    FHover: Boolean;
    procedure EnterCard(Sender: TObject);
    procedure LeaveCard(Sender: TObject);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    Titulo, Detalhe, Categoria: string;
    Ilustracao: Integer;
    Impressora, Selecionado: Boolean;
    Compacto: Boolean; { printer card in the left column: icon left, text right }
    constructor Create(AOwner: TComponent); override;
  end;

  { Left column: printer types (stacked vertically). Client area: what to print. }
  TInicio = class(TPanel)
  private
    FColuna: TScrollBox;
    FConteudo: TScrollBox;
    FArea: TPanel;
    FCabecalho, FPasso1, FPasso2, FResumo, FVazio, FRodape: TLabel;
    FBusca: TEdit;
    FFiltro: TComboBox;
    FImpressoras: array[0..3] of TCartaoInicio;
    FModelos: TList;
    FTipo: Integer;
    FAbrir: TNotifyEvent;
    procedure ImpressoraClick(Sender: TObject);
    procedure Filtrar(Sender: TObject);
    procedure Organizar(Sender: TObject);
    procedure Popular;
    procedure Modelo(const Nome, Info, Grupo: string; Icone, Codigo: Integer);
    function Rotulo(const Texto: string; Tam: Integer; Negrito: Boolean;
      APai: TWinControl = nil): TLabel;
    procedure OrganizarColuna(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SelecionarImpressora(Tipo: Integer);
    property TipoImpressora: Integer read FTipo;
    property AoAbrirModelo: TNotifyEvent read FAbrir write FAbrir;
  end;

implementation

const
  Fundo = $FAF8F5;
  Tinta = $392B21;
  Suave = $796B60;
  Azul = $C66A26;
  Borda = $E9E2DA;
  LarguraColuna = 270;
  AlturaCartaoImp = 116;
  NomesImp: array[0..3] of string = ('Zebra / Ribbon (rolo)', 'Térmica 80 mm (80 col)',
    'Térmica 55 / 58 mm', 'Convencional · Papel A4');
  InfoImp: array[0..3] of string = ('Etiquetas adesivas com ou sem ribbon', 'Bobina térmica 80 mm (PDV / balcão)',
    'Bobina compacta 55/58 mm (40–55 col)', 'Exclusivo Papel A4 / Carta (Laser e Jato)');

constructor TCartaoInicio.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TabStop := True;
  Cursor := crHandPoint;
  Font.Name := 'Segoe UI';
  Font.Size := 10;
  OnMouseEnter := @EnterCard;
  OnMouseLeave := @LeaveCard;
end;

procedure TCartaoInicio.EnterCard(Sender: TObject);
begin
  FHover := True;
  Invalidate;
end;

procedure TCartaoInicio.LeaveCard(Sender: TObject);
begin
  FHover := False;
  Invalidate;
end;

procedure TCartaoInicio.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if CanFocus then SetFocus;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TCartaoInicio.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if Key in [VK_RETURN, VK_SPACE] then
  begin
    Click;
    Key := 0;
  end;
end;

procedure TCartaoInicio.Paint;
var
  X, Y, I: Integer;
  Estilo: TTextStyle;
  procedure Caixa(L, T, R, B: Integer; Cor: TColor);
  begin
    Canvas.Brush.Color := Cor;
    Canvas.Pen.Color := Azul;
    Canvas.RoundRect(X + L, Y + T, X + R, Y + B, 7, 7);
  end;
  procedure Linha(L, T, R, B: Integer);
  begin
    Canvas.MoveTo(X + L, Y + T);
    Canvas.LineTo(X + R, Y + B);
  end;
  procedure Barras;
  var J: Integer;
  begin
    for J := 0 to 14 do
    begin
      Canvas.Pen.Width := 1 + Ord(J mod 3 = 0);
      Linha(22 + J * 3, 40, 22 + J * 3, 56);
    end;
    Canvas.Pen.Width := 2;
  end;
begin
  Canvas.Brush.Color := clWhite;
  if Selecionado then Canvas.Brush.Color := $FFF4E9;
  Canvas.Pen.Color := Borda;
  Canvas.Pen.Width := 1;
  if FHover or Selecionado or Focused then
  begin
    Canvas.Pen.Color := Azul;
    Canvas.Pen.Width := 2;
  end;
  Canvas.RoundRect(2, 2, Width - 2, Height - 2, 16, 16);
  X := (Width - 92) div 2;
  Y := 16;
  if Compacto then
  begin
    X := 4;
    Y := (Height - 78) div 2;
  end;
  Canvas.Pen.Width := 2;
  Canvas.Pen.Color := Azul;
  if Impressora then
  begin
    if Ilustracao = 3 then
    begin
      Caixa(24, 0, 68, 39, clWhite);
      for I := 0 to 2 do Linha(31, 10 + I * 7, 60, 10 + I * 7);
      Caixa(7, 23, 85, 62, $F8E8D9);
      Caixa(24, 45, 68, 78, clWhite);
      for I := 0 to 2 do Linha(30, 54 + I * 7, 61, 54 + I * 7);
    end
    else
    begin
      if Ilustracao = 2 then
      begin
        Caixa(23, 2, 69, 76, $F8E8D9);
        Caixa(30, 10, 62, 28, clWhite);
        for I := 0 to 2 do Linha(32, 38 + I * 8, 60, 38 + I * 8);
      end
      else
      begin
        Caixa(12, 13, 80, 66, $F8E8D9);
        Caixa(23, 0, 69, 29, clWhite);
        Caixa(21, 41, 71, 77, clWhite);
        Barras;
        if Ilustracao = 1 then
          for I := 0 to 2 do Linha(29, 62 + I * 4, 63, 62 + I * 4);
      end;
    end;
  end
  else
  begin
    Canvas.Brush.Color := $FFF4E9;
    Canvas.Pen.Color := $FFF4E9;
    Canvas.Ellipse(X + 4, Y - 2, X + 88, Y + 75);
    Canvas.Pen.Color := Azul;
    case Ilustracao of
      0: begin { price label }
        Caixa(10, 15, 82, 60, clWhite);
        Canvas.Font.Size := 18;
        Canvas.Font.Style := [fsBold];
        Canvas.Font.Color := Azul;
        Canvas.TextOut(X + 24, Y + 21, 'R$');
      end;
      1: begin Caixa(13, 12, 79, 62, clWhite); Barras; Linha(24, 24, 61, 24); end;
      2: begin { calendar }
        Caixa(18, 12, 74, 65, clWhite);
        Linha(18, 27, 74, 27);
        Linha(31, 5, 31, 20); Linha(61, 5, 61, 20);
        Linha(31, 46, 42, 56); Linha(42, 56, 63, 35);
      end;
      3: begin { laboratory tubes }
        Caixa(24, 10, 38, 65, clWhite); Caixa(52, 10, 66, 65, clWhite);
        Caixa(21, 6, 41, 17, $F8E8D9); Caixa(49, 6, 69, 17, $F8E8D9);
        Linha(25, 44, 37, 44); Linha(53, 35, 65, 35);
      end;
      4: begin { medicine }
        Caixa(22, 17, 70, 66, clWhite); Caixa(29, 5, 63, 18, $F8E8D9);
        Canvas.Pen.Width := 5;
        Linha(46, 29, 46, 54); Linha(34, 41, 58, 41);
      end;
      5: begin { parcel }
        Caixa(13, 12, 79, 65, $F8E8D9); Caixa(37, 12, 55, 35, clWhite);
        Linha(24, 48, 45, 48); Linha(24, 55, 57, 55);
      end;
      6: begin { badge }
        Caixa(17, 13, 75, 67, clWhite); Caixa(35, 5, 57, 20, $F8E8D9);
        Canvas.Brush.Color := $F8E8D9;
        Canvas.Ellipse(X + 26, Y + 29, X + 43, Y + 46);
        Linha(24, 56, 45, 56); Linha(52, 34, 66, 34); Linha(52, 44, 66, 44);
      end;
      7: begin { manual and video, schematic QR illustration }
        Caixa(9, 7, 59, 66, clWhite); Linha(18, 19, 47, 19); Linha(18, 27, 44, 27);
        Caixa(34, 32, 84, 65, $F8E8D9);
        Canvas.Brush.Color := Azul;
        Canvas.Polygon([Point(X + 53,Y + 40),Point(X + 53,Y + 57),Point(X + 68,Y + 49)]);
      end;
    end;
  end;
  Canvas.Pen.Width := 1;
  Canvas.Font.Assign(Font);
  Canvas.Brush.Style := bsClear;
  Estilo := Canvas.TextStyle;
  Estilo.Alignment := taCenter;
  Estilo.Layout := tlCenter;
  Estilo.Wordbreak := True;
  Estilo.SingleLine := False;
  Canvas.Font.Color := Tinta;
  Canvas.Font.Style := [fsBold];
  if Compacto then
  begin
    Estilo.Alignment := taLeftJustify;
    Estilo.Layout := tlTop;
    Canvas.TextRect(Rect(102, 10, Width - 10, 52), 102, 10, Titulo, Estilo);
    Canvas.Font.Style := [];
    Canvas.Font.Size := 8;
    Canvas.Font.Color := Suave;
    Canvas.TextRect(Rect(102, 52, Width - 10, Height - 26), 102, 52, Detalhe, Estilo);
    Canvas.Font.Size := 9;
    Canvas.Font.Color := Azul;
    if Selecionado then
    begin
      Canvas.Font.Style := [fsBold];
      Canvas.TextRect(Rect(102, Height-24, Width-10, Height-6), 102, Height-24, 'SELECIONADA', Estilo);
    end
    else
      Canvas.TextRect(Rect(102, Height-24, Width-10, Height-6), 102, Height-24, 'Selecionar', Estilo);
    Canvas.Brush.Style := bsSolid;
    Exit;
  end;
  Canvas.TextRect(Rect(12, 98, Width - 12, 142), 12, 98, Titulo, Estilo);
  Canvas.Font.Style := [];
  Canvas.Font.Size := 9;
  Canvas.Font.Color := Suave;
  Canvas.TextRect(Rect(12, 144, Width - 12, Height - 29), 12, 144, Detalhe, Estilo);
  Canvas.Font.Color := Azul;
  if Impressora then
  begin
    if Selecionado then
      Canvas.TextRect(Rect(8, Height-27, Width-8, Height-7), 8, Height-27, 'SELECIONADA', Estilo)
    else
      Canvas.TextRect(Rect(8, Height-27, Width-8, Height-7), 8, Height-27, 'Selecionar', Estilo);
  end
  else if Tag = 1002 then
    Canvas.TextRect(Rect(8, Height-27, Width-8, Height-7), 8, Height-27, 'Importar etiqueta  >', Estilo)
  else if Tag = 1000 then
    Canvas.TextRect(Rect(8, Height-27, Width-8, Height-7), 8, Height-27, 'Personalizar QR Code  >', Estilo)
  else
    Canvas.TextRect(Rect(8, Height-27, Width-8, Height-7), 8, Height-27, 'Criar etiqueta  >', Estilo);
  Canvas.Brush.Style := bsSolid;
end;

function TInicio.Rotulo(const Texto: string; Tam: Integer; Negrito: Boolean;
  APai: TWinControl): TLabel;
begin
  Result := TLabel.Create(Self);
  if APai = nil then APai := FArea;
  Result.Parent := APai;
  Result.AutoSize := False;
  Result.Caption := Texto;
  Result.Font.Size := Tam;
  Result.Font.Color := Tinta;
  if Negrito then Result.Font.Style := [fsBold];
  Result.WordWrap := True;
end;

constructor TInicio.Create(AOwner: TComponent);
var I: Integer;
begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  Caption := '';
  Color := Fundo;
  Font.Name := 'Segoe UI';
  Font.Size := 10;
  FModelos := TList.Create;

  { Coluna esquerda fixa: tipos de impressora empilhados verticalmente. }
  FColuna := TScrollBox.Create(Self);
  FColuna.Parent := Self;
  FColuna.Align := alLeft;
  FColuna.Width := LarguraColuna;
  FColuna.BorderStyle := bsNone;
  FColuna.Color := $F3EEE8;
  FColuna.HorzScrollBar.Visible := False;
  FColuna.OnResize := @OrganizarColuna;

  { Painel cliente: o que imprimir (busca, finalidade e modelos). }
  FConteudo := TScrollBox.Create(Self);
  FConteudo.Parent := Self;
  FConteudo.Align := alClient;
  FConteudo.BorderStyle := bsNone;
  FConteudo.Color := Fundo;
  FConteudo.HorzScrollBar.Visible := False;
  FConteudo.OnResize := @Organizar;
  FArea := TPanel.Create(Self);
  FArea.Parent := FConteudo;
  FArea.BevelOuter := bvNone;
  FArea.Color := Fundo;
  FArea.SetBounds(0, 0, 1000, 1000);

  FCabecalho := Rotulo('Etiquetas', 22, True, FColuna);
  FPasso1 := Rotulo('1  Tipo de impressora', 13, True, FColuna);
  for I := 0 to 3 do
  begin
    FImpressoras[I] := TCartaoInicio.Create(Self);
    with FImpressoras[I] do
    begin
      Parent := FColuna;
      Impressora := True;
      Compacto := True;
      Ilustracao := I;
      Titulo := NomesImp[I];
      Detalhe := InfoImp[I];
      Tag := I;
      OnClick := @ImpressoraClick;
      AccessibleName := Titulo;
      AccessibleDescription := Detalhe;
    end;
  end;
  FResumo := Rotulo('', 9, False, FColuna);
  FResumo.Font.Color := Suave;
  FPasso2 := Rotulo('2  O que você quer imprimir?', 15, True);
  FBusca := TEdit.Create(Self);
  FBusca.Parent := FArea;
  FBusca.TextHint := 'Buscar modelo de etiqueta...';
  FBusca.OnChange := @Filtrar;
  FFiltro := TComboBox.Create(Self);
  FFiltro.Parent := FArea;
  FFiltro.Style := csDropDownList;
  FFiltro.Items.AddStrings(['Todas as finalidades', 'Varejo', 'Saúde', 'Logística', 'Identificação', 'Conteúdo digital']);
  FFiltro.ItemIndex := 0;
  FFiltro.OnChange := @Filtrar;
  FVazio := Rotulo('Nenhum modelo encontrado. Altere a busca ou a finalidade.', 12, False);
  FRodape := Rotulo('3  Preencha o conteúdo, visualize e imprima. Selecione o dispositivo e o papel na janela de impressão.', 10, False);
  FRodape.Font.Color := Suave;
  SelecionarImpressora(0);
end;

destructor TInicio.Destroy;
begin
  FModelos.Free;
  inherited Destroy;
end;

procedure TInicio.Modelo(const Nome, Info, Grupo: string; Icone, Codigo: Integer);
var C: TCartaoInicio;
begin
  C := TCartaoInicio.Create(Self);
  C.Parent := FArea;
  C.Titulo := Nome;
  C.Detalhe := Info;
  C.Categoria := Grupo;
  C.Ilustracao := Icone;
  C.Tag := Codigo;
  C.OnClick := FAbrir;
  C.AccessibleName := Nome;
  C.AccessibleDescription := Info;
  FModelos.Add(C);
end;

procedure TInicio.Popular;
var S: string;
begin
  while FModelos.Count > 0 do
  begin
    TObject(FModelos[0]).Free;
    FModelos.Delete(0);
  end;
  Modelo('Manuais e vídeos · QR Code', 'Link, título, texto e imagem em uma etiqueta', 'Conteúdo digital', 7, 1000);
  case FTipo of
    0:
    begin
      S := 'Rolo adesivo / Ribbon';
      Modelo('Mercado Livre · envios', 'Importar etiqueta original PDF, ZIP ou ZPL', 'Logística', 5, 1002);
      Modelo('Preços e gôndola', S + ' · preço por kg / litro', 'Varejo', 0, 7);
      Modelo('Padaria e açougue', S + ' · código EAN-13', 'Varejo', 1, 8);
      Modelo('Validade de produtos', S + ' · lote e conservação', 'Varejo', 2, 9);
      Modelo('Tubos de coleta', S + ' · identificação de amostras', 'Saúde', 3, 0);
      Modelo('Lâminas de laboratório', 'Exclusivo Ribbon · biópsia e citologia (25×15 mm)', 'Saúde', 3, 1);
      Modelo('Bolsas de sangue', 'Exclusivo Ribbon · hemoterapia (100×70 mm)', 'Saúde', 4, 2);
      Modelo('Transporte biológico', 'Exclusivo Ribbon · UN 3373 (100×100 mm)', 'Saúde', 5, 3);
      Modelo('Medicamentos', S + ' · posologia', 'Saúde', 4, 4);
      Modelo('Dose unitária', S + ' · fracionamento', 'Saúde', 4, 5);
      Modelo('Soro e infusão', S + ' · identificação hospitalar', 'Saúde', 4, 6);
      Modelo('Envio e despacho', S + ' · volumes e destinatário (100×150 mm)', 'Logística', 5, 10);
      Modelo('Etiqueta tipo ML (150 × 100 mm)', S + ' · 150 mm comprimento × 100 mm altura', 'Logística', 5, 13);
      Modelo('Patrimônio e ativo fixo', 'Exclusivo Ribbon · etiqueta durável (50×25 mm)', 'Identificação', 1, 14);
      Modelo('Crachá de visitante', S + ' · visitante / acompanhante', 'Identificação', 6, 11);
      Modelo('Crachá com foto', S + ' · funcionário / operador', 'Identificação', 6, 12);
      Modelo('Pulseiras de bebê', 'Exclusivo Ribbon/Zebra · neonatal 25 × 285 mm', 'Saúde', 6, 1001);
    end;
    1:
    begin
      S := 'Bobina térmica 80 mm';
      Modelo('Comanda e pedido 80 mm', 'Exclusivo Térmica 80 col · cozinha e balcão', 'Varejo', 1, 15);
      Modelo('Senha de atendimento 80 mm', 'Exclusivo Térmica 80 col · recepção e fila', 'Identificação', 6, 16);
      Modelo('Preços e gôndola', S + ' · preço por kg / litro', 'Varejo', 0, 7);
      Modelo('Padaria e açougue', S + ' · código EAN-13', 'Varejo', 1, 8);
      Modelo('Validade de produtos', S + ' · lote e conservação', 'Varejo', 2, 9);
      Modelo('Tubos / comprovante coleta', S + ' · identificação de amostras', 'Saúde', 3, 0);
      Modelo('Transporte biológico', S + ' · identificação UN 3373', 'Saúde', 5, 3);
      Modelo('Medicamentos', S + ' · posologia', 'Saúde', 4, 4);
      Modelo('Dose unitária', S + ' · fracionamento', 'Saúde', 4, 5);
      Modelo('Soro e infusão', S + ' · identificação hospitalar', 'Saúde', 4, 6);
      Modelo('Envio e despacho', S + ' · volumes e destinatário', 'Logística', 5, 10);
      Modelo('Etiqueta tipo ML (80 mm)', S + ' · expedição em bobina 80 col', 'Logística', 5, 13);
      Modelo('Crachá de visitante', S + ' · visitante / acompanhante', 'Identificação', 6, 11);
      Modelo('Crachá de operador', S + ' · portaria / funcionário', 'Identificação', 6, 12);
    end;
    2:
    begin
      S := 'Bobina 55 / 58 mm';
      Modelo('Sacola e delivery 55 mm', 'Exclusivo 55/58 mm · entrega compacta', 'Logística', 5, 17);
      Modelo('Preço rápido corredor 55 mm', 'Exclusivo 55/58 mm · gôndola móvel', 'Varejo', 0, 18);
      Modelo('Comanda resumida 55 mm', 'Exclusivo 55/58 mm · pedido portátil', 'Varejo', 1, 19);
      Modelo('Senha / ticket portátil 55 mm', 'Exclusivo 55/58 mm · portaria e fila', 'Identificação', 6, 20);
      Modelo('Preços e gôndola', S + ' · preço por kg / litro', 'Varejo', 0, 7);
      Modelo('Padaria e açougue', S + ' · código EAN-13', 'Varejo', 1, 8);
      Modelo('Validade de produtos', S + ' · lote e conservação', 'Varejo', 2, 9);
      Modelo('Coleta domiciliar', S + ' · amostra portátil', 'Saúde', 3, 0);
      Modelo('Medicamentos', S + ' · posologia', 'Saúde', 4, 4);
      Modelo('Dose unitária', S + ' · beira-leito', 'Saúde', 4, 5);
      Modelo('Soro e infusão', S + ' · identificação hospitalar', 'Saúde', 4, 6);
      Modelo('Envio / sacola logística', S + ' · despacho compacto', 'Logística', 5, 10);
      Modelo('Crachá de visitante', S + ' · passe rápido', 'Identificação', 6, 11);
      Modelo('Crachá operador', S + ' · identificação compacta', 'Identificação', 6, 12);
    end;
  else
    begin
      { Codes: purpose * 100 + sheet model, matching etiquetaspimaco enums (Exclusivo Papel A4 / Carta). }
      Modelo('Mercado Livre · PDF A4', 'Importar etiqueta original PDF em folha A4', 'Logística', 5, 1002);
      Modelo('Etiqueta tipo ML em A4 (150 × 100 mm)', 'Exclusivo Papel A4 · 2 por folha (150 × 100 mm)', 'Logística', 5, 410);
      Modelo('Aviso / identificação A4', 'Exclusivo Papel A4 · folha A4 inteira para caixa/setor', 'Logística', 5, 609);
      Modelo('Preços e gôndola', 'Pimaco A4255 · 27 por folha A4', 'Varejo', 0, 2);
      Modelo('Código de barras', 'Pimaco A4251 · 65 por folha A4', 'Varejo', 1, 1);
      Modelo('Preços em folha Carta', 'Pimaco 6180 · 30 por folha', 'Varejo', 0, 7);
      Modelo('Cartaz de oferta A4', 'Exclusivo Papel A4 · folha inteira de oferta', 'Varejo', 0, 9);
      Modelo('Validade de produtos', 'Pimaco A4255 · 27 por folha A4', 'Varejo', 2, 102);
      Modelo('Lâminas e microtubos', 'Pimaco A4248 · 96 por folha A4', 'Saúde', 3, 200);
      Modelo('Tubos de coleta', 'Pimaco A4251 · 65 por folha A4', 'Saúde', 3, 201);
      Modelo('Medicamentos', 'Pimaco A4260 · 21 por folha A4', 'Saúde', 4, 303);
      Modelo('Soro e farmácia', 'Pimaco A4262 · 14 por folha A4', 'Saúde', 4, 304);
      Modelo('Envio e despacho', 'Pimaco A4268 · 4 por folha A4', 'Logística', 5, 406);
      Modelo('Mala direta', 'Pimaco A4260 · 21 por folha A4', 'Logística', 5, 403);
      Modelo('Envelopes e expedição', 'Pimaco Carta 6182 · 14 por folha', 'Logística', 5, 408);
      Modelo('Crachás e identificação', 'Pimaco A4263 · 10 por folha A4', 'Identificação', 6, 505);
    end;
  end;
end;

procedure TInicio.SelecionarImpressora(Tipo: Integer);
var I: Integer;
begin
  if (Tipo < 0) or (Tipo > 3) then Exit;
  FTipo := Tipo;
  for I := 0 to 3 do
  begin
    FImpressoras[I].Selecionado := I = Tipo;
    FImpressoras[I].Invalidate;
  end;
  FResumo.Caption := NomesImp[Tipo] + ' selecionada. Os modelos ao lado serão abertos neste formato.';
  Popular;
  OrganizarColuna(Self);
  Organizar(Self);
end;

procedure TInicio.ImpressoraClick(Sender: TObject);
begin
  SelecionarImpressora(TComponent(Sender).Tag);
end;

procedure TInicio.Filtrar(Sender: TObject);
begin
  Organizar(Self);
end;

procedure TInicio.OrganizarColuna(Sender: TObject);
var W, I, Y: Integer;
begin
  if not Assigned(FResumo) then Exit;
  W := Max(160, FColuna.ClientWidth - 32);
  FCabecalho.SetBounds(16, 16, W, 40);
  FPasso1.SetBounds(16, 66, W, 26);
  Y := 100;
  for I := 0 to 3 do
  begin
    FImpressoras[I].SetBounds(16, Y, W, AlturaCartaoImp);
    Inc(Y, AlturaCartaoImp + 10);
  end;
  FResumo.SetBounds(16, Y + 4, W, 64);
end;

procedure TInicio.Organizar(Sender: TObject);
var W, Colunas, CW, I, N, Y, PY: Integer;
  C: TCartaoInicio;
  Busca, Grupo: string;
begin
  if not Assigned(FRodape) then Exit;
  W := Max(300, FConteudo.ClientWidth - 48);
  FArea.Width := FConteudo.ClientWidth;
  PY := -28; { título do passo 2 no topo do painel cliente }
  FPasso2.SetBounds(24, PY + 52, W, 32);
  FBusca.SetBounds(24, PY + 96, Max(140, W - 240), 32);
  FFiltro.SetBounds(24 + Max(140, W - 240) + 12, PY + 96, 228, 32);
  Y := PY + 148;
  Colunas := Max(1, Min(4, (W + 16) div 220));
  CW := (W - (Colunas - 1) * 16) div Colunas;
  Busca := UTF8LowerCase(Trim(FBusca.Text));
  Grupo := FFiltro.Text;
  N := 0;
  for I := 0 to FModelos.Count - 1 do
  begin
    C := TCartaoInicio(FModelos[I]);
    C.Visible := ((Busca = '') or (Pos(Busca, UTF8LowerCase(C.Titulo + ' ' + C.Detalhe + ' ' + C.Categoria)) > 0))
      and ((FFiltro.ItemIndex = 0) or (C.Categoria = Grupo));
    if not C.Visible then Continue;
    C.OnClick := FAbrir;
    C.SetBounds(24 + (N mod Colunas) * (CW + 16), Y + (N div Colunas) * 232, CW, 216);
    Inc(N);
  end;
  FVazio.Visible := N = 0;
  FVazio.SetBounds(24, Y, W, 60);
  Y := Y + Max(1, (N + Colunas - 1) div Colunas) * 232;
  FRodape.SetBounds(24, Y + 8, W, 52);
  FArea.Height := Y + 80;
end;

end.
