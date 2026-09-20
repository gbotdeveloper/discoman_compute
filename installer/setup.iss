; Installer for the Discoman Compute desktop app.
;
; Not meant to be run by hand: .github/workflows/release.yml passes the four
; defines below and calls ISCC. To try it locally on Windows:
;
;   flutter build windows --release
;   "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" ^
;     /DAppVersion=0.1.0 ^
;     /DAppExeName=discoman_compute.exe ^
;     /DSourceDir=%CD%\build\windows\x64\runner\Release ^
;     /DOutputDir=%CD% ^
;     installer\setup.iss

#define AppName "Discoman Compute"
#define AppPublisher "GBot"
#define AppURL "https://github.com/gbotdeveloper/discoman_compute"

[Setup]
; Never change AppId. It is how Windows recognises an existing installation
; and upgrades it in place, instead of leaving two copies side by side.
AppId={{1B8F9870-A07D-45D9-B444-A159E1C47190}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
; `lowest` keeps the installer out of UAC entirely: it installs under the
; person's own profile, so downloading and running it never needs an
; administrator. It also means one account's install does not touch another's.
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir={#OutputDir}
OutputBaseFilename=DiscomanCompute-Setup
UninstallDisplayIcon={app}\{#AppExeName}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Tasks]
Name: desktopicon; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"

[Files]
; A Flutter windows build is an .exe next to its DLLs and a data folder, so
; the whole directory ships, not just the executable.
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "Start {#AppName}"; Flags: nowait postinstall skipifsilent
