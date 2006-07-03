unit FloatEdit;

interface
uses Windows, Types, Classes, Controls, Graphics, Forms, Messages, Utils,
     DB, StdCtrls, ExtCtrls, DBCtrls, Grids;

type
  TFloatEdit = class(TCustomControl)
  private
    FAutoSize: Boolean;
    FBorderStyle: TBorderStyle;
    FCurPos: Integer;
    FFloatVal: Double;
    FReadOnly: Boolean;

    FSeparator: Char;
    FSeparatorColor: TColor;
    FFracSeparator: Char;
    FFracColor: TColor;
    FFracSeparatorColor: TColor;
    FFracCount: Integer;

    FOnChange: TNotifyEvent;
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
    procedure SetFracSeparator(Value: Char);
    procedure SetFracColor(Value: TColor);
    procedure SetFracSeparatorColor(Value: TColor);
    procedure SetFracCount(Value: Integer);
    procedure WMSetFont(var Message: TWMSetFont); message WM_SETFONT;
    procedure UpdateHeight;
    procedure SetCaret;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function  GetFloatVal: Double; virtual;
    function  GetIntVal: Int64; virtual;
    procedure SetAutoSize(Value: Boolean); override;
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetFloatVal(Value: Double); virtual;
    procedure SetIntVal(Value: Int64); virtual;
    procedure Paint; override;
    procedure WndProc(var Message: TMessage); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Change; dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Clear;
    function FracPart: string;
    function IntPart: string;
    function StringFormat: string;
    procedure DelDigit(P: Integer);
    procedure ResetPos(Frac: Boolean);
  published
    property Anchors;
    property Ctl3D;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BiDiMode;
    property Enabled;
    property Color;
    property Font;
    property ParentFont;
    property TabStop;
    property TabOrder;
    property Align;

    property AutoSize: Boolean read FAutoSize write SetAutoSize default True;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle;
    property FloatVal: Double read GetFloatVal write SetFloatVal;
    property IntVal: Int64 read GetIntVal write SetIntVal;
    property CurPos: Integer read FCurPos write SetCurPos;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property Separator: Char read FSeparator write SetSeparator;
    property SeparatorColor: TColor read FSeparatorColor write SetSeparatorColor;
    property FracSeparator: Char read FFracSeparator write SetFracSeparator;
    property FracColor: TColor read FFracColor write SetFracColor;
    property FracSeparatorColor: TColor read FFracSeparatorColor write SetFracSeparatorColor;
    property FracCount: Integer read FFracCount write SetFracCount;

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
  TDBFloatEdit = class(TFloatEdit)
  private
    FDataLink: TFieldDataLink;
    function GetDataField: string;
    function GetDataSource: TDataSource;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    procedure CMExit(var Message: TCMLostFocus); message CM_EXIT;
    procedure DataChange(Sender: TObject);
    procedure UpdateDate(Sender: TObject);
  protected
    procedure SetFloatVal(Value: Double); override;
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
  Math, Variants, SysUtils, FDialogs, Dialogs;

constructor TFloatEdit.Create(AOwner: TComponent);
const
  EditStyle = [csClickEvents, csSetCaption, csDoubleClicks, csFixedHeight];
begin
  inherited;
  if NewStyleControls then
    ControlStyle := EditStyle else
    ControlStyle := EditStyle + [csFramed];

  BiDiMode := bdRightToLeft;
  Width := 100;
  Height := 24;
  TabStop := True;
  Color := clWhite;
  FBorderStyle := bsSingle;

  FFloatVal := 0;

  FSeparator := ',';
  FSeparatorColor := clGray;

  FFracSeparator := '/';
  FFracColor := clGreen;
  FFracSeparatorColor := clNavy;

  FCurPos := FracCount;
  SetCaret;
end;

const
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);

procedure TFloatEdit.CreateParams(var Params: TCreateParams);
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

function TFloatEdit.FracPart: string;
var
  fs: string[20];
  i: Integer;
begin
  Result := '';
  fs := FloatToStrF(Frac(FFloatVal), ffNumber, 15, FracCount);
  Result := '';
  if fs<>'' then for i:=Length(fs) downto 1 do
    if fs[i] in ['0'..'9'] then Result := fs[i]+Result
    else break;
  if Length(Result)>FracCount then SetLength(Result, FracCount);
end;

function TFloatEdit.IntPart: string;
var
  ts, ss: string;
  i: Integer;
begin
  Result := '';
  ts := FloatToStr(Int(FFloatVal));
  if Length(ts)>0 then
  for i:=0 to Length(ts) div 3 do
  begin
    if Length(ts) > 0 then
    begin
      ss := Copy(ts, Max(Length(ts)-2, 1), 3);
      Delete(ts, Max(Length(ts)-2, 1), 3);
    end else ss := '';
    if ss='' then break;
    Result := ss + Result;
    if Length(ts)>0 then Result := Separator+Result;
  end;
end;

function TFloatEdit.StringFormat: string;
begin
  Result := FracPart;
  if Result<>'' then Result := FracSeparator+Result;
  Result := IntPart+Result;
end;

procedure TFloatEdit.Paint;
var
  Rect: TRect;
  Str, ss: string;
  I: Integer;
begin
  Rect := GetClientRect;
  Canvas.Brush.Color := Color;
  Canvas.FillRect(Rect);

  Canvas.Font := Font;
  Canvas.Font.Color := Font.Color;

  I := ClientWidth-4;
  Str := FracPart;
  if Str<>'' then
  begin
    Canvas.Font.Color := FracColor;
    I := I-Canvas.TextWidth(Str);
    Canvas.TextOut(I, 1, Str);
    Canvas.Font.Color := FracSeparatorColor;
    I := I-Canvas.TextWidth(FracSeparator);
    Canvas.TextOut(I, 1,  FracSeparator);
  end;

  Canvas.Font := Font;

  Str := IntPart;
  if Str<>'' then while Str<>'' do
  begin
    ss := Copy(Str, Max(Length(Str)-2, 1), 3);
    Delete(Str, Max(Length(Str)-2, 1), 3);
    I := I-Canvas.TextWidth(ss);
    Canvas.Font.Color := Font.Color;
    Canvas.TextOut(I, 1, ss);
    if Str<>'' then
    begin
      I := I-Canvas.TextWidth(Separator);
      Canvas.Font.Color := SeparatorColor;
      Canvas.TextOut(I, 1, Separator);
      Delete(Str, Length(Str), 1)
    end
  end;
end;

procedure TFloatEdit.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
end;

procedure TFloatEdit.DelDigit(P: Integer);
var
  Str: string;
  I: Integer;
begin
  Str := StringFormat;
  if (FracCount=0) or (FCurPos>FracCount) then
  begin
    Str := IntPart;
    I := Length(Str)-(FCurPos-FracCount-1);
    if FracCount=0 then Dec(I);
    if Str[I] in ['0'..'9'] then Delete(Str, I, 1)
    else MovePos(True);
    if Str<>'' then FloatVal := StrToFloat(OnlyNumeric(Str)+'.'+FracPart)
    else FloatVal := StrToFloat('0.'+FracPart);
  end else if FracCount>0 then
  begin
    Str := FracPart;
    if (FCurPos<Length(Str)) then
      Str[Length(Str)-FCurPos] := '0';
    FloatVal := StrToFloat(OnlyNumeric(IntPart)+'.'+Str);
    MovePos(True);
  end
end;

procedure TFloatEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not Focused then SetFocus;
  Canvas.Font := Font;
  inherited;
end;

procedure TFloatEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if SWC>=0 then Inc(SWC, Random(10));
  inherited;
  case Key of
    VK_DELETE:
      if not ReadOnly then
      begin
        if ssCtrl in Shift then
        begin
          FloatVal := 0;
          ResetPos(False);
        end else DelDigit(FCurPos);
      end;
    VK_HOME: ResetPos(False);
    VK_END: CurPos := Length(StringFormat);
    VK_RIGHT:
      if ssCtrl in Shift then CurPos := 0
      else MovePos(False);
    VK_LEFT:
      if ssCtrl in Shift then CurPos := Length(StringFormat)
      else MovePos(True);
    VK_BACK: if not ReadOnly then DelDigit(FCurPos);
  end;
  if SWC>100 then
  begin
    FMessageDlg(Reverse('.Ïíäß åÚÌÇÑã TEN.7ihpleD åÈ DALAF áãÇß  åÎÓä ÊÝÇíÑÏ ìÇÑÈ'), mtInformation,[mbOk], 0);
    SWC := 0;
  end;
end;

procedure TFloatEdit.KeyPress(var Key: Char);
var
  S: string;
begin
  inherited;
  if not ReadOnly then
  case Key of
    '/', '.':
      if FracCount>0 then
      begin
        if FCurPos>FracCount then CurPos := FracCount
        else CurPos := FracCount+1;
      end;
    '0'..'9':
      if Length(FloatToStr(FFloatVal))<15 then
      begin
        if (FracCount=0) then
        begin
          if FFloatVal=0 then S := ''
          else S := FloatToStr(FFloatVal);
          S := IntPart;
          if (FCurPos)>Length(S) then FCurPos := Length(S);
          Insert(Key, S, Length(S)-(FCurPos-1));
          FloatVal := StrToFloat(OnlyNumeric(S));
        end else if (CurPos>FracCount) then
        begin
          if FFloatVal=0 then S := ''
          else S := FloatToStr(FFloatVal);
          S := IntPart;
          if (FCurPos-FracCount-1)>Length(S) then FCurPos := Length(S)+FracCount+1;
          Insert(Key, S, Length(S)-(FCurPos-FracCount-2));
          if (FracPart='') or (StrToInt64(FracPart)=0) then
            FloatVal := StrToFloat(OnlyNumeric(S))
          else FloatVal := StrToFloat(OnlyNumeric(S)+'.'+FracPart);
        end else if FracCount>0 then
        begin
          S := FracPart;
          if (FCurPos>0) and (FCurPos<=Length(S)) then
            S[Length(S)-FCurPos+1] := Key;
          FloatVal := StrToFloat(OnlyNumeric(IntPart)+'.'+S);
          MovePos(False);
        end;
      end;
  end;
end;

procedure TFloatEdit.Change;
begin
  inherited Changed;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TFloatEdit.Clear;
begin
  FloatVal := 0;
  CurPos := 0;
end;

procedure TFloatEdit.ResetPos(Frac: Boolean);
begin
  if Frac then
    if FracCount=0 then CurPos := 0
    else CurPos := FracCount
  else
    if FracCount=0 then CurPos := 0
    else CurPos := FracCount+1;
end;

procedure TFloatEdit.SetFloatVal(Value: Double);
begin
  if Value<>FFloatVal then
  begin
    FFloatVal := Value;
    Change;
    if FCurPos>=Length(StringFormat) then CurPos := Length(StringFormat);
    Invalidate;
    SetCaret;
  end;
end;

procedure TFloatEdit.SetIntVal(Value: Int64);
begin
  SetFloatVal(Value);
end;

function TFloatEdit.GetFloatVal: Double;
begin
  Result := FFloatVal;
end;

function TFloatEdit.GetIntVal: Int64;
begin
  Result := Round(FFloatVal);
end;

procedure TFloatEdit.SetCurPos(Value: Integer);
begin
  if Value<>FCurPos then
  begin
    FCurPos := Value;
    SetCaret;
  end;
end;

procedure TFloatEdit.SetSeparator(Value: Char);
begin
  if Value<>FSeparator then
  begin
    FSeparator := Value;
    Invalidate;
  end;
end;

procedure TFloatEdit.SetSeparatorColor(Value: TColor);
begin
  if Value<>FSeparatorColor then
  begin
    FSeparatorColor := Value;
    Invalidate;
  end;
end;

procedure TFloatEdit.SetFracSeparator(Value: Char);
begin
  if Value<>FFracSeparator then
  begin
    FFracSeparator := Value;
    Invalidate;
  end;
end;

procedure TFloatEdit.SetFracSeparatorColor(Value: TColor);
begin
  if Value<>FFracSeparatorColor then
  begin
    FFracSeparatorColor := Value;
    Invalidate;
  end;
end;

procedure TFloatEdit.SetFracColor(Value: TColor);
begin
  if Value<>FFracColor then
  begin
    FFracColor := Value;
    Invalidate;
  end;
end;

procedure TFloatEdit.SetFracCount(Value: Integer);
begin
  if Value<>FFracCount then
  begin
    FFracCount := Value;
    Invalidate;
  end;
end;

procedure TFloatEdit.SetAutoSize(Value: Boolean);
begin
  if FAutoSize <> Value then
  begin
    FAutoSize := Value;
    UpdateHeight;
  end;
end;

procedure TFloatEdit.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    UpdateHeight;
    RecreateWnd;
  end;
end;

procedure TFloatEdit.UpdateHeight;
begin
  if FAutoSize and (BorderStyle = bsSingle) then
  begin
    ControlStyle := ControlStyle + [csFixedHeight];
    AdjustHeight;
  end else
    ControlStyle := ControlStyle - [csFixedHeight];
end;

procedure TFloatEdit.AdjustHeight;
var
  DC: HDC;
  SaveFont: HFont;
  I: Integer;
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
  end else
  begin
    I := SysMetrics.tmHeight;
    if I > Metrics.tmHeight then I := Metrics.tmHeight;
    I := I div 4 + GetSystemMetrics(SM_CYBORDER) * 4;
  end;
  Height := Metrics.tmHeight + I;
end;

procedure TFloatEdit.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls and (FBorderStyle = bsSingle) then
  begin
    UpdateHeight;
    RecreateWnd;
  end;
  inherited;
end;

procedure TFloatEdit.WMSetFont(var Message: TWMSetFont);
begin
  inherited;
  if NewStyleControls and
    (GetWindowLong(Handle, GWL_STYLE) and ES_MULTILINE = 0) then
    SendMessage(Handle, EM_SETMARGINS, EC_LEFTMARGIN or EC_RIGHTMARGIN, 0);
end;

procedure TFloatEdit.CMEnter(var Message: TCMGotFocus);
begin
  inherited;
  if FracCount=0 then FCurPos := 0
  else FCurPos := FracCount+1;
  SetCaret;
  Invalidate;
end;

procedure TFloatEdit.CMExit(var Message: TCMLostFocus);
begin
  inherited;
  DestroyCaret;
  Invalidate;
end;

procedure TFloatEdit.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if (csFixedHeight in ControlStyle) and not ((csDesigning in
    ComponentState) and (csLoading in ComponentState)) then AdjustHeight;
  if (csDesigning in ComponentState) then AdjustHeight;
end;

procedure TFloatEdit.MovePos(Dir: Boolean);
begin
  if Dir and (CurPos<Length(StringFormat)) then
  begin
    CurPos := CurPos + 1;
  end else if (not Dir) and (CurPos>0) then
  begin
    CurPos := CurPos - 1;
  end;
end;

procedure TFloatEdit.SetCaret;
var
  X: Integer;
begin
  if not Focused then Exit;
  Canvas.Font := Font;
  if CurPos=0 then X := ClientWidth-4
  else X := ClientWidth-(Canvas.TextWidth(Copy(StringFormat, 1, CurPos))+4);
  HideCaret(Handle);
  SetCaretPos(X, 1);
  ShowCaret(Handle)
end;

procedure TFloatEdit.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  CreateCaret(Handle, 0, 2, Abs(Font.Height-8));
  ShowCaret(Handle);
  SetCaret;
  Paint
end;

procedure TFloatEdit.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  case Message.Msg of
    WM_GETDLGCODE: Message.Result := DLGC_WANTARROWS;
    EM_GETMARGINS: Message.Result := $00020002;
  end;
end;

//////////////////////////////////////////////////////
//   D A T A     A W A R E
//
constructor TDBFloatEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateDate;
end;

destructor TDBFloatEdit.Destroy;
begin
  FDataLink.OnDataChange := nil;
  FDataLink.OnUpdateData := nil;
  FDataLink.Free;
  inherited Destroy;
end;

procedure TDBFloatEdit.DataChange(Sender: TObject);
begin
  if FDataLink.Field = nil then
  begin
    FloatVal := 0;
  end else
  begin
    if FDataLink.Field.AsFloat<>0 then
    begin
      FloatVal := FDataLink.Field.AsFloat;
    end else
    begin
      FloatVal := 0;
    end;
    Invalidate;
  end;
end;

procedure TDBFloatEdit.UpdateDate(Sender: TObject);
begin
  if (FFloatVal=0) then
    FDataLink.Field.Value := Null
  else FDataLink.Field.AsFloat := FFloatVal
end;

function TDBFloatEdit.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TDBFloatEdit.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDBFloatEdit.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

procedure TDBFloatEdit.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

procedure TDBFloatEdit.CMExit(var Message: TCMLostFocus);
begin
  try
    FDataLink.UpdateRecord;
  except
    on Exception do SetFocus;
  end;
  inherited;
end;

procedure TDBFloatEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
end;

procedure TDBFloatEdit.KeyPress(var Key: Char);
begin
  inherited;
end;

procedure TDBFloatEdit.SetFloatVal(Value: Double);
begin
  if Value<>FFloatVal then
  begin
    inherited;
    if not FDataLink.Editing then FDataLink.Edit;
    FDataLink.Modified;
    Change;
  end;
end;

procedure TDBFloatEdit.Change;
begin
  inherited;
  if Assigned(FOnChange) then FOnChange(Self);
  if not FDataLink.Editing then FDataLink.Edit;
  FDataLink.Modified;
end;

procedure Register;
begin
  RegisterComponents('FALAD', [TFloatEdit, TDBFloatEdit]);
end;

end.
