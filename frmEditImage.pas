unit frmEditImage;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  scControls, scGPControls, uGDIUnit, AARotate, AARotate_Fast, scExtControls,
  scGPImages, acImage;

type
  TDrawingTool = (dtLine, dtRectangle, dtEllipse, dtRoundRect);

  TPictureArray = array of TPicture;

  TEditImage = class(TForm)
    pnlEditImage: TPanel;
    btnInit: TButton;
    btnSaveAndClose: TButton;
    btnClose: TButton;
    lblMousePoint: TLabel;
    lblOrigin: TLabel;
    btnCrop: TscGPGlyphButton;
    btnBox: TscGPGlyphButton;
    ScrollBox1: TScrollBox;
    lblBeginPoint: TLabel;
    lblEndPoint: TLabel;
    edtBeginX: TLabeledEdit;
    edtBeginY: TLabeledEdit;
    edtEndX: TLabeledEdit;
    edtEndY: TLabeledEdit;
    btnManualCrop: TButton;
    imgEdit: TsImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnCloseClick(Sender: TObject);
    procedure btnSaveAndCloseClick(Sender: TObject);
    procedure btnInitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure imgEditMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure imgEditMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure imgEditMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure btnCropClick(Sender: TObject);
    procedure btnBoxClick(Sender: TObject);
    procedure btnManualCropClick(Sender: TObject);
  private
    procedure SavePicture;
    procedure UndoPicture;
    procedure SetImageSize;
    { Private declarations }
  public
    BrushStyle: TBrushStyle;
    PenStyle: TPenStyle;
    PenWide: Integer;
    Drawing: Boolean;
    Origin, MovePt: TPoint;
    DrawingTool: TDrawingTool;
    paPictures: TPictureArray;
    CropBeginPoint, CropEndPoint: TPoint;
    BoxBeginPoint, BoxEndPoint: TPoint;
    RotatedCount: Integer;
    procedure SaveStyles;
    procedure RestoreStyles;
    procedure DrawShape(TopLeft, BottomRight: TPoint; AMode: TPenMode);
    { Public declarations }
  end;

var
  EditImage: TEditImage;

implementation

{$R *.dfm}

procedure TEditImage.btnBoxClick(Sender: TObject);
begin
  if btnCrop.Down then
    btnCrop.Down := False;
  btnBox.Down := True;
end;

procedure TEditImage.btnCloseClick(Sender: TObject);
begin
  if (Length(paPictures) = 0) or
     ((Length(paPictures) > 0) and (MessageDlg('The image has been changed. Do you really want to close this form?', mtConfirmation, mbYesNo, 0) = mrYes))  then
    ModalResult := mrCancel
  else
    Exit;
end;

procedure TEditImage.btnCropClick(Sender: TObject);
begin
  if btnBox.Down then
    btnBox.Down := False;
  btnCrop.Down := True;
end;

procedure TEditImage.btnInitClick(Sender: TObject);
var
  i: Integer;
begin
  imgEdit.Picture.Assign(paPictures[0]);

  for i := High(paPictures) downto Low(paPictures) + 1 do
  begin
    paPictures[Length(paPictures) - 1].Free;
    SetLength(paPictures, Length(paPictures) - 1);
  end;
end;

procedure TEditImage.btnManualCropClick(Sender: TObject);
var
  bmpCrop: TBitmap;
begin
  TryStrToInt(edtBeginX.Text, CropBeginPoint.X);
  TryStrToInt(edtBeginY.Text, CropBeginPoint.Y);
  TryStrToInt(edtEndX.Text, CropEndPoint.X);
  TryStrToInt(edtEndY.Text, CropEndPoint.Y);
  if MessageDlg('Crop하시겠습니까?', mtConfirmation, mbYesNo, 0) = mrNo then Exit;
  SavePicture;
  bmpCrop := TBitmap.Create;

  try
    bmpCrop.Assign(imgEdit.Picture);
    bmpCrop.Canvas.CopyRect(Rect(0, 0, CropEndPoint.X - CropBeginPoint.X, CropEndPoint.Y - CropBeginPoint.Y), bmpCrop.Canvas, Rect(CropBeginPoint.X + 1, CropBeginPoint.Y + 1, CropEndPoint.X - 1, CropEndPoint.Y - 1));
    bmpCrop.Width := CropEndPoint.X - CropBeginPoint.X;
    bmpCrop.Height := CropEndPoint.Y - CropBeginPoint.Y;
    imgEdit.Picture.Assign(bmpCrop);
    SetImageSize;
  finally
    bmpCrop.Free;
  end;
end;

procedure TEditImage.btnSaveAndCloseClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TEditImage.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TEditImage.FormCreate(Sender: TObject);
begin
  SetImageSize;
//  Position := poScreenCenter;

  Self.DoubleBuffered := True; // to reduce flickering...
  btnBox.Down := True;
  imgEdit.Stretch := False;
  RotatedCount := 0;
end;

procedure TEditImage.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) then
    case Key of
      90:
        UndoPicture;
      83:
        btnSaveAndClose.Click; // Ctrl+S
      73:
        btnInit.Click;         // Ctrl+i
    end;

  if Key = 49 then btnCrop.OnClick(nil);
  if Key = 50 then btnBox.OnClick(nil);
end;

procedure TEditImage.imgEditMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    SavePicture;
    with imgEdit, Canvas do
    begin
      Brush.Color := clBtnFace;
      Brush.Style := bsClear;
      if btnCrop.Down then
      begin
        Pen.Style := psDot;
        Pen.Color := clBlack;
        Pen.Width := 1;
        CropBeginPoint := Point(X, Y);
      end
      else if btnBox.Down then
      begin
        Pen.Style := psSolid;
        Pen.Color := clRed;
        Pen.Width := 5;
        BoxBeginPoint := Point(X, Y);
      end;
    end;
    DrawingTool := dtRectangle;

    Drawing := True;
    imgEdit.Canvas.MoveTo(X, Y);
    Origin := Point(X, Y);
    MovePt := Origin;
//    lblOrigin.Caption := Format('Origin: (%d, %d)', [X, Y]);
  end
  else if Button = mbRight then
  begin
    UndoPicture;
    SetImageSize;
  end;
end;

procedure TEditImage.imgEditMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  ARect: TRect;
begin
  lblMousePoint.Caption := Format('Point : (%d, %d)', [X, Y]);
  if Drawing then
  begin
    DrawShape(Origin, MovePt, pmNotXor);
    MovePt := Point(X, Y);
    DrawShape(Origin, MovePt, pmNotXor);
    lblOrigin.Caption := Format('Box W,H: (%d, %d)', [Abs(X-Origin.X), Abs(Y-Origin.Y)]);
  end;
end;

procedure TEditImage.imgEditMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  bmpCrop, bmpRotated: TBitmap;
  dwOffset: Integer;
begin
  if Button = mbLeft then
  begin
    if Drawing then
    begin
      DrawShape(Origin, Point(X, Y), pmCopy);
      Drawing := False;
    end;
    if btnCrop.Down then
    begin
      CropEndPoint := Point(X, Y);
      bmpCrop := TBitmap.Create;

      try
        bmpCrop.Assign(imgEdit.Picture);
        bmpCrop.Canvas.CopyRect(Rect(0, 0, Abs(X - Origin.X), Abs(Y - Origin.Y)), bmpCrop.Canvas, Rect(Origin.X + 1, Origin.Y + 1, X - 1, Y - 1));
        bmpCrop.Width := Abs(X - Origin.X);
        bmpCrop.Height := Abs(Y - Origin.Y);

        // Crop후의 이미지의 Height가 더 길면 90도 회전
        if bmpCrop.Height > bmpCrop.Width then
        begin
          bmpRotated := TBitmap.Create;
          try
            bmpRotated := FastAARotatedBitmap(bmpCrop, 90, TColor($00ff00ff){bgcolor}, True, False, False, 1.0);
            imgEdit.Picture.Bitmap.Assign(bmpRotated);
            imgEdit.Width := imgEdit.Picture.Bitmap.Width;
            imgEdit.Height := imgEdit.Picture.Bitmap.Height;
            imgEdit.Picture.Bitmap.PixelFormat := bmpCrop.PixelFormat;
            Inc(RotatedCount);
          finally
            bmpRotated.Free;
          end;
        end
        else
        begin
          imgEdit.Picture.Assign(bmpCrop);
        end;

        SetImageSize;
      finally
        bmpCrop.Free;
      end;

      SetImageSize;
    end;
    if btnBox.Down then
    begin
      BoxEndPoint := Point(X, Y);
    end;
  end;
end;

procedure TEditImage.DrawShape(TopLeft, BottomRight: TPoint; AMode: TPenMode);
begin
  with imgEdit.Canvas do
  begin
    Pen.Mode := AMode;
    case DrawingTool of
      dtLine:
        begin
          imgEdit.Canvas.MoveTo(TopLeft.X, TopLeft.Y);
          imgEdit.Canvas.LineTo(BottomRight.X, BottomRight.Y);
        end;
      dtRectangle:
        begin
          imgEdit.Canvas.Rectangle(TopLeft.X, TopLeft.Y, BottomRight.X, BottomRight.Y);
        end;
      dtEllipse:
        imgEdit.Canvas.Ellipse(TopLeft.X, TopLeft.Y, BottomRight.X, BottomRight.Y);
      dtRoundRect:
        imgEdit.Canvas.RoundRect(TopLeft.X, TopLeft.Y, BottomRight.X, BottomRight.Y, (TopLeft.X - BottomRight.X) div 2, (TopLeft.Y - BottomRight.Y) div 2);
    end;
  end;
end;

procedure TEditImage.RestoreStyles;
begin
  with imgEdit.Canvas do
  begin
    BrushStyle := Brush.Style;
    PenStyle := Pen.Style;
    PenWide := Pen.Width;
  end;
end;

procedure TEditImage.SaveStyles;
begin
  with imgEdit.Canvas do
  begin
    Brush.Style := BrushStyle;
    Pen.Style := PenStyle;
    Pen.Width := PenWide;
  end;
end;

procedure TEditImage.SavePicture;
begin
  Setlength(paPictures, Length(paPictures) + 1);
  paPictures[Length(paPictures) - 1] := TPicture.Create;
  paPictures[Length(paPictures) - 1].Assign(imgEdit.Picture);
end;

procedure TEditImage.UndoPicture;
begin
  if Length(paPictures) <= 1 then
  begin
    imgEdit.Picture.Assign(paPictures[0]);
    Exit;
  end;

  SaveStyles;
  imgEdit.Picture.Assign(paPictures[Length(paPictures) - 1]);
  RestoreStyles;
  paPictures[Length(paPictures) - 1].Free;
  SetLength(paPictures, Length(paPictures) - 1);
end;

procedure TEditImage.SetImageSize;
begin
//  ClientWidth := imgEdit.Picture.Width + pnlEditImage.Width + 5;
//  ClientHeight := imgEdit.Picture.Height + 5;
  Invalidate;
end;

end.

