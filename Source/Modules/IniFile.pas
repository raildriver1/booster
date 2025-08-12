{********************************************************}
{                                                        }
{             ������: IniFile.pas                        }
{      Copyright (c) 2003 Vasily V. Altunin              }
{                                                        }
{  ��������      : �������� �������� � ����������        }
{                  �������� ������ ��� ������            }
{                  ��� ������ � INI-�������              }
{  �����������   : ������� �������                       }
{                  (skyr@users.sourceforge.net)          }
{  ������������� : 11.12.2003                            }
{  ������        : 0.02                                  }
{  ���� �������  : http://sky3d.sourceforge.net          }
{  �� ������ �������� � ������������ ��� �����������     }
{  ���� ������ ��� ������� ���������� ����� �����.       }
{  ������������ ���������� �� ������ ����� � ������      }
{  'License' � 'License_rus'.                            }
{                                                        }
{********************************************************}

unit IniFile;

interface

type

  TIniString = Array of string; //������������ ������ ��� ��������� �����


TIniKeyValue=class // ����� ��� �������� �������� key=value
  Key:String; // ����
  Value:String; // ��������

  constructor Create(DataString:String); // ����������� ������

end;


// ����� ��� �������� ���������� � ������ Ini �����
TIniSection=class
  SectionName : string; //�������� ������ ��������! �������� - ����� ��� '[' � ']'
  Items       : array of TIniKeyValue; //������ ������ � ��������
  ItemNo      : Integer; //���������� �������� � ������

  constructor Create(SectioName:String);//����������� ������

end;


{
  TiniFile

  ������� ����� � ������� ����������� ��� ���������� � Ini �����
  ��������! � ����� �� ����������� �����������, �.�. ������ ������������
  � �������� '#' � ';'
  ������ ������ ������ �� ����� �������� � ������������ � �������
  �������� ������ � ����=��������
  �������� " x=15 ;����� ���������� ���������! "
  ������ ����������� ����� ������������ � �������� ������� ������
}

TiniFile=class

  BadIniFile   : Boolean; // ���� ����������� �������� �� ���� ini-������
  IniStrNum    : Integer; // ���������� ����� Ini-�����
  IniFileName  : String; // ��� ini-�����
  SectionNum   : Integer; // ���������� ������ � Ini-�����
  IniSections  : Array of TIniSection; // ���������� ������ Ini-�����

  constructor Create(FileName : String);

  // ��������� ���������� ������ ��� Ini-����
  procedure SaveToFile;
  // ����������, �������� �� ���� - Ini-������
  function IsIniFile : boolean;
  // ���������, ��������� �� ������ Ini-�����
  function IsIniSection(SectionName : String) : boolean;
  // ���������, ��������� �� ���� ������ Ini-�����
  function IsIniSectionKey(SectionName, KeyName : String) : boolean;
  // ���������� �������� ����� � ������ Ini-�����
  function GetIniSectionKeyValue(SectionName, KeyName : String) : string;
  // �������������/������� �������� ����� � ������ Ini-�����
  function SetIniSectionKeyValue(SectionName, KeyName, Value : String) : string;
  // ������� ������ Ini-�����
  function CreateIniSection(SectionName : String) : boolean;
  // ���������� ���������� ����� Ini-�����
  function GetIniStrNum() : Integer;
  // ��������� ���������� Ini-����� � �����
  procedure ReadIniToArray();
end;

implementation

uses SysUtils;

//====================================================================

{
  ����������� ������ TIniKeyValue
  � �������� �������� �������� ������ '����=��������'
  ���������� ������� � ���������� �������� ��������
  '����' � '��������' � �������� ������ key � value
}
constructor TIniKeyValue.Create(DataString:String);
var
  I    : Integer;
  ISep : Boolean; // ���� ������������ ��� �� �������� ���� =
begin
  key:='';
  value:='';
  ISep:=False;
  for i:=1 to length(DataString) do
  begin
  if (Copy(dataString,i,1)='=') then
    ISep:=True;
  if (not ISep) then
    key:=key+Copy(dataString,i,1)
  else
    if (Copy(dataString,I,1)<>'=') then
      { ���� ����������� ����������,
        �� ������ ���������� ���������� ����������� }
      if ( (Copy(dataString,I,1)='.') or (Copy(dataString,I,1)='.') ) then
        value:=value+DecimalSeparator
      else
        value:=value+Copy(dataString,I,1);
  end;
end;

//====================================================================

{
  ����������� ������ TIniSection
  � �������� �������� �������� ������ � ��������� ������
  � ������������� �������� ������ SectionName
}
constructor TIniSection.Create(SectioName:String);
begin
  SectionName:=SectioName;
end;

//====================================================================

{
  ����������� ������ TIniFile
  � �������� �������� �������� ������ � ������ Ini-�����
}
constructor TIniFile.Create(FileName:String);
begin

IniFileName:=FileName;

BadIniFile:=False; // ��-��������� ���� "����������"

// ������������ ���������� ����� � �����, ���� �� �� ����������, ��
// ������� ������
IniStrNum:=GetIniStrNum();

if (not IsIniFile()) then // ���� ������ ����� �� �������� ���������� ����
   BadIniFile:=True;

// ���� ����� ������ ��� 0, ��� �� ������ � �� �� ��������, ��������� �� � �����
If (IniStrNum>0) then
   ReadIniToArray();

end;

//====================================================================

{
  IsIniFile
  ���������� �������� �������� �� ���� �� ������ Ini-�����
}
function TIniFile.IsIniFile:boolean;
var
  F    : TextFile;
  Buf  : String; // ����� ��� ������ �� �����
begin
    AssignFile(F,IniFileName);
    Reset(F);
    while (not eof(F)) do
    begin
      ReadLn(F,Buf);
      // ���� ������ ������ ���������� � '[' ��� ������
      // �� ���� ��������
      if ( (Copy(Buf,1,1)='[') or (Trim(Buf)='') ) then
      begin
        result:=True;
        CloseFile(F);
        exit;
      end;
      // ���� ������ ���������� �� � '#' ��� ';' �� ���� �� ��������
      if ( (Copy(Buf,1,1)<>'#') and (Copy(Buf,1,1)<>';') ) then
      begin
        result:=False;
        CloseFile(F);
        exit;
      end;
    end;
    CloseFile(F);
    result:=True; // ���� ��� ��������
end;

//====================================================================

{
  SaveToFile
  ��������� ����� ��� Ini-����
}
procedure TIniFile.SaveToFile;
var
F   : TextFile;
I,J : Integer;
begin
    AssignFile(F,IniFileName);
    Rewrite(F);
    if (IniStrNum>0) then
      for I:=0 to SectionNum-1 do
      begin
        WriteLn(F,'['+IniSections[I].SectionName+']'); // ����� ������
        for J:=0 to IniSections[I].ItemNo-1 do // � ����� ��� ����� � ��������
          WriteLn(F,IniSections[I].Items[J].Key+
                    '='+IniSections[I].Items[J].Value);
      end;
      CloseFile(F);
end;

//====================================================================

{
  IsIniSection
  ���������, ��������� �� ������ Ini-�����
}
function TiniFile.IsIniSection(SectionName : String) : boolean;
var
  I : Integer;
begin
  if (IniStrNum>0) then // ���� ���� � ����� ������
  begin
    if (SectionNum=0) then
    begin
      result:=False;
      exit;
    end;
    for I:=0 to SectionNum-1 do // ��������� �������� ������ ������
      if (UpperCase(IniSections[I].SectionName)=UpperCase(SectionName)) then
        begin
          result:=True;
          exit;
        end;
  end;
  result:=False;
end;

//====================================================================

{
  IsIniSectionKey
  ���������, ��������� �� ���� ������ Ini-�����
}

function TiniFile.IsIniSectionKey(SectionName, KeyName : String) : boolean;
var
I,J : Integer; 
begin
  if (IsIniSection(SectionName)) then
    if (IniStrNum>0) then
      for I:=0 to SectionNum-1 do
        if (IniSections[I].ItemNo>0) then
          for J:=0 to IniSections[I].ItemNo-1 do
            if (UpperCase(IniSections[I].SectionName)=UpperCase(SectionName)) then
              if (IniSections[I].Items[J].Key=KeyName) then
              begin
                result:=True;
                exit;
              end;
  result:=False;
end;

//====================================================================

{
  GetIniSectionKeyValue
  ���������� �������� ����� � ������ Ini-�����
}

function TiniFile.GetIniSectionKeyValue(SectionName, KeyName : String) : string;
var
  I,J : Integer;
begin
  if IsIniSectionKey(SectionName, KeyName) then
  begin
    for I:=0 to SectionNum do
      for J:=0 to IniSections[I].ItemNo-1 do
      begin
        if (UpperCase(IniSections[I].SectionName)=UpperCase(SectionName)) then
          if (UpperCase(IniSections[I].Items[J].Key)=UpperCase(KeyName)) then
          begin
            result:=IniSections[I].Items[J].Value;
            exit;
          end;
      end;
  end
  else
    result:='-1'; //����� -1
end;

//====================================================================

{
  SetIniSectionKeyValue
  �������������/������� �������� ����� � ������ Ini-�����
}

function TiniFile.SetIniSectionKeyValue(SectionName, KeyName, Value : String) : string;
var
  I,J : Integer;
begin
  if (IsIniSectionKey(SectionName, KeyName)) then
  begin
    for I:=0 to SectionNum do
      for J:=0 to IniSections[I].ItemNo-1 do
      begin
        if (UpperCase(IniSections[I].SectionName)=UpperCase(SectionName)) then
          if (UpperCase(IniSections[I].Items[J].Key)=UpperCase(KeyName)) then
          begin
            IniSections[I].Items[J].Value:=Value;
            result:=IniSections[I].Items[J].Value;
            exit;
          end;
      end;
  end
  else
  begin
    if (SectionNum=0) then
      CreateIniSection(SectionName)
    else
      if (not IsIniSection(SectionName)) then
        CreateIniSection(SectionName);
      for I:=0 to SectionNum-1 do
        if (UpperCase(IniSections[I].SectionName)=UpperCase(SectionName)) then
          begin
            if (Length(IniSections[I].Items)=0) then
              J:=0
            else
              J:=Length(IniSections[I].Items);
            SetLength(IniSections[I].Items,J+1);
            IniSections[I].Items[J]:=TIniKeyValue.Create(KeyName+'='+Value);
            IniSections[I].ItemNo:=IniSections[I].ItemNo+1;
          end;
  end;
end;

//====================================================================

{
  GetIniStrNum
  ���������� ���������� ����� Ini-�����
}

function TiniFile.GetIniStrNum() : Integer;
var
  strnum    : Integer;
  F         : TextFile;
  Buf       : string;
begin
    if FileExists(IniFileName) then
    begin
      AssignFile(F,IniFileName);
      reset(F);
      strnum:=0;
      while not eof(F) do
      begin
        readln(F,Buf);
        if (Trim(Buf)<>'') then
          Inc(strnum);
      end;
      closefile(F);
      result := strnum;
    end
    else
    begin
      AssignFile(F,IniFileName);
      rewrite(F);
      Closefile(F);
      result:=0;
    end;
end;


//====================================================================

{
  ReadIniToArray
  ��������� ���������� Ini-�����
}

procedure TiniFile.ReadIniToArray();
var
  F   : TextFile;
  Buf : String;
  K : Integer;
begin
    AssignFile(F,IniFileName);
    Reset(F);
    SectionNum:=0;
    K:=0;
    while (not eof(F)) do
    begin
      ReadLn(F,Buf);
      if (Trim(Buf)<>'') then
        if ((Copy(Buf,1,1)<>';') and (Copy(Buf,1,1)<>'#')) then
        begin
          if ( (Copy(Buf,1,1)='[') and (Copy(Buf,length(Buf),1)=']')) then//������� ������
          begin
            SectionNum:=SectionNum+1;
            SetLength(IniSections, Length(IniSections)+1);
            IniSections[SectionNum-1]:=TIniSection.Create(Copy(Buf,2,length(Buf)-2));
            IniStrNum:=IniStrNum+1;
            K:=0;
          end
          else
          begin
            SetLength(IniSections[SectionNum-1].Items,Length(IniSections[SectionNum-1].Items)+1);
            IniSections[SectionNum-1].Items[K]:=TIniKeyValue.Create(Buf);
            IniSections[SectionNum-1].ItemNo:=IniSections[SectionNum-1].ItemNo+1;
            IniStrNum:=IniStrNum+1;
            K:=K+1;
          end;
        end;
    end;
    closefile(F);
end;

//====================================================================

{
  CreateIniSection
  ������� ������ Ini-�����
}

function TiniFile.CreateIniSection(SectionName : String) : boolean;
begin
  if (not IsIniSection(SectionName)) then
  begin
    SetLength(IniSections, Length(IniSections)+1);
    IniSections[SectionNum]:=TIniSection.Create(SectionName);
    SectionNum:=SectionNum+1;
    IniStrNum:=IniStrNum+1;
    Result:=True;
    exit;
  end;
  Result:=False;
end;

//====================================================================

end.
