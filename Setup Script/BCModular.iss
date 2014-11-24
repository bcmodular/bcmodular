; -- 64BitTwoArch.iss --
; Demonstrates how to install a program built for two different
; architectures (x86 and x64) using a single installer.

; SEE THE DOCUMENTATION FOR DETAILS ON CREATING .ISS SCRIPT FILES!
#define AppName "BC Modular"
#define RegSubKey "Software\BCModular\BCModular"

[Setup]
AppName={#AppName}
AppVersion=0.98b
DefaultDirName={pf}\{#AppName}
DefaultGroupName={#AppName}
UninstallDisplayIcon={app}\{#AppName}.ico
AppPublisher=BC Modular
AppPublisherURL=http://www.bcmodular.co.uk/
AppCopyright=Copyright (C) 2014 BC Modular
AppContact=support@bcmodular.co.uk
AppSupportURL=http://bcmodular.co.uk/forum/
AppUpdatesURL=http://www.bcmodular.co.uk/
Compression=lzma2
SolidCompression=yes
LicenseFile=license.txt
; "ArchitecturesInstallIn64BitMode=x64" requests that the install be
; done in "64-bit mode" on x64, meaning it should use the native
; 64-bit Program Files directory and the 64-bit view of the registry.
; On all other architectures it will install in "32-bit mode".
ArchitecturesInstallIn64BitMode=x64
; Note: We don't set ProcessorsAllowed because we want this
; installation to run on all architectures (including Itanium,
; since it's capable of running 32-bit code too).
WizardImageFile=C:\development\github\bcmodular\Setup Script\Images\BCWizImage.bmp
WizardSmallImageFile=C:\development\github\bcmodular\Setup Script\Images\BCWizSmallImage.bmp
VersionInfoVersion=0.9.8

[Types]
Name: "full"; Description: "Full installation"

[Files]
; Install MyProg-x64.exe if running in 64-bit mode (x64; see above),
; MyProg.exe otherwise.
; Place all x64 files here
; Place all x86 files here, first one should be marked 'solidbreak'
; Place all common files here, first one should be marked 'solidbreak'
Source: "..\Dll\*"; DestDir: "{code:GetScopeDir}\App\Dll"; Flags: ignoreversion solidbreak;
Source: "..\MMdsp\*"; DestDir: "{code:GetScopeDir}\App\Dsp"; Flags: ignoreversion uninsneveruninstall;
Source: "..\BC Modules\*"; DestDir: "{code:GetModularDir}"; Flags: ignoreversion recursesubdirs;
Source: "..\Presets\*"; DestDir: "{code:GetScopeDir}\Presets"; Flags: ignoreversion;
Source: "..\BCFX\*"; DestDir: "{code:GetScopeDir}\Devices\Effects\Stereo"; Flags: ignoreversion;
Source: "..\BC Shells\*"; DestDir: "{code:GetShellDir}"; Flags: ignoreversion;

[Icons]
Name: "{group}\Uninstall {#AppName}"; Filename: "{uninstallexe}"

[Code]
// global vars
var
  DirPage: TInputDirWizardPage;
  DirPageID: Integer;

function GetScopeDir(Param: String): String;
var
  ScopeDir: String;
begin
  ScopeDir := DirPage.Values[0];
  RegWriteStringValue(HKEY_CURRENT_USER, '{#RegSubKey}', 'ScopeDir', ScopeDir);
  { Return the selected ScopeDir }
  Result := ScopeDir;
end;

function GetModularDir(Param: String): String;
var
  ModularDir: String;
begin
  ModularDir := DirPage.Values[1];
  RegWriteStringValue(HKEY_CURRENT_USER, '{#RegSubKey}', 'ModularDir', ModularDir);
  { Return the selected ModularDir }
  Result := ModularDir;
end;

function GetShellDir(Param: String): String;
var
  ShellDir: String;
begin
  ShellDir := DirPage.Values[2];
  RegWriteStringValue(HKEY_CURRENT_USER, '{#RegSubKey}', 'ShellDir', ShellDir);
  { Return the selected ShellDir }
  Result := ShellDir;
end;

procedure InitializeWizard;
var
  ScopeDir: String;
  ModularDir: String;
  ShellDir: String;
begin
  if not(RegQueryStringValue(HKEY_CURRENT_USER, '{#RegSubKey}', 'ScopeDir', ScopeDir)) then
  begin
    ScopeDir := ExpandConstant('{pf}\Scope PCI');
  end; 

  if not(RegQueryStringValue(HKEY_CURRENT_USER, '{#RegSubKey}', 'ModularDir', ModularDir)) then
  begin
    ModularDir := ExpandConstant('{pf}\Scope PCI\Modular Modules\BC Modules');
  end; 

  if not(RegQueryStringValue(HKEY_CURRENT_USER, '{#RegSubKey}', 'ShellDir', ShellDir)) then
  begin
    ShellDir := ExpandConstant('{pf}\Scope PCI\Devices\BC Shells');
  end; 

  DirPage := CreateInputDirPage(
    wpSelectComponents,
    'Select Directories',
    'Where should files be installed?',
    '',
    False,
    '{#AppName}'
  );

  DirPage.Add('Scope Installation Directory');
  DirPage.Values[0] := ScopeDir;
  
  DirPage.Add('Modular Modules Directory');
  DirPage.Values[1] := ModularDir;

  DirPage.Add('Modular Shells Directory');
  DirPage.Values[2] := ShellDir;

end;
