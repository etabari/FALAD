unit Utils;
interface
uses StdCtrls, ExtCtrls, CheckLst;

function CS2CS(const Text: string; Src, Dst: string): string; overload;
function CS2CS(const Ch: Char; Src, Dst: string): Char; overload;
function PW2MS(const Text: string): string;

const
  WinChars: string[50] = 'Åçéêòø¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷◊ÿŸ⁄€‹›ﬁﬂ·„‰ÂÊÏÌ';
  DBChars:  string[50] = 'ø¡¬√ƒ≈∆«»Å… ÀÃçÕŒœ–—“é”‘’÷◊ÿŸ⁄€‹›ﬁﬂòê·„‰ÊÂÏÌ';

  ShortFarsiDayNames: array[1..7] of char = ('‘', 'Ï', 'œ', '”', 'ç', 'Å', 'Ã');
  FarsiMonthNames: array[1..12] of string[12] =
    ('›—Ê—œÌ‰',
     '«—œÌ»Â‘ ',
     'Œ—œ«œ',
     ' Ì—',
     '„—œ«œ',
     '‘Â—ÌÊ—',
     '„Â—',
     '¬»«‰',
     '¬–—',
     'œÏ',
     '»Â„‰',
     '«”›‰œ');

type
  TFarsiDateTime = LongInt;

function GetToday6: string;
function GetToday6_C: string;
function Months(Y, M: integer): integer;
function Months_C(Y, M: integer): integer;
function C2I_N(AYear, AMonth, ADay: Word; N: integer): TFarsiDateTime;
function I2C_N(AYear, AMonth, ADay: Word; N: integer): TDateTime;
function C2I(Date: TDateTime): TFarsiDateTime;
function GetDateStr6(Y, M, D: Word): string;
function FDayOfWeek(Y, M, D: Word): Word;
function DateFormat(S: string; Y4: Boolean): string;
function FarsiDate: TFarsiDateTime;
function FarsiDateToStr(ADate: TFarsiDateTime; Y4: Boolean): string;
function CDateToFarsiStr(ADate: TDateTime; Y4: Boolean): string;
function EncodeFarsiDate(AYear, AMonth, ADay: Word): TFarsiDateTime;
function DecodeFarsiDate(ADate: TFarsiDateTime; var Y, M, D: Word): Boolean; overload;
function DecodeFarsiDate(ADate: string; var Y, M, D: Word): Boolean; overload;
function StrToCDate(DateStr: string): TDateTime;
function CompareDate(CDate1, CDate2: TDateTime): Integer; overload;
function CompareDate(CDate1: TDateTime; Date2: string): Integer; overload;
function CompareRange(ACDate: TDateTime; Date1, Date2: string): Boolean;
function RemSep(DateStr: string): string;
function GetHYearOf(ADate: TDateTime): Integer;
function GetHMonthOf(ADate: TDateTime): Integer;

function StrToLong(S: string): LongInt;
procedure SwapInt(var Int1, Int2: integer);
function FillRight(Str: string; Ch: Char; Len: Word): string;
function FillLeft(Str: string; Ch: Char; Len: Word): string;

function Reverse(Str: string): string;
procedure StrReverse(Str: PChar);
function Dup(Ch: Char; Len: integer): string;

function IsFarsiAlpha(Ch: Char): Boolean;
function CorrectFarsi(Str: string): string;
function GetToken(const Del, Line: string; var T: shortstring; var Loc: Integer): Boolean;
function GetFontPt(Size: Integer): Integer;
function PackNum(NumStr: string): string;

function PanizToMS(Ch: Char): string;
function PanizStringToMS(Str: string): string;

function OnlyNumeric(Str: string): string;
function IncStr(Str: string): string;
function NumToText(R: Double): string;
function TranslateKeYe(Key: Char; PrevKey: Word): Char;
procedure BestFit(Image: TImage; W, H: Integer);
function FloatFormat(Num: Double): string;

procedure SetCheckListValue(CheckList: TCheckListBox; Value: Integer);
function GetCheckListValue(CheckList: TCheckListBox): Integer;

function GetBuildNumber(FileName: string): Integer;
function GetFileVersion(FileName: string): string;

var
  SWC: Integer = 0;

implementation

uses Windows, SysUtils, Controls, Graphics;


function GetBuildNumber(FileName: string): Integer;
var
  Sz, DW: Cardinal;
  P: array[0..200] of char;
  Buf: Pointer;
  VB: Pointer;
  VSz: Cardinal;
begin
  Result := 0;
  StrPCopy(P, FileName);
  Sz :=  GetFileVersionInfoSize(P, DW);
  if Sz>0 then
  begin
    VSz := SizeOf(VS_FIXEDFILEINFO);
    Buf := AllocMem(Sz);
    try
      if GetFileVersionInfo(P, 0, Sz, Buf) then
      begin
        if VerQueryValue(Buf, '\', VB, VSz) then
          Result := VS_FIXEDFILEINFO(VB^).dwFileVersionLS
      end;
    finally
      FreeMem(Buf);
    end;
  end;
end;

function GetFileVersion(FileName: string): string;
var
  Sz, DW: Cardinal;
  P: array[0..200] of char;
  Buf: Pointer;
  VB: Pointer;
  VSz: Cardinal;
begin
  Result := '';
  StrPCopy(P, FileName);
  Sz :=  GetFileVersionInfoSize(P, DW);
  if Sz>0 then
  begin
    VSz := SizeOf(VS_FIXEDFILEINFO);
    Buf := AllocMem(Sz);
    try
      if GetFileVersionInfo(P, 0, Sz, Buf) then
      begin
        if VerQueryValue(Buf, '\', VB, VSz) then
          Result :=
            IntToStr(VS_FIXEDFILEINFO(VB^).dwFileVersionMS shr 16)+'.'+IntToStr(VS_FIXEDFILEINFO(VB^).dwFileVersionMS and $00FF)+'.'+
            IntToStr(VS_FIXEDFILEINFO(VB^).dwFileVersionLS shr 16)+'.'+IntToStr(VS_FIXEDFILEINFO(VB^).dwFileVersionLS and $00FF);
      end;
    finally
      FreeMem(Buf);
    end;
  end;
end;

function FloatFormat(Num: Double): string;
begin
  Result := FormatFloat('###,###,###,###,###', Abs(Num));
  if Num<0 then Result := Result + '-';
end;

function TranslateKeYe(Key: Char; PrevKey: Word): Char;
begin
  Result := Key;
  case Key of
    'í', 'ˆ':if PrevKey=68 then Result := 'Ï';
    'ò': if PrevKey=186 then Result := 'ﬂ';
  end;
end;

procedure BestFit(Image: TImage; W, H: Integer);
var
  Ratio: Real;
begin
  if not Assigned(Image.Picture) then Exit;
  if (Image.Picture.Width<=W) and (Image.Picture.Height<=H) then Exit;
  Ratio := W/H;
  if Image.Picture.Width / Image.Picture.Height>Ratio then
  begin
    Image.Width := W;
    Image.Height := Trunc(Image.Picture.Height*W/Image.Picture.Width);
  end else
  begin
    Image.Height := H;
    Image.Width := Trunc(Image.Picture.Width*H/Image.Picture.Height);
  end;
end;

function GetFontPt(Size: Integer): Integer;
begin
  case Size of
    1: Result := 8;
    2: Result := 10;
    3: Result := 12;
    4: Result := 14;
    5: Result := 18;
    6: Result := 24;
    7: Result := 36;
    else Result := 10;
  end;
end;

function CorrectFarsi(Str: string): string;
var
  i: integer;
begin
  for i:=1 to Length(Str) do
  begin
    if (Str[i]='Ì') and ( (i=Length(Str)) or
       (Pos(Str[i+1], WinChars)=0)) then
      Str[i] := #236; 
  end;
  Result := Str;
end;

function CS2CS(const Text: string; Src, Dst: string): string;
var
  i, p: integer;
begin
  SetLength(Result, Length(Text));
  for i:=1 to Length(Text) do
  begin
    p := Pos(Text[i], Src);
    if p>0 then Result[i] := Dst[p]
    else Result[i] := Text[i];
  end
end;

function CS2CS(const Ch: Char; Src, Dst: string): Char;
var
  p: integer;
begin
  p := Pos(Ch, Src);
  if p>0 then Result := Dst[p]
  else Result := Ch;
end;

function PW2MS(const Text: string): string;
var
  i, j: Integer;
begin
  Result := ''; j := 1;
  SetLength(Result, Length(Text));
  for i:=1 to Length(Text) do
  begin
    case Text[i] of
      #32..#127:
        case Text[i] of
          '(': Result[j] := ')';
          ')': Result[j] := '(' ;
          else Result[j] := Text[i];
        end;
      #129: Result[j] := #161;
      #131: Result[j] := #191;
      #132: Result[j] := #220;
      #133: Result[j] := #194;
      #134,#135: Result[j] := #199;
      #136: Result[j] := #195;
      #137,#138: Result[j] := #198;
      #139: Result[j] := #193;
      #140..#143: Result[j] := #200;
      #148..#151: Result[j] := #202;
      #152..#155: Result[j] := #203;
      #156..#159: Result[j] := #204;
      #160..#163: Result[j] := #141;
      #164..#167: Result[j] := #205;
      #168..#171: Result[j] := #206;
      #172..#173: Result[j] := #207;
      #174..#175: Result[j] := #208;
      #176..#177: Result[j] := #209;
      #178..#179: Result[j] := #210;
      #180..#181: Result[j] := #142;
      #182..#185: Result[j] := #211;
      #186..#189: Result[j] := #212;
      #190..#193: Result[j] := #213;
      #194..#197: Result[j] := #214;
      #198..#201: Result[j] := #216;
      #202..#205: Result[j] := #217;
      #206..#209: Result[j] := #218;
      #210..#213: Result[j] := #219;
      #214..#217: Result[j] := #221;
      #218..#221: Result[j] := #222;
      #222..#225: Result[j] := #223;
      #226..#229: Result[j] := #144;
      #230..#231:
        begin
          SetLength(Result, Length(Result)+1);
          Result[j] := #225; Inc(j); Result[j] := #199;
        end;
      #232..#235: Result[j] := #225;
      #236..#239: Result[j] := #227;
      #240..#243: Result[j] := #228;
      #244..#245: Result[j] := #230;
      #246..#247: Result[j] := #196;
      #248..#251: Result[j] := #229;
      #252..#253: Result[j] := #237;
      #254..#255: Result[j] := #236;
      else Result[j] := #32;
    end;
    Inc(j);
  end;
end;

{========================================}
{     Farsi Date and Time                }
{========================================}
function StrToCDate(DateStr: string): TDateTime;
var
  Y, M, D: Word;
begin
  if DecodeFarsiDate(DateStr, Y, M, D) then
    Result := I2C_N(Y, M, D, 0)
  else Result := 0;
end;

function FarsiDateToStr(ADate: TFarsiDateTime; Y4: Boolean): string;
var
  Y, M, D: Word;
begin
  DecodeFarsiDate(ADate, Y, M, D);
  if not Y4 then Y := Y mod 100;
  Result := GetDateStr6(Y, M, D);
  Insert('/', Result, 5);
  Insert('/', Result, 3);
end;

function CDateToFarsiStr(ADate: TDateTime; Y4: Boolean): string;
var
  Y, M, D: Word;
  FDate: TFarsiDateTime;
begin
  DecodeDate(ADate, Y, M, D);
  if (ADate=0) or (Y=1) then Result := ''
  else
  begin
    FDate := C2I_N(Y, M, D, 0);
    DecodeFarsiDate(FDate, Y, M, D);
    if Y4 then
      if Y<100 then Y := Y + 1300
      else
    else if Y>=100 then Y := Y mod 100;
    Result := DateFormat(GetDateStr6(Y, M, D), Y4);
  end;
end;

function CompareDate(CDate1, CDate2: TDateTime): Integer; overload;
begin
  if CDate1>CDate2 then Result := 1
  else if CDate1<CDate2 then Result := -1
  else Result := 0;
end;

function CompareDate(CDate1: TDateTime; Date2: string): Integer; overload;
var
  CDate2: TDateTime;
begin
  CDate2 := StrToCDate(Date2);
  if CDate1>CDate2 then Result := 1
  else if CDate1<CDate2 then Result := -1
  else Result := 0;
end;

function CompareRange(ACDate: TDateTime; Date1, Date2: string): Boolean;
begin
  Result := ((RemSep(Date1)='') or (CompareDate(ACDate, Date1)>=0)) and ((RemSep(Date2)='') or (CompareDate(ACDate, Date2)<=0))
end;

function FarsiDate: TFarsiDateTime;
var
  Y, M, D: Word;
begin
  DecodeDate(Date, Y, M, D);
  Result := C2I_N(Y, M, D, 0);
end;

function EncodeFarsiDate(AYear, AMonth, ADay: Word): TFarsiDateTime;
var
  i, j: Integer;
begin
  Result := 0;
  if AYear>=1 then
  begin
    for i:=1 to AYear-1 do
      for j:=1 to 12 do Result := Result+Months(i, j);
    for i:=1 to AMonth-1 do Result := Result+Months(AYear, i);
    Result := Result+ADay;
  end;
end;

function DecodeFarsiDate(ADate: string; var Y, M, D: Word): Boolean;
var
  i: Integer;
begin
  for i:=Length(ADate) downto 1 do if not (ADate[i] in ['0'..'9']) then
    Delete(ADate, i, 1);
  if Length(ADate)=6 then
  begin
    Y := StrToInt(Copy(ADate, 1, 2));
    M := StrToInt(Copy(ADate, 3, 2));
    D := StrToInt(Copy(ADate, 5, 2));
    Result := True;
  end else Result := False;
end;

function RemSep(DateStr: string): string;
var
  i: Integer;
begin
  for i:=Length(DateStr) downto 1 do if not (DateStr[i] in ['0'..'9']) then
    Delete(DateStr, i, 1);
  Result := DateStr;
end;

function DecodeFarsiDate(ADate: TFarsiDateTime; var Y, M, D: Word): Boolean;
var
  i: Integer;
begin
  Y := 1; i := 1; D := 1;
  while ADate>Months(Y, i) do
  begin
    for i:=1 to 12 do
    begin
      if ADate>Months(Y, i) then
        ADate := ADate - Months(Y, i)
      else break;
    end;
    if i>12 then
    begin
      Inc(Y);
      i := 1;
    end;
  end;
  M := i;
  D := Round(ADate);
  Result := True;
end;

function FDayOfWeek(Y, M, D: Word): Word;
var
  Dc: TDateTime;
begin
  Dc := I2C_N(Y, M, D, 0);
  Result := DayOfWeek(Dc);
  if Result=7 then Result := 1 else Result := Result+1;
end;

function GetDateStr6(Y, M, D: Word): string;
begin
  Result := IntToStr(Y mod 100);
  if Length(Result)=1 then Result := '0'+Result;
  Result := Result+IntToStr(M);
  if Length(Result)=3 then Insert('0', Result, 3);
  Result := Result+IntToStr(D);
  if Length(Result)=5 then Insert('0', Result, 5);
end;

function Months;
begin
  if M=0 then
  begin
    M := 12;
    Y := Y-1;
  end;
  case M of
    1..6: Months := 31;
    12: if (((Y Mod 4)=2) and (Y<1374)) or (((Y Mod 4)=3) and (Y>=1374)) then
          Months := 30
        else Months := 29;
    else Months := 30;
  end;
end;

function Months_C;
begin
  case M of
    1, 3, 5, 7, 8, 10, 12: Months_C := 31;
    2: if Y mod 4 = 0 then Months_C := 29 else Months_C := 28;
    else Months_C := 30;
  end;
end;

function GetToday6: string;
var
  Date_I: TFarsiDateTime;
  Date_C: TDateTime;
  AYear, AMonth, ADay: Word;
begin
  Date_C := Now;
  DecodeDate(Date_C, AYear, AMonth, ADay);
  Date_I := C2I_N(AYear, AMonth, ADay, 0);
  DecodeFarsiDate(Date_I, AYear, AMonth, ADay);
  Result := GetDateStr6(AYear, AMonth, ADay);
end;

function GetToday6_C: string;
var
  Date1: TDate;
  AYear, AMonth, ADay: Word;
begin
  Date1 := Now;
  DecodeDate(Date1, AYear, AMonth, ADay);
  Result := GetDateStr6(AYear, AMonth, ADay);
end;

function C2I_N;
var
  Yd, M: Integer;
begin
   Yd := ADay+N;
   M := AMonth;
   for M:=1 to M-1 do  Yd := Yd + Months_C(AYear, M);

   AYear := AYear-621;
   Dec(Yd, Months(AYear-1, 12)+Months(AYear-1, 11)+20);
   if Months(AYear-1, 12)=30 then Inc(Yd);

   if (Yd>0) then
   begin
      AMonth := 1;
      while Yd>Months(AMonth, AMonth) do
      begin
        Dec(Yd, Months(AYear, AMonth));
        Inc(AMonth);
      end;
      ADay := Yd;
   end else if (Yd<=0) then
   begin
     Dec(AYear);
     AMonth := 12;
     while -Yd>=Months(AYear, AMonth) do
     begin
       Inc(Yd, Months(AYear, AMonth));
       Dec(AMonth);
     end;
     ADay := Months(AYear, AMonth)+Yd;
   end;
   Result := EncodeFarsiDate(AYear, AMonth, ADay);
end;

function C2I(Date: TDateTime): TFarsiDateTime;
var
  Y, M, D: Word;
begin
  DecodeDate(Date, Y, M, D);
  Result := C2I_N(Y, M, D, 0);
end;

function I2C_N;
var
  Yd, M: Integer;
begin
   Yd := ADay+N;
   M := AMonth;
   for M:=1 to M-1 do Yd := Yd + Months(AYear, M);

   if AYear<1000 then AYear := AYear+1300;
   AYear := AYear+621;
   Inc(Yd, Months_C(AYear-1, 12)+Months_C(AYear-1, 11)+18);

   if (Yd>0) then
   begin
      AMonth := 1;
      while Yd>Months_C(AYear, AMonth) do
      begin
        Dec(Yd, Months_C(AYear, AMonth));
        if AMonth<12 then Inc(AMonth)
        else
        begin
          Inc(AYear);
          AMonth := 1;
        end
      end;
      ADay := Yd;
   end else if (Yd<=0) then
   begin
     Dec(AYear);
     AMonth := 12;
     while -Yd>=Months_C(AYear, AMonth) do
     begin
       Inc(Yd, Months_C(AYear, AMonth));
       Dec(AMonth);
     end;
     ADay := Months_C(AYear, AMonth)+Yd;
   end;
   Result := EncodeDate(AYear, AMonth, ADay);
end;

function DateFormat(S: string; Y4: Boolean): string;
var
  Y: integer;
begin
  if Y4 then
  begin
    if Length(S)=6 then S := '13'+S;
    Y := 4;
  end else Y := 2;

  if Length(S)>Y+2 then Insert('/', S, Y+3);
  if Length(S)>Y then Insert('/', S, Y+1);
  DateFormat := S;
end;

function GetHYearOf(ADate: TDateTime): Integer;
var
  HDate: TFarsiDateTime;
  y, m, d: Word;
begin
  HDate := C2I(ADate);
  DecodeFarsiDate(HDate, y, m, d);
  Result := y;
end;

function GetHMonthOf(ADate: TDateTime): Integer;
var
  HDate: TFarsiDateTime;
  y, m, d: Word;
begin
  HDate := C2I(ADate);
  DecodeFarsiDate(HDate, y, m, d);
  Result := m;
end;

function StrToLong(S: string): LongInt;
var
  D: LongInt;
  I: Integer;
begin
  Val(S, D, I);
  StrToLong := D;
end;

function FillRight;
begin
  while Length(Str)<Len do Str := Str+Ch;
  Result := Str;
end;

function FillLeft;
begin
  while Length(Str)<Len do Str := Ch+Str;
  Result := Str;
end;

procedure SwapInt;
var
  I: integer;
begin
  I := Int1;
  Int1 := Int2;
  Int2 := I;
end;

function IncChar(var Ch: Char): Byte;
begin
  Result := 0;
  Inc(Ch);
  if Ch=Succ('9') then
  begin
    Result := 1;
    Ch := '0';
  end;
end;

function OnlyNumeric(Str: string): string;
var
  i: Integer;
begin
  if Str<>'' then
  for i:=Length(Str) downto 1 do
    if not(Str[i] in ['0'..'9']) then Delete(Str, i, 1);
  Result := Str;
end;

function IncStr(Str: string): string;
var
  Cary, i: Integer;
begin
  if Str<>'' then for i:=Length(Str) downto 1 do
  begin
    if Str[i]='9' then
    begin
      Str[i] := '0';
      Cary := 1;
    end else
    begin
      Str[i] := Succ(Str[i]);
      Cary := 0;
    end;
    if Cary=0 then break;
  end;
  Result := Str;
end;

function Reverse;
var
  i, l: integer;
  Rev: string;
begin
  l := Length(Str);
  SetLength(Rev, l);
  for i:=l downto 1 do Rev[i] := Str[l-i+1];
  Reverse := Rev
end;

procedure StrReverse(Str: PChar);
var
  i, l: integer;
  Rev: PChar;
begin
  l := StrLen(Str);
  Rev := StrNew(Str);
  for i:=l-1 downto 0 do Rev[i] := Str[l-i-1];
  Rev[l] := #0;
  StrCopy(Str, Rev);
end;

function Dup;
var
  Str: string;
  i: integer;
begin
  SetLength(Str, Len);
  for i:=1 to Len do Str[i] := Ch;
  Dup := Str
end;

function IsFarsiAlpha(Ch: Char): Boolean;
begin
  IsFarsiAlpha := Pos(Ch, WinChars)>0
end;

function PackNum(NumStr: string): string;
var
  i: Integer;
begin
  for i:=Length(NumStr) downto 1 do
    if not (NumStr[i] in ['0'..'9', '.']) then
      Delete(NumStr, i, 1);
  Result := NumStr;
end;

function GetToken(const Del, Line: string; var T: shortstring; var Loc: Integer): Boolean;
var
  i: Integer;
begin
  T := '';
  i := Loc;
  GetToken := False;
  while (i<=Length(Line)) and (Line[i]=' ') do Inc(i);
  if (i<=Length(Line)) then
  begin
    Loc := i;
    if IsDelimiter(Del, Line, i) then
    begin
      Inc(i);
      T := Copy(Line, Loc, i-Loc);
      GetToken := True;
    end else
    begin
      while (i<=Length(Line)) and not IsDelimiter(Del, Line, i) do Inc(i);
      T := Copy(Line, Loc, i-Loc);
      GetToken := True;
    end;
    Loc := i;
  end;
end;

function NumToText(R: Double): string;
const
  OneToTwentyName : array [ 0..19 ] of string[ 6 ] =

('',
'Ìﬂ',
'œÊ',
'”Â',
'çÂ«—',
'Å‰Ã',
'‘‘',
'Â› ',
'Â‘ ',
'‰Â',
'œÂ',
'Ì«“œÂ',
'œÊ«“œÂ',
'”Ì“œÂ',
'çÂ«—œÂ',
'Å«‰“œÂ',
'‘«‰“œÂ',
'Â›œÂ',
'ÂÃœÂ',
'‰Ê“œÂ');


  DecadeToHundred : array [ 0..9 ] of string [ 6 ] = ('',
  'œÂ', '»Ì” ', '”Ï', 'çÂ·', 'Å‰Ã«Â', '‘’ ', 'Â› «œ', 'Â‘ «œ', '‰Êœ');


  HundredToTousend: array [ 0..9 ] of string [ 7 ] = ('',
  '’œ', 'œÊÌ” ','”Ì’œ','çÂ«—’œ','Å«‰’œ','‘‘’œ','Â› ’œ','Â‘ ’œ','‰Â’œ');


  Units           : array [ 1..5 ] of string [ 8 ] = ('',
	'Â“«—', '„Ì·ÌÊ‰',  '„Ì·Ì«—œ', ' —Ì·ÌÊ‰');

var
  Remain, TempR: double;
  Temp: Integer;
  Base: integer;
  S: string;
  Neg: Boolean;

function GetFarsiSentence(N : integer; Base : integer) : string ;
var
  S : string ;
  NoOfHundred,
  NoOfTen    : integer ;
begin
  S := '' ;
  NoOfHundred := N div 100 ;

  N := N - NoOfHundred * 100 ;
  if (N > 0) and (NoOfHundred > 0 ) then
    S := HundredToTousend[NoOfHundred] + ' Ê ' + S
  else
    S := HundredToTousend[NoOfHundred] + ' '+S;
  if N >= 20 then
    begin
      NoOfTen := N Div 10 ;
      N := N - NoOfTen * 10 ;
      if (N > 0) and (NoOfTen > 0)  then
        S := S+''+DecadeToHundred[NoOfTen]+' Ê '
      else
        S := S+' '+DecadeToHundred[NoOfTen];
      S := S+' '+OneToTwentyName[N];
    end
  else
    S :=  S + '' + OneToTwentyName[N];
  Result :=   S + ' '+Units[Base] +  ' Ê ';
end;

begin
  Base := 1 ;
  if R<0 then
  begin
    Neg := True;
    R := -R;
  end else Neg := False;
  TempR := R;
  S := '' ;
  while R > 0 do
  begin
    Remain := Int(R / 1000);
    Temp := Round(R - Remain * 1000);
    if Temp > 0 then
    begin
      S := GetFarsiSentence(Temp, Base)+''+S;
    end;
    R := Remain;
    Inc(Base);
  end;
  if TempR>0 then Delete(S, Length(S)-2, 3);
  if Neg then S := S+' „‰Â«Ï ';
  Result := S;
end;

function PanizToMS(Ch: Char): string;
begin
  case Ch of
    #140: Result := 'ø';
    #141: Result := '°';
    #142: Result := ' ';
    #143: Result := ' ';
    #144: Result := '‹';
    #145: Result := '¬';
    #146: Result := '«';
    #147: Result := '«';
    #148: Result := '∆';
    #149: Result := '¡';

    #150: Result := '»';
    #151: Result := 'Å';
    #152: Result := ' ';
    #153: Result := 'À';
    #154: Result := 'Ã';
    #155: Result := ' Ã';
    #156: Result := 'ç';
    #157: Result := ' ç';
    #158: Result := 'Õ';
    #159: Result := ' Õ';

    #160: Result := 'Œ';
    #161: Result := ' Œ';
    #162: Result := 'œ';
    #163: Result := '–';
    #164: Result := '—';
    #165: Result := '“';
    #166: Result := 'é';
    #167: Result := '”';
    #168: Result := '”';
    #169: Result := '‘';

    #170: Result := '‘';
    #171: Result := '’';
    #172: Result := '’';
    #173: Result := '÷';
    #174: Result := '÷';
    #175: Result := 'ÿ';

    #224: Result := 'Ÿ';
    #225: Result := '⁄';
    #226: Result := '⁄';
    #227: Result := ' ⁄';
    #228: Result := ' ⁄';
    #229: Result := '€';

    #230: Result := '€';
    #231: Result := '€';
    #232: Result := '€';
    #233: Result := '›';
    #234: Result := 'ﬁ';
    #235: Result := ' ﬁ';
    #236: Result := 'ﬂ';
    #237: Result := 'ê';
    #238: Result := '«·';
    #239: Result := '·';

    #240: Result := ' ·';
    #241: Result := '„';
    #242: Result := ' „';
    #243: Result := '‰';
    #244: Result := ' ‰';
    #245: Result := 'Ê';
    #246: Result := 'ƒ';
    #247: Result := 'Â';
    #248: Result := 'Â';
    #249: Result := ' Â';

    #250: Result := ' Â';
    #251: Result := 'Ì';
    #252: Result := 'Ï';
    #253: Result := '';
    #254: Result := 'Ï';
    '(':  Result := ')';
    ')':  Result := '(';
    else Result := Ch;
  end;
end;

function PanizStringToMS(Str: string): string;
var
  i: Integer;
begin
  Result := '';
  for i:=1 to Length(Str) do
  begin
    Result := Result + PanizToMS(Str[i]);
  end;
end;

procedure SetCheckListValue(CheckList: TCheckListBox; Value: Integer);
var
  i, m: Integer;
begin
  m := 1;
  for i:=0 to CheckList.Items.Count-1 do if not CheckList.Header[i] then
  begin
    if Value and m <> 0 then CheckList.State[i] := cbChecked
    else CheckList.State[i] := cbUnchecked;
    m := m shl 1;
  end;
end;

function GetCheckListValue(CheckList: TCheckListBox): Integer;
var
  i, m: Integer;
begin
  m := 1;
  Result := 0;
  for i:=0 to CheckList.Items.Count-1 do if not CheckList.Header[i] then
  begin
    if CheckList.State[i]=cbChecked then Result := Result or m;
    m := m shl 1;
  end;
end;

end.











