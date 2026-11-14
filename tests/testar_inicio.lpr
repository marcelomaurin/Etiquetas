program testar_inicio;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, Classes, SysUtils, Graphics, Controls, StdCtrls,
  ExtCtrls, inicio, qrmidia, enviosarquivo, zipper, mercadolivre;

var
  Log: TStringList;
  Saida: string;

procedure Check(OK: Boolean; const Mensagem: string);
begin
  if not OK then raise Exception.Create(Mensagem);
  Log.Add('OK: ' + Mensagem);
end;

procedure SalvarImagem(G: TGraphic; const Nome: string);
var P: TPortableNetworkGraphic;
begin
  P := TPortableNetworkGraphic.Create;
  try P.Assign(G); P.SaveToFile(Saida + Nome + '.png'); finally P.Free; end;
end;

procedure Capturar(F: TForm; const Nome: string);
var B: TBitmap;
begin
  F.Show;
  Application.ProcessMessages;
  B := TBitmap.Create;
  try
    F.GetFormImage(B);
    SalvarImagem(B, Nome);
  finally B.Free; end;
end;

procedure TestarInicio;
var F: TForm; D: TInicio; I, J, N: Integer; E: TEdit; C: TCartaoInicio;
begin
  F := TForm.CreateNew(nil);
  try
    F.SetBounds(20, 20, 1120, 820);
    D := TInicio.Create(F);
    D.Parent := F;
    D.Align := alClient;
    F.Show;
    Application.ProcessMessages;
    for I := 0 to 3 do
    begin
      D.SelecionarImpressora(I);
      N := 0;
      for J := 0 to D.ComponentCount - 1 do
        if (D.Components[J] is TCartaoInicio) then
        begin
          C := TCartaoInicio(D.Components[J]);
          if not C.Impressora then Inc(N);
        end;
      Check(N >= 15, 'Catálogo completo da impressora ' + IntToStr(I));
    end;
    D.SelecionarImpressora(0);
    Capturar(F, 'inicio');
    F.Width := 760;
    Capturar(F, 'inicio-compacto');
    for J := 0 to D.ComponentCount - 1 do
      if D.Components[J] is TEdit then
      begin
        E := TEdit(D.Components[J]);
        E.Text := 'qR CoDe';
      end;
    N := 0;
    for J := 0 to D.ComponentCount - 1 do
      if D.Components[J] is TCartaoInicio then
      begin
        C := TCartaoInicio(D.Components[J]);
        if not C.Impressora and C.Visible then Inc(N);
      end;
    Check(N = 1, 'Busca sem diferenciar maiúsculas e minúsculas');
  finally F.Free; end;
end;

procedure TestarQR;
var F: TfrmQRMidia; E: TEdit; P: TImage; I, J, K: Integer; C: TComboBox; B: TButton;
  Texto: TMemo;
begin
  for I := 0 to 3 do
  begin
    F := TfrmQRMidia.CreateParaImpressora(nil, I);
    try
      F.Show;
      Application.ProcessMessages;
      E := TEdit(F.FindComponent('LinkConteudo'));
      P := TImage(F.FindComponent('PreviaEtiqueta'));
      Check(E.Text = '', 'Link começa vazio ' + IntToStr(I));
      Check(TMemo(F.FindComponent('TextoApoio')).Text = '', 'Texto opcional começa vazio ' + IntToStr(I));
      E.Text := 'https://example.com/manual?produto=123';
      Check(not P.Picture.Bitmap.Empty, 'Prévia QR para impressora ' + IntToStr(I));
      for J := 0 to F.ComponentCount - 1 do
        if F.Components[J] is TButton then
        begin
          B := TButton(F.Components[J]);
          if B.Caption = 'Salvar imagem PNG' then Check(B.Enabled, 'QR válido habilita exportação ' + IntToStr(I));
        end;
      SalvarImagem(P.Picture.Bitmap, 'qr-' + IntToStr(I));
      for J := 0 to F.ComponentCount - 1 do
        if F.Components[J] is TComboBox then
        begin
          C := TComboBox(F.Components[J]);
          if C.Items.IndexOf('Saúde · clínica') >= 0 then
            for K := 1 to 4 do
            begin
              C.ItemIndex := K;
              C.OnChange(C);
              SalvarImagem(P.Picture.Bitmap, 'qr-' + IntToStr(I) + '-fundo-' + IntToStr(K));
            end;
        end;
      if I = 0 then
      begin
        for J := 0 to F.ComponentCount - 1 do
          if F.Components[J] is TComboBox then
          begin
            C := TComboBox(F.Components[J]);
            if C.Items.IndexOf('Saúde · clínica') >= 0 then
            begin
              C.ItemIndex := 1;
              C.OnChange(C);
            end;
          end;
        Capturar(F, 'editor-qr');
      end;
      F.CarregarImagemArquivo(ExpandFileName(ExtractFilePath(ParamStr(0)) + '../background/qrcode/saude-clinica.png'));
      SalvarImagem(P.Picture.Bitmap, 'qr-' + IntToStr(I) + '-imagem');
      if I = 3 then
        for J := 0 to F.ComponentCount - 1 do
          if F.Components[J] is TComboBox then
          begin
            C := TComboBox(F.Components[J]);
            if C.Items.IndexOf('Cartaz A4') >= 0 then
            begin
              C.ItemIndex := 1;
              C.OnChange(C);
              SalvarImagem(P.Picture.Bitmap, 'qr-cartaz-a4');
            end;
          end;
      Texto := TMemo(F.FindComponent('TextoApoio'));
      Texto.Text := StringOfChar('W', 600);
      for J := 0 to F.ComponentCount - 1 do
        if F.Components[J] is TButton then
        begin
          B := TButton(F.Components[J]);
          if B.Caption = 'Salvar imagem PNG' then Check(not B.Enabled, 'Texto excedente bloqueia exportação ' + IntToStr(I));
        end;
      Texto.Clear;
      E.Text := 'arquivo-local.pdf';
      for J := 0 to F.ComponentCount - 1 do
        if F.Components[J] is TButton then
        begin
          B := TButton(F.Components[J]);
          if B.Caption = 'Salvar imagem PNG' then Check(not B.Enabled, 'Link inválido bloqueia exportação ' + IntToStr(I));
        end;
    finally F.Free; end;
  end;
end;

procedure TestarJanelaEnvios;
var F: TfrmMercadoLivre;
begin
  F := TfrmMercadoLivre.CreateParaImpressora(nil, 0);
  try Capturar(F, 'mercado-livre'); finally F.Free; end;
  Check(True, 'Janela de importação Mercado Livre criada');
end;

procedure TestarImportacao;
const ZPL: RawByteString = '^XA^FO30,30^FDTESTE^FS^XZ';
var A: TArquivoEnvio; Z: TZipper; S, D: TMemoryStream; L: TStringList;
  Caminho: string; Falhou: Boolean; Bytes: RawByteString;
begin
  A := TArquivoEnvio.Create;
  S := TMemoryStream.Create;
  D := TMemoryStream.Create;
  L := TStringList.Create;
  Z := TZipper.Create;
  try
    S.WriteBuffer(ZPL[1], Length(ZPL));
    S.Position := 0;
    Caminho := Saida + 'etiquetas.zip';
    Z.FileName := Caminho;
    Z.Entries.AddFileEntry(S, '../nao-extrair/etiqueta.txt');
    Z.ZipAllFiles;
    TArquivoEnvio.ListarZIP(Caminho, L);
    Check(L.Count = 1, 'ZIP lista etiqueta TXT');
    A.Carregar(Caminho, L[0], D);
    Check(TArquivoEnvio.Formato(D) = 'ZPL', 'TXT reconhecido por conteúdo ZPL');
    SetLength(Bytes, D.Size);
    D.ReadBuffer(Bytes[1], Length(Bytes));
    Check(Bytes = ZPL, 'Importação preserva todos os bytes originais');
    Check(not DirectoryExists(Saida + 'nao-extrair'), 'ZIP processado em memória sem criar caminhos do arquivo');
    D.Clear;
    Bytes := 'arquivo de texto sem comandos';
    D.WriteBuffer(Bytes[1], Length(Bytes));
    Falhou := False;
    try TArquivoEnvio.Formato(D); except on E: Exception do Falhou := True; end;
    Check(Falhou, 'TXT inválido rejeitado');
    D.Clear;
    Bytes := '%PDF-1.4 teste';
    D.WriteBuffer(Bytes[1], Length(Bytes));
    Check(TArquivoEnvio.Formato(D) = 'PDF', 'PDF identificado por assinatura');
    D.Size := LimiteEtiqueta + 1;
    Falhou := False;
    try TArquivoEnvio.Formato(D); except on E: Exception do Falhou := True; end;
    Check(Falhou, 'Arquivo acima do limite rejeitado');
  finally
    Z.Free; L.Free; D.Free; S.Free; A.Free;
  end;
end;

begin
  Application.Initialize;
  Saida := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'output' + PathDelim;
  ForceDirectories(Saida);
  Log := TStringList.Create;
  try
    try
      TestarImportacao;
      TestarInicio;
      TestarQR;
      TestarJanelaEnvios;
      Log.Add('PASSOU');
    except
      on E: Exception do
      begin
        Log.Add('FALHOU: ' + E.Message);
        Log.SaveToFile(Saida + 'verificacao.txt');
        Halt(1);
      end;
    end;
    Log.SaveToFile(Saida + 'verificacao.txt');
  finally Log.Free; end;
end.
