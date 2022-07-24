unit config;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, setmain;

type

  { Tfrmconfig }

  Tfrmconfig = class(TForm)
    btSalvar: TButton;
    edDLL: TEdit;
    edDB: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure btSalvarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmconfig: Tfrmconfig;

implementation

{$R *.lfm}

{ Tfrmconfig }

procedure Tfrmconfig.FormShow(Sender: TObject);
begin
  edDLL.text := FSetMain.SQLLITEDLL;
  edDB.text := FSetMain.db;

end;

procedure Tfrmconfig.btSalvarClick(Sender: TObject);
begin
  FSetMain.SQLLITEDLL:= edDLL.Text;
  FSetMain.db:= edDB.text;
  close;
end;

end.

