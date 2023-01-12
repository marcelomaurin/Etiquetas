; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Etiquetas"
#define MyAppVersion "1.3"
#define MyAppPublisher "MAURINSOFT"
#define MyAppURL "http://maurinsoft.com.br"
#define MyAppExeName "etiquetas.exe"
#define MyInstallExeName "setup_etiquetas_0103"

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
DefaultDirName={commonpf}\{#MyAppName}
DisableProgramGroupPage=yes
OutputDir=D:\projetos\maurinsoft\Etiquetas\bin\
OutputBaseFilename={#MyInstallExeName}
Compression=lzma
SolidCompression=yes

 

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked


[Types]
Name: "ETIQUETA"; Description: {cm:T_ETIQUETA}

[Components]
Name: "Etiqueta"; Description: "Arquivos da Etiqueta"; Types: ETIQUETA;



[CustomMessages]
T_ETIQUETA=ETIQUETA
TD_ETIQUETA=Install demo ETIQUETA 

; [Setup], [Files] etc sections go here
[Code]




[Files]
Source: "D:\projetos\maurinsoft\Etiquetas\src\etiquetas.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\projetos\maurinsoft\Etiquetas\db\etiqueta.db"; DestDir: "{app}\db\"; Flags: ignoreversion
Source: "D:\projetos\maurinsoft\Etiquetas\sqlite\win64\sqlite3.def"; DestDir: "{app}\sqlite\win64\"; Flags: ignoreversion
Source: "D:\projetos\maurinsoft\Etiquetas\sqlite\win64\sqlite3.dll"; DestDir: "{app}\sqlite\win64\"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{commonprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppExeName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

