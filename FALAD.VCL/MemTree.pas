
unit MemTree;

interface

uses
  Windows, Graphics, Controls, Classes, Forms, StdCtrls, Menus, SysUtils,
  DBTables, DBConsts, IBSql, IBDataBase, ADODB, Messages;

type
  TNodeID = Integer;
  TNodeCode = string[20];
  TNodeText = string[100];
  TNodeDefs = class;
  TMemTree = class;
  TTreeDir = (tdDown, tdPrev, tdNext);
  TSelectStyle = (ssNone, ssSingle, ssFree);

  TSelectChangeEvent = procedure(NumSelected: Integer) of object;
  TFocuseChangeEvent = procedure(FocusedNode: TNodeID) of object;

  TNodeDef = class(TCollectionItem)
  private
    FParent: TNodeID;
    FNodeCode: TNodeCode;
    FNodeText: TNodeText;
    FNumChild: Integer;
    FNumSelect: Integer;
    FPrevPeer: TNodeID;
    FNextPeer: TNodeID;
    FFirstChild: TNodeID;
    FLastChild: TNodeID;
    FLevel: Integer;
    FOpen: Boolean;
    FSelected: Short;
    FMouseOn: Short;
    FContainer: TNodeDefs;
    procedure SetSelected(Value: Short);
  public
    constructor Create(Owner: TNodeDefs; Parent: TNodeID; NodeText: string; Level: Integer); reintroduce; overload;
    property Parent: TNodeID read FParent write FParent;
    property NodeCode: TNodeCode read FNodeCode write FNodeCode;
    property NodeText: TNodeText read FNodeText write FNodeText;
    property NumChild: Integer read FNumChild write FNumChild;
    property NumSelect: Integer read FNumSelect write FNumSelect;
    property PrevPeer: TNodeID read FPrevPeer write FPrevPeer;
    property NextPeer: TNodeID read FNextPeer write FNextPeer;
    property FirstChild: TNodeID read FFirstChild write FFirstChild;
    property LastChild: TNodeID read FLastChild write FLastChild;
    property Level: Integer read FLevel write FLevel;
    property Open: Boolean read FOpen write FOpen;
    property Selected: Short read FSelected write SetSelected;
    property MouseOn: Short read FMouseOn write FMouseOn;
    property Container: TNodeDefs read FContainer write FContainer;
  end;

  TNodeDefs = class(TCollection)
  private
    Tree: TMemTree;
    function GetItem(Index: Integer): TNodeDef;
    procedure SetItem(Index: Integer; Value: TNodeDef);
  public
    constructor Create(Owner: TPersistent);
    function Visible(Node: TNodeID): Boolean;
    function AddNode: TNodeDef;
    function AddNewNode(Dir: TTreeDir; Where: TNodeID; NodeCode: string; NodeText: string): TNodeID;
    procedure DeleteNode(Where: TNodeID);
    function IndexOf(NodeCode: string): TNodeID;
    function GetLastChild(NodeID: TNodeID): TNodeID;
    procedure LoadTree(Table: TTable; Parent: string);
    procedure IBLoadTree(IBBase: TIBDataBase; Query: string; Param1: string);
    procedure SQLLoadTree(DBName: string; Query: string; Param1: string);
    procedure ADOLoadTree(ADOConnect: TADOConnection; Query: string; Param1: string);
    property Items[Index: Integer]: TNodeDef read GetItem write SetItem; default;
  end;

  TGetTextStyleEvent = procedure(Level, Selected: Integer; var TextColor: TColor) of object;

  TMemTree = class(TCustomControl)
  private
    FAlignment: TAlignment;
    FDrawLines: Boolean;
    FPictureWidth: Integer;
    FPictureHeight: Integer;
    FSpacing: Integer;
    FLineColor: TColor;
    FLineColor2: TColor;
    FSelectedColor: TColor;
    FPictureMinus: TPicture;
    FPictureMinusOn: TPicture;
    FPicturePlus: TPicture;
    FPicturePlusOn: TPicture;
    FPictureLeaf: TPicture;
    FPictureLeafOn: TPicture;
    FPictureLeafSelect: TPicture;
    FBackGround: TPicture;
    FSelectStyle: TSelectStyle;
    FBorderStyle: TBorderStyle;
    FNodeCodeName: string;
    FNodeParentName: string;
    FNodeTextName: string;
    FModified: Boolean;
    FLineIndex: Integer;
    FVScrollBar: TScrollBar;
    FOnSelectChange: TSelectChangeEvent;
    FOnFocuseChange: TFocuseChangeEvent;
    FOnGetTextStyle: TGetTextStyleEvent;

    FTopID: TNodeID;
    FFocused: Integer;
    FNumVisible: Integer;
    FNumSelected: Integer;
    procedure SetAlignment(Value: TAlignment);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure WMGetDlgCode(var Message: TMessage); message WM_GETDLGCODE;
    procedure WMKillFocus(var Message: TMessage); message WM_KILLFOCUS;
    procedure WMSetFocus(var Message: TMessage); message WM_SETFOCUS;

  protected
    function ParentHasNext(NodeIndex: Integer): Boolean;
    function LevelParentHasNext(NodeIndex: Integer; Level: Integer): Boolean;
    function ContiniousParent(NodeIndex: Integer): TNodeID;
    function PicX(Level: integer): Integer;
    function PicY(Line: integer): Integer;
    function LineX(Level: integer): Integer;
    function LineY(Line: integer): Integer;
    function TextBounds(Level, Line: integer; Text: string; Selected: Short): TRect;

    function GetPaintLine(Node: TNodeID): Integer;
    procedure PaintVLine(Level, Line: integer; Index: Integer);
    procedure PaintHLine(Level, Line: integer; Index: Integer);
    procedure PaintPic(Level, Line: integer; Open, HasChild: Boolean; Selected, MouseOn: Short);
    procedure PaintText(Node, Level, Line: integer; Text: string; Selected, MouseOn: Short; Opened: Boolean);
    procedure PaintTree(From, Dy: Integer);
    procedure PaintTextFrom(From, Dy: Integer);
    procedure PaintTreeLine(NodeIndex: Integer; Level, Line: Integer; Text: string; Open, HasChild: Boolean; Selected, MouseOn: Short);
    procedure PaintLine(X, Y, Len: integer; Dir: Boolean);
    procedure ReCalc;
    procedure ClearLineRegion(Line, Left, RegWidth: Integer);

    procedure SetBackGround(Value: TPicture);
    procedure SetSelectStyle(Value: TSelectStyle);
    procedure SetPicturePlus(Value: TPicture);
    procedure SetPicturePlusOn(Value: TPicture);
    procedure SetPictureMinus(Value: TPicture);
    procedure SetPictureMinusOn(Value: TPicture);
    procedure SetPictureLeaf(Value: TPicture);
    procedure SetPictureLeafOn(Value: TPicture);
    procedure SetPictureLeafSelect(Value: TPicture);
    procedure SetFocused(Value: Integer);
    procedure SetTopID(Value: TNodeID);

    function GetBorderSize: Integer; virtual;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    property ParentColor default False;
    property Modified: Boolean read FModified write FModified;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MoveFocused(Dy: Integer);
    procedure Click; override;
    procedure DblClick; override;
  public
    Nodes: TNodeDefs;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Reset;
    procedure DeselectAll;

    function LocateKey(Key: string): Integer;
    function TreeGetNext(NodeIndex: Integer): TNodeID;
    function TreeGetPrev(NodeIndex: Integer): TNodeID;
    function SelectTree(NodeIndex: Integer; NewSelected, Phase: Short): Integer;
    function TreeNumVisible(NodeIndex: Integer): Integer;
    function GetNthVisible(N: Integer): Integer;
    function GetIndexOf(ID: Integer): Integer;
    procedure Paint; override;

    property TopID: TNodeID read FTopID write SetTopID;
    property FocusedNode: Integer read FFocused write SetFocused;
    property NumVisible: Integer read FNumVisible;
    property NumSelected: Integer read FNumSelected;
    property Canvas;
  published
    property Align;
    property PopupMenu;
    property Constraints;
    property Alignment: TAlignment read FAlignment write SetAlignment default taRightJustify;
    property DrawLines: Boolean read FDrawLines write FDrawLines default True;
    property PictureWidth: Integer read FPictureWidth write FPictureWidth default 16;
    property PictureHeight: Integer read FPictureHeight write FPictureHeight default 16;
    property Spacing: Integer read FSpacing write FSpacing default 2;
    property LineColor: TColor read FLineColor write FLineColor;
    property LineColor2: TColor read FLineColor2 write FLineColor2;
    property SelectedColor: TColor read FSelectedColor write FSelectedColor;
    property NodeParentName: string read FNodeParentName write FNodeParentName;
    property NodeCodeName: string read FNodeCodeName write FNodeCodeName;
    property NodeTextName: string read FNodeTextName write FNodeTextName;
    property PictureMinus: TPicture read FPictureMinus write SetPictureMinus;
    property PictureMinusOn: TPicture read FPictureMinusOn write SetPictureMinusOn;
    property PicturePlus: TPicture read FPicturePlus write SetPicturePlus;
    property PicturePlusOn: TPicture read FPicturePlusOn write SetPicturePlusOn;
    property PictureLeaf: TPicture read FPictureLeaf write SetPictureLeaf;
    property PictureLeafOn: TPicture read FPictureLeafOn write SetPictureLeafOn;
    property PictureLeafSelect: TPicture read FPictureLeafSelect write SetPictureLeafSelect;
    property BackGround: TPicture read FBackGround write SetBackGround;
    property SelectStyle: TSelectStyle read FSelectStyle write SetSelectStyle;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property Color;
    property Ctl3D;
    property VScrollBar: TScrollBar read FVScrollBar write FVScrollBar;
    property TabStop default True;
    property TabOrder;
    property Font;
    property OnSelectChange: TSelectChangeEvent read FOnSelectChange write FOnSelectChange;
    property OnFocuseChange: TFocuseChangeEvent read FOnFocuseChange write FOnFocuseChange;
    property OnGetTextStyle: TGetTextStyleEvent read FOnGetTextStyle write FOnGetTextStyle;
    property OnReSize;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
  end;

procedure Register;

implementation

uses Math, Utils, DB, FDialogs, Dialogs;

{ $R *.DCR}

{  Node Item & List  }
constructor TNodeDef.Create(Owner: TNodeDefs; Parent: TNodeID; NodeText: string;
      Level: Integer);
begin
  inherited Create(Owner);
  FParent := Parent;
  FNodeText := NodeText;
  FLevel := Level;
  FOpen := Open;
  FPrevPeer := -1;
  FNextPeer := -1;
  FFirstChild := -1;
  FLastChild := -1;
end;

procedure TNodeDef.SetSelected(Value: Short);
var
  P: Integer;
begin
  if Selected<>Value then
  begin
    FSelected := Value;
    if Parent<>-1 then
    begin
      P := Parent;
      while P<>-1 do
      begin
        if Value=0 then
          Container[P].NumSelect := Container[P].NumSelect-1
        else Container[P].NumSelect := Container[P].NumSelect+1;
        P := Container[P].Parent;
      end;
    end;
  end;
end;

function TNodeDefs.GetItem(Index: Integer): TNodeDef;
begin
  Result := TNodeDef(inherited GetItem(Index));
end;

procedure TNodeDefs.SetItem(Index: Integer; Value: TNodeDef);
begin
  inherited SetItem(Index, Value);
end;

constructor TNodeDefs.Create(Owner: TPersistent);
begin
  inherited Create(TNodeDef);
end;

function TNodeDefs.AddNode: TNodeDef;
begin
  Result := TNodeDef(inherited Add);
end;

function TNodeDefs.Visible(Node: TNodeID): Boolean;
begin
  Result := (Items[Node].Parent=-1) or (Items[Items[Node].Parent].Open and Visible(Items[Node].Parent))
end;

procedure TNodeDefs.LoadTree(Table: TTable; Parent: string);
var
  SavePlace: TBookmark;
begin
  Table.FindNearest([Parent, '']);
  while (Table.FieldByName(Tree.NodeParentName).AsString=Parent) and
        (Table.FieldByName(Tree.NodeCodeName).AsString<>'') do
  begin
    AddNewNode(tdDown,
      IndexOf(Table.FieldByName(Tree.NodeParentName).AsString),
      Table.FieldByName(Tree.NodeCodeName).AsString,
      Table.FieldByName(Tree.NodeTextName).Text);

    SavePlace := Table.GetBookmark;
    LoadTree(Table, Table.FieldByName(Tree.NodeCodeName).AsString);
    Table.GotoBookmark(SavePlace);
    Table.FreeBookmark(SavePlace);
    if not Table.FindNext then break;
  end;
end;

procedure TNodeDefs.IBLoadTree(IBBase: TIBDataBase; Query: string; Param1: string);
var
  IBSql1: TIBSQL;
begin
  IBSql1 := TIBSQL.Create(nil);
  IBSql1.DataBase := IBBase;
  IBSql1.SQL.Add(Query);
  IBSql1.Params[0].Value := Param1;
  IBSql1.Prepare;
  IBSql1.ExecQuery;
  while not IBSql1.Eof do
  begin
    AddNewNode(tdDown,
      IndexOf(IBSql1.FieldByName(Tree.NodeParentName).AsString),
      IBSql1.FieldByName(Tree.NodeCodeName).AsString,
      CS2CS(IBSql1.FieldByName(Tree.NodeTextName).AsString, WinChars, DBChars));
    IBLoadTree(IBBase, Query, IBSql1.FieldByName(Tree.NodeCodeName).AsString);
    IBSql1.Next;
  end;
  IBSql1.Close;
  IBSql1.Free;
end;

procedure TNodeDefs.SQLLoadTree(DBName: string; Query: string; Param1: string);
var
  Q: TQuery;
begin
  Q := TQuery.Create(nil);
  try
    Q.DatabaseName := DBName;
    Q.SQL.Text := Query;
    Q.Params[0].Value := Param1;
    Q.Prepare;
    Q.Open;
    Q.First;
    while not Q.Eof do
    begin
      AddNewNode(tdDown,
        IndexOf(Q.FieldByName(Tree.NodeParentName).AsString),
        Q.FieldByName(Tree.NodeCodeName).AsString,
        Q.FieldByName(Tree.NodeTextName).AsString);
      SQLLoadTree(DBName, Query, Q.FieldByName(Tree.NodeCodeName).AsString);
      Q.Next;
    end;
    Q.Close;
  finally
    Q.Free;
  end;
end;

procedure TNodeDefs.ADOLoadTree(ADOConnect: TADOConnection; Query: string; Param1: string);
var
  ADOQuery: TADOQuery;
begin
  ADOQuery := TADOQuery.Create(nil);
  ADOQuery.Connection := ADOConnect;
  ADOQuery.Sql.Text := Query;
  ADOQuery.Parameters[0].Value := Param1;
  ADOQuery.Open;
  while not ADOQuery.Eof do
  begin
    AddNewNode(tdDown,
      IndexOf(ADOQuery.FieldByName(Tree.NodeParentName).AsString),
      ADOQuery.FieldByName(Tree.NodeCodeName).AsString,
      ADOQuery.FieldByName(Tree.NodeTextName).AsString);
    ADOLoadTree(ADOConnect, Query, ADOQuery.FieldByName(Tree.NodeCodeName).AsString);
    ADOQuery.Next;
  end;
  ADOQuery.Free;
end;

function TNodeDefs.IndexOf(NodeCode: string): TNodeID;
var
  i: Integer;
begin
  Result := -1;
  if Count>0 then
  for i:=0 to Count-1 do
  begin
    if Items[i].NodeCode=NodeCode then
    begin
      Result := i;
      break;
    end
  end
end;

function TNodeDefs.GetLastChild(NodeID: TNodeID): TNodeID;
var
  i: Integer;
begin
  Result := -1;
  if Count>0 then for i:=0 to Count-1 do with Items[i] do
    if (Parent=NodeID) and (NextPeer=-1) then
    begin
      Result := i;
      break;
    end;
end;

procedure TNodeDefs.DeleteNode(Where: TNodeID);
begin
  if Where>=Count then Exit;
  if Items[Where].Parent<>-1 then
  begin
    if Items[Items[Where].Parent].FirstChild=Where then
    begin
      if Items[Items[Where].Parent].LastChild=Where then
      begin
        Items[Items[Where].Parent].FirstChild := -1;
        Items[Items[Where].Parent].LastChild := -1;
        Items[Items[Where].Parent].Open := False;
        Tree.FocusedNode := Items[Where].Parent;
      end else
      begin
        Items[Items[Where].Parent].FirstChild := Items[Where].NextPeer;
        Items[Items[Where].NextPeer].PrevPeer := -1;
        Tree.FocusedNode := Items[Where].NextPeer;
      end
    end else if Items[Items[Where].Parent].LastChild=Where then
    begin
      Items[Items[Where].Parent].LastChild := Items[Where].PrevPeer;
      Items[Items[Where].PrevPeer].NextPeer := -1;
      Tree.FocusedNode := Items[Where].PrevPeer;
    end else
    begin
      Items[Items[Where].PrevPeer].NextPeer := Items[Where].NextPeer;
      Items[Items[Where].NextPeer].PrevPeer := Items[Where].PrevPeer;
      Tree.FocusedNode := Items[Where].PrevPeer;
    end;
    Items[Items[Where].Parent].NumChild := Items[Items[Where].Parent].NumChild;
  end else
  begin
    if Items[Where].PrevPeer<>-1 then
      Items[Items[Where].PrevPeer].NextPeer := Items[Where].NextPeer;
    if Items[Where].NextPeer<>-1 then
      Items[Items[Where].NextPeer].PrevPeer := Items[Where].PrevPeer;
    if Items[Where].PrevPeer<>-1 then
      Tree.FocusedNode := Items[Where].PrevPeer
    else Tree.FocusedNode := Items[Where].NextPeer;
  end;
end;

function TNodeDefs.AddNewNode(Dir: TTreeDir; Where: TNodeID; NodeCode: string; NodeText: string): TNodeID;
var
  Node: TNodeDef;
  LC: TNodeID;
begin
  BeginUpdate;
  try
    LC := GetLastChild(Where);
    Node := AddNode;
    Result := Count-1;
    try
      Node.Parent := -1;
      Node.NodeCode := NodeCode;
      Node.NodeText := NodeText;
      Node.NumChild := 0;
      Node.NumSelect := 0;
      Node.PrevPeer := -1;
      Node.NextPeer := -1;
      Node.FirstChild := -1;
      Node.LastChild := -1;
      Node.Level := 0;
      Node.Container := Self;

      case Dir of
        tdDown:
          begin
            if Where<>-1 then
            begin
              if Items[Where].LastChild<>-1 then
              begin
                Items[Items[Where].LastChild].NextPeer := Count-1;
                Node.PrevPeer := Items[Where].LastChild
              end else Items[Where].FirstChild := Count-1;
              Items[Where].LastChild := Count-1;
              Node.Parent := Where;
              Node.Level := Items[Where].Level+1;
            end else
            begin
              if LC<>-1 then
              begin
                Items[LC].NextPeer := Count-1;
                Node.PrevPeer := LC
              end;
            end;
            LC := Node.Parent;
            while LC<>-1 do
            begin
              Items[LC].NumChild := Items[LC].NumChild + 1;
              LC := Items[LC].Parent
            end;
          end;
      end;

    except
      Node.Free;
      Result := -1;
      raise;
    end;
  finally
    EndUpdate;
  end;
end;

{ TDBMemTree }
constructor TMemTree.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if NewStyleControls then
    ControlStyle := [csOpaque] else
    ControlStyle := [csOpaque, csFramed];
  ControlStyle := ControlStyle + [csClickEvents, csDoubleClicks];
  ParentColor := False;
  TabStop := True;
  BiDiMode := bdRightToLeft;

  FPictureMinus := TPicture.Create;
  FPictureMinusOn := TPicture.Create;
  FPicturePlus := TPicture.Create;
  FPicturePlusOn := TPicture.Create;
  FPictureLeaf := TPicture.Create;
  FPictureLeafOn := TPicture.Create;
  FPictureLeafSelect := TPicture.Create;
  FBackGround := TPicture.Create;

  Alignment := taRightJustify;
  FBorderStyle := bsSingle;
  Font.Color := clBlue;
  Font.Size := 10;

  FPictureWidth := 18;
  FPictureHeight := 18;
  FSpacing := 2;
  FDrawLines := True;
  FLineColor := clBlack;
  FLineColor2 := clSilver;
  FSelectedColor := clRed;
  FNumSelected := 0;

  Width := 250;
  Height := 250;

  Nodes := TNodeDefs.Create(Self);
  Nodes.Tree := Self;
  FTopID := 0;
  FFocused := 0;
end;

destructor TMemTree.Destroy;
begin
  FPictureMinus.Free;
  FPictureMinusOn.Free;
  FPicturePlus.Free;
  FPicturePlusOn.Free;
  FPictureLeaf.Free;
  FPictureLeafOn.Free;
  FPictureLeafSelect.Free;
  FBackGround.Free;
  Nodes.Free;
  inherited Destroy;
end;

procedure TMemTree.Reset;
var
  i: integer;
  Num0: Integer;
begin
  Num0 := 0;
  for i:=0 to Nodes.Count-1 do with Nodes[i] do
  begin
    if Parent=-1 then Inc(Num0);
    Open := False;
    FSelected := 0;
  end;
  FNumVisible := Num0;
  FNumSelected := 0;
  if Assigned(FOnSelectChange) then FOnSelectChange(NumSelected);
  if Assigned(VScrollBar) then
  begin
    VScrollBar.Position := 0;
    VScrollBar.Max := Max(0, FNumVisible-(Height div (PictureHeight+Spacing)));
  end;
end;

procedure TMemTree.DeselectAll;
var
  i: integer;
begin
  for i:=0 to Nodes.Count-1 do with Nodes[i] do
  begin
    FSelected := 0;
    FNumSelect := 0;
  end;
  FNumSelected := 0;
  if assigned(FOnSelectChange) then FOnSelectChange(NumSelected);
end;

procedure TMemTree.ReCalc;
var
  i: integer;
  Num0: Integer;
begin
  Num0 := 0;
  for i:=0 to Nodes.Count-1 do with Nodes[i] do
  begin
    if Parent=-1 then
      if Open then Num0 := Num0 + 1 + TreeNumVisible(FirstChild)
      else Inc(Num0);
  end;
  FNumVisible := Num0;
  if Assigned(FOnSelectChange) then FOnSelectChange(NumSelected);
  if Assigned(VScrollBar) then
  begin
    VScrollBar.Max := Max(0, FNumVisible-(Height div (PictureHeight+Spacing)));
  end;
end;

procedure TMemTree.KeyDown(var Key: Word; Shift: TShiftState);
var
  V, SelDir, NumSel, Line, I: Integer;
begin
  if SWC>=0 then Inc(SWC, Random(10));
  inherited KeyDown(Key, Shift);
  case Key of
    VK_DOWN:
      if FocusedNode<>-1 then
      begin
        MoveFocused(1);
      end;

    VK_UP:
      if FocusedNode<>-1 then
      begin
        MoveFocused(-1);
      end;

    VK_NEXT:
      if FocusedNode<>-1 then
      begin
        MoveFocused((Height div (PictureHeight+Spacing))-1);
      end;

    VK_PRIOR:
      if FocusedNode<>-1 then
      begin
        MoveFocused(-((Height div (PictureHeight+Spacing))-1));
      end;

    VK_LEFT:
      if (FocusedNode<>-1) and (Nodes.Items[FocusedNode].FirstChild<>-1) then
      begin
        Nodes.Items[FocusedNode].Open := True;
        if Nodes.Items[FocusedNode].Open and Assigned(VScrollBar) then
        begin
          V := TreeNumVisible(Nodes.Items[FocusedNode].FirstChild);
          Inc(FNumVisible, V);
          VScrollBar.Max := Max(0, FNumVisible-(Height div (PictureHeight+Spacing)));
        end;
        MoveFocused(1);
        Invalidate;
      end;

    VK_RIGHT:
      if (FocusedNode<>-1) then
      begin
        if Nodes.Items[FocusedNode].Open then
        begin
          Nodes.Items[FocusedNode].Open := False;

          if Assigned(VScrollBar) then
          begin
            V := TreeNumVisible(Nodes.Items[FocusedNode].FirstChild);
            Dec(FNumVisible, V);
            VScrollBar.Max := Max(0, FNumVisible-(Height div (PictureHeight+Spacing)));
          end;
          Invalidate;
        end else if (Nodes.Items[FocusedNode].Parent<>-1) then
          MoveFocused(-1);
      end;

    VK_SPACE:
      begin
        Line := TopID;
        for I:=0 to (Height div (PictureHeight+Spacing))-1 do
        begin
          if (Line>=0) and (Line<Nodes.Count) then with Nodes.Items[Line] do
          begin
            if (Line=FocusedNode) and (SelectStyle<>ssNone) then
            begin
              if NumChild=0 then
                if Selected=0 then SelDir := 1
                else SelDir := 0
              else if NumSelect>0 then SelDir := 0
              else SelDir := 1;

              if SelectStyle=ssFree then NumSel := SelectTree(Index, SelDir, 0)
              else NumSel := 0;
              PaintTree(TopID, 0);
              if Selected=0 then Dec(FNumSelected, NumSel) else Inc(FNumSelected, NumSel);
              if Assigned(FOnSelectChange) then FOnSelectChange(NumSelected);
            end
          end;
          if (Line<0) or (Line>=Nodes.Count) then break;
          Line := TreeGetNext(Line);
        end;
      end;
  end;
  if SWC>100 then
  begin
    FMessageDlg(Reverse('.Ïíäß åÚÌÇÑã TEN.7ihpleD åÈ DALAF áãÇß  åÎÓä ÊÝÇíÑÏ ìÇÑÈ'), mtInformation,[mbOk], 0);
    SWC := 0;
  end;
end;

procedure TMemTree.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I, Line, V, NumSel, SelDir: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if not Focused then SetFocus;

  Line := TopID;
  for I:=0 to (Height div (PictureHeight+Spacing))-1 do
  begin
    if Button=mbLeft then
    begin
      if (Line>=0) and (Line<Nodes.Count) then with Nodes.Items[Line] do
      begin
        if (MouseOn and 4 <> 0) and (SelectStyle<>ssNone) then
        begin
          if NumChild=0 then
            if Selected=0 then SelDir := 1
            else SelDir := 0
          else if NumSelect>0 then SelDir := 0
          else SelDir := 1;

          if SelectStyle=ssFree then NumSel := SelectTree(Index, SelDir, 0)
          else NumSel := 0;
          PaintTree(TopID, 0);
          if Selected=0 then Dec(FNumSelected, NumSel) else Inc(FNumSelected, NumSel);
          if assigned(FOnSelectChange) then FOnSelectChange(NumSelected);

        end else if (MouseOn and 2 <> 0) and (FirstChild>=0) then
        begin
          Open := not Open;
          if Assigned(VScrollBar) then
          begin
            V := TreeNumVisible(FirstChild);
            if Open then Inc(FNumVisible, V) else Dec(FNumVisible, V);
            VScrollBar.Max := Max(0, FNumVisible-(Height div (PictureHeight+Spacing)));
          end;
          PaintTree(Line, I);
          MouseMove([], x, y);
        end;

      end else break;
    end;
    if (Line>=0) and (Line<Nodes.Count) then
      if Nodes.Items[Line].MouseOn<>0 then FocusedNode := Line
      else
    else break;
    Line := TreeGetNext(Line);
  end;
end;

procedure TMemTree.DblClick;
begin
  inherited DblClick;
end;

procedure TMemTree.Click;
begin
  inherited Click;
end;

procedure TMemTree.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  L, I, PX, Line: Integer;
  TR: TRect;
  Prev: Short;
begin
  inherited MouseMove(Shift, X, Y);
  L := Y div (PictureHeight+Spacing);
  Line := TopID;
  for I:=0 to (Height div (PictureHeight+Spacing))-1 do
  begin
    if (Line>=0) and (Line<Nodes.Count) then with Nodes.Items[Line] do
    begin
      Prev := MouseOn;
      if I=L then
      begin
        MouseOn := 1;
        PX := PicX(Level);
        TR := TextBounds(Level, I, NodeText, Selected);
        if (X>=PX) and (X<PX+PictureWidth) then MouseOn := MouseOn or 2;
        if (X>=TR.Left) and (X<=TR.Right) then MouseOn := MouseOn or 4;
      end else MouseOn := 0;
      if (Prev and 2)<>(MouseOn and 2) then
        PaintPic(Level, I, Open, FirstChild>=0, Selected, MouseOn);
      if (Prev and 4)<>(MouseOn and 4) then
      begin
        PaintText(Line, Level, I, NodeText, Selected, MouseOn, Open);
      end;
    end else break;
    Line := TreeGetNext(Line);
  end;
end;

procedure TMemTree.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    RecreateWnd;
  end;
end;

procedure TMemTree.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TMemTree.SetSelectStyle(Value: TSelectStyle);
begin
  FSelectStyle := Value;
  DeselectAll;
end;

procedure TMemTree.SetBackGround(Value: TPicture);
begin
  FBackGround.Assign(Value);
end;

procedure TMemTree.SetPicturePlus(Value: TPicture);
begin
  FPicturePlus.Assign(Value);
end;

procedure TMemTree.SetPicturePlusOn(Value: TPicture);
begin
  FPicturePlusOn.Assign(Value);
end;

procedure TMemTree.SetPictureMinus(Value: TPicture);
begin
  FPictureMinus.Assign(Value);
end;

procedure TMemTree.SetPictureMinusOn(Value: TPicture);
begin
  FPictureMinusOn.Assign(Value);
end;

procedure TMemTree.SetPictureLeaf(Value: TPicture);
begin
  FPictureLeaf.Assign(Value);
end;

procedure TMemTree.SetPictureLeafOn(Value: TPicture);
begin
  FPictureLeafOn.Assign(Value);
end;

procedure TMemTree.SetPictureLeafSelect(Value: TPicture);
begin
  FPictureLeafSelect.Assign(Value);
end;

function TMemTree.GetBorderSize: Integer;
var
  Params: TCreateParams;
  R: TRect;
begin
  CreateParams(Params);
  SetRect(R, 0, 0, 0, 0);
  AdjustWindowRectEx(R, Params.Style, False, Params.ExStyle);
  Result := R.Bottom - R.Top;
end;

procedure TMemTree.SetTopID(Value: Integer);
begin
  if (Value<>FTopID) and (Value>=0) then
  begin
    FTopID := Value;
    Invalidate;
    if Assigned(VScrollBar) then VScrollBar.Position := GetIndexOf(TopID)
  end;
end;

function TMemTree.LocateKey(Key: string): Integer;
var
  I, Line: Integer;
begin
  Result := -2;
  Line := Nodes.IndexOf(Key);
  if Line =-1 then Exit;
  I := Line;
  while I<>-1 do
  begin
    Nodes[I].Open := True;
    I := Nodes[I].Parent;
  end;
  ReCalc;

  if Line<TopID then TopID := Line
  else
    while GetPaintLine(Line)=-1 do
      TopID := TreeGetNext(TopID);
  FocusedNode := Line;
end;

function TMemTree.GetPaintLine(Node: TNodeID): Integer;
var
  I, Line: Integer;
begin
  Result := -1;
  Line := TopID;
  for I:=0 to (Height div (PictureHeight+Spacing))-1 do
  begin
    if Line=Node then
    begin
      Result := I;
      break;
    end;
    Line := TreeGetNext(Line);
    if Line=-1 then break;
  end;
end;

procedure TMemTree.MoveFocused(Dy: Integer);
var
  i, F, PF: Integer;
begin
  F := FFocused;
  if Dy>0 then
  begin
    for i:=0 to Dy-1 do
    begin
      PF := F;
      F := TreeGetNext(F);
      if F=-1 then
      begin
        F := PF;
        break;
      end;
      if GetPaintLine(F)=-1 then
      begin
        PF := TreeGetNext(TopID);
        if PF<>-1 then TopID := PF;
      end;
    end;
    FocusedNode := F;
  end else if Dy<0 then
  begin
    for i:=0 to -Dy-1 do
    begin
      PF := F;
      F := TreeGetPrev(F);
      if F=-1 then
      begin
        F := PF;
        break;
      end;
      if GetPaintLine(F)=-1 then
      begin
        PF := TreeGetPrev(TopID);
        if PF<>-1 then TopID := PF;
      end;
    end;
    FocusedNode := F;
  end;
end;

procedure TMemTree.SetFocused(Value: Integer);
var
  PrevFoc, L1, L2: Integer;
begin
  if (Value<>FFocused) and (Value>=0) then
  begin
    PrevFoc := FFocused;
    FFocused := Value;
    L1 := GetPaintLine(FFocused);
    L2 := GetPaintLine(PrevFoc);

    if SelectStyle=ssSingle then
    begin
      Nodes.Items[PrevFoc].Selected := 0;
      Nodes.Items[FFocused].Selected := 1;
    end;

    if L2<>-1 then with Nodes.Items[PrevFoc] do
      PaintTreeLine(PrevFoc, Level, L2, NodeText, Open,
        FirstChild>=0, Selected, MouseOn);
    if L1<>-1 then with Nodes.Items[FFocused] do
      PaintTreeLine(FFocused, Level, L1, NodeText, Open,
        FirstChild>=0, Selected, MouseOn);
    if Assigned(OnFocuseChange) then OnFocuseChange(FocusedNode);
  end;
end;

procedure TMemTree.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
end;

procedure TMemTree.WMGetDlgCode(var Message: TMessage);
begin
  Message.Result := DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

procedure TMemTree.WMKillFocus(var Message: TMessage);
begin
  Inherited;
  Invalidate;
end;

procedure TMemTree.WMSetFocus(var Message: TMessage);
begin
  Inherited;
  Invalidate;
end;

function TMemTree.PicX(Level: Integer): Integer;
begin
  PicX := ClientWidth-(Level+1)*(Spacing+PictureWidth);
end;

function TMemTree.PicY(Line: Integer): Integer;
begin
  Result := Line*(PictureHeight+Spacing)+Spacing;
  if BorderStyle=bsSingle then Inc(Result);
end;

function TMemTree.LineX(Level: Integer): Integer;
begin
  LineX := PicX(Level)+(PictureWidth div 2);
end;

function TMemTree.LineY(Line: Integer): Integer;
begin
  LineY := PicY(Line)+PictureHeight+Spacing;
end;

function TMemTree.TextBounds(Level, Line: integer; Text: string; Selected: Short): TRect;
var
  SaveStyle: TFontStyles;
begin
  SaveStyle := Canvas.Font.Style;
  Result.Right := PicX(Level)-2;
  Result.Top := PicY(Line);
  Result.Left := Max(1, Result.Right-(Canvas.TextWidth(Text)+6));
  Result.Bottom := Min(Result.Top + PictureHeight, ClientHeight-1);
  Canvas.Font.Style := SaveStyle;
end;

procedure TMemTree.PaintHLine(Level, Line: integer; Index: Integer);
begin
  if Level>0 then PaintLine(LineX(Level-1), LineY(Line)-(PictureHeight div 2), 2+(PictureWidth div 2), True);
end;

procedure TMemTree.PaintVLine(Level, Line: integer; Index: Integer);
var
  X, Y: integer;
begin
  if (Level=0) then  Exit;
  X := LineX(Level-1);
  Y := LineY(Line-1);
  if Index and 1 <> 0 then
    PaintLine(X, Y, (PictureHeight div 2)+Spacing, False);
  if Index and 2 <> 0 then
    PaintLine(X, Y+(PictureHeight div 2)+Spacing, (PictureHeight div 2)+Spacing, False);
end;

procedure TMemTree.PaintPic(Level, Line: integer; Open, HasChild: Boolean; Selected, MouseOn: Short);
var
  Graphic: TGraphic;
begin
  if not HasChild then
    if Selected<>0 then Graphic := PictureLeafSelect.Graphic
    else if MouseOn and 2 <> 0 then Graphic := PictureLeafOn.Graphic
    else Graphic := PictureLeaf.Graphic
  else if Open then
    if MouseOn and 2 <> 0 then Graphic := PictureMinusOn.Graphic
    else Graphic := PictureMinus.Graphic
  else
    if MouseOn and 2 <> 0 then Graphic := PicturePlusOn.Graphic
    else Graphic := PicturePlus.Graphic;
  if Graphic<>nil then Graphic.Transparent := True;
  Canvas.StretchDraw(Rect(PicX(Level), PicY(Line),
      PicX(Level)+PictureWidth, PicY(Line)+PictureHeight),
      Graphic);
end;

procedure TMemTree.PaintText(Node, Level, Line: integer; Text: string; Selected, MouseOn: Short; Opened: Boolean);
var
  R, RB: TRect;
  TextColor: TColor;
begin
  Canvas.Font := Font;

  if Assigned(OnGetTextStyle) then
  begin
    FOnGetTextStyle(Level, Selected, TextColor);
  end else
    if Selected>0 then TextColor := SelectedColor
    else TextColor := Font.Color;

  Canvas.Font.Color := TextColor;
  if MouseOn and 4 <> 0 then Canvas.Font.Style := Canvas.Font.Style + [fsUnderline];
  if (Node=FocusedNode) and Focused then Canvas.Font.Style := Canvas.Font.Style+[fsBold]
  else if Selected<>0 then Canvas.Font.Style := Canvas.Font.Style+[fsBold];

  Canvas.Brush.Style := bsClear;
  R := TextBounds(Level, Line, Text, Selected);
  RB := TextBounds(Level, Line, Text, 1);
  ClearLineRegion(Line, RB.Left, RB.Right-RB.Left+1);
  Canvas.TextRect(R, R.Left, R.Top, Text);

  Canvas.Pen.Color := Font.Color;
  Canvas.Pen.Style := psDot;
  Canvas.Brush.Style := bsClear;
  if Node=FocusedNode then
    Canvas.Polygon([Point(R.Left-3, R.Top+1),
      Point(R.Right, R.Top+1), Point(R.Right, R.Bottom-1),
      Point(R.Left-3, R.Bottom-1), Point(R.Left-3, R.Top+1)]);
end;

procedure TMemTree.ClearLineRegion(Line, Left, RegWidth: Integer);
var
  DC, SourceDC, SaveHandle, B: Integer;
  R: TRect;
begin
  if BorderStyle=bsSingle then B := 1 else B := 0;
  if BackGround.Bitmap.Width>0 then
  begin
    try
      DC := Canvas.Handle;
      SourceDC := CreateCompatibleDC(DC);
      SaveHandle := SelectObject(SourceDC, BackGround.Bitmap.Handle);
      try
        SetBkMode(DC, Transparent);
        BitBlt(DC, Left, PicY(Line), RegWidth, Min(ClientHeight-B-PicY(Line), PictureHeight),
            SourceDC, Left, PicY(Line), srccopy);
      finally
        SelectObject(SourceDC, SaveHandle);
        DeleteDC(SourceDC);
      end
    except on Exception do
    end
  end else
  begin
    R := Rect(Left, PicY(Line), Min(Left+RegWidth, ClientWidth-1), Min(PicY(Line)+PictureHeight+Spacing, ClientHeight-1));
    Canvas.Brush.Color := Color;
    Canvas.Brush.Style := bsSolid;
    Canvas.FillRect(R);
  end;
end;

procedure TMemTree.PaintTreeLine(NodeIndex: Integer; Level, Line: Integer; Text: string; Open, HasChild: Boolean; Selected, MouseOn: Short);
var
  DC, SourceDC, SaveHandle, I, B, H: Integer;
begin

  if BorderStyle=bsSingle then B := 1 else B := 0;
  if BackGround.Bitmap.Width>0 then
  begin
    DC := Canvas.Handle;
    SourceDC := CreateCompatibleDC(DC);
    SaveHandle := SelectObject(SourceDC, BackGround.Bitmap.Handle);
    try
      SetBkMode(DC, Transparent);
      if Line=0 then BitBlt(DC, B, B, Width-2*B, Spacing, SourceDC, 0, 0, srccopy);
      SetTextColor(DC, Canvas.Font.Color);
      H := PictureHeight+Spacing;

      BitBlt(DC, B, PicY(Line), Width-2*B, Min(ClientHeight-B-PicY(Line), PictureHeight+Spacing), SourceDC, 0, PicY(Line), srccopy);
      finally
        DeleteDC(SourceDC);
        SelectObject(SourceDC, SaveHandle);
    end
  end else
  begin
    ClearLineRegion(Line, B, ClientWidth-B*2);
  end;

  if NodeIndex<>-1 then
  begin
    PaintText(NodeIndex, Level, Line, Text, Selected, MouseOn, Open);
    PaintPic(Level, Line, Open, HasChild, Selected, MouseOn);

    if DrawLines then
    begin
      PaintHLine(Level, Line, 0);
      PaintVLine(Level, Line, 1);
      if Level>1 then
        for I:=Level-1 downto 1 do
          if LevelParentHasNext(NodeIndex, I) then
            PaintVLine(I, Line, 3);
      if Nodes[NodeIndex].NextPeer>=0 then PaintVLine(Level, Line, 2);
    end;
  end;
end;

procedure TMemTree.PaintLine(X, Y, Len: integer; Dir: Boolean);
begin
  Canvas.Pen.Color := LineColor;
  Canvas.Pen.Style := psSolid;
  Canvas.PenPos := Point(X, Y);
  if Dir then Canvas.LineTo(X-Len, Y)
  else Canvas.LineTo(X, Y+Len);

  Canvas.Pen.Color := LineColor2;
  if Dir then
  begin
    Canvas.PenPos := Point(X, Y+1);
    Canvas.LineTo(X-Len+2, Y+1);
  end else
  begin
    Canvas.PenPos := Point(X+1, Y);
    Canvas.LineTo(X+1, Y+Len+2);
  end;
end;

procedure TMemTree.Paint;
begin
  try
    Canvas.Font := Font;
    Canvas.Brush.Color := LineColor;
    Canvas.Pen.Color := LineColor;
    FLineIndex := 0;
    if BorderStyle=bsSingle then
    begin
      Canvas.FrameRect(ClientRect);
    end;
    PaintTree(TopID, 0);
  finally
  end
end;

procedure TMemTree.PaintTree(From, Dy: Integer);
var
  I, Line, B: Integer;
begin
  I := Dy;
  Line := From;
  if BorderStyle=bsSingle then B := 2 else B := 0;
  while (I<((ClientHeight-B) div (PictureHeight+Spacing))+1) do
  begin
    if (Line>=0) and (Line<Nodes.Count) then with Nodes.Items[Line] do
    begin
      PaintTreeLine(Index, Level, I, NodeText, Open, FirstChild>=0, Selected, MouseOn);
      Line := TreeGetNext(Line);
    end else PaintTreeLine(-1, 0, I, '', False, False, 0, 0);
    Inc(I);
  end
end;

procedure TMemTree.PaintTextFrom;
var
  I, Line: Integer;
begin
  I := Dy;
  Line := From;
  while (I<(Height div (PictureHeight+Spacing))+1) do
  begin
    if Line>=0 then with Nodes.Items[Line] do
    begin
      PaintText(Line, Level, I, NodeText, Selected, MouseOn, Open);
      Line := TreeGetNext(Line);
    end;
    Inc(I);
  end;
end;

function TMemTree.ParentHasNext(NodeIndex: Integer): Boolean;
begin
  ParentHasNext := (Nodes[NodeIndex].Parent>=0) and (Nodes[Nodes[NodeIndex].Parent].NextPeer>=0)
end;

function TMemTree.LevelParentHasNext(NodeIndex: Integer; Level: Integer): Boolean;
begin
  if (Nodes[NodeIndex].Level=Level) then Result := (Nodes[NodeIndex].NextPeer>=0)
  else if (Nodes[NodeIndex].Parent<>-1) then Result := LevelParentHasNext(Nodes[NodeIndex].Parent, Level)
  else Result := False
end;

function TMemTree.ContiniousParent(NodeIndex: Integer): TNodeID;
begin
  Result := -1;
  with Nodes[NodeIndex] do
    if Parent>=0 then
      if Nodes[Parent].NextPeer>=0 then Result := Parent
      else Result := ContiniousParent(Parent)
end;

function TMemTree.TreeGetNext(NodeIndex: Integer): TNodeID;
begin
  with Nodes[NodeIndex] do
    if Open and (FirstChild>=0) then Result := FirstChild
    else if NextPeer>=0 then Result := NextPeer
    else if Parent>=0 then
    begin
      Result := ContiniousParent(NodeIndex);
      if Result>=0 then Result := Nodes[Result].NextPeer
    end else Result := -1;
end;

function TMemTree.TreeGetPrev(NodeIndex: Integer): TNodeID;
var
  L: TNodeID;
begin
  if Nodes[NodeIndex].PrevPeer>=0 then
  begin
    Result := Nodes[NodeIndex].PrevPeer;
    L := Nodes[Result].LastChild;
    while Nodes[Result].Open and (L>=0) do
    begin
      Result := L;
      L := Nodes[L].LastChild;
    end;
  end else if Nodes[NodeIndex].Parent>=0 then Result := Nodes[NodeIndex].Parent
  else Result := -1;
end;

function TMemTree.SelectTree(NodeIndex: Integer; NewSelected, Phase: Short): Integer;
begin
  Result := 0;
  if NodeIndex<0 then Exit;
  if Nodes[NodeIndex].Selected<>NewSelected then Inc(Result);
  Nodes[NodeIndex].Selected := NewSelected;
  if Phase>0 then Inc(Result, SelectTree(Nodes[NodeIndex].NextPeer, NewSelected, 1));
  Inc(Result, SelectTree(Nodes[NodeIndex].FirstChild, NewSelected, 1));
end;

function TMemTree.TreeNumVisible(NodeIndex: TNodeID): Integer;
begin
  if NodeIndex=-1 then Result := 0
  else with Nodes[NodeIndex] do
  if Open then Result := 1+TreeNumVisible(FirstChild)+TreeNumVisible(NextPeer)
  else Result := 1+TreeNumVisible(NextPeer)
end;

function TMemTree.GetNthVisible(N: Integer): Integer;
var
  i, F, PF: Integer;
begin
  F := 0;
  PF := 0;
  for i:=1 to N do
  begin
    PF := F;
    if PF>=0 then F := TreeGetNext(PF);
  end;
  if F>=0 then  Result := F else  Result := PF;
end;

function TMemTree.GetIndexOf(ID: Integer): Integer;
var
  i, F: Integer;
begin
  F := 0;
  i := 0;
  Result := -1;
  while F>=0 do
  begin
    if F=ID then
    begin
      Result := i;
      break;
    end;
    Inc(i);
    F := TreeGetNext(F);
  end;
end;

procedure Register;
begin
  RegisterComponents('FALAD', [TMemTree]);
end;

end.