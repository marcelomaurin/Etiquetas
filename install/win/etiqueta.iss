; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Etiquetas"
#define MyAppVersion "1.1"
#define MyAppPublisher "MAURINSOFT"
#define MyAppURL "http://maurinsoft.com.br"
#define MyAppExeName "etiquetas.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{25A25926-C819-4F28-B173-8916AF42FCD4}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DisableProgramGroupPage=yes
OutputBaseFilename=etiqueta_setup_01
Compression=lzma
SolidCompression=yes

 

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked


[Types]
;Name: "Elgin"; Description:  {cm:T_Elgin}
;Name: "Pos58"; Description: {cm:T_Pos58}
;Name: "Pos5811"; Description: {cm:T_Pos5811}
Name: "ETIQUETA"; Description: {cm:T_ETIQUETA}

[Components]
Name: "Etiqueta"; Description: "Arquivos da Etiqueta"; Types: ETIQUETA;



[CustomMessages]
;T_BANCO=BANCO
;TD_BANCO=Banco de Dados
;T_Pos58=Pos
;TD_Pos58=Instala��o padr�o do fila com drivers do Pos58
;T_Pos5811=Pos
;TD_Pos5811=Instala��o padr�o do fila com drivers do Pos5811
T_ETIQUETA=ETIQUETA
TD_ETIQUETA=Install demo ETIQUETA 

; [Setup], [Files] etc sections go here
[Code]
//#define MSIDT_CustomType "Whatever"
//#include "DescriptiveTypes.isi"
//procedure InitializeWizard();
//begin
// InitializeDescriptiveTypes();
//end;



[Files]
Source: "D:\projetos\maurinsoft\Etiquetas\src\etiquetas.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\projetos\maurinsoft\Etiquetas\db\etiqueta.db"; DestDir: "{app}\db\"; Flags: ignoreversion
Source: "D:\projetos\maurinsoft\Etiquetas\sqlite\win64\sqlite3.def"; DestDir: "{app}\sqlite\win64\"; Flags: ignoreversion
Source: "D:\projetos\maurinsoft\Etiquetas\sqlite\win64\sqlite3.dll"; DestDir: "{app}\sqlite\win64\"; Flags: ignoreversion
;Source: "D:\projetos\maurinsoft\fila\cliente.cfg"; DestDir: "{app}"; 
;Source: "D:\projetos\maurinsoft\fila\drivers\Elgin i9\ELGIN Printer Driver_v-1.6.6.exe"; DestDir: "{app}"; Components: Elgin ;
;Source: "D:\projetos\maurinsoft\fila\drivers\POS58\POS Printer Driver Setup .exe"; DestDir: "{app}"; Components: Pos58;
;Source: "D:\projetos\maurinsoft\fila\drivers\POS5811-DD\POS Printer Driver Setup .exe"; DestDir: "{app}"; Components: Pos5811;
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{commonprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
;Filename: "{app}\ELGIN Printer Driver_v-1.6.6.exe"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Components: Elgin;
;Filename: "{app}\POS Printer Driver Setup .exe"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Components: Pos58; 
;Filename: "{app}\POS Printer Driver Setup .exe"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Components: Pos5811; 
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
