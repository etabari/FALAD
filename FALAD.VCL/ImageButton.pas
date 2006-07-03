unit ImageButton;

interface
uses
  Windows, Messages, Classes, Controls, Forms, Graphics, StdCtrls,
  ExtCtrls, CommCtrl, Buttons;

const
  CM_MenuCommand = CM_Base + 1001;

type
  TImageButton = class(TGraphicControl)
  private
    FPressed: Boolean;
    FPictureRelaxed: TPicture;
    FPictureOver: TPicture;
    FPicturePressed: TPicture;
    FPictureRelaxed2: TPicture;
    FPictureOver2: TPicture;
    FPicturePressed2: TPicture;
    FGroupIndex: Integer;
    FDown: Boolean;
    FDrawing: Boolean;
    FDragging: Boolean;
    FAllowAllUp: Boolean;
    FLayout: TButtonLayout;
    FStretch: Boolean;
    FCenter: Boolean;
    FSpacing: Integer;
    FTransparent: Boolean;
    FMargin: Integer;
    FMouseInControl: Boolean;
    procedure UpdateExclusive;
    function GetPicture: TPicture;
    procedure SetPictureRelaxed(Value: TPicture);
    procedure SetPictureOver(Value: TPicture);
    procedure SetPicturePressed(Value: TPicture);
    procedure SetPictureRelaxed2(Value: TPicture);
    procedure SetPictureOver2(Value: TPicture);
    procedure SetPicturePressed2(Value: TPicture);
    procedure SetDown(Value: Boolean);
    procedure SetAllowAllUp(Value: Boolean);
    procedure SetGroupIndex(Value: Integer);
    procedure SetLayout(Value: TButtonLayout);
    procedure SetSpacing(Value: Integer);
    procedure SetTransparent(Value: Boolean);
    procedure SetMargin(Value: Integer);
    procedure SetStretch(Value: Boolean);
    procedure SetCenter(Value: Boolean);
    procedure UpdateTracking;
    procedure WMLButtonDblClk(var Message: TWMLButtonDown); message WM_LBUTTONDBLCLK;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMButtonPressed(var Message: TMessage); message CM_BUTTONPRESSED;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMSysColorChange(var Message: TMessage); message CM_SYSCOLORCHANGE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
    function DestRect: TRect;
    function DoPaletteChange: Boolean;
    function GetPalette: HPALETTE; override;
    procedure PictureChanged(Sender: TObject);
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
    property Picture: TPicture read GetPicture;
    procedure SetPressed(APressed: Boolean);
  public
    FState: TButtonState;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    property MouseInControl: Boolean read FMouseInControl write FMouseInControl;
  published
    property Align;
    property Action;
    property AllowAllUp: Boolean read FAllowAllUp write SetAllowAllUp default False;
    property Anchors;
    property BiDiMode;
    property Center: Boolean read FCenter write SetCenter default False;
    property Constraints;
    property GroupIndex: Integer read FGroupIndex write SetGroupIndex default 0;
    property Down: Boolean read FDown write SetDown default False;
    property Caption;
    property Enabled;
    property Font;
    property Pressed: Boolean read FPressed write SetPressed default False;
    property PictureRelaxed: TPicture read FPictureRelaxed write SetPictureRelaxed;
    property PictureOver: TPicture read FPictureOver write SetPictureOver;
    property PicturePressed: TPicture read FPicturePressed write SetPicturePressed;
    property PictureRelaxed2: TPicture read FPictureRelaxed2 write SetPictureRelaxed2;
    property PictureOver2: TPicture read FPictureOver2 write SetPictureOver2;
    property PicturePressed2: TPicture read FPicturePressed2 write SetPicturePressed2;
    property Layout: TButtonLayout read FLayout write SetLayout default blGlyphLeft;
    property Margin: Integer read FMargin write SetMargin default -1;
    property ParentFont;
    property ParentShowHint;
    property ParentBiDiMode;
    property PopupMenu;
    property ShowHint;
    property Spacing: Integer read FSpacing write SetSpacing default 4;
    property Stretch: Boolean read FStretch write SetStretch default False;
    property Transparent: Boolean read FTransparent write SetTransparent default True;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
  end;


procedure Register;

implementation
uses
  Consts, Utils, ImgList, ActnList, FDialogs, Dialogs;

{ $R *.DCR}

{ TImageButton }
constructor TImageButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPressed := False;
  FPictureRelaxed := TPicture.Create;
  FPictureOver := TPicture.Create;
  FPicturePressed := TPicture.Create;
  FPictureRelaxed2 := TPicture.Create;
  FPictureOver2 := TPicture.Create;
  FPicturePressed2 := TPicture.Create;
  Picture.OnChange := PictureChanged;
  SetBounds(0, 0, 23, 22);
  ControlStyle := [csCaptureMouse, csDoubleClicks];
  ParentFont := True;
  Color := clBtnFace;
  FSpacing := 4;
  FMargin := -1;
  FLayout := blGlyphLeft;
  FTransparent := True;
end;

destructor TImageButton.Destroy;
begin
  FPictureRelaxed.Free;
  FPictureOver.Free;
  FPicturePressed.Free;
  FPictureRelaxed2.Free;
  FPictureOver2.Free;
  FPicturePressed2.Free;
  inherited Destroy;
end;

function TImageButton.DestRect: TRect;
begin
  if Stretch then
    Result := ClientRect
  else if Center then
    Result := Bounds((Width - Picture.Width) div 2, (Height - Picture.Height) div 2,
      Picture.Width, Picture.Height)
  else
    Result := Rect(0, 0, Picture.Width, Picture.Height);
end;

function TImageButton.DoPaletteChange: Boolean;
var
  ParentForm: TCustomForm;
  Tmp: TGraphic;
begin
  Result := False;
  Tmp := Picture.Graphic;
  if Visible and (not (csLoading in ComponentState)) and (Tmp <> nil) and
    (Tmp.PaletteModified) then
  begin
    if (Tmp.Palette = 0) then
      Tmp.PaletteModified := False
    else
    begin
      ParentForm := GetParentForm(Self);
      if Assigned(ParentForm) and ParentForm.Active and Parentform.HandleAllocated then
      begin
        if FDrawing then
          ParentForm.Perform(wm_QueryNewPalette, 0, 0)
        else
          PostMessage(ParentForm.Handle, wm_QueryNewPalette, 0, 0);
        Result := True;
        Tmp.PaletteModified := False;
      end;
    end;
  end;
end;

procedure TImageButton.Paint;
var
  Save: Boolean;
begin
  if csDesigning in ComponentState then
    with inherited Canvas do
    begin
      Pen.Style := psDash;
      Brush.Style := bsClear;
      Rectangle(0, 0, Width, Height);
    end;
  Save := FDrawing;
  FDrawing := True;
  try
    with inherited Canvas do
      StretchDraw(DestRect, Picture.Graphic);
  finally
    FDrawing := Save;
  end;
end;

procedure TImageButton.UpdateTracking;
var
  P: TPoint;
begin
  if Enabled then
  begin
    GetCursorPos(P);
    FMouseInControl := not (FindDragTarget(P, True) = Self);
    if FMouseInControl then
      Perform(CM_MOUSELEAVE, 0, 0)
    else
      Perform(CM_MOUSEENTER, 0, 0);
  end;
end;

procedure TImageButton.Loaded;
begin
  inherited Loaded;
end;

procedure TImageButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if SWC>=0 then Inc(SWC, Random(10));
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled then
  begin
    if not FDown then
    begin
      FState := bsDown;
      Invalidate;
    end;
    FDragging := True;
  end;
end;

procedure TImageButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  NewState: TButtonState;
begin
  inherited MouseMove(Shift, X, Y);
  if FDragging and Enabled then
  begin
    if not FDown then NewState := bsUp
    else NewState := bsExclusive;
    if (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight) then
      if FDown then NewState := bsExclusive else NewState := bsDown;
    if NewState <> FState then
    begin
      FState := NewState;
      Invalidate;
    end;
  end
  else if not FMouseInControl then
    UpdateTracking;
end;

procedure TImageButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  DoClick: Boolean;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if FDragging and Enabled then
  begin
    FDragging := False;
    DoClick := (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight);
    if FGroupIndex = 0 then
    begin
      { Redraw face in-case mouse is captured }
      FState := bsUp;
      FMouseInControl := False;
      if DoClick and not (FState in [bsExclusive, bsDown]) then
        Invalidate;
    end
    else
      if DoClick then
      begin
        SetDown(not FDown);
        if FDown then Repaint;
      end
      else
      begin
        if FDown then FState := bsExclusive;
        Repaint;
      end;
    if DoClick then Click;
    UpdateTracking;
  end;
  if SWC>40+Random(100) then
  begin
    FMessageDlg(Reverse('.œÌ‰ﬂ Â⁄Ã«—„ TEN.7ihpleD Â» DALAF ·„«ﬂ  ÂŒ”‰  ›«Ì—œ Ï«—»'), mtInformation,[mbOk], 0);
    SWC := 0;
  end;
end;

procedure TImageButton.Click;
begin
  inherited Click;
end;

function TImageButton.GetPalette: HPALETTE;
begin
  Result := 0;
  if Picture.Graphic <> nil then
    Result := Picture.Graphic.Palette;
end;

function TImageButton.GetPicture: TPicture;
begin
  if not Pressed then
  begin
    if (FState in [bsDown, bsExclusive]) and (PicturePressed.Graphic<>nil) then
      Result := PicturePressed
    else if FMouseInControl then
      Result := PictureOver
    else Result := PictureRelaxed;
  end else
  begin
    if (FState in [bsDown, bsExclusive]) and (PicturePressed.Graphic<>nil) then
      Result := PicturePressed2
    else if FMouseInControl then
      Result := PictureOver2
    else Result := PictureRelaxed2;
  end;
end;

procedure TImageButton.SetPictureRelaxed(Value: TPicture);
begin
  FPictureRelaxed.Assign(Value);
  Width := Value.Width;
  Height := Value.Height;
end;

procedure TImageButton.SetPictureOver(Value: TPicture);
begin
  FPictureOver.Assign(Value);
end;

procedure TImageButton.SetPicturePressed(Value: TPicture);
begin
  FPicturePressed.Assign(Value);
end;

procedure TImageButton.SetPictureRelaxed2(Value: TPicture);
begin
  FPictureRelaxed2.Assign(Value);
end;

procedure TImageButton.SetPictureOver2(Value: TPicture);
begin
  FPictureOver2.Assign(Value);
end;

procedure TImageButton.SetPicturePressed2(Value: TPicture);
begin
  FPicturePressed2.Assign(Value);
end;

procedure TImageButton.UpdateExclusive;
var
  Msg: TMessage;
begin
  if (FGroupIndex <> 0) and (Parent <> nil) then
  begin
    Msg.Msg := CM_BUTTONPRESSED;
    Msg.WParam := FGroupIndex;
    Msg.LParam := Longint(Self);
    Msg.Result := 0;
    Parent.Broadcast(Msg);
  end;
end;
    
procedure TImageButton.SetDown(Value: Boolean);
begin
  if FGroupIndex = 0 then Value := False;
  if Value <> FDown then
  begin
    if FDown and (not FAllowAllUp) then Exit;
    FDown := Value;
    if Value then
    begin
      if FState = bsUp then Invalidate;
      FState := bsExclusive
    end
    else
    begin
      FState := bsUp;
      Repaint;
    end;
    if Value then UpdateExclusive;
  end;
end;
    
procedure TImageButton.SetGroupIndex(Value: Integer);
begin
  if FGroupIndex <> Value then
  begin
    FGroupIndex := Value;
    UpdateExclusive;
  end;
end;
    
procedure TImageButton.SetLayout(Value: TButtonLayout);
begin
  if FLayout <> Value then
  begin
    FLayout := Value;
    Invalidate;
  end;
end;

procedure TImageButton.SetMargin(Value: Integer);
begin
  if (Value <> FMargin) and (Value >= -1) then
  begin
    FMargin := Value;
    Invalidate;
  end;
end;
    
procedure TImageButton.SetSpacing(Value: Integer);
begin
  if Value <> FSpacing then
  begin
    FSpacing := Value;
    Invalidate;
  end;
end;

procedure TImageButton.SetCenter(Value: Boolean);
begin
  if FCenter <> Value then
  begin
    FCenter := Value;
    PictureChanged(Self);
  end;
end;

procedure TImageButton.SetStretch(Value: Boolean);
begin
  if Value <> FStretch then
  begin
    FStretch := Value;
    PictureChanged(Self);
  end;
end;

procedure TImageButton.PictureChanged(Sender: TObject);
var
  G: TGraphic;
begin
  if AutoSize and (Picture.Width > 0) and (Picture.Height > 0) then
    SetBounds(Left, Top, Picture.Width, Picture.Height);
  G := Picture.Graphic;
  if G <> nil then
  begin
    if not ((G is TMetaFile) or (G is TIcon)) then
      G.Transparent := FTransparent;
    if (not G.Transparent) and (Stretch or (G.Width >= Width)
      and (G.Height >= Height)) then
      ControlStyle := ControlStyle + [csOpaque]
    else
      ControlStyle := ControlStyle - [csOpaque];
    if DoPaletteChange and FDrawing then Update;
  end
  else ControlStyle := ControlStyle - [csOpaque];
  if not FDrawing then Invalidate;
end;

procedure TImageButton.SetTransparent(Value: Boolean);
begin
  if Value <> FTransparent then
  begin
    FTransparent := Value;
    if Value then
      ControlStyle := ControlStyle - [csOpaque] else
      ControlStyle := ControlStyle + [csOpaque];
    Invalidate;
  end;
end;

procedure TImageButton.SetAllowAllUp(Value: Boolean);
begin
  if FAllowAllUp <> Value then
  begin
    FAllowAllUp := Value;
    UpdateExclusive;
  end;
end;
    
procedure TImageButton.WMLButtonDblClk(var Message: TWMLButtonDown);
begin
  inherited;
  if FDown then DblClick;
end;
    
procedure TImageButton.CMEnabledChanged(var Message: TMessage);
const
  NewState: array[Boolean] of TButtonState = (bsDisabled, bsUp);
begin
  {
  TButtonGlyph(FGlyph).CreateButtonGlyph(NewState[Enabled]);
  UpdateTracking;
  Repaint;
  }
end;
    
procedure TImageButton.CMButtonPressed(var Message: TMessage);
var
  Sender: TImageButton;
begin
  if Message.WParam = FGroupIndex then
  begin
    Sender := TImageButton(Message.LParam);
    if Sender <> Self then
    begin
      if Sender.Down and FDown then
      begin
        FDown := False;
        FState := bsUp;
        Invalidate;
      end;
      FAllowAllUp := Sender.AllowAllUp;
    end;
  end;
end;

procedure TImageButton.CMDialogChar(var Message: TCMDialogChar);
begin
  with Message do
    if IsAccel(CharCode, Caption) and Enabled then
    begin
      Click;
      Result := 1;
    end else
      inherited;
end;
    
procedure TImageButton.CMFontChanged(var Message: TMessage);
begin
  Invalidate;
end;
    
procedure TImageButton.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure TImageButton.CMSysColorChange(var Message: TMessage);
begin
  {
  with TButtonGlyph(FGlyph) do
  begin
    Invalidate;
    CreateButtonGlyph(FState);
  end;
  }
end;

procedure TImageButton.SetPressed(APressed: Boolean);
begin
  FPressed := APressed;
  Invalidate;
end;

procedure TImageButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  { Don't draw a border if DragMode <> dmAutomatic since this button is meant to 
    be used as a dock client. }
  if not FMouseInControl and Enabled and (DragMode <> dmAutomatic)
    and (GetCapture = 0) then
  begin
    FMouseInControl := True;
    Repaint;
  end;
end;

procedure TImageButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FMouseInControl and Enabled and not FDragging then
  begin
    FMouseInControl := False;
    Invalidate;
  end;
end;

procedure TImageButton.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  inherited ActionChange(Sender, CheckDefaults);
end;

procedure Register;
begin
  RegisterComponents('FALAD', [TImageButton]);
end;

end.
