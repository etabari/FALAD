unit DateEdit;

interface
uses Windows, Types, Classes, Controls, Graphics, Forms, Messages, Utils,
     DB, StdCtrls, ExtCtrls, DBCtrls, Grids;

type
  TDateEdit = class(TCustomControl)
  private
    FAutoSize: Boolean;
    FYear: Word;
    FMonth: Word;
    FDay: Word;
    FCurPos: Integer;
    FReadOnly: Boolean;
    FSeparator: Char;
    FSeparatorColor: TColor;
    FFirstYYColor: TColor;
    FLockYY: Boolean;
    FBorderStyle: TBorderStyle;
    FOnChange: TNotifyEvent;
    FBorderColor: TColor;
    procedure AdjustHeight;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMEnter(var Message: TCMGotFocus); message CM_ENTER;
    procedure CMExit(var Message: TCMLostFocus); message CM_EXIT;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure MovePos(Dir: Boolean);
    procedure SetCurPos(Value: Integer);
    procedure SetSeparator(Value: Char);
    procedure SetSeparatorColor(Value: TColor);
    procedure SetFirstYYColor(Value: TColor);
    procedure SetCaret;
    procedure UpdateHeight;
    procedure WMSetFont(var Message: TWMSetFont); message WM_SETFONT;
    procedure SetBorderColor(const Value: TColor);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure SetAutoSize(Value: Boolean); override;
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetCDate(Value: TDateTime); virtual;
    procedure SetYear(Value: Word); virtual;
    procedure SetMonth(Value: Word); virtual;
    procedure SetDay(Value: Word); virtual;
    procedure Paint; override;
    procedure WndProc(var Message: TMessage); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    function GetHDate: TFarsiDateTime;
    procedure SetHDate(Value: TFarsiDateTime);
    function GetCDate: TDateTime;
    function  Y_Str: string;
    function  M_Str: string;
    function  D_Str: string;
    function  AsText_I(Y4: Boolean): string;
    function  AsText_C(Y4: Boolean): string;
    procedure Change; dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Clear;
    function StringFormat: string;
    function SelectFromCalendar: Boolean;
    property HDate: TFarsiDateTime read GetHDate write SetHDate;
    property CDate: TDateTime read GetCDate write SetCDate;
  published
    property Anchors;
    property Ctl3D;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BorderColor : TColor read FBorderColor write SetBorderColor;
    property BiDiMode;
    property Enabled;
    property Color;
    property Font;
    property ParentFont;
    property TabStop;
    property TabOrder;
    property Align;

    property AutoSize: Boolean read FAutoSize write SetAutoSize default False;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property LockYY: Boolean read FLockYY write FLockYY;
    property Year: Word read FYear write SetYear;
    property Month: Word read FMonth write SetMonth;
    property Day: Word read FDay write SetDay;
    property CurPos: Integer read FCurPos write SetCurPos;
    property Separator: Char read FSeparator write SetSeparator;
    property SeparatorColor: TColor read FSeparatorColor write SetSeparatorColor;
    property FirstYYColor: TColor read FFirstYYColor write SetFirstYYColor;

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

type
  TDBDateEdit = class(TDateEdit)
  private
    FDataLink: TFieldDataLink;
    function GetDataField: string;
    function GetDataSource: TDataSource;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    procedure CMExit(var Message: TCMLostFocus); message CM_EXIT;
    procedure DateChange(Sender: TObject);
    procedure UpdateDate(Sender: TObject);
  protected
    procedure SetYear(Value: Word); override;
    procedure SetMonth(Value: Word); override;
    procedure SetDay(Value: Word); override;
    procedure SetCDate(Value: TDateTime); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Change; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property ReadOnly;
  end;

procedure Register;

implementation
uses
  Variants, SysUtils, CalendarView;

constructor TDateEdit.Create(AOwner: TComponent);
const
  EditStyle = [csClickEvents, csSetCaption, csDoubleClicks];
begin
  inherited;
  if NewStyleControls then
    ControlStyle := EditStyle else
    ControlStyle := EditStyle + [csFramed];

  FAutoSize := false;
  BiDiMode := bdRightToLeft;
  Width := 100;
  Height := 24;
  TabStop := True;
  Color := clWhite;
  FBorderStyle := bsSingle;

  FYear := 0;
  FMonth := 0;
  FDay := 0;

  FSeparator := '/';
  FSeparatorColor := clBlack;
  FFirstYYColor := clGray;
  FLockYY := True;

  FCurPos := 0;
  SetCaret;
end;

const
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);

procedure TDateEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or (ES_AUTOHSCROLL or ES_AUTOVSCROLL) or
      BorderStyles[FBorderStyle];
    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
  end;
end;

procedure TDateEdit.Paint;
var
  Rect: TRect;
begin
  Rect := GetClientRect;
  Canvas.Brush.Color := Color;
  if FBorderColor = clNone then
    Canvas.FillRect(Rect)
  else
  begin
    Canvas.Pen.Color :=  FBorderColor;
    Canvas.Rectangle(Rect);
  end;

  Canvas.Font := Font;

  Canvas.Font.Color := Font.Color;
  Canvas.TextOut(2, 1, Y_Str);
  Canvas.Font.Color := SeparatorColor;
  Canvas.TextOut(2+Canvas.TextWidth('88'), 1, Separator);
  Canvas.Font.Color := Font.Color;
  Canvas.TextOut(2+Canvas.TextWidth('88'+Separator), 1, M_Str);
  Canvas.Font.Color := SeparatorColor;
  Canvas.TextOut(2+Canvas.TextWidth('88'+Separator+'08'), 1, Separator);
  Canvas.Font.Color := Font.Color;
  Canvas.TextOut(2+Canvas.TextWidth('88'+Separator+'08'+Separator), 1, D_Str);
end;

procedure TDateEdit.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
end;

procedure TDateEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not Focused then SetFocus;
  Canvas.Font := Font;
  if (X<2+Canvas.TextWidth('8')) then CurPos := 0
  else if (X<2+Canvas.TextWidth('88')) then CurPos := 1
  else if (X<2+Canvas.TextWidth('88'+Separator+'0')) then CurPos := 3
  else if (X<2+Canvas.TextWidth('88'+Separator+'08')) then CurPos := 4
  else if (X<2+Canvas.TextWidth('88'+Separator+'08'+Separator+'2')) then CurPos := 6
  else if (X<2+Canvas.TextWidth('88'+Separator+'08'+Separator+'2')) then CurPos := 7;
  inherited;
end;

procedure TDateEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  case Key of
    VK_DELETE:
      if not ReadOnly then
      begin
        Year := 0;
        Month := 0;
        Day := 0;
        CurPos := 0;
        Change;
      end;

    VK_HOME: CurPos := 0;
    VK_END: CurPos := 8;

    VK_INSERT: SelectFromCalendar;

    VK_PRIOR:
      begin
        if not ReadOnly then
        case CurPos of
          6..7:
            begin
              if Day>5 then Day := Day-5
              else Day := 1;
              Change;
            end;
        end;
      end;

    VK_NEXT:
      begin
        if not ReadOnly then
        case CurPos of
          6..7:
            begin
              if Day<Months(Year, Month)-5 then Day := Day+5
              else Day := Months(Year, Month);
              Change;
            end;
        end
      end;

    VK_UP:
      begin
        if not ReadOnly then
        begin
          case CurPos of
//            3..4: if Month<12 then Month := Month+1;
            6..7: if Day<Months(Year, Month) then Day := Day+1;
          end;
          Change;
        end;
      end;

    VK_DOWN:
      begin
        if not ReadOnly then
        begin
          case CurPos of
//            3..4: if Month>1 then Month := Month-1;
            6..7: if Day>1 then Day := Day-1;
          end;
          Change;
        end;
      end;

    VK_RIGHT:
      if ssCtrl in Shift then
        case CurPos of 0..1: CurPos := 3; 3..4: CurPos := 6; end
      else MovePos(True);

    VK_LEFT, VK_BACK:
      if ssCtrl in Shift then
        case CurPos of 6..7: CurPos := 3; 3..4: CurPos := 0; end
      else MovePos(False);
  end;
end;

procedure TDateEdit.KeyPress(var Key: Char);
var
  S: string[10];
begin
  inherited;
  if not ReadOnly then
  case Key of
    '0'..'9':
      begin
        case CurPos of
          0..1:
            begin
              S := Y_Str;
              S[CurPos+1] := Key;
              Year := StrToInt(Trim(S));
              MovePos(True);
              Change;
            end;
          3..4:
            begin
              S := M_Str;
              if ((CurPos=3) and (Key>'1')) or ((CurPos=4) and (S[1]='1') and (Key>'2')) then
              begin
                Month := StrToInt(Key);
                CurPos := 6;
              end else
              begin
                S[CurPos-2] := Key;
                Month := StrToInt(Trim(S));
                if Month>12 then Month := 12;
                MovePos(True);
              end;
              Change;
            end;

          6..7:
            begin
              S := D_Str;
              if ((CurPos=6) and (Key>'3')) or ((CurPos=7) and (S[1]='3') and (Key>'1')) then
              begin
                Day := StrToInt(Key);
                CurPos := 8;
              end else
              begin
                S[CurPos-5] := Key;
                Day := StrToInt(Trim(S));
                MovePos(True);
              end;
              Change;
            end;
        end;
        if Day>Months(Year, Month) then
        begin
          Change;
          Day := Months(Year, Month);
          CurPos := 6;
        end;
      end;
  end;
end;

procedure TDateEdit.Change;
begin
  inherited Changed;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TDateEdit.Clear;
begin
  CDate := 0;
  CurPos := 0;
end;

procedure TDateEdit.SetYear(Value: Word);
begin
  if Value<>FYear then
  begin
    FYear := Value;
    if Day>Months(Year, Month) then FDay := Months(Year, Month);
    Invalidate;
  end;
end;

procedure TDateEdit.SetMonth(Value: Word);
begin
  if Value<>FMonth then
  begin
    FMonth := Value;
    if Day>Months(Year, Month) then FDay := Months(Year, Month);
    Invalidate;
  end;
end;

procedure TDateEdit.SetDay(Value: Word);
begin
  if Value<>FDay then
  begin
    FDay := Value;
    if Day>Months(Year, Month) then FDay := Months(Year, Month);
    Invalidate;
  end;
end;

procedure TDateEdit.SetCurPos(Value: Integer);
begin
  if Value<>FCurPos then
  begin
    FCurPos := Value;
    SetCaret;
  end;
end;

procedure TDateEdit.SetSeparator(Value: Char);
begin
  if Value<>FSeparator then
  begin
    FSeparator := Value;
    Invalidate;
  end;
end;

procedure TDateEdit.SetSeparatorColor(Value: TColor);
begin
  if Value<>FSeparatorColor then
  begin
    FSeparatorColor := Value;
    Invalidate;
  end;
end;

procedure TDateEdit.SetAutoSize(Value: Boolean);
begin
  if FAutoSize <> Value then
  begin
    FAutoSize := Value;
    UpdateHeight;
  end;
end;

procedure TDateEdit.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    UpdateHeight;
    RecreateWnd;
  end;
end;

procedure TDateEdit.UpdateHeight;
begin
  if not FAutoSize then //and (BorderStyle = bsSingle) then
  begin
    ControlStyle := ControlStyle + [csFixedHeight];
    AdjustHeight;
  end else
    ControlStyle := ControlStyle - [csFixedHeight];
end;

procedure TDateEdit.AdjustHeight;
var
  DC: HDC;
  SaveFont: HFont;
  I, J: Integer;
  SysMetrics, Metrics: TTextMetric;
begin
  DC := GetDC(0);
  GetTextMetrics(DC, SysMetrics);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  if NewStyleControls then
  begin
    if Ctl3D then I := 8 else I := 6;
    I := GetSystemMetrics(SM_CYBORDER) * I;
    J := I;
  end else
  begin
    I := SysMetrics.tmHeight;
    if I > Metrics.tmHeight then I := Metrics.tmHeight;
    I := I div 4 + GetSystemMetrics(SM_CYBORDER) * 4;
    J := I;
  end;
  if FAutoSize then
    Height := Metrics.tmHeight + I;

  if FAutoSize and (csDesigning in ComponentState) then
  begin
    Canvas.Font := Font;
    Width := J+Canvas.TextWidth('88'+Separator+'08'+Separator+'28');
  end;
end;

procedure TDateEdit.SetFirstYYColor(Value: TColor);
begin
  if Value<>FFirstYYColor then
  begin
    FFirstYYColor := Value;
    Invalidate;
  end;
end;

procedure TDateEdit.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls and (FBorderStyle = bsSingle) then
  begin
    UpdateHeight;
    RecreateWnd;
  end;
  inherited;
end;

procedure TDateEdit.WMSetFont(var Message: TWMSetFont);
begin
  inherited;
  if NewStyleControls and
    (GetWindowLong(Handle, GWL_STYLE) and ES_MULTILINE = 0) then
    SendMessage(Handle, EM_SETMARGINS, EC_LEFTMARGIN or EC_RIGHTMARGIN, 0);
end;

procedure TDateEdit.CMEnter(var Message: TCMGotFocus);
begin
  inherited;
  SetCaret;
  Invalidate;
end;

procedure TDateEdit.CMExit(var Message: TCMLostFocus);
begin
  inherited;
  DestroyCaret;
  Invalidate;
end;

procedure TDateEdit.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if AutoSize then
  begin
    if (csFixedHeight in ControlStyle) and not ((csDesigning in
      ComponentState) and (csLoading in ComponentState)) then AdjustHeight;
    if (csDesigning in ComponentState) then AdjustHeight;
  end;
end;

procedure TDateEdit.MovePos(Dir: Boolean);
begin
  if Dir then
  begin
    case CurPos of
      0, 3, 6: CurPos := CurPos + 1;
      1, 4: CurPos := CurPos + 2;
      else if CurPos<8 then CurPos := CurPos + 1;
    end;
  end else
  begin
    case CurPos of
      1, 4, 7: CurPos := CurPos - 1;
      3, 6: CurPos := CurPos - 2;
      else if CurPos>0 then CurPos := CurPos - 1;
    end;
  end;
end;

procedure TDateEdit.SetCaret;
var
  X: Integer;
begin
  if not Focused then Exit;
  Canvas.Font := Font;
  if CurPos=0 then X := 4
  else X := 2+Canvas.TextWidth(Copy(StringFormat, 1, CurPos));
  HideCaret(Handle);
  SetCaretPos(X, 1);
  ShowCaret(Handle)
end;

procedure TDateEdit.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  CreateCaret(Handle, 0, 2, Abs(Font.Height-8));
  ShowCaret(Handle);
  SetCaret;
  Paint
end;

procedure TDateEdit.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  case Message.Msg of
    WM_GETDLGCODE: Message.Result := DLGC_WANTARROWS;
    EM_GETMARGINS: Message.Result := $00020002;
  end;
end;

function TDateEdit.StringFormat: string;
begin
  Result := '88'+'/'+'08'+'/'+'28';
end;

function TDateEdit.Y_Str: string;
begin
  if Year>0 then
  begin
    Result := IntToStr(Year mod 100);
    if Length(Result)<2 then Result := Dup('0', 2-Length(Result))+Result;
  end else
  begin
    Result := '00';
  end;
end;

function TDateEdit.M_Str: string;
begin
  if Month>0 then
  begin
    Result := IntToStr(Month);
    if Length(Result)<2 then Result := Dup('0', 2-Length(Result))+Result;
  end else
  begin
    Result := '00';
  end;
end;

function TDateEdit.D_Str: string;
begin
  if Day>0 then
  begin
    Result := IntToStr(Day);
    if Length(Result)<2 then Result := Dup('0', 2-Length(Result))+Result;
  end else
  begin
    Result := '00';
  end;
end;

function TDateEdit.AsText_I(Y4: Boolean): string;
begin
  Result := Y_Str+M_Str+D_Str;
  if not Y4 then Delete(Result, 1, 2);
end;

function TDateEdit.GetHDate: TFarsiDateTime;
begin
  if (Year=0) or (Month=0) or (Day=0) then
    Result := 0
  else Result := EncodeFarsiDate(Year, Month, Day);
end;

procedure TDateEdit.SetHDate(Value: TFarsiDateTime);
var
  Y, M, D: Word;
begin
  if Value=0 then
  begin
    Y := 0;
    M := 0;
    D := 0;
  end else DecodeFarsiDate(Value, Y, M, D);
  if (Y<>Year) or (M<>Month) or (D<>day) then
  begin
    Year := Y;
    Month := M;
    Day := D;
  end;
end;

function TDateEdit.GetCDate: TDateTime;
begin
  if (Year=0) or (Month=0) or (Day=0) then
    Result := 0
  else Result := I2C_N(Year, Month, Day, 0);
end;

procedure TDateEdit.SetCDate(Value: TDateTime);
var
  Y, M, D: Word;
begin
  if Value=0 then
  begin
    Y := 0;
    M := 0;
    D := 0;
  end else DecodeFarsiDate(C2I(Value), Y, M, D);
  if (Y<>Year) or (M<>Month) or (D<>day) then
  begin
    Year := Y;
    Month := M;
    Day := D;
    Change;
  end;
end;

function TDateEdit.AsText_C(Y4: Boolean): string;
begin
  Result := '';
end;

function TDateEdit.SelectFromCalendar: Boolean;
var
  Dt: TDateTime;
  P: TPoint;
begin
  Result := False;
  P := ClientToScreen(Point(Width, 0));
  Dt := CDate;
  if Dt=0 then Dt := Date;
  if SelectDate(Dt, '', nil, P.X, P.Y) then
  begin
    CDate := Dt;
    Result := True;
    Invalidate;
  end;
end;

procedure TDateEdit.SetBorderColor(const Value: TColor);
begin
  FBorderColor := Value;
  Invalidate;
end;


//////////////////////////////////////////////////////
//   D A T A     A W A R E
//
constructor TDBDateEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := self;
  FDataLink.OnDataChange := DateChange;
  FDataLink.OnUpdateData := UpdateDate;
end;

destructor TDBDateEdit.Destroy;
begin
  FDataLink.OnDataChange := nil;
  FDataLink.OnUpdateData := nil;
  FDataLink.Free;
  inherited Destroy;
end;

procedure TDBDateEdit.DateChange(Sender: TObject);
var
  Y, M, D: Word;
begin
  if FDataLink.Field = nil then
  begin
    FYear := 0;
    FMonth := 0;
    FDay := 0;
  end else
  begin
    if FDataLink.Field.AsDateTime<>0 then
    begin
      DecodeFarsiDate(C2I(FDataLink.Field.AsDateTime), Y, M, D);
      FYear := Y;
      FMonth := M;
      FDay := D;
    end else
    begin
      FYear := 0;
      FMonth := 0;
      FDay := 0;
    end;
    Invalidate;
  end;
end;

procedure TDBDateEdit.UpdateDate(Sender: TObject);
begin
  if (Year=0) or (Month=0) or (Day=0) then
    FDataLink.Field.Value := Null
  else FDataLink.Field.AsDateTime := I2C_N(Year, Month, Day, 0)
end;

function TDBDateEdit.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TDBDateEdit.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDBDateEdit.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

procedure TDBDateEdit.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

procedure TDBDateEdit.CMExit(var Message: TCMLostFocus);
begin
{  try
    FDataLink.UpdateRecord;
  except
    on Exception do SetFocus;
  end;
  }
  inherited;
end;

procedure TDBDateEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      if not ReadOnly then
      begin
        DateChange(Self);
      end;
  end;
  inherited;
end;

procedure TDBDateEdit.KeyPress(var Key: Char);
begin
  inherited;
end;

 {
procedure TDBDateEdit.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;

end;
  }

procedure TDBDateEdit.SetDay(Value: Word);
begin
  if not FDataLink.Editing then FDataLink.Edit;
  inherited;
  FDataLink.Modified;
end;

procedure TDBDateEdit.SetMonth(Value: Word);
begin
  if not FDataLink.Editing then FDataLink.Edit;
  inherited;
  FDataLink.Modified;
end;

procedure TDBDateEdit.SetYear(Value: Word);
begin
  if not FDataLink.Editing then FDataLink.Edit;
  inherited;
  FDataLink.Modified;
end;

procedure TDBDateEdit.SetCDate(Value: TDateTime);
var
  Y, M, D: Word;
begin
  if Value=0 then
  begin
    Y := 0;
    M := 0;
    D := 0;
  end else DecodeFarsiDate(C2I(Value), Y, M, D);
  if (Y<>Year) or (M<>Month) or (D<>day) then
  begin
    Year := Y;
    Month := M;
    Day := D;
    if not FDataLink.Editing then FDataLink.Edit;
    FDataLink.Modified;
    Change;
  end;
end;

procedure TDBDateEdit.Change;
begin
  inherited;
  if Assigned(FOnChange) then FOnChange(Self);
  if not FDataLink.Editing then FDataLink.Edit;
  FDataLink.Modified;
end;

procedure Register;
begin
  RegisterComponents('FALAD', [TDateEdit, TDBDateEdit]);
end;


end.
