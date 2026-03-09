#define MyAppName "Voli di Carta"
#define MyAppVersion "1.3.7"
#define MyAppPublisher "Claudio Becchis - PolarisCore.it"
#define MyAppURL "https://polariscore.it"
#define MyAppExeName "book_review.exe"
#define MyAppReleaseDir "src\build\windows\x64\runner\Release"

[Setup]
AppId={{B4E1F3A2-8C7D-4F9E-B2A1-3D5E6F7A8B9C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=
OutputDir=installer
OutputBaseFilename=Voli di Carta_Setup_v{#MyAppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
WizardSizePercent=120
DisableWelcomePage=no
DisableDirPage=no
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription={#MyAppName} - Le tue recensioni, sempre con te
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

[Languages]
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
italian.WelcomeLabel1=Benvenuto nel wizard di installazione di [name]
italian.WelcomeLabel2=Questo wizard installerà [name/ver] sul tuo computer.%n%nVoli di Carta ti permette di recensire i libri che leggi e condividerli con la community.%n%nSviluppato da Claudio Becchis · polariscore.it
english.WelcomeLabel1=Welcome to the [name] Setup Wizard
english.WelcomeLabel2=This wizard will install [name/ver] on your computer.%n%nVoli di Carta lets you review books you read and share them with the community.%n%nDeveloped by Claudio Becchis · polariscore.it

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "startupicon"; Description: "Avvia Voli di Carta all'avvio di Windows"; GroupDescription: "Opzioni:"; Flags: unchecked

[Files]
Source: "{#MyAppReleaseDir}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#MyAppReleaseDir}\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs
Source: "{#MyAppReleaseDir}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Disinstalla {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{autostartup}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: startupicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Avvia {#MyAppName}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
end;
