unit uGDIUnit;

interface

uses
  Windows;

type

  GDIPlusStartupInput = record        // GDI Sartup
    GdiPlusVersion: integer;
    DebugEventCallback: integer;
    SuppressBackgroundThread: integer;
    SuppressExternalCodecs: integer;
  end;

  CombineMode = (
    CombineModeReplace,     // 0
    CombineModeIntersect,   // 1
    CombineModeUnion,       // 2
    CombineModeXor,         // 3
    CombineModeExclude,     // 4
    CombineModeComplement   // 5 (Exclude From)
  );
  TCombineMode = CombineMode;

  MatrixOrder = (
    MatrixOrderPrepend,
    MatrixOrderAppend
  );
  TMatrixOrder = MatrixOrder;
  GpMatrixOrder = TMatrixOrder;

  EncoderParameter = packed record
    Guid           : TGUID;   // GUID of the parameter
    NumberOfValues : ULONG;   // Number of the parameter values
    Type_          : ULONG;   // Value type, like ValueTypeLONG  etc.
    Value          : Pointer; // A pointer to the parameter values
  end;
  TEncoderParameter = EncoderParameter;
  PEncoderParameter = ^TEncoderParameter;

  EncoderParameters = packed record
    Count     : UINT;               // Number of parameters in this structure
    Parameter : array[0..0] of TEncoderParameter;  // Parameter values
  end;
  TEncoderParameters = EncoderParameters;
  PEncoderParameters = ^TEncoderParameters;

  ImageCodecInfo = packed record
    Clsid             : TGUID;
    FormatID          : TGUID;
    CodecName         : PWCHAR;
    DllName           : PWCHAR;
    FormatDescription : PWCHAR;
    FilenameExtension : PWCHAR;
    MimeType          : PWCHAR;
    Flags             : DWORD;
    Version           : DWORD;
    SigCount          : DWORD;
    SigSize           : DWORD;
    SigPattern        : PBYTE;
    SigMask           : PBYTE;
  end;
  TImageCodecInfo = ImageCodecInfo;
  PImageCodecInfo = ^TImageCodecInfo;

  PGPRectF = ^TGPRectF;
  TGPRectF = packed record
    X     : Single;
    Y     : Single;
    Width : Single;
    Height: Single;
  end;
  TRectFDynArray = array of TGPRectF;

  GpStringFormat = Pointer;
  GpFont         = Pointer;
  GpFontFamily   = Pointer;

const
  LibGdiPlus     = 'GdiPlus.dll';   // Default Name der DLL

  PixelFormatIndexed     = $00010000; // Indexes into a palette
  PixelFormatGDI         = $00020000; // Is a GDI-supported format
  PixelFormatAlpha       = $00040000; // Has an alpha component
  PixelFormatPAlpha      = $00080000; // Pre-multiplied alpha
  PixelFormatExtended    = $00100000; // Extended color 16 bits/channel
  PixelFormatCanonical   = $00200000;

  PixelFormatUndefined      = 0;
  PixelFormatDontCare       = 0;

  PixelFormat1bppIndexed    = (1  or ( 1 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  PixelFormat4bppIndexed    = (2  or ( 4 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  PixelFormat8bppIndexed    = (3  or ( 8 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  PixelFormat16bppGrayScale = (4  or (16 shl 8) or PixelFormatExtended);
  PixelFormat16bppRGB555    = (5  or (16 shl 8) or PixelFormatGDI);
  PixelFormat16bppRGB565    = (6  or (16 shl 8) or PixelFormatGDI);
  PixelFormat16bppARGB1555  = (7  or (16 shl 8) or PixelFormatAlpha or PixelFormatGDI);
  PixelFormat24bppRGB       = (8  or (24 shl 8) or PixelFormatGDI);
  PixelFormat32bppRGB       = (9  or (32 shl 8) or PixelFormatGDI);
  PixelFormat32bppARGB      = (10 or (32 shl 8) or PixelFormatAlpha or PixelFormatGDI or PixelFormatCanonical);
  PixelFormat32bppPARGB     = (11 or (32 shl 8) or PixelFormatAlpha or PixelFormatPAlpha or PixelFormatGDI);
  PixelFormat48bppRGB       = (12 or (48 shl 8) or PixelFormatExtended);
  PixelFormat64bppARGB      = (13 or (64 shl 8) or PixelFormatAlpha  or PixelFormatCanonical or PixelFormatExtended);
  PixelFormat64bppPARGB     = (14 or (64 shl 8) or PixelFormatAlpha  or PixelFormatPAlpha or PixelFormatExtended);
  PixelFormatMax            = 15;

function GdipCreateFromHDC(
  hDC: HDC;
  var Graphics: Cardinal
): Integer; stdcall; external LibGdiPlus;

function GdipLoadImageFromFile(
  const fileName: PWideChar;
  var Image: Cardinal
): Integer; stdcall; external LibGdiPlus;

function GdipSaveImageToFile(          // ** Added
  image: Cardinal{GPIMAGE};
  filename: PWCHAR;
  clsidEncoder: PGUID;
  encoderParams: PENCODERPARAMETERS
): Integer{GPSTATUS}; stdcall; external LibGdiPlus;

function GdipGetImageWidth(
  Image: Cardinal;
  var Width: UINT
): Integer; stdcall; external LibGdiPlus;

function GdipGetImageHeight(
  Image: Cardinal;
  var Height: UINT
): Integer; stdcall; external LibGdiPlus;

function GdipGetImagePixelFormat(
  image: Cardinal;
  out format: integer
): Integer; stdcall; external LibGdiPlus;

function GdipDrawImageRect(
  Graphics: Cardinal;
  Image: Cardinal;
  X, Y, Width, Height: Single
): Integer; stdcall; external LibGdiPlus;

function GdipDisposeImage(
  Image: Cardinal
): Integer; stdcall; external LibGdiPlus;

function GdipDeleteGraphics(
  Graphics: Cardinal
): Integer; stdcall; external LibGdiPlus;

function GdipDrawImageRectRectI(
  graphics: Cardinal;
  image: Cardinal;
  dstx: Integer;
  dsty: Integer;
  dstwidth: Integer;
  dstheight: Integer;
  srcx: Integer;
  srcy: Integer;
  srcwidth: Integer;
  srcheight: Integer;
  srcUnit: Cardinal;
  imageAttributes: Pointer;
  callback: BOOL;
  callbackData: Pointer
): Integer; stdcall; external LibGdiPlus;

function GdipSetClipRectI(
  graphics: Cardinal;
  x: Integer;
  y: Integer;
  width: Integer;
  height: Integer;
  combineMode: COMBINEMODE
): Integer; stdcall; external LibGdiPlus;

function GdipSetInterpolationMode(
  graphics: Cardinal;
  interpolationMode: Cardinal
): Integer; stdcall; external LibGdiPlus;

function GdipResetClip(
  graphics: Cardinal
): Integer; stdcall; external LibGdiPlus;

function GdipCreateSolidFill(
  color: DWORD;
  out brush: Pointer
): Integer; stdcall; external LibGdiPlus;

function GdipFillRectangleI(
  graphics: Cardinal;
  brush: Pointer;
  x: Integer;
  y: Integer;
  width: Integer;
  height: Integer
): Integer; stdcall; external LibGdiPlus;

function GdipDeleteBrush(
  brush: Pointer
): Integer; stdcall; external LibGdiPlus;

function GdipCreateBitmapFromHBITMAP(
  hbm: HBITMAP;
  hpal: LongWord;
  out bitmap: Pointer
): Integer; stdcall; external LibGdiPlus;

function GdipCreateHBITMAPFromBitmap(        // ** Added
  bitmap: Pointer {GPBITMAP};
  out hbmReturn: HBITMAP;
  background: integer{ARGB}
): Integer{GPSTATUS}; stdcall; external LibGdiPlus;

function GdipCloneBitmapAreaI(               // ** Added
  x: Integer; y: Integer;
  width: Integer;
  height: Integer;
  format: integer {PIXELFORMAT};
  srcBitmap: Pointer {GPBITMAP};
  out dstBitmap: Pointer {GPBITMAP}
): Integer{GPSTATUS}; stdcall; external LibGdiPlus;

function GdipGetImageEncodersSize(           // ** Added
  out numEncoders: UINT;
  out size: UINT
): Integer{GPSTATUS}; stdcall; external LibGdiPlus;

function GdipGetImageEncoders(               // ** Added
  numEncoders: UINT;
  size: UINT;
  encoders: PIMAGECODECINFO
): Integer{GPSTATUS}; stdcall; external LibGdiPlus;

function GdipCreateFontFamilyFromName(
  name: WideString; //PWCHAR;
  fontCollection: Pointer;
  out FontFamily: GpFontFamily
): Integer; stdcall; external LibGdiPlus;

function GdipCreateFont(
  fontFamily: GpFontFamily;
  emSize: Single;
  style: Integer;
  unit_: Integer;
  out font: GPFont
): Integer; stdcall; external LibGdiPlus;

function GdipCreateStringFormat(
  formatAttributes: Integer;
  language: LANGID;
  out format: GPSTRINGFORMAT
): Integer; stdcall; external LibGdiPlus;

function GdipMeasureString(
  graphics: Cardinal;
  string_: WideString; //PWCHAR;
  length: Integer;
  font: GPFONT;
  layoutRect: PGPRectF;
  stringFormat: GPSTRINGFORMAT;
  boundingBox: PGPRectF;
  codepointsFitted: PInteger;
  linesFilled: PInteger
): Integer; stdcall; external LibGdiPlus;


function GdipDeleteStringFormat(
  format: GPSTRINGFORMAT
): Integer; stdcall; external LibGdiPlus;

function GdipDeleteFont(
  font: GPFont
): Integer; stdcall; external LibGdiPlus;

function GdipDeleteFontFamily(
  FontFamily: GpFontFamily
): Integer; stdcall; external LibGdiPlus;

function GdipTranslateWorldTransform(
  graphics: Cardinal;
  dx: Single;
  dy: Single;
  order: GPMATRIXORDER
): Integer; stdcall; external LibGdiPlus;

function GdipRotateWorldTransform(
  graphics: Cardinal;
  angle: Single;
  order: GPMATRIXORDER
): Integer; stdcall; external LibGdiPlus;

function GdipSetStringFormatAlign(
  format: GPSTRINGFORMAT;
  align: Integer
): Integer; stdcall; external LibGdiPlus;

function GdipSetStringFormatLineAlign(
  format: GPSTRINGFORMAT;
  align: Integer
): Integer; stdcall; external LibGdiPlus;

function GdipSetStringFormatFlags(
  format: GPSTRINGFORMAT;
  flags: Integer
): Integer; stdcall; external LibGdiPlus;

function GdipSetTextRenderingHint(
  graphics: Cardinal;
  mode: Integer
): Integer; stdcall; external LibGdiPlus;

function GdipDrawString(
  graphics: Cardinal;
  string_: WideString; //PWCHAR;
  length: Integer;
  font: GPFont;
  layoutRect: PGPRectF;
  stringFormat: GPSTRINGFORMAT;
  brush: Pointer
): Integer; stdcall; external LibGdiPlus;

function GdipResetWorldTransform(
  graphics: Cardinal
): Integer; stdcall; external LibGdiPlus;

function GdipCreatePen1(
  color: COLORREF;
  width: Single;
  unit_: Integer;
  out pen: Integer
): Integer; stdcall; external LibGdiPlus;

function GdipDrawLineI(
  graphics: Cardinal;
  pen: Integer;
  x1: Integer;
  y1: Integer;
  x2: Integer;
  y2: Integer
): Integer; stdcall; external LibGdiPlus;

function GdipSetSmoothingMode(
  graphics: Cardinal;
  smoothingMode: Integer
): Integer; stdcall; external LibGdiPlus;

function GdipDeletePen(
  pen: integer
): Integer; stdcall; external LibGdiPlus;

function GdipFillEllipseI(
  graphics: Cardinal;
  brush: Pointer;
  x: Integer;
  y: Integer;
  width: Integer;
  height: Integer
): Integer; stdcall; external LibGdiPlus;

function  GDI_Close: boolean;
function  GDI_Init: boolean;

implementation

var // GDI variable
  hGDIP: Cardinal; // Library Handle
  StartUpInfo: GDIPlusStartupInput;
  GdiplusStartup: function(var token: Integer;
                           var lpInput: GDIPlusStartupInput;
                           lpOutput: Integer): Integer; stdcall;

  GdiplusShutdown: function(var token: Integer): Integer; stdcall;
  GdipToken: Integer;

// GDIPLUS entladen
function GDI_Close: boolean;
begin
  if hGDIP <> 0 then begin
    GdiplusShutdown := GetProcAddress(hGDIP, 'GdiplusShutdown');
    GdiplusShutdown(GdipToken);
    Result := FreeLibrary(hGDIP);
  end
  else Result:=false;
end;

// GDIPLUS laden
function GDI_Init: boolean;
begin
  Result := false;
  hGDIP := LoadLibrary(LibGdiPlus);
  if hGDIP <> 0 then begin
    GdiplusStartup := GetProcAddress(hGDIP, 'GdiplusStartup');
    if Assigned(GdiplusStartup) then begin
      FillChar(StartUpInfo, SizeOf(StartUpInfo), 0);
      StartUpInfo.GdiPlusVersion := 1;
      GdiplusStartup(GdipToken, StartUpInfo, 0);
      Result := true;
    end
    else GDI_Close;
  end;
end;

initialization
  hGDIP:=0;

end.
