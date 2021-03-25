unit uFunction;

interface

uses
  Windows, Classes, StrUtils, SysUtils, Vcl.Forms, Vcl.Graphics, jpeg,
  ShlObj, ShellAPI, Winapi.CommCtrl, Controls, Winapi.Messages, scGPControls,
  scControls, scGPVertPagers, IOUtils, System.IniFiles;

type
  TRGBArray = array[Word] of TRGBTriple;
  pRGBArray = ^TRGBArray;

{Image Handling}
procedure SmoothResize(Src: TBitmap; Dst: TBitmap);
procedure ResizeBMP2JPG(const src: TMemoryStream; var des: TMemoryStream; const iWidth: Integer);

implementation

procedure SmoothResize(Src: TBitmap; Dst: TBitmap);
var
  x, y: Integer;
  xP, yP: Integer;
  xP2, yP2: Integer;
  SrcLine1, SrcLine2: pRGBArray;
  t3: Integer;
  z, z2, iz2: Integer;
  DstLine: pRGBArray;
  DstGap: Integer;
  w1, w2, w3, w4: Integer;
begin
  Src.PixelFormat := pf24Bit;
  Dst.PixelFormat := pf24Bit;

  if (Src.Width = Dst.Width) and (Src.Height = Dst.Height) then
    Dst.Assign(Src)
  else
  begin
    DstLine := Dst.ScanLine[0];
    DstGap := Integer(Dst.ScanLine[1]) - Integer(DstLine);

    xP2 := MulDiv(pred(Src.Width), $10000, Dst.Width);
    yP2 := MulDiv(pred(Src.Height), $10000, Dst.Height);
    yP := 0;

    for y := 0 to pred(Dst.Height) do
    begin
      xP := 0;

      SrcLine1 := Src.ScanLine[yP shr 16];

      if (yP shr 16 < pred(Src.Height)) then
        SrcLine2 := Src.ScanLine[succ(yP shr 16)]
      else
        SrcLine2 := Src.ScanLine[yP shr 16];

      z2 := succ(yP and $FFFF);
      iz2 := succ((not yP) and $FFFF);
      for x := 0 to pred(Dst.Width) do
      begin
        t3 := xP shr 16;
        z := xP and $FFFF;
        w2 := MulDiv(z, iz2, $10000);
        w1 := iz2 - w2;
        w4 := MulDiv(z, z2, $10000);
        w3 := z2 - w4;
        DstLine[x].rgbtRed := (SrcLine1[t3].rgbtRed * w1 + SrcLine1[t3 + 1].rgbtRed * w2 + SrcLine2[t3].rgbtRed * w3 + SrcLine2[t3 + 1].rgbtRed * w4) shr 16;
        DstLine[x].rgbtGreen := (SrcLine1[t3].rgbtGreen * w1 + SrcLine1[t3 + 1].rgbtGreen * w2 + SrcLine2[t3].rgbtGreen * w3 + SrcLine2[t3 + 1].rgbtGreen * w4) shr 16;
        DstLine[x].rgbtBlue := (SrcLine1[t3].rgbtBlue * w1 + SrcLine1[t3 + 1].rgbtBlue * w2 + SrcLine2[t3].rgbtBlue * w3 + SrcLine2[t3 + 1].rgbtBlue * w4) shr 16;
        Inc(xP, xP2);
      end; {for}
      Inc(yP, yP2);
      DstLine := pRGBArray(Integer(DstLine) + DstGap);
    end; {for}
  end; {if}
end; {SmoothResize}

procedure ResizeBMP2JPG(const src: TMemoryStream; var des: TMemoryStream; const iWidth: Integer);
var
  OldBitmap: Vcl.Graphics.TBitmap;
  NewBitmap: Vcl.Graphics.TBitmap;
  jpg: TJPEGImage;
begin
  jpg := TJPEGImage.Create;
  OldBitmap := Vcl.Graphics.TBitmap.Create;
  try
    src.Position := 0;
    OldBitmap.LoadFromStream(src);

    if (OldBitmap.Width > iWidth) then
    begin
      NewBitmap := Vcl.Graphics.TBitmap.Create;
      try
        NewBitmap.Width := iWidth;
        NewBitmap.Height := MulDiv(iWidth, OldBitmap.Height, OldBitmap.Width);
        SmoothResize(OldBitmap, NewBitmap);
        jpg.Assign(NewBitmap);
        jpg.CompressionQuality := 75;
//        jpg.SaveToFile('.\ResizeJPG.jpg');
        des.Clear;
        des.Position := 0;
        jpg.SaveToStream(des);
      finally
        NewBitmap.Free;
      end; {try}
    end
    else
    begin
      jpg.Assign(OldBitmap);
      jpg.CompressionQuality := 75;
//        jpg.SaveToFile('.\ResizeJPG.jpg');
      des.Clear;
      des.Position := 0;
      jpg.SaveToStream(des);
    end; {if}
  finally
    FreeAndNil(OldBitmap);
    FreeAndNil(jpg);
  end; {try}
end; {ResizeImage}

procedure Jpeg2Bmp(const BmpFileName, JpgFileName: string);
var
  bmp: TBitmap;
  jpg: TJPEGImage;
begin
  bmp := TBitmap.Create;
  bmp.PixelFormat := pf32bit;
  jpg := TJPEGImage.Create;
  try
    jpg.LoadFromFile(JpgFileName);
    bmp.Assign(jpg);
    bmp.SaveToFile(BmpFileName);
  finally
    jpg.Free;
    bmp.Free;
  end;
end;

procedure Bmp2Jpeg(const BmpFileName, JpgFileName: string);
var
  bmp: TBitmap;
  jpg: TJPEGImage;
begin
  bmp := TBitmap.Create;
  bmp.PixelFormat := pf32bit;
  jpg := TJPEGImage.Create;
  try
    bmp.LoadFromFile(BmpFileName);
    jpg.Assign(bmp);
    jpg.SaveToFile(JpgFileName);
  finally
    jpg.Free;
    bmp.Free;
  end;
end;

end.
