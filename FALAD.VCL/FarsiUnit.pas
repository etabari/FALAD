unit FarsiUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

type
  TFarsiForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    PrevKey: Word;
  public
    { Public declarations }
  end;

var
  FarsiForm: TFarsiForm;

implementation
uses Utils;

{$R *.dfm}

procedure TFarsiForm.FormCreate(Sender: TObject);
begin
  //
end;

procedure TFarsiForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TFarsiForm.FormDestroy(Sender: TObject);
begin
  FarsiForm := nil;
end;

procedure TFarsiForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  PrevKey := Key;
end;

procedure TFarsiForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  Key := TranslateKeYe(Key, PrevKey);
end;

end.
