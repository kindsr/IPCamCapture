unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, MRVCamView,
  MRVType, MRVCamera, MRVCamControl, MRVFFMpeg, jpeg, MRVBitmap, MRVImg, System.StrUtils,
  acImage, scControls, scGPControls, uGDIUnit, AARotate, AARotate_Fast,
  Vcl.ComCtrls, System.JSON.Types, System.JSON.Writers, MMSystem;

const
  CPREFIX = 'ABC_';
  DEFAULT_FOLDER = 'Snapshot';
  MAN_COLOR = '#d3a60b';
  BAG_COLOR = '#cb0edb';

type
  TDrawingTool = (dtLine, dtRectangle, dtEllipse, dtRoundRect);
  TPictureArray = array of TPicture;
  TJSONFileArray = array of TStringWriter;

  TAreaInfo = record
    Tag: string;
    BeginPoint: TPoint;
    EndPoint: TPoint;
  end;
  TBoxInfoArray = array of TAreaInfo;

  TSavedPicture = record
    iFrame: Integer;
    PictureFilePath: string;
    BoxInfo: TBoxInfoArray;
  end;
  TSavedPictureArray = array of TSavedPicture;

type
  TMainForm = class(TForm)
    RVCamera1: TRVCamera;
    Panel2: TPanel;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Current: TLabel;
    lblCurrentNumber: TLabel;
    ButtonConnect: TButton;
    ButtonDisconnect: TButton;
    btnSnapshot: TButton;
    edtPrefix: TEdit;
    RVCamView1: TRVCamView;
    Panel4: TPanel;
    imgEdit: TsImage;
    StatusBar1: TStatusBar;
    Panel3: TPanel;
    Panel5: TPanel;
    lblMousePoint: TLabel;
    lblOrigin: TLabel;
    btnBox: TscGPGlyphButton;
    btnMan: TscGPGlyphButton;
    btnInit: TButton;
    btnSave: TButton;
    btnClose: TButton;
    edtMan: TLabeledEdit;
    edtBag: TLabeledEdit;
    mmLog: TMemo;
    edtWorkNo: TLabeledEdit;
    procedure ButtonConnectClick(Sender: TObject);
    procedure ButtonDisconnectClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSnapshotClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RVCamera1GetImage(Sender: TObject; img: TRVMBitmap);
    procedure btnBoxClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnInitClick(Sender: TObject);
    procedure imgEditMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgEditMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imgEditMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnSaveClick(Sender: TObject);
    procedure btnManClick(Sender: TObject);
  private
    procedure SaveSnapShot(img: TRVMBitmap);
    procedure SaveSnapShotToStream(img : TRVMBitmap; var dest : TMemoryStream);
    procedure SavePicture;
    procedure UndoPicture;
    procedure SetImageSize;
    procedure DrawShape(TopLeft, BottomRight: TPoint; AMode: TPenMode);
    procedure RestoreStyles;
    procedure SaveStyles;
    function CropPicture(Picture: TPicture; AreaInfo: TAreaInfo) : TPicture; overload;
    function CropPicture(Picture: TPicture; AreaInfo: array of TAreaInfo) : TPictureArray; overload;
    procedure MakeJson(Pictures: TSavedPictureArray);
    procedure MakeJsonBoxes(frameNo: Integer; Boxes: TBoxInfoArray; var Writer: TJsonTextWriter; var inputTag: string);
    procedure ClearComponents;
    procedure ShowLog(strMsg: string);
    { Private declarations }
  public
    BrushStyle: TBrushStyle;
    PenStyle: TPenStyle;
    PenWide: Integer;
    Drawing: Boolean;
    Origin, MovePt: TPoint;
    DrawingTool: TDrawingTool;
    paPictures: TPictureArray;
    BoxBeginPoint, BoxEndPoint: TPoint;
    RotatedCount: Integer;
    baBoxes: TBoxInfoArray;
    paCropPictures: TPictureArray;
    paCropBoxPictures: TPictureArray;
    SavedPictures: TSavedPictureArray;
    CropAreaInfo : array[0..4] of TAreaInfo;
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  FSnapshot : Boolean;
  FDefaultPrefix: string;
  FDefaultPath : string;
  FDefaultFileName : string;
  FJSONFileName : string;
  FCurrentNumber : string;
  FIDNum, FFrameNum: Integer;
  FSnapshotStream : TMemoryStream;
  FCropPicture, FCropBoxPicture: TPicture;
  ptLeftBegin, ptLeftEnd, ptRightBegin, ptRightEnd: TPoint;
  ptLeftBoxBegin, ptLeftBoxEnd, ptRightBoxBegin, ptRightBoxEnd: TPoint;
  iRotatedCntLeft, iRotatedCntRight: Integer;
  gProgressBarMax, gProgressBarNow: Integer;

implementation

{$R *.dfm}

procedure TMainForm.btnBoxClick(Sender: TObject);
begin
  if btnMan.Down then
    btnMan.Down := False;
  btnBox.Down := True;
end;

procedure TMainForm.btnManClick(Sender: TObject);
begin
  if btnBox.Down then
    btnBox.Down := False;
  btnMan.Down := True;
end;

procedure TMainForm.btnCloseClick(Sender: TObject);
begin
  if (Length(paPictures) = 0) or
     ((Length(paPictures) > 0) and (MessageDlg('The image has been changed. Do you really want to close this form?', mtConfirmation, mbYesNo, 0) = mrYes))  then
    Close
  else
    Exit;
end;

procedure TMainForm.btnInitClick(Sender: TObject);
var
  i: Integer;
begin
  imgEdit.Picture := nil;

  for i := Length(paPictures)-1 downto 0 do
  begin
    paPictures[i].Free;
    SetLength(paPictures, i);
  end;

  SetLength(baBoxes, 0);
end;

procedure TMainForm.btnSaveClick(Sender: TObject);
var
  iCurrentNum, i : Integer;
  iMan, iBag: Integer;
  jpg: TJpegImage;
begin
  if Trim(edtMan.Text) = '' then
  begin
    ShowMessage('Input Man count');
    edtMan.SetFocus;
    Exit;
  end;

  if Trim(edtBag.Text) = '' then
  begin
    ShowMessage('Input Bag count');
    edtBag.SetFocus;
    Exit;
  end;

  if Trim(edtWorkNo.Text) = '' then
  begin
    ShowMessage('Input Work No.');
    edtWorkNo.SetFocus;
    Exit;
  end;

  FCurrentNumber := IfThen(Trim(edtPrefix.Text)='', '0001', string(edtPrefix.Text).PadLeft(4, '0'));
  if Trim(edtPrefix.Text) = '' then edtPrefix.Text := FCurrentNumber;
  lblCurrentNumber.Caption := FCurrentNumber;

  FDefaultPrefix := CPREFIX;
  if TryStrToInt(edtMan.Text, iMan) and (iMan > 0) then
    FDefaultPrefix := FDefaultPrefix + 'MAN_' + string(edtMan.Text).PadLeft(2, '0') + '_' + string(edtBag.Text).PadLeft(2, '0') + '_' + string(edtWorkNo.Text).PadLeft(3, '0')
  else if TryStrToInt(edtMan.Text, iMan) and (iMan = 0) then
    FDefaultPrefix := FDefaultPrefix + 'BAG_' + string(edtBag.Text).PadLeft(2, '0') + '_' + string(edtWorkNo.Text).PadLeft(3, '0');

  FDefaultPath := GetCurrentDir + PathDelim + FDefaultPrefix;
  FDefaultFileName := FDefaultPath + PathDelim + FDefaultPrefix + '_' + FCurrentNumber;

  if FileExists(FDefaultFileName + '.jpg') then
  begin
    ShowMessage('Already exists the filename.');
    Exit;
  end;

  jpg := TJpegImage.Create;

  try
    // Save the Pictures
    try
      if not DirectoryExists(FDefaultPath) then
        CreateDir(FDefaultPath);
    except
      ShowMessage('Fail to create directory');
    end;

    // 원본크롭저장
    FCropPicture := CropPicture(paPictures[0], CropAreaInfo[0]);
    jpg.Assign(FCropPicture.Bitmap);
    jpg.SaveToFile(FDefaultFileName + '.jpg');

    FCropBoxPicture := CropPicture(imgEdit.Picture, CropAreaInfo[0]);
    jpg.Assign(FCropBoxPicture.Bitmap);
//    jpg.SaveToFile(FDefaultPath + '_' + FCurrentNumber + '_Box.jpg');
  finally
    jpg.Free;
  end;

  iCurrentNum := StrToInt(FCurrentNumber);
  // SavedPictureArray Set
  SetLength(SavedPictures, Length(SavedPictures) + 1);
  SavedPictures[Length(SavedPictures)-1].iFrame := FFrameNum;
  Inc(FFrameNum);
  SavedPictures[Length(SavedPictures)-1].PictureFilePath := FDefaultFileName + '.jpg';
  SetLength(SavedPictures[Length(SavedPictures)-1].BoxInfo, Length(SavedPictures[Length(SavedPictures)-1].BoxInfo)+1);
  SavedPictures[Length(SavedPictures)-1].BoxInfo := baBoxes;

  // Save BoxArea Points as json
  MakeJson(SavedPictures);
  StatusBar1.Panels[0].Text := 'Files are Saved';

  // Initalize paPitures record
  imgEdit.Picture := nil;

  for i := Length(paPictures)-1 downto 1 do
  begin
    paPictures[i].Free;
    SetLength(paPictures, i);
  end;
  SetLength(baBoxes, 1);

  // Increase Current number
  inc(iCurrentNum);
  edtPrefix.Text := IntToStr(iCurrentNum).PadLeft(4, '0');
end;

procedure TMainForm.btnSnapshotClick(Sender: TObject);
begin
  Beep;
  if not RVCamera1.IsStreamPlaying then Exit;
  btnInit.Click;
  FSnapshotStream.Clear;
  FSnapshot := True;
end;

procedure TMainForm.ButtonConnectClick(Sender: TObject);
begin
  if RVCamera1.IsSupportedGStreamer then
  begin
    Label1.Caption := 'GS=OK'
  end;
  if RVCamera1.IsSupportedFFMPEG then
  begin
    Label2.Caption := 'FFMPEG=OK'
  end;
  RVCamera1.PlayVideoStream;
end;

procedure TMainForm.ButtonDisconnectClick(Sender: TObject);
begin
  if RVCamera1.IsStreamPlaying then
  begin
    RVCamera1.Abort;
    RVCamera1.WaitForVideo;
    if Application.Terminated then
      exit;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FSnapshotStream) then FreeAndNil(FSnapshotStream);
  if Assigned(FCropPicture) then FreeAndNil(FCropPicture);
  if Assigned(FCropBoxPicture) then FreeAndNil(FCropBoxPicture);

  if RVCamera1.IsStreamPlaying then
  begin
    RVCamera1.Abort;
    RVCamera1.WaitForVideo;
    if Application.Terminated then
      exit;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  i : Integer;
begin
  FSnapshotStream := TMemoryStream.Create;
  FCropPicture := TPicture.Create;
  FCropBoxPicture := TPicture.Create;
  btnMan.Down := True;
  FIDNum := 0;
  FFrameNum := 0;

  // Crop Area Info Setting  410x230   160,105
  CropAreaInfo[0].BeginPoint := Point(641+160, 0+105);
  CropAreaInfo[0].EndPoint   := Point(641+160+410, 0+105+230); // 1280,480
//  CropAreaInfo[1].BeginPoint := Point(0, 0);
//  CropAreaInfo[1].EndPoint   := Point(320, 240);
//  CropAreaInfo[2].BeginPoint := Point(321, 0);
//  CropAreaInfo[2].EndPoint   := Point(640, 240);
//  CropAreaInfo[3].BeginPoint := Point(0, 241);
//  CropAreaInfo[3].EndPoint   := Point(320, 480);
//  CropAreaInfo[4].BeginPoint := Point(321, 241);
//  CropAreaInfo[4].EndPoint   := Point(640, 480);
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) then
    case Key of
      67:
        btnSnapshot.Click;    // Ctrl+C
      90:
        UndoPicture;            // Ctrl+z
      83:
        btnSave.Click; // Ctrl+S
      73:
        btnInit.Click;         // Ctrl+i
    end;

  if Key = 81 then btnMan.OnClick(nil);
  if Key = 87 then btnBox.OnClick(nil);
end;

procedure TMainForm.ClearComponents;
var
  i, j: Integer;
begin
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i].ClassType = TEdit then
    begin
      TEdit(Components[i]).Text := '';
    end
    else if Components[i].ClassType = TLabel then
    begin
    end
    else if Components[i].ClassType = TMemo then
    begin
      if Pos('mmLog', TMemo(Components[i]).Name) > 0 then
        Continue;
      TMemo(Components[i]).Lines.Clear;
    end
    else if Components[i].ClassType = TsImage then
    begin
      TsImage(Components[i]).Picture := nil;
    end
    else if Components[i].ClassType = TButton then
    begin
    end;
  end;
end;

procedure TMainForm.ShowLog(strMsg: string);
var
  strFileName: string;
  strDateTime: string;
  fileLog: TextFile;
begin
  if mmLog.CanFocus = true then
  begin
    mmLog.Lines.Add(strMsg);
    if mmLog.Lines.Count > 300 then
    begin
      mmLog.Lines.Delete(0);
      mmLog.Lines.Add('');
      mmLog.Lines.Delete(mmLog.Lines.Count - 1);
    end;
  end;
end;

procedure TMainForm.RVCamera1GetImage(Sender: TObject; img: TRVMBitmap);
begin
  if not FSnapshot then Exit;

//  SaveSnapShot(img);
//  SaveSnapShotToStream(img, FSnapshotStream);
  imgEdit.Picture.Assign(img.GetBitmap);
  FSnapshot := False;
end;

procedure TMainForm.SaveSnapShot(img: TRVMBitmap);
var
  jpg: TJpegImage;
begin
  FCurrentNumber := IfThen(Trim(edtPrefix.Text)='', '000001', string(edtPrefix.Text).PadLeft(6, '0'));
  if Trim(edtPrefix.Text) = '' then edtPrefix.Text := FCurrentNumber;
  lblCurrentNumber.Caption := FCurrentNumber;
  FDefaultPath := GetCurrentDir + PathDelim + DEFAULT_FOLDER + PathDelim + CPREFIX + FCurrentNumber;
  FDefaultFileName := FDefaultPath + PathDelim + CPREFIX +  FCurrentNumber;

  if (img <> nil) then
  begin
    jpg := TJpegImage.Create;
    try
      jpg.Assign(img.GetBitmap);
      try
        if not DirectoryExists(DEFAULT_FOLDER) then
          CreateDir(DEFAULT_FOLDER);
        if not DirectoryExists(FDefaultPath) then
          CreateDir(FDefaultPath);
      except
        ShowMessage('Fail to create directory');
      end;
      jpg.SaveToFile(FDefaultFileName + '_100.jpg');
    finally
      jpg.Free;
    end;
  end;
end;

procedure TMainForm.SaveSnapShotToStream(img : TRVMBitmap; var dest : TMemoryStream);
var
  jpg: TJpegImage;
  bmp: TBitmap;
begin
  FCurrentNumber := IfThen(Trim(edtPrefix.Text)='', '000001', string(edtPrefix.Text).PadLeft(6, '0'));
  if Trim(edtPrefix.Text) = '' then edtPrefix.Text := FCurrentNumber;
  lblCurrentNumber.Caption := FCurrentNumber;
  FDefaultPath := GetCurrentDir + PathDelim + DEFAULT_FOLDER + PathDelim + CPREFIX + FCurrentNumber;
  FDefaultFileName := FDefaultPath + PathDelim + CPREFIX +  FCurrentNumber;

  if (img <> nil) then
  begin
    try
      if not DirectoryExists(DEFAULT_FOLDER) then
        CreateDir(DEFAULT_FOLDER);
      if not DirectoryExists(FDefaultPath) then
        CreateDir(FDefaultPath);
    except
      ShowMessage('Fail to create directory');
    end;
    img.GetBitmap.SaveToFile(FDefaultFileName + '_100.bmp');
    dest.Position := 0;
    img.GetBitmap.SaveToStream(dest);
  end;
end;

procedure TMainForm.imgEditMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    if Length(paPictures) = 0 then SavePicture;
    with imgEdit, Canvas do
    begin
      Brush.Color := clBtnFace;
      Brush.Style := bsClear;
      if btnMan.Down then
      begin
        Pen.Color := clBlue;
      end
      else if btnBox.Down then
      begin
        Pen.Color := clRed;
      end;
      Pen.Style := psSolid;
      Pen.Width := 3;
      BoxBeginPoint := Point(X, Y);
    end;
    DrawingTool := dtRectangle;

    Drawing := True;
    imgEdit.Canvas.MoveTo(X, Y);
    Origin := Point(X, Y);
    MovePt := Origin;
//    lblOrigin.Caption := Format('Origin: (%d, %d)', [X, Y]);
  end;
end;

procedure TMainForm.imgEditMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
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

procedure TMainForm.imgEditMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
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
    BoxEndPoint := Point(X, Y);
    SavePicture;
  end
  else if Button = mbRight then
  begin
    UndoPicture;
    SetImageSize;
  end;
end;

procedure TMainForm.DrawShape(TopLeft, BottomRight: TPoint; AMode: TPenMode);
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

procedure TMainForm.RestoreStyles;
begin
  with imgEdit.Canvas do
  begin
    BrushStyle := Brush.Style;
    PenStyle := Pen.Style;
    PenWide := Pen.Width;
  end;
end;

procedure TMainForm.SaveStyles;
begin
  with imgEdit.Canvas do
  begin
    Brush.Style := BrushStyle;
    Pen.Style := PenStyle;
    Pen.Width := PenWide;
  end;
end;

procedure TMainForm.SavePicture;
begin
  Setlength(paPictures, Length(paPictures) + 1);
  paPictures[Length(paPictures) - 1] := TPicture.Create;
  paPictures[Length(paPictures) - 1].Assign(imgEdit.Picture);

  SetLength(baBoxes, Length(baBoxes) + 1);
  baBoxes[Length(baBoxes) - 1].Tag := IfThen(btnMan.Down,'0','1');
  baBoxes[Length(baBoxes) - 1].BeginPoint := BoxBeginPoint;
  baBoxes[Length(baBoxes) - 1].EndPoint := BoxEndPoint;
end;

procedure TMainForm.UndoPicture;
begin
  if Length(paPictures) = 0 then Exit;
  if (Length(paPictures) <> 0) and (Length(paPictures) <= 1) then
  begin
    imgEdit.Picture.Assign(paPictures[0]);
    Exit;
  end;

  SaveStyles;
  imgEdit.Picture.Assign(paPictures[Length(paPictures) - 2]);
  RestoreStyles;
  paPictures[Length(paPictures) - 1].Free;
  SetLength(paPictures, Length(paPictures) - 1);
  SetLength(baBoxes, Length(baBoxes) - 1);
end;

function TMainForm.CropPicture(Picture: TPicture; AreaInfo: TAreaInfo) : TPicture;
var
  bmpCrop: TBitmap;
  i: Integer;
begin
  if Picture = nil then Exit;
  Result := TPicture.Create;

  bmpCrop := TBitmap.Create;
  try
    bmpCrop.Assign(Picture);
    bmpCrop.Canvas.CopyRect(Rect(0, 0, AreaInfo.EndPoint.X - AreaInfo.BeginPoint.X, AreaInfo.EndPoint.Y - AreaInfo.BeginPoint.Y), bmpCrop.Canvas, Rect(AreaInfo.BeginPoint.X + 1, AreaInfo.BeginPoint.Y + 1, AreaInfo.EndPoint.X - 1, AreaInfo.EndPoint.Y - 1));
    bmpCrop.Width := AreaInfo.EndPoint.X - AreaInfo.BeginPoint.X;
    bmpCrop.Height := AreaInfo.EndPoint.Y - AreaInfo.BeginPoint.Y;
    Result.Assign(bmpCrop);
  finally
    bmpCrop.Free;
  end;
end;

function TMainForm.CropPicture(Picture: TPicture; AreaInfo: array of TAreaInfo) : TPictureArray;
var
  bmpCrop: TBitmap;
  i: Integer;
begin
  if Picture = nil then Exit;
  SetLength(Result, Length(AreaInfo));
  for i := Low(Result) to High(Result) do
    Result[i] := TPicture.Create;

  bmpCrop := TBitmap.Create;
  try
    for i := Low(AreaInfo) to High(AreaInfo) do
    begin
      bmpCrop.Assign(Picture);
      bmpCrop.Canvas.CopyRect(Rect(0, 0, AreaInfo[i].EndPoint.X - AreaInfo[i].BeginPoint.X, AreaInfo[i].EndPoint.Y - AreaInfo[i].BeginPoint.Y), bmpCrop.Canvas, Rect(AreaInfo[i].BeginPoint.X + 1, AreaInfo[i].BeginPoint.Y + 1, AreaInfo[i].EndPoint.X - 1, AreaInfo[i].EndPoint.Y - 1));
      bmpCrop.Width := AreaInfo[i].EndPoint.X - AreaInfo[i].BeginPoint.X;
      bmpCrop.Height := AreaInfo[i].EndPoint.Y - AreaInfo[i].BeginPoint.Y;
      Result[i].Assign(bmpCrop);
    end;
  finally
    bmpCrop.Free;
  end;
end;

procedure TMainForm.SetImageSize;
begin
//  ClientWidth := imgEdit.Picture.Width + pnlEditImage.Width + 5;
//  ClientHeight := imgEdit.Picture.Height + 5;
  Invalidate;
end;

procedure TMainForm.MakeJson(Pictures: TSavedPictureArray);
var
  StringWriter: TStringWriter;
  Writer: TJsonTextWriter;
  i,j: Integer;
  inputTag, visitedFrames: string;
  txtFile: TextFile;
  tmp: TStringList;
begin
  StringWriter := TStringWriter.Create;
  Writer := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting := TJsonFormatting.None;

  Writer.WriteStartObject;
  Writer.WritePropertyName('frames');
  Writer.WriteStartObject;
  // MakeJson(Boxes: TBoxInfoArray; Writer: TJsonTextWriter)
  visitedFrames := '';
  for i := 0 to Length(Pictures)-1 do
  begin
    visitedFrames := visitedFrames + IfThen(i=0,IntToStr(Pictures[i].iFrame),','+IntToStr(Pictures[i].iFrame));
    MakeJsonBoxes(Pictures[i].iFrame, Pictures[i].BoxInfo, Writer, inputTag);
  end;
  Writer.WriteEndObject;
  Writer.WritePropertyName('framerate');
  Writer.WriteValue('1');
  Writer.WritePropertyName('inputTags');
  Writer.WriteValue(inputTag); //inputTag);
  Writer.WritePropertyName('suggestiontype');
  Writer.WriteValue('track');
  Writer.WritePropertyName('scd');
  Writer.WriteValue(false);
  Writer.WritePropertyName('visitedFrames');
  Writer.WriteStartArray;

  tmp := TStringList.Create;
  try
    tmp.Delimiter := ',';
    tmp.DelimitedText := visitedFrames;
    for j := 0 to tmp.Count-1 do
      Writer.WriteValue(StrToInt(tmp[j]));
  finally
    tmp.Free;
  end;

  Writer.WriteEndArray;
  Writer.WritePropertyName('tag_colors');
  Writer.WriteStartArray;
  if inputTag = 'MAN' then Writer.WriteValue(MAN_COLOR)
  else if inputTag = 'BAG' then Writer.WriteValue(BAG_COLOR)
  else if inputTag = 'MAN, BAG' then
  begin
    Writer.WriteValue(MAN_COLOR);
    Writer.WriteValue(BAG_COLOR);
  end;
  Writer.WriteEndArray;
  Writer.WriteEndObject;

  try
    try
      AssignFile(txtFile, FDefaultPath + '.json');

//      if FileExists(FDefaultPath + '.json') then
//        Append(txtFile)
//      else
      Rewrite(txtFile);
//      mmLog.Lines.Append(StringWriter.ToString);
      Writeln(txtFile, StringWriter.ToString);
    except
    end;
  finally
    CloseFile(txtFile);
  end;
end;

procedure TMainForm.MakeJsonBoxes(frameNo: Integer; Boxes: TBoxInfoArray; var Writer: TJsonTextWriter; var inputTag: string);
var
  i: Integer;
begin
  Writer.WritePropertyName(IntToStr(frameNo));
  Writer.WriteStartArray;
  inputTag := '';
  for i := 1 to Length(Boxes)-1 do
  begin
//    if Boxes[i].Tag='0' then
//    begin
//      if inputTag = '' then
//      begin
//        inputTag := 'MAN';
//      end
//      else if inputTag = 'BAG' then
//      begin
//        inputTag := 'MAN, BAG';
//      end;
//    end
//    else
//    begin
//      if inputTag = '' then
//      begin
//        inputTag := 'BAG';
//      end
//      else if inputTag = 'MAN' then
//      begin
//        inputTag := 'MAN, BAG';
//      end;
//    end;
    inputTag := 'MAN, BAG';

    // Crop Area Info Setting  410x230   160,105
    //  CropAreaInfo[0].BeginPoint := Point(641+160, 0+105);
    //  CropAreaInfo[0].EndPoint   := Point(641+160+410, 0+105+230); // 1280,480
    Writer.WriteStartObject;
    Writer.WritePropertyName('x1');
    Writer.WriteValue(Boxes[i].BeginPoint.X - 640-160);
    Writer.WritePropertyName('y1');
    Writer.WriteValue(Boxes[i].BeginPoint.Y-105);
    Writer.WritePropertyName('x2');
    Writer.WriteValue(Boxes[i].EndPoint.X - 640-160);
    Writer.WritePropertyName('y2');
    Writer.WriteValue(Boxes[i].EndPoint.Y-105);
    Writer.WritePropertyName('id');
    Writer.WriteValue(FIDNum);
    Inc(FIDNum);
    Writer.WritePropertyName('width');
//    Writer.WriteValue(640);
    Writer.WriteValue(410);
    Writer.WritePropertyName('height');
//    Writer.WriteValue(480);
    Writer.WriteValue(230);
    Writer.WritePropertyName('type');
    Writer.WriteValue('Rectangle');
    Writer.WritePropertyName('tags');
    Writer.WriteStartArray;
    Writer.WriteValue(IfThen(Boxes[i].Tag='0','MAN','BAG'));
    Writer.WriteEndArray;
    Writer.WritePropertyName('name');
    Writer.WriteValue(i);
    Writer.WriteEndObject;
  end;
  Writer.WriteEndArray;
end;

end.
