unit CalendarView;

interface
uses DBCtrls, Types, Classes, Controls, Graphics, Forms, Messages, Utils;

const
  ShorDayNames = ['‘', 'Ï', 'œ', '”', 'ç', 'Å', 'Ã'];

type
 // TDateChangeEvent = procedure(Y, M, D: Word) of object;
  TGetDayStateEvent = procedure(Y, M, D: Word) of object;

  TDayStyle = record
     d: TDateTime;
     fcolor: TColor;
     bcolor: TColor;
  end;

  TCalendarView = class(TCustomControl)
  private
    FSelYear: Integer;
    FSelMonth: Integer;
    FSelDay: Integer;
    FFirstDow: Word;
    FCellW, FCellH: Word;
    FOnDay: integer;
    FFTopYear: word;
    FFTopMonth: word;

    FDayStyles: TList;
    FDayMarks: TList;

    FTodayColor: TColor;
    FTodayBackColor: TColor;
    FSelectColor: TColor;
    FSelectBackColor: TColor;
    FFridayColor: TColor;
    FWeekTitleColor: TColor;
    FWeekBackColor: TColor;
    FPriorMonthColor: TColor;
    FSpringColor: TColor;
    FSpringBackColor: TColor;
    FSummerColor: TColor;
    FSummerBackColor: TColor;
    FAtumnColor: TColor;
    FAtumnBackColor: TColor;
    FWinterColor: TColor;
    FWinterBackColor: TColor;
    FUnSelectColor: TColor;
    FUnSelectBackColor: TColor;
    FMouseOnColor: TColor;

    FOnChange: TNotifyEvent;
    FLockTopDate: boolean;
    FTopDate: TDateTime;
    FFocusOnClick: boolean;

    procedure GotoNow;
    procedure GotoDate(Y, M, D: Integer);

    procedure SetYear(Value: Integer);
    procedure SetMonth(Value: Integer);
    procedure SetDay(Value: Integer);
    procedure SetDayDo(Value: Integer);
    procedure SetMonthDo(Value: Integer);

    function CellRect(Sect: Integer; Day: Word): TRect;
    function DayOfCell(X, Y: Word): Integer;
    procedure PaintHeader;
    procedure PaintWeekHeader;
    procedure PaintPriorMonthDays;
    procedure PaintMonthDays;
    procedure PaintButtons;
    procedure PaintCell(R: TRect; S: string; Marked: TColor);

    procedure SetTodayColor(Value: TColor);
    procedure SetTodayBackColor(Value: TColor);
    procedure SetSelectColor(Value: TColor);
    procedure SetSelectBackColor(Value: TColor);
    procedure SetWeekTitleColor(Value: TColor);
    procedure SetWeekBackColor(Value: TColor);
    procedure SetFridayColor(Value: TColor);
    procedure SetPriorMonthColor(Value: TColor);
    procedure SetSpringColor(Value: TColor);
    procedure SetSpringBackColor(Value: TColor);
    procedure SetAtumnColor(Value: TColor);
    procedure SetAtumnBackColor(Value: TColor);
    procedure SetSummerColor(Value: TColor);
    procedure SetSummerBackColor(Value: TColor);
    procedure SetWinterColor(Value: TColor);
    procedure SetWinterBackColor(Value: TColor);
    procedure SetUnSelectColor(Value: TColor);
    procedure SetUnSelectBackColor(Value: TColor);
    procedure SetMouseOnColor(Value: TColor);

    function TitleColor: TColor;
    function TitlebackColor: TColor;

    function GetCDate: TDateTime;
    procedure SetCDate(Value: TDateTime);
    function GetFDate: TFarsiDateTime;
    procedure SetFDate(Value: TFarsiDateTime);

    function DayColor(fy, fm, fd: word; IsFont: Boolean): TColor;
    function Marked(fy, fm, fd: word): TColor;

    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure SetLockToDate(const Value: boolean);
    procedure SetTopDate(const Value: TDateTime);

    function TopYear: word;
    function TopMonth: word;


  protected
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Resize; override;
    procedure SetFocuse(var Msg: TMessage); message WM_SETFOCUS;
    procedure KillFocuse(var Msg: TMessage); message WM_KILLFOCUS;
    procedure WM_GetDlgCode(var Msg: TMessage); message WM_GETDLGCODE;
    procedure SetDayColor(ADate: TDateTime; FontColor, BgColor: TColor);
    procedure ClearDayColor();
    procedure SetDayMark(ADay: TDateTime; AColor: TColor);
    procedure ClearDayMarks();
  published
    property Anchors;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BiDiMode;
    property Enabled;
    property Color;
    property Font;
    property TabStop;
    property TabOrder;
    property Align;

    property LockTopDate: boolean read FLockTopDate write SetLockToDate;
    property TopDate: TDateTime read FTopDate write SetTopDate;
    property CDate: TDateTime read GetCDate write SetCDate;
    property HDate: TFarsiDateTime read GetFDate write SetFDate;
    property SelYear: Integer read FSelYear write SetYear;
    property SelMonth: Integer read FSelMonth write SetMonth;
    property SelDay: Integer read FSelDay write SetDay;

    property FocusOnClick:boolean read FFocusOnClick write FFocusOnClick;

    property TodayColor: TColor read FTodayColor write SetTodayColor;
    property TodayBackColor: TColor read FTodayBackColor write SetTodayBackColor;
    property SelectColor: TColor read FSelectColor write SetSelectColor;
    property SelectBackColor: TColor read FSelectBackColor write SetSelectBackColor;
    property FridayColor: TColor read FFridayColor write SetFridayColor;
    property WeekTitleColor: TColor read FWeekTitleColor write SetWeekTitleColor;
    property WeekBackColor: TColor read FWeekBackColor write SetWeekBackColor;
    property PriorMonthColor: TColor read FPriorMonthColor write SetPriorMonthColor;
    property SpringColor: TColor read FSpringColor write SetSpringColor;
    property SpringBackColor: TColor read FSpringBackColor write SetSpringBackColor;
    property SummerColor: TColor read FSummerColor write SetSummerColor;
    property SummerBackColor: TColor read FSummerBackColor write SetSummerBackColor;
    property AtumnColor: TColor read FAtumnColor write SetAtumnColor;
    property AtumnBackColor: TColor read FAtumnBackColor write SetAtumnBackColor;
    property WinterColor: TColor read FWinterColor write SetWinterColor;
    property WinterBackColor: TColor read FWinterBackColor write SetWinterBackColor;
    property UnSelectColor: TColor read FUnSelectColor write SetUnSelectColor;
    property UnSelectBackColor: TColor read FUnSelectBackColor write SetUnSelectBackColor;
    property MouseOnColor: TColor read FMouseOnColor write SetMouseOnColor;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
  end;


function SelectDate(var Date: TDateTime; const DlgCaption: TCaption; Font: TFont; X, Y: Integer): Boolean;
function SelectDateToField(F: TDBEdit): Boolean;

procedure Register;

implementation

uses Windows, Math, SysUtils, ExtCtrls, FDialogs, Dialogs;

{ TCalendarView }

constructor TCalendarView.Create(AOwner: TComponent);
var
  D1: TFarsiDateTime;
  Y, M, D: Word;
begin
  inherited;

  BiDiMode := bdRightToLeft;
  DecodeDate(Date, Y, M, D);
  D1 := C2I_N(Y, M, D, 0);
  DecodeFarsiDate(D1, Y, M, D);
  Canvas.Font := Font;
  FDayStyles := TList.Create;
  FDayMarks := TList.Create;
  Width := 180;
  Height := 180;
  TabStop := True;
  BevelKind := bkSoft;
  Color := clWhite;
  FFocusOnClick := true;

  FSelYear := Y;
  FSelMonth := M;
  FSelDay := 1;
//  TopDate := CDate;
  FFirstDow := FDayOfWeek(TopYear, TopMonth, 1);
  FOnDay := 0;
  FLockTopDate := false;

  FTodayColor := clWhite;
  FTodayBackColor := $00FF8000;
  FSelectColor := clNavy;
  FSelectBackColor := $00F8F9F7;
  FWeekTitleColor := clBlue;
  FWeekBackColor := clSilver;
  FFridayColor := clRed;
  FPriorMonthColor := clSilver;
  FSpringColor := clWhite;
  FSpringBackColor := clGreen;
  FSummerColor := clLime;
  FSummerBackColor := clGreen div 2;
  FAtumnColor := clBlack;
  FAtumnBackColor := clYellow;
  FWinterColor := clWhite;
  FWinterBackColor := clBlue;
  FUnSelectColor := clSilver;
  FUnSelectBackColor := clGray;
  FMouseOnColor := clRed;



end;

destructor TCalendarView.Destroy;
begin
  ClearDayColor;
  FDayMarks.Free;
  FDayStyles.Free;
  inherited;
end;

procedure TCalendarView.CMFontChanged(var Message: TMessage);
begin
  Canvas.Font := Font;
  FCellW := Canvas.TextWidth('3Ÿ3');
  FCellH := Canvas.TextHeight('êŒ');
  Width := FCellW*7+12;
  Height := FCellH*8+14;
end;

procedure TCalendarView.Resize;
begin
  Canvas.Font := Font;
  FCellW := Canvas.TextWidth('3Ÿ3');
  FCellH := Canvas.TextHeight('êŒ');
  Width := FCellW*7+12;
  Height := FCellH*8+14;
end;

procedure TCalendarView.SetFocuse(var Msg: TMessage);
begin
  PaintHeader;
end;

procedure TCalendarView.KillFocuse(var Msg: TMessage);
begin
  PaintHeader;
end;

procedure TCalendarView.Paint;
begin

  if Font.Name = 'MS Sans Serif' then
    Font.Name := 'Microsoft Sans Serif';

//  if Font.Size<12 then
//    Font.Size := 12;


  Canvas.Lock;
  Canvas.Font := Font;
  Canvas.Brush.Color := Color;
  Canvas.FillRect(GetClientRect);
  PaintHeader;
  PaintWeekHeader;
  PaintPriorMonthDays;
  PaintMonthDays;
  Canvas.Unlock;
end;

procedure TCalendarView.PaintCell(R: TRect; S: string; Marked: TColor);
var
  P, W: Integer;
  c: TColor;
begin
  W := R.Right-R.Left;
  P := W-Canvas.TextWidth(S);
  if Odd(P) then Inc(P);
  if P>0 then P := P div 2 else P := 0;
  Canvas.TextRect(R, R.Left+P, R.Top, S);
  if Marked<>clNone then
  begin
    c := Canvas.Brush.Color;
    Canvas.Brush.Color := Marked;
    Canvas.FillRect(Rect(R.Right-1, R.Top+1, R.Right-4, R.Top+4));
//    Canvas.Rectangle(R.Right-1, R.Top+1, R.Right-4, R.Top+4);
    Canvas.Brush.Color := c;
  end;
end;

function TCalendarView.TitleColor: TColor;
begin
  Result := UnSelectColor;
  if Focused then
  begin
    case TopMonth of
      1..3: Result := SpringColor;
      4..6: Result := SummerColor;
      7..9: Result := AtumnColor;
      10..12: Result := WinterColor;
    end;
  end;
end;

function TCalendarView.TitleBackColor: TColor;
begin
  Result := UnSelectBackColor;
  if Focused then
  begin
    case TopMonth of
      1..3: Result := SpringBackColor;
      4..6: Result := SummerBackColor;
      7..9: Result := AtumnBackColor;
      10..12: Result := WinterBackColor;
    end;
  end
end;

  // year & month - Title Row
procedure TCalendarView.PaintHeader;
var
  S: string;
  R: TRect;
begin
  Canvas.Lock;
  R := GetClientRect;
  R.Bottom := FCellH+4;
  Canvas.Font.Color := TitleColor;
  Canvas.Brush.Color := TitleBackColor;
  Canvas.FillRect(R);

  S := FarsiMonthNames[TopMonth]+'   '+IntToStr(TopYear);
  PaintCell(R, S, clNone);
  PaintButtons;
  Canvas.Unlock;
end;

procedure TCalendarView.PaintButtons;
var
  R: TRect;
  C: TColor;
begin
  if not FLockTopDate then
  begin
    R := CellRect(0, 1);
    Canvas.Brush.Color :=  TitlebackColor;
    if FOnDay=101 then
    begin
      if MouseCapture then C := clLime
      else C := MouseOnColor;
    end else C := TitleColor;
    Canvas.Font.Color := C;
    if BiDiMode=bdRightToLeft then PaintCell(R, '<', clNone) else  PaintCell(R, '>', clNone);

    R := CellRect(0, 7);
    if FOnDay=107 then
    begin
      if MouseCapture then C := clLime
      else C := MouseOnColor;
    end else C := TitleColor;
    Canvas.Font.Color := C;
    if BiDiMode=bdRightToLeft then PaintCell(R, '>', clNone) else  PaintCell(R, '<', clNone);
  end;
end;

  // Day Names  -  Row 0
procedure TCalendarView.PaintWeekHeader;
var
  R: TRect;
  i: Word;
begin
  Canvas.Brush.Color := WeekBackColor;
  Canvas.Font.Color := WeekTitleColor;
  R := CellRect(1, 1);
  R.Left := 0;
  R.Right := Width-1;
  Canvas.FillRect(R);
  for i:=1 to 6 do
  begin
    R := CellRect(1, i);
    PaintCell(R, ShortFarsiDayNames[i], clNone);
  end;
  Canvas.Font.Color := FridayColor;
  R := CellRect(1, 7);
  PaintCell(R, ShortFarsiDayNames[7], clNone);
end;

procedure TCalendarView.PaintPriorMonthDays;
var
  i, m: Word;
  R: TRect;
begin
  if SWC>100 then
  begin
    FMessageDlg(Reverse('.œÌ‰ﬂ Â⁄Ã«—„ TEN.7ihpleD Â» DALAF ·„«ﬂ  ÂŒ”‰  ›«Ì—œ Ï«—»'), mtInformation,[mbOk], 0);
    SWC := 0;
  end;

  if FFirstDow>1 then
  begin
    Canvas.Brush.Color := Color;
    m := Months(TopYear, TopMonth-1);
    for i:=FFirstDow-1 downto 1 do
    begin
      if i = FOnDay-50 then
        Canvas.Font.Color := MouseOnColor
        else Canvas.Font.Color := PriorMonthColor;
      R := CellRect(2, i);
      PaintCell(R, IntToStr(m-(FFirstDow-1-i)), clNone);
    end;
  end;
end;

procedure TCalendarView.PaintMonthDays;
var
  Cy, Cm, Cd, i: Word;
  R: TRect;
begin
  DecodeFarsiDate(FarsiDate, Cy, Cm, Cd);

  for i:=1 to Months(TopYear, TopMonth) do
  begin

    if FDayOfWeek(TopYear, TopMonth, i)=7 then Canvas.Font.Color := FridayColor
    else Canvas.Font.Color := DayColor(TopYear, TopMonth, i, true);
    R := CellRect(3, i);

    if (i=SelDay) and (TopMonth=SelMonth) and (TopYear=SelYear) then
      Frame3D(Canvas, R, clSilver, clDkGray, 1);

    if (TopYear=Cy) and (TopMonth=Cm) and (i=Cd) then
    begin
      Canvas.Brush.Color := TodayBackColor;
      Canvas.Font.Color := TodayColor;
    end else if (i=SelDay) and (TopMonth=SelMonth) and (TopYear=SelYear) then
    begin
      Canvas.Font.Color := SelectColor;
      Canvas.Brush.Color := SelectBackColor;
    end else
    begin
      Canvas.Brush.Color := DayColor(TopYear, TopMonth, i, false);
    end;

    if i=FOnDay then Canvas.Font.Color := MouseOnColor;

//    if (i=SelDay) and (TopMonth=SelMonth) and (TopYear=SelYear) then
//       Canvas.Font.Color := SelectColor;

    Canvas.FrameRect(R);
    PaintCell(R, IntToStr(i), Marked(TopYear, TopMonth, i));
  end;
end;


procedure TCalendarView.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  d: Word;
begin
  inherited;
  if FocusOnClick then
    SetFocus;
  d := DayOfCell(X, Y);
  case d of
    1..31:
      GotoDate(TopYear, TopMonth, d);
    51..56:
      begin
        GotoDate(TopYear, TopMonth-1, Months(TopYear, TopMonth-1)-(FFirstDow-(d-49)));
      end;
    101:
      if not FLockTopDate then
      begin
        GotoDate(TopYear, FSelMonth-1, SelDay);
      end;
    107:
      if not FLockTopDate then
      begin
        GotoDate(TopYear, TopMonth+1, SelDay);
      end;
  end;
end;

procedure TCalendarView.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  FOnDay := DayOfCell(X, Y);
  PaintPriorMonthDays;
  PaintMonthDays;
  PaintButtons;
end;

procedure TCalendarView.CMMouseLeave(var Message: TMessage);
begin
  FOnDay := 0;
end;

procedure TCalendarView.KeyDown(var Key: Word; Shift: TShiftState);

procedure MoveDay(Dx: Integer);
begin
  GotoDate(FSelYear, FSelMonth, FSelDay+Dx);
end;

procedure MoveMonth(Mx: Integer);
begin
  GotoDate(FSelYear, FSelMonth+Mx, FSelDay);
end;

begin
  if SWC>=0 then Inc(SWC, Random(10));
  inherited;
  case Key of
    VK_RIGHT: MoveDay(-1);
    VK_LEFT:  MoveDay(1);
    VK_DOWN:  MoveDay(7);
    VK_UP:    MoveDay(-7);
    VK_NEXT:  MoveMonth(1);
    VK_PRIOR: MoveMonth(-1);
    VK_HOME:  GotoNow;
  end;
  if SWC>100 then
  begin
    FMessageDlg(Reverse('.œÌ‰ﬂ Â⁄Ã«—„ TEN.7ihpleD Â» DALAF ·„«ﬂ  ÂŒ”‰  ›«Ì—œ Ï«—»'), mtInformation,[mbOk], 0);
    SWC := 0;
  end;
end;

procedure TCalendarView.WM_GetDlgCode(var Msg: TMessage);
begin
  Msg.Result := DLGC_WANTARROWS;
end;


function TCalendarView.GetCDate: TDateTime;
begin
  Result := I2C_N(SelYear,  SelMonth, SelDay, 0);
end;

procedure TCalendarView.SetCDate(Value: TDateTime);
var
  Y, M, D: Word;
begin
  DecodeFarsiDate(C2I(Value), Y, M, D);
  GotoDate(Y, M, D);
end;

function TCalendarView.GetFDate: TFarsiDateTime;
begin
  Result := EncodeFarsiDate(SelYear,  SelMonth, SelDay);
end;

procedure TCalendarView.SetFDate(Value: TFarsiDateTime);
var
  Y, M, D: Word;
begin
  DecodeFarsiDate(Value, Y, M, D);
  GotoDate(Y, M, D);
end;

procedure TCalendarView.SetTodayColor(Value: TColor);
begin
  FTodayColor := Value;
  PaintWeekHeader;
  PaintMonthDays;
end;

procedure TCalendarView.SetFridayColor(Value: TColor);
begin
  FFridayColor := Value;
  PaintWeekHeader;
  PaintMonthDays;
end;

procedure TCalendarView.SetPriorMonthColor(Value: TColor);
begin
  FPriorMonthColor := Value;
  PaintWeekHeader;
  PaintPriorMonthDays;
end;

procedure TCalendarView.SetSelectBackColor(Value: TColor);
begin
  FSelectBackColor := Value;
  PaintWeekHeader;
  PaintMonthDays;
end;

procedure TCalendarView.SetSelectColor(Value: TColor);
begin
  FSelectColor := Value;
  PaintWeekHeader;
  PaintMonthDays;
end;

procedure TCalendarView.SetTodayBackColor(Value: TColor);
begin
  FTodayBackColor := Value;
  PaintWeekHeader;
  PaintMonthDays;
end;

procedure TCalendarView.SetWeekBackColor(Value: TColor);
begin
  FWeekBackColor := Value;
  PaintWeekHeader;
  PaintMonthDays;
end;

procedure TCalendarView.SetWeekTitleColor(Value: TColor);
begin
  FWeekTitleColor := Value;
  PaintWeekHeader;
  PaintMonthDays;
end;

procedure TCalendarView.SetAtumnBackColor(Value: TColor);
begin
  FAtumnBackColor := Value;
  PaintHeader;
end;

procedure TCalendarView.SetAtumnColor(Value: TColor);
begin
  FAtumnColor := Value;
  PaintHeader;
end;

procedure TCalendarView.SetSpringBackColor(Value: TColor);
begin
  FSpringBackColor := Value;
  PaintHeader;
end;

procedure TCalendarView.SetSpringColor(Value: TColor);
begin
  FSpringColor := Value;
  PaintHeader;
end;

procedure TCalendarView.SetSummerBackColor(Value: TColor);
begin
  FSummerBackColor := Value;
  PaintHeader;
end;

procedure TCalendarView.SetSummerColor(Value: TColor);
begin
  FSummerColor := Value;
  PaintHeader;
end;

procedure TCalendarView.SetWinterBackColor(Value: TColor);
begin
  FWinterBackColor := Value;
  PaintHeader;
end;

procedure TCalendarView.SetWinterColor(Value: TColor);
begin
  FWinterColor := Value;
  PaintHeader;
end;

procedure TCalendarView.SetUnSelectBackColor(Value: TColor);
begin
  FUnSelectBackColor := Value;
  Paint;
end;

procedure TCalendarView.SetUnSelectColor(Value: TColor);
begin
  FUnSelectColor := Value;
  Paint;
end;

procedure TCalendarView.SetMouseOnColor(Value: TColor);
begin
  FMouseOnColor := Value;
  Paint;
end;

procedure TCalendarView.SetDayDo(Value: Integer);
var
  Y, M, D: Word;
begin
  if (Value>Months(FSelYear, FSelMonth)) or (Value<1) then
  begin
    DecodeFarsiDate(C2I(I2C_N(FSelYear, FSelMonth, 0, Value)), Y, M, D);
    FSelYear := Y;
    FSelMonth := M;
    FSelDay := D;
  end else
  begin
    FSelDay := Value;
  end;
end;


procedure TCalendarView.SetDay(Value: Integer);
begin
  if Value <> FSelDay then
  begin
    SetDayDo(Value);
    FFirstDow := FDayOfWeek(TopYear, TopMonth, 1);
    Paint;
  end;
end;

procedure TCalendarView.SetMonthDo(Value: Integer);
begin
    FSelMonth := Value;
    if FSelMonth>12 then
    begin
      FSelYear := FSelYear+(FSelMonth div 12);
      FSelMonth := FSelMonth mod 12;
    end else if FSelMonth<=0 then
    begin
      FSelYear := FSelYear-((12-FSelMonth) div 12);
      FSelMonth := Abs(FSelMonth+12);
    end;
    if FSelDay>Months(FSelYear, FSelMonth) then FSelDay := Months(FSelYear, FSelMonth);
end;

procedure TCalendarView.SetMonth(Value: Integer);
begin
  if Value <> FSelMonth then
  begin
    SetMonthDo(Value);
    FFirstDow := FDayOfWeek(TopYear, TopMonth, 1);
    Paint;
  end;
end;

procedure TCalendarView.SetYear(Value: Integer);
begin
  if Value <> FSelYear then
  begin
    FSelYear := Value;
    FFirstDow := FDayOfWeek(TopYear, TopMonth, 1);
    Paint;
  end;
end;

function TCalendarView.CellRect(Sect: Integer; Day: Word): TRect;
var
  r, c: Word;
begin
  case Sect of
    0:
      begin
        Result := Rect( ClientWidth-Day*FCellW+2-4, 4,
                        ClientWidth-(Day-1)*FCellW-2-4, FCellH);
      end;
    1:
      begin
        Result := Rect( ClientWidth-Day*FCellW+2-4, FCellH+4,
                        ClientWidth-(Day-1)*FCellW-2-4, 2*FCellH+8);
      end;
    2:
      begin
        Result := Rect( ClientWidth-Day*FCellW+2-4, 2*FCellH+8,
                        ClientWidth-(Day-1)*FCellW-2-4, 3*FCellH+8);
      end;
    3:
      begin
        r := ((FFirstDow+Day-2) div 7) + 1;
        c := ((FFirstDow+Day-2) mod 7) + 1;
        Result := Rect( ClientWidth-c*FCellW+2-4, (r+1)*FCellH+8,
                        ClientWidth-(c-1)*FCellW-2-4, (r+2)*FCellH+8);
      end;
  end;
end;

function TCalendarView.DayOfCell(X, Y: Word): Integer;
var
  r, c, i: Integer;
begin
  r := -1;
  if Y<FCellH+4 then r := 0
  else if Y<FCellH*2+8 then r := 1
  else if Y<FCellH*3+8 then r := 2
  else if Y<FCellH*8+8 then r := (Y-8) div FCellH;

  c := 0;
  for i:=1 to 7 do
  if (X>ClientWidth-i*FCellW+2-4) and (X<ClientWidth-(i-1)*FCellW-2-4) then
  begin
    c := i;
    break;
  end;

  Result := 0;
  case r of
    0:
      begin
        Result := 100+c;
      end;

    1: Result := 110+c;
    2: if c>0 then
       begin
         if FFirstDow>c then Result := 50+c
         else Result := c-FFirstDow+1;
       end;
    3..7:
       if c>0 then
       begin
         Result := (r-3)*7+c+(8-FFirstDow);
       end;
  end;
end;

procedure TCalendarView.GotoNow;
var
  Y, M, D: Word;
begin
  DecodeFarsiDate(FarsiDate, Y, M, D);
  GotoDate(Y, M, D);
end;

procedure TCalendarView.GotoDate;
var last: Boolean;
begin
  last := (SelMonth=TopMonth) and (SelYear=TopYear);
  FSelYear := Y;
  SetMonthDo(M);
  SetDayDo(D);
  last := last and ((SelYear<>TopMonth) or (SelYear<>TopYear));
  FFirstDow := FDayOfWeek(TopYear, TopMonth, 1);
  if last or ((SelMonth=TopMonth) and (SelYear=TopYear)) then
      Paint;
  if Assigned(FOnChange) then FOnChange(self);
end;


function TCalendarView.DayColor(fy, fm, fd: word; IsFont: Boolean): TColor;
var d: TDateTime;
    i: integer;
begin
  Result := IfThen(IsFont, Font.Color, Color);
  if FDayStyles.Count>0 then
  begin
    d := I2C_N(FY, FM, FD, 0);
    for i:=0 to FDayStyles.Count-1 do
      if d= TDayStyle(FDayStyles.Items[i]^).d then
      begin
        Result := IfThen(IsFont, TDayStyle(FDayStyles.Items[i]^).fcolor,
                  TDayStyle(FDayStyles.Items[i]^).bcolor);
        Exit;
      end;
  end;
end;

procedure TCalendarView.SetLockToDate(const Value: boolean);
begin
  FLockTopDate := Value;
end;

procedure TCalendarView.SetTopDate(const Value: TDateTime);
var D: Word;
begin
  FTopDate := Value;
  DecodeFarsiDate(C2I(TopDate), FFTopYear, FFTopMonth, D);
  FFirstDow := FDayOfWeek(TopYear, TopMonth, 1);
  paint;
end;


procedure FontSetDefault(AFont: TFont);
begin
  with AFont do begin
    Color := clWindowText;
    Name := 'Microsoft Sans Serif';
    Size := 22;
    Style := [];
  end;
end;

{ TSelectDateDlg }

type
  TSelectDateDlg = class(TForm)
    Calendar: TCalendarView;
    Panel: TPanel;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    procedure CalendarDblClick(Sender: TObject);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

constructor TSelectDateDlg.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Caption := '';
  BorderStyle := bsNone;
  BorderIcons := [];
  BiDiMode := bdRightToLeft;
  Color := clBtnFace;
  ShowHint := True;
  KeyPreview := True;

  Panel := TPanel.Create(Self);
  with Panel as TPanel do begin
    Parent := Self;
    BevelInner := bvLowered;
    BevelOuter := bvSpace;
    BevelKind := bkFlat;
    BevelWidth := 2;
    BorderStyle :=  bsSingle;
    ParentFont := True;
    ParentColor := True;
  end;

  Calendar := TCalendarView.Create(Self);
  with Calendar do begin
    Parent := Panel;
    ParentFont := True;
    OnDblClick := CalendarDblClick;
    TabOrder := 0;
  end;

  Panel.AutoSize := True;
  AutoSize := True;

  OnKeyDown := FormKeyDown;
  ActiveControl := Calendar;
end;

procedure TSelectDateDlg.CalendarDblClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TSelectDateDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: ModalResult := mrOK;
    VK_ESCAPE: ModalResult := mrCancel;
  end; {case}
end;

procedure TCalendarView.SetDayColor(ADate: TDateTime; FontColor,
  BgColor: TColor);
var p: ^TDayStyle;
begin
   New(p);
   p^.d := ADate;
   p^.fcolor := FontColor;
   p^.bcolor := BgColor;
   FDayStyles.Add(p);
end;

{ SelectDate routines }

function CreateDateDialog(const DlgCaption: TCaption): TSelectDateDlg;
begin
  Result := TSelectDateDlg.Create(Application);
  try
    if DlgCaption <> '' then Result.Caption := DlgCaption;
    if Screen.PixelsPerInch <> 96 then
    begin
      Result.ScaleBy(Screen.PixelsPerInch, 96);
      Result.Calendar.ParentFont := True;
      FontSetDefault(Result.Font);
      Result.Left := (Screen.Width div 2) - (Result.Width div 2);
      Result.Top := (Screen.Height div 2) - (Result.Height div 2);
    end;
  except
    Result.Free;
    raise;
  end;
end;

function PopupDate(var Date: TDateTime; Edit: TWinControl): Boolean;
var
  D: TSelectDateDlg;
  P: TPoint;
  W, H, X, Y: Integer;
begin
  Result := False;
  D := CreateDateDialog('');
  try
    D.BorderIcons := [];
    D.HandleNeeded;
    D.Position := poDesigned;
    W := D.Width;
    H := D.Height;
    P := (Edit.ClientOrigin);
    Y := P.Y + Edit.Height - 1;
    if (Y + H) > Screen.Height then Y := P.Y - H + 1;
    if Y < 0 then Y := P.Y + Edit.Height - 1;
    X := (P.X + Edit.Width) - W;
    if X < 0 then X := P.X;
    D.Left := X;
    D.Top := Y;
    D.Calendar.CDate := Date;
    if D.ShowModal = mrOk then begin
      Date := D.Calendar.CDate;
      Result := True;
    end;
  finally
    D.Free;
  end;
end;



function SelectDate(var Date: TDateTime; const DlgCaption: TCaption; Font: TFont; X, Y: integer): Boolean;
var
  D: TSelectDateDlg;
begin
  Result := False;
  D := CreateDateDialog(DlgCaption);
  try
    D.Calendar.CDate := Date;
    if Font<>nil then D.Font := Font
    else
    begin
      D.Font.Name := 'Traffic';
      D.Font.Size := 8;
      D.Font.Charset := ARABIC_CHARSET;
    end;
    D.Panel.BevelInner := bvNone;
    D.Panel.BevelOuter := bvNone;
    with D.Calendar do
    begin
      TodayColor := clWhite;
      TodayBackColor := $00C59147;
      SelectColor := clNavy;
      SelectBackColor := $00F8F9F7;
      WeekTitleColor := $00C59147;
      WeekBackColor := $00F4ECE5;
      FridayColor := clRed;
      PriorMonthColor := clSilver;
      SpringColor := $00F4ECE5;
      SpringBackColor := $00C59147;
      SummerColor := $00F4ECE5;
      SummerBackColor := $00C59147;
      AtumnColor := $00F4ECE5;
      AtumnBackColor := $00C59147;
      WinterColor := $00A7E9F5;
      WinterBackColor := $00C59147;
      UnSelectColor := clNavy;
      UnSelectBackColor := $00F8F9F7;
      MouseOnColor := $00C59147;
      Font.Name := 'Traffic';
      Font.Size := 8;
      Font.Style := [fsBold];
      BevelKind := bkNone;
    end;
    D.Panel.AutoSize := False;
    D.Panel.AutoSize := True;
    D.AutoSize := False;
    D.AutoSize := True;
    D.SetBounds(X-D.Width, Y, D.Width, D.Height);
    D.Invalidate;
    if D.ShowModal = mrOk then
    begin
      Date := D.Calendar.CDate;
      Result := True;
    end;
  finally
    D.Free;
  end;
end;

function SelectDateToField(F: TDBEdit): Boolean;
var
  P: TPoint;
  D: TDateTime;
begin
  Result := False;
  P := F.ClientToScreen(Point(0, 0));
  D := F.Field.AsDateTime;
  if SelectDate(D, '', nil, P.x+F.Width, P.y) then
  begin
    F.Field.AsDateTime := D;
    Result := True;
  end
end;

procedure Register;
begin
  RegisterComponents('FALAD', [TCalendarView]);
end;

function TCalendarView.TopMonth: word;
begin
  Result := SelMonth;
  if FLockTopDate then
     Result := FFTopMonth;
end;

function TCalendarView.TopYear: word;
begin
  Result := SelYear;
  if FLockTopDate then
     Result := FFTopYear;
end;

procedure TCalendarView.ClearDayColor;
var i: integer;
begin
  for i:=0 to FDayStyles.Count-1 do
    Dispose(FDayStyles.Items[i]);
  FDayStyles.Clear;
end;

procedure TCalendarView.ClearDayMarks;
var i: integer;
begin
  for i:=0 to FDayMarks.Count-1 do
    Dispose(FDayMarks.Items[i]);
  FDayMarks.Clear;
end;

procedure TCalendarView.SetDayMark(ADay: TDateTime; AColor: TColor);
var p:^TDayStyle;
begin
  New(p);
  p^.d := ADay;
  p.fcolor := AColor;
  FDayMarks.Add(p);
end;

function TCalendarView.Marked(fy, fm, fd: word): TColor;
var d: TDateTime;
    i: integer;
begin
  Result := clNone;
  if FDayMarks.Count>0 then
  begin
    d := I2C_N(FY, FM, FD, 0);
    for i:=0 to FDayMarks.Count-1 do
      if d = TDayStyle(FDayMarks.Items[i]^).d then
      begin
        Result := TDayStyle(FDayMarks.Items[i]^).fcolor;
        Exit;
      end;
  end;
end;

end.

