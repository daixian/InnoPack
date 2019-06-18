; 脚本由 Inno Setup 脚本向导 生成！
; 有关创建 Inno Setup 脚本文件的详细资料请查阅帮助文档！

#define MyAppName "GC2000一体机服务安装"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "未来立体"
#define MyAppURL "http://www.f3dt.com/"
#define MyAppIcon "f3dteaching.ico"

[Setup]
; 注: AppId的值为单独标识该应用程序。
; 不要为其他安装程序使用相同的AppId值。
; (生成新的GUID，点击 工具|在IDE中生成GUID。)
AppId={{BE9170DA-A474-47F6-977C-6A70B5F7A788}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf64}\MRSystem
;DefaultGroupName= 
DisableProgramGroupPage=yes
;OutputDir="C:\Users\xiekun.FUTURE3D\Desktop\inno test"
OutputBaseFilename={#MyAppName}
Compression=lzma
SolidCompression=yes
UninstallDisplayIcon="f3dteaching.ico"
SetupIconFile="f3dteaching.ico"

[Languages]
Name: "chinesesimp"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Files]
Source: "MRSystem\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; 将vc和.net放到临时目录并判断是否需要安装
Source: "Runtime\vc_redist.x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall; AfterInstall: InstallVC_redist; Check: VCRedistNeedsInstall
Source: "Runtime\NDP452-KB2901907-x86-x64-AllOS-ENU.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall; AfterInstall: InstallFramework; Check: not IsDotNetReallyInstalled
; 注意: 不要在任何共享系统文件上使用“Flags: ignoreversion”

;[Icons]
;Name: "{app}\{#MyAppIcon}"; Filename: "{app}\{#MyAppIcon}"

[Run]
Filename: "{app}\安装.bat"; Description: "install MRService"; Flags: postinstall shellexec runascurrentuser

[UninstallRun]
Filename: "{app}\InstallUtil /u {app}\MRDevService.exe"; Flags: shellexec
Filename: "{app}\卸载.bat"; Flags: waituntilterminated shellexec runascurrentuser

[UninstallDelete]
;按顺序删除，以防删除后出现问题
Type: filesandordirs; Name: "{app}\log"
Type: filesandordirs; Name: "{app}\update"
Type: files; Name: "{app}\*"
Type: filesandordirs; Name: "{app}"

[Code]
#IFDEF UNICODE
  #DEFINE AW "W"
#ELSE
  #DEFINE AW "A"
#ENDIF
procedure InstallVC_redist;
var
  StatusText: string;
  ResultCode: Integer;
begin
  StatusText := WizardForm.StatusLabel.Caption;
  WizardForm.StatusLabel.Caption := '安装VC++ 2015中....';
  WizardForm.ProgressGauge.Style := npbstMarquee;
  try
    if not Exec(ExpandConstant('{tmp}\vc_redist.x64.exe'), '/q /norestart', '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
    begin
      { you can interact with the user that the installation failed }
      MsgBox('VC++ 2015 安装失败代码: ' + IntToStr(ResultCode) + '.', mbError, MB_OK);
    end;
  finally
    WizardForm.StatusLabel.Caption := StatusText;
    WizardForm.ProgressGauge.Style := npbstNormal;
  end;
end;

procedure InstallFramework;
var
  StatusText: string;
  ResultCode: Integer;
begin
  StatusText := WizardForm.StatusLabel.Caption;
  WizardForm.StatusLabel.Caption := '安装.Net Framework v4.5.2中....';
  WizardForm.ProgressGauge.Style := npbstMarquee;
  try
    if not Exec(ExpandConstant('{tmp}\NDP452-KB2901907-x86-x64-AllOS-ENU.exe'), '/q /norestart', '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
    begin
      { you can interact with the user that the installation failed }
      MsgBox('.Net Framework v4.5.2 安装失败代码: ' + IntToStr(ResultCode) + '.', mbError, MB_OK);
    end;
  finally
    WizardForm.StatusLabel.Caption := StatusText;
    WizardForm.ProgressGauge.Style := npbstNormal;
  end;
end;


type
  INSTALLSTATE = Longint;
const
  INSTALLSTATE_INVALIDARG = -2;  { An invalid parameter was passed to the function. }
  INSTALLSTATE_UNKNOWN = -1;     { The product is neither advertised or installed. }
  INSTALLSTATE_ADVERTISED = 1;   { The product is advertised but not installed. }
  INSTALLSTATE_ABSENT = 2;       { The product is installed for a different user. }
  INSTALLSTATE_DEFAULT = 5;      { The product is installed for the current user. }

  VC_2013_REDIST_X86 = '{7DAD0258-515C-3DD4-8964-BD714199E0F7}';
  VC_2013_REDIST_X64 = '{5740BD44-B58D-321A-AFC0-6D3D4556DD6C}';

  // Visual C++ 2015 Redistributable 14.0.23026
  VC_2015_REDIST_X86_MIN = '{A2563E55-3BEC-3828-8D67-E5E8B9E8B675}';
  VC_2015_REDIST_X64_MIN = '{0D3E9E15-DE7A-300B-96F1-B4AF12B96488}';

  VC_2015_REDIST_X86_ADD = '{BE960C1C-7BAD-3DE6-8B1A-2616FE532845}';
  VC_2015_REDIST_X64_ADD = '{BC958BD2-5DAC-3862-BB1A-C1BE0790438D}';

function MsiQueryProductState(szProduct: string): INSTALLSTATE;
  external 'MsiQueryProductState{#AW}@msi.dll stdcall';

function VCVersionInstalled(const ProductID: string): Boolean;
begin
  Result := MsiQueryProductState(ProductID) = INSTALLSTATE_DEFAULT;
end;

function VCRedistNeedsInstall: Boolean;
begin
  { here the Result must be True when you need to install your VCRedist }
  { or False when you don't need to, so now it's upon you how you build }
  { this statement, the following won't install your VC redist only when }
  { the Visual C++ 2010 Redist (x86) and Visual C++ 2010 SP1 Redist(x86) }
  { are installed for the current user }
  Result := not VCVersionInstalled(VC_2015_REDIST_X64_ADD)
end;
type TDotNetFramework = (
    DotNet_v11_4322,  // .NET Framework 1.1
    DotNet_v20_50727, // .NET Framework 2.0
    DotNet_v30,       // .NET Framework 3.0
    DotNet_v35,       // .NET Framework 3.5
    DotNet_v4_Client, // .NET Framework 4.0 Client Profile
    DotNet_v4_Full,   // .NET Framework 4.0 Full Installation
    DotNet_v45);      // .NET Framework 4.5

//
// Checks whether the specified .NET Framework version and service pack
// is installed (See: http://www.kynosarges.de/DotNetVersion.html)
//
// Parameters:
//   Version     - Required .NET Framework version
//   ServicePack - Required service pack level (0: None, 1: SP1, 2: SP2 etc.)
//

function IsDotNetInstalled(Version: TDotNetFramework; ServicePack: cardinal): boolean;
var
  KeyName      : string;
  Check45      : boolean;
  Success      : boolean;
  InstallFlag  : cardinal;
  ReleaseVer   : cardinal;
  ServiceCount : cardinal;
begin
  // Registry path for the requested .NET Version
  KeyName := 'SOFTWARE\Microsoft\NET Framework Setup\NDP\';

  case Version of
    DotNet_v11_4322:  KeyName := KeyName + 'v1.1.4322';
    DotNet_v20_50727: KeyName := KeyName + 'v2.0.50727';
    DotNet_v30:       KeyName := KeyName + 'v3.0';
    DotNet_v35:       KeyName := KeyName + 'v3.5';
    DotNet_v4_Client: KeyName := KeyName + 'v4\Client';
    DotNet_v4_Full:   KeyName := KeyName + 'v4\Full';
    DotNet_v45:       KeyName := KeyName + 'v4\Full';
  end;

  // .NET 3.0 uses "InstallSuccess" key in subkey Setup
  if (Version = DotNet_v30) then
    Success := RegQueryDWordValue(HKLM, KeyName + '\Setup', 'InstallSuccess', InstallFlag) else
    Success := RegQueryDWordValue(HKLM, KeyName, 'Install', InstallFlag);

  // .NET 4.0/4.5 uses "Servicing" key instead of "SP"
  if (Version = DotNet_v4_Client) or
     (Version = DotNet_v4_Full) or
     (Version = DotNet_v45) then
    Success := Success and RegQueryDWordValue(HKLM, KeyName, 'Servicing', ServiceCount) else
    Success := Success and RegQueryDWordValue(HKLM, KeyName, 'SP', ServiceCount);

  // .NET 4.5 is distinguished from .NET 4.0 by the Release key
  if (Version = DotNet_v45) then
    begin
      Success := Success and RegQueryDWordValue(HKLM, KeyName, 'Release', ReleaseVer);
      Success := Success and (ReleaseVer >= 379893);
    end;

  Result := Success and (InstallFlag = 1) and (ServiceCount >= ServicePack);
end;

function IsDotNetReallyInstalled(): Boolean; begin result := IsDotNetInstalled(DotNet_v45, 0); end;

