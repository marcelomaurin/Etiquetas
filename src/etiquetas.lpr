program etiquetas;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, fortes324forlaz, main, ticket, relticket, zcomponent, dmbase
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='Etiquetas';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tfrmmain, frmmain);
  Application.CreateForm(TfrmTicket, frmTicket);
  Application.CreateForm(Tfrmrelticket, frmrelticket);
  Application.Run;
end.

