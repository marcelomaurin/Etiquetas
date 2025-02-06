program etiquetas;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, anchordockpkg, rxnew, fortes324forlaz, lnetvisual, gondola, ticket,
  relticket02, zcomponent, dmbase, registro, funcoes, setmain, config, main, 
Import, csvproducts, relticket, csvendereco, MalaDireta, reletiq01, etqlab
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='Etiquetas';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

