program testar_inicio;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, Classes, SysUtils, Graphics, Controls, StdCtrls,
  ExtCtrls, inicio, qrmidia, enviosarquivo, zipper, mercadolivre,
  ZConnection, tabelafinalidade, crudfinalidade, wizardimpressao, etiquetasnovas;

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
      { Imagem de fundo (cobre a etiqueta inteira; QR sobre retângulo branco). }
      C := TComboBox(F.FindComponent('ImagemFundo'));
      Check(Assigned(C) and (C.Items.Count = 11), 'Lista de imagens de fundo ' + IntToStr(I));
      Check(TComboBox(F.FindComponent('ImagemTopo')).Items[0] = 'Nenhuma', 'Imagem de topo aceita Nenhuma ' + IntToStr(I));
      for K := 1 to 9 do
      begin
        C.ItemIndex := K;
        C.OnChange(C);
        Check(C.ItemIndex = K, 'Imagem de fundo ' + IntToStr(K) + ' encontrada ' + IntToStr(I));
        SalvarImagem(P.Picture.Bitmap, 'qr-' + IntToStr(I) + '-bg-' + IntToStr(K));
      end;
      C.ItemIndex := 0;
      C.OnChange(C);
      if I = 0 then
      begin
        C := TComboBox(F.FindComponent('ImagemTopo'));
        C.ItemIndex := 1;
        C.OnChange(C);
        C := TComboBox(F.FindComponent('ImagemFundo'));
        C.ItemIndex := 1;
        C.OnChange(C);
        SalvarImagem(P.Picture.Bitmap, 'qr-0-topo-e-fundo');
        Capturar(F, 'editor-qr-fundo');
        C.ItemIndex := 4;
        C.OnChange(C);
        SalvarImagem(P.Picture.Bitmap, 'qr-0-teatro');
        C.ItemIndex := 0;
        C.OnChange(C);
        C := TComboBox(F.FindComponent('ImagemTopo'));
        C.ItemIndex := 0;
        C.OnChange(C);
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

{ Banco de teste (cópia do modelo): migração da coluna imagem_fundo,
  gravação/recarga do fundo e capturas das telas de cadastro e do assistente. }
procedure TestarBancoETelas;
var
  Conn: TZConnection;
  Spec: TTabelaFinalidade;
  Linhas: TListaLinhasTabela;
  Valores: array of string;
  G: TfrmGerenciadorTabelas;
  Crud: TfrmCrudFinalidade;
  Wiz: TfrmWizardImpressao;
  Setorial: TfrmEtiquetasSetoriais;
  Opcoes: TOpcoesPapelWizard;
  Banco: string;
  I: Integer;
  Achou: Boolean;
begin
  Banco := Saida + 'teste.db';
  DeleteFile(Banco);
  with TMemoryStream.Create do
  try
    LoadFromFile(ExpandFileName(ExtractFilePath(ParamStr(0)) + '../db/etiqueta.db'));
    SaveToFile(Banco);
  finally Free; end;
  Conn := TZConnection.Create(nil);
  try
    Conn.Protocol := 'sqlite';
    Conn.Database := Banco;
    Conn.LibraryLocation := ExpandFileName(ExtractFilePath(ParamStr(0)) + '../src/sqlite3.dll');
    Conn.Connect;
    GConexaoFinalidade := Conn;
    CriarTodasTabelasFinalidade(Conn);
    Check(ObterTabelaFinalidade('qr_midia', Spec), 'Tabela qr_midia registrada');
    Check(Spec.Campos[High(Spec.Campos)].Coluna = 'imagem_fundo', 'Coluna imagem_fundo no fim da lista');
    SetLength(Valores, 11);
    Valores[0] := '0';
    Valores[1] := 'https://example.com/manual?produto=123';
    Valores[2] := 'Manual de instruções';
    Valores[3] := 'Leia antes de usar o equipamento.';
    Valores[4] := 'Aponte a câmera e acesse o manual';
    Valores[5] := '1';
    Valores[6] := '0';
    Valores[7] := '90';
    Valores[8] := '120';
    Valores[9] := '';
    Valores[10] := 'teatro';
    InserirRegistroTabela(Conn, Spec, Valores);
    Valores[2] := 'Assista ao vídeo';
    Valores[5] := '3';
    Valores[10] := 'logistica';
    InserirRegistroTabela(Conn, Spec, Valores);
    Linhas := CarregarRegistrosTabela(Conn, Spec);
    Achou := False;
    for I := 0 to High(Linhas) do
      if (Length(Linhas[I].Valores) > 10) and (Linhas[I].Valores[10] = 'teatro') then Achou := True;
    Check(Achou, 'Imagem de fundo gravada e relida do banco');

    G := TfrmGerenciadorTabelas.CreateGerenciador(nil, 'qr_midia');
    try Capturar(G, 'cadastros'); finally G.Free; end;
    Crud := TfrmCrudFinalidade.CreateComFinalidade(nil, 'qr_midia', False);
    try Capturar(Crud, 'gerenciar-registros'); finally Crud.Free; end;
    SetLength(Opcoes, 1);
    Opcoes[0].Codigo := 'qr_midia';
    Opcoes[0].Descricao := 'QR Code (90 x 120 mm)';
    Opcoes[0].ChaveFinalidade := 'qr_midia';
    Wiz := TfrmWizardImpressao.CreateWizard(nil, 'qr_midia', Opcoes, 0, Valores, 1);
    try Capturar(Wiz, 'assistente-registros-passo1'); finally Wiz.Free; end;
    Setorial := TfrmEtiquetasSetoriais.CreateSetorial(nil, miZebraRolo, msLabTuboColeta);
    try Capturar(Setorial, 'assistente-passo1'); finally Setorial.Free; end;
    Check(True, 'Telas de cadastro e assistente capturadas');
  finally
    GConexaoFinalidade := nil;
    Conn.Free;
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
      TestarBancoETelas;
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
