[Setup]
AppName=TrayMonster
AppVersion=1.0.0
AppPublisher=TrayMonster
DefaultDirName={autopf}\TrayMonster
DefaultGroupName=TrayMonster
OutputDir=build\installer
OutputBaseFilename=TrayMonster_Setup
SetupIconFile=windows\runner\resources\app_icon.ico
Compression=lzma2
SolidCompression=yes
PrivilegesRequired=lowest
UninstallDisplayIcon={app}\tray_monster_app.exe

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\TrayMonster"; Filename: "{app}\tray_monster_app.exe"
Name: "{autodesktop}\TrayMonster"; Filename: "{app}\tray_monster_app.exe"; Tasks: desktopicon
Name: "{userstartup}\TrayMonster"; Filename: "{app}\tray_monster_app.exe"; Tasks: startupicon

[Tasks]
Name: "desktopicon"; Description: "Create desktop shortcut"; GroupDescription: "Shortcuts:"
Name: "startupicon"; Description: "Start with Windows"; GroupDescription: "Shortcuts:"

[Run]
Filename: "{app}\tray_monster_app.exe"; Description: "Launch TrayMonster"; Flags: nowait postinstall skipifsilent
