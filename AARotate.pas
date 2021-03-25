// This unit is Delphi version of Anti-Aliased Image Rotation (Aarot) unit, the original
//  source code is written in C++ and VB by Mark Gordon.
// Please visit http://www.codeproject.com/KB/graphics/aarot.aspx   if you want to know
//  more about Anti-Aliased Image Rotation (Aarot).
//
//           15 Mar 2009
//
//   written by Silhwan  (hyunsh@hanafos.com)


unit AARotate;

interface

uses Windows, graphics, Math;

// Parameters & Result
//  SrcBitmap : The source image to be rotated.
//  Rotation : The degree by which the image should be rotated counter-clockwise.
//  BgColor : The color of the background where the rotated bitmap does not overlap the
//            destination bitmap.
//  AutoBlend : Decides if the edges of the rotated image should be blended with the
//            background color defined by BgColor.
//            If false, the rgbReserved byte of each pixel will be set to the appropriate
//            alpha values so that the rotated image can be blended onto another image later
//            without a harsh edge.
//  Result : The rotated image. Returns nil if there are errors.

function AARotatedBMP(SrcBitmap : TBitmap; Rotation : double; BgColor : integer; AutoBlend : boolean) : TBitmap;


implementation

const
   dx : array[0..3] of double = (0.0, 1.0, 1.0, 0.0);
   dy : array[0..3] of double = (0.0, 0.0, 1.0, 1.0);

type

   aar_pnt = record
     X : double;
     Y : double;
   end;

   BITMAP = record
      bmType : DWORD;
      bmWidth : DWORD;
      bmHeight : DWORD;
      bmWidthBytes : DWORD;
      bmPlanes : WORD;
      bmBitsPixel : WORD;
      bmBits : longint;
   end;

   aar_dblrgbquad = record
      red   : double;
      green : double;
      blue  : double;
      alpha : double;
   end;

var
   coss, sins : double;
   polyoverlapsize : integer;
   polysortedsize : integer;
   polyoverlap : array[0..15] of aar_pnt;
   polysorted  : array[0..15] of aar_pnt;
   corners     : array[0..3] of aar_pnt;

function aar_min(A, B : double) : double;
begin
   if A < B Then
     result := A
   else
     result := B;
end;

function aar_max(A, B : double) : double;
begin
   if A > B Then
     result := A
   else
     result := B;
end;

function aar_roundup(A : Double) : longint;
begin
   if Abs(A - trunc(A + 0.0000000005)) < 0.000000001 then
      aar_roundup := trunc(A + 0.0000000005)
   else
      aar_roundup := trunc(A + 1);
end;

function aar_cos(degrees : double) : double;
var
   off : double;
   idegrees : integer;
begin
   off := (degrees / 30 - round(degrees / 30));
   if (off < 0.0000001) and (off > -0.0000001) then
   begin
      idegrees := round(degrees);
      if (idegrees < 0) then
         idegrees := (360 - (-idegrees mod 360))
      else
         idegrees := (idegrees mod 360);

      case (idegrees) of
              0 : result := 1.0;
             30 : result := 0.866025403784439;
             60 : result := 0.5;
             90 : result := 0.0;
            120 : result := -0.5;
            150 : result := -0.866025403784439;
            180 : result := -1.0;
            210 : result := -0.866025403784439;
            240 : result := -0.5;
            270 : result := 0.0;
            300 : result := 0.5;
            330 : result := 0.866025403784439;
            360 : result := 1.0;
         else
            result := cos(degrees * 3.14159265358979 / 180);  // it shouldn't get here
      end;
   end else
      result := cos(degrees * 3.14159265358979 / 180);
end;

function aar_sin(degrees : double) : double;
begin
   result := aar_cos(degrees + 90.0);
end;

function area : double;
var
   i : integer;
   ret : Double;
begin
   ret := 0;

  //Loop through each triangle with respect to (0, 0) and add the cross multiplication
   for i := 1 to (polysortedsize - 2) do
      ret := ret + (polysorted[i].x - polysorted[0].x) * (polysorted[i+1].y - polysorted[0].y)
                 - (polysorted[i+1].x - polysorted[0].x) * (polysorted[i].y - polysorted[0].y);

  //Take the absolute value over 2
   result := Abs(ret) / 2.0;
end;

procedure sortpoints;
// This function will sort the points for me so I can take the area of them
var
   i : integer;
   leftmost : integer;
   lastpoint : integer;
   selectedpoint : integer;
   inhull : array of Boolean;

begin
   if (polyoverlapsize <= 3) then
   begin
      for i := 0 to (polyoverlapsize - 1) do
      begin
         polysorted[i].x := polyoverlap[i].x;
         polysorted[i].y := polyoverlap[i].y;
      end;
      polysortedsize := polyoverlapsize;
      exit;
   end;

   polysortedsize := 0;
   leftmost := 0;

   for i := 1 to (polyoverlapsize - 1) do
   begin
      if polyoverlap[i].X < polyoverlap[leftmost].X then
         leftmost := i
      else if (polyoverlap[i].X = polyoverlap[leftmost].X) and (polyoverlap[i].Y < polyoverlap[leftmost].Y) then
         leftmost := i;
   end;

   SetLength(inhull, polyoverlapsize);
   { for i := 0 to (polyoverlapsize - 1) do
       inhull[i] := false;  }

   lastpoint := leftmost;

   repeat
      selectedpoint := -1;
      for i := 0 to (polyoverlapsize - 1) do begin
       // ignore the lastpoint and points already in the hull
         if (i <> lastpoint) and (inhull[i] = false) then
            if selectedpoint = -1 then
             // if no point is yet selected, select this one
               selectedpoint := i
            else if ((polyoverlap[i].X - polyoverlap[lastpoint].X) * (polyoverlap[selectedpoint].Y - polyoverlap[lastpoint].Y)
                  - (polyoverlap[selectedpoint].X - polyoverlap[lastpoint].X) * (polyoverlap[i].Y - polyoverlap[lastpoint].Y)) <= 0 then
             // if the cross multiplication of the selected point and point i in reference to lastpoint is <= 0 than select it
               selectedpoint := i;
      end;

      lastpoint := selectedpoint;
      inhull[lastpoint] := true;
      polysorted[polysortedsize] := polyoverlap[lastpoint];
      inc(polysortedsize);
   until (lastpoint = leftmost);  //  Loop While lastpoint <> leftmost

   SetLength(inhull, 0);
end;

function isinsquare(r : aar_pnt; c : aar_pnt) : boolean;
var
   rx, ry : double;
   nr : aar_pnt;
begin
  //Offset r
   rx := r.x - c.x;
   ry := r.y - c.y;

  //rotate r
   nr.x := rx * coss + ry * sins;
   nr.y := ry * coss - rx * sins;

  //Find if the rotated polygon is within the square of size 1 centerd on the origin
   nr.x := abs(nr.x);
   nr.y := abs(nr.y);
   result := (nr.x < 0.5) and (nr.y < 0.5);
end;

function pixoverlap(p : array of aar_pnt; c : aar_pnt) : double;
const
   ja : array[0..3] of integer = (1, 2, 3, 0);
var
   i, j : integer;

   minx, maxx, miny, maxy : double;
   z : double;

begin
   polyoverlapsize := 0;
   polysortedsize := 0;

   for i := 0 to 3 do
   begin
     //Search for source points within the destination square
      if (p[i].x >= 0) and (p[i].x <= 1) and (p[i].y >= 0) and (p[i].y <= 1) then
      begin
         polyoverlap[polyoverlapsize] := p[i];
         inc(polyoverlapsize);
      end;

     //Search for destination points within the source square
      if (isinsquare(corners[i], c)) then
      begin
         polyoverlap[polyoverlapsize] := corners[i];
         inc(polyoverlapsize);
      end;

     //Search for line intersections
      j := ja[i];
      minx := aar_min(p[i].x, p[j].x);
      miny := aar_min(p[i].y, p[j].y);
      maxx := aar_max(p[i].x, p[j].x);
      maxy := aar_max(p[i].y, p[j].y);

      if (minx < 0.0) and (0.0 < maxx) then
      begin
       //Cross left
         z := p[i].y - p[i].x * (p[i].y - p[j].y) / (p[i].x - p[j].x);
         if (z >= 0.0) and (z <= 1.0) then
         begin
            polyoverlap[polyoverlapsize].x := 0.0;
            polyoverlap[polyoverlapsize].y := z;
            inc(polyoverlapsize);
         end
      end
      else if (minx < 1.0) and (1.0 < maxx) then
      begin
       //Cross right
         z := p[i].y + (1 - p[i].x) * (p[i].y - p[j].y) / (p[i].x - p[j].x);
         if (z >= 0.0) and (z <= 1.0) then
         begin
            polyoverlap[polyoverlapsize].x := 1.0;
            polyoverlap[polyoverlapsize].y := z;
            inc(polyoverlapsize);
         end
      end;

      if (miny < 0.0) and (0.0 < maxy) then
      begin
       //Cross bottom
         z := p[i].x - p[i].y * (p[i].x - p[j].x) / (p[i].y - p[j].y);
         if (z >= 0.0) and (z <= 1.0) then
         begin
            polyoverlap[polyoverlapsize].x := z;
            polyoverlap[polyoverlapsize].y := 0.0;
            inc(polyoverlapsize);
         end
      end
      else if (miny < 1.0) and (1.0 < maxy) then
      begin
       //Cross top
         z := p[i].x + (1 - p[i].y) * (p[i].x - p[j].x) / (p[i].y - p[j].y);
         if (z >= 0.0) and (z <= 1.0) then
         begin
            polyoverlap[polyoverlapsize].x := z;
            polyoverlap[polyoverlapsize].y := 1.0;
            inc(polyoverlapsize);
         end;
      end;
   end;

  //Sort the points and return the area
   sortpoints;
   result := area;
end;

function byterange(a : double) : byte;
var
   b : integer;
begin
   b := round(a);
   if b < 0 then
      b := 0;
   if b > 255 then
      b := 255;

   result := b;
end;

function dorotate(src : HBITMAP; rotation : double; bgcolor : integer; autoblend : boolean) : HBITMAP;
const
   mx : array[0..3] of integer = (-1, 1, 1, -1);
   my : array[0..3] of integer = (-1, -1, 1, 1);
var
   indminx, indminy : integer;
   indmaxx, indmaxy : integer;
   srcbmp : Bitmap;
   srcxres, srcyres : double;
   xres, yres : double;
   width, height : integer;
   srcdib : array of TRGBQUAD;
   dbldstdib : array of aar_dblrgbquad;
   srcdibbmap : TBITMAPINFO;
   ldc : HDC;

   p : array[0..3] of aar_pnt;
   poffset : array[0..3] of aar_pnt;
   c : aar_pnt;
   xtrans, ytrans : double;
   x, y : integer;
   i, j : integer;
   mindx, mindy, maxdx, maxdy : integer;
   SrcIndex : integer;
   xx, yy : integer;

   dbloverlap : double;

   tmpaar_pnt : aar_pnt;
   DstIndex : integer;
   dstdib : array of TRGBQUAD;
   backcolor : TRGBQUAD;

   screenmode : DEVMODE;
   dstbmp : HBITMAP;
   dstdibmap : TBITMAPINFO;

begin
  //Calculate some index values so that values can easily be looked up
   indminx := trunc(rotation / 90) mod 4;
   indminy := (indminx + 1) mod 4;
   indmaxx := (indminx + 2) mod 4;
   indmaxy := (indminx + 3) mod 4;

  //Load the source bitmaps information
   if (GetObject(src, sizeof(srcbmp), @srcbmp) = 0) then
   begin
      result := 0;
      exit;
   end;

  //Calculate the sources x and y offset
   srcxres := srcbmp.bmWidth / 2.0;
   srcyres := srcbmp.bmHeight / 2.0;

  //Calculate the x and y offset of the rotated image (half the width and height of the rotated image)
   xres := mx[indmaxx] * srcxres * coss - my[indmaxx] * srcyres * sins;
   yres := mx[indmaxy] * srcxres * sins + my[indmaxy] * srcyres * coss;

  //Get the width and height of the image
   width := aar_roundup(xres * 2);
   height := aar_roundup(yres * 2);

  //Create the source dib array and the destdib array
   SetLength(srcdib, srcbmp.bmWidth * srcbmp.bmHeight);
   SetLength(dbldstdib, width * height);

  //Load source bits into srcdib
   srcdibbmap.bmiHeader.biSize := sizeof(srcdibbmap.bmiHeader);
   srcdibbmap.bmiHeader.biWidth := srcbmp.bmWidth;
   srcdibbmap.bmiHeader.biHeight := -srcbmp.bmHeight;
   srcdibbmap.bmiHeader.biPlanes := 1;
   srcdibbmap.bmiHeader.biBitCount := 32;
   srcdibbmap.bmiHeader.biCompression := BI_RGB;

   ldc := CreateCompatibleDC(0);
   GetDIBits(ldc, src, 0, srcbmp.bmHeight, srcdib, srcdibbmap, DIB_RGB_COLORS);
   DeleteDC(ldc);

   c.X := 0; c.Y := 0;

  //Loop through the source's pixels
   for x := 0 to (srcbmp.bmWidth - 1) do
   begin
      for y := 0 to (srcbmp.bmHeight - 1) do
      begin
        //Construct the source pixel's rotated polygon
         xtrans := x - srcxres;
         ytrans := y - srcyres;

         p[0].x := (xtrans * coss) - (ytrans * sins) + xres;
         p[0].y := xtrans * sins + ytrans * coss + yres;
         p[1].x := (xtrans + 1.0) * coss - ytrans * sins + xres;
         p[1].y := (xtrans + 1.0) * sins + ytrans * coss + yres;
         p[2].x := (xtrans + 1.0) * coss - (ytrans + 1.0) * sins + xres;
         p[2].y := (xtrans + 1.0) * sins + (ytrans + 1.0) * coss + yres;
         p[3].x := xtrans * coss - (ytrans + 1.0) * sins + xres;
         p[3].y := xtrans * sins + (ytrans + 1.0) * coss + yres;

        //Caculate center of the polygon
         c.x := 0;
         c.y := 0;
         for i := 0 to 3 do
         begin
            c.x := c.x + p[i].x / 4.0;
            c.y := c.y + p[i].y / 4.0;
         end;

        //Find the scan area on the destination's pixels
         mindx := trunc(p[indminx].x);
         mindy := trunc(p[indminy].y);
         maxdx := aar_roundup(p[indmaxx].x);
         maxdy := aar_roundup(p[indmaxy].y);

         SrcIndex := x + y * srcbmp.bmWidth;

        //loop through the scan area to find where source(x, y) overlaps with the destination pixels
         for xx := mindx to (maxdx - 1) do
         begin
            for yy := mindy to (maxdy - 1) do
            begin
               for i := 0 to 3 do
               begin
                  poffset[i].x := p[i].x - xx;
                  poffset[i].y := p[i].y - yy;
               end;

              //Calculate the area of the source's rotated pixel (polygon p) over the destinations pixel (xx, yy)
              //The function actually calculates the area of poffset over the square (0,0)-(1,1)
               tmpaar_pnt.X := c.x - xx;
               tmpaar_pnt.Y := c.y - yy;
               dbloverlap := pixoverlap(poffset, tmpaar_pnt);
               if (dbloverlap <> 0) then
               begin
                  DstIndex := xx + yy * width;

                 //Add the rgb and alpha values in proportion to the overlap area
                  dbldstdib[DstIndex].red := dbldstdib[DstIndex].red + (srcdib[SrcIndex].rgbRed) * dbloverlap;
                  dbldstdib[DstIndex].blue := dbldstdib[DstIndex].blue + (srcdib[SrcIndex].rgbBlue) * dbloverlap;
                  dbldstdib[DstIndex].green := dbldstdib[DstIndex].green + (srcdib[SrcIndex].rgbGreen) * dbloverlap;
                  dbldstdib[DstIndex].alpha := dbldstdib[DstIndex].alpha + dbloverlap;
               end;
            end;   // for YY
         end;   // for XX
      end;   // for Y
   end;   // for X

   SetLength(srcdib, 0);

  //Create final destination bits
   SetLength(dstdib, width * height);

  //load dstdib with information from dbldstdib
   backcolor.rgbRed := bgcolor and $000000FF;
   backcolor.rgbGreen := (bgcolor and $0000FF00) div $00000100;
   backcolor.rgbBlue := (bgcolor and $00FF0000) div $00010000;
   for i := 0 to (width * height - 1) do
   begin
      if (dbldstdib[i].alpha <> 0) then
      begin
         if (autoblend) then
         begin
            dstdib[i].rgbReserved := 0;
            dstdib[i].rgbRed := byterange(dbldstdib[i].red + (1 - dbldstdib[i].alpha) * backcolor.rgbRed);
            dstdib[i].rgbGreen := byterange(dbldstdib[i].green + (1 - dbldstdib[i].alpha) * backcolor.rgbGreen);
            dstdib[i].rgbBlue := byterange(dbldstdib[i].blue + (1 - dbldstdib[i].alpha) * backcolor.rgbBlue);
         end else
         begin
            dstdib[i].rgbRed := byterange(dbldstdib[i].red / dbldstdib[i].alpha);
            dstdib[i].rgbGreen := byterange(dbldstdib[i].green / dbldstdib[i].alpha);
            dstdib[i].rgbBlue := byterange(dbldstdib[i].blue / dbldstdib[i].alpha);
            dstdib[i].rgbReserved := byterange(255.0 * dbldstdib[i].alpha);
         end;
      end else
      begin
        //No color information -> fill with background color
         dstdib[i].rgbRed := backcolor.rgbRed;
         dstdib[i].rgbGreen := backcolor.rgbGreen;
         dstdib[i].rgbBlue := backcolor.rgbBlue;
         dstdib[i].rgbReserved := 0;
      end;
   end;

   SetLength(dbldstdib, 0);

  //Get Current Display Settings
   screenmode.dmSize := sizeof(DEVMODE);
   EnumDisplaySettings(nil, $FFFFFFFF{ENUM_CURRENT_SETTINGS}, screenmode);

  //Create the final bitmap object
   dstbmp := CreateBitmap(width, height, 1, screenmode.dmBitsPerPel, nil);

  //Write the bits into the bitmap and return it
   dstdibmap.bmiHeader.biSize := sizeof(dstdibmap.bmiHeader);
   dstdibmap.bmiHeader.biWidth := width;
   dstdibmap.bmiHeader.biHeight := -height;
   dstdibmap.bmiHeader.biPlanes := 1;
   dstdibmap.bmiHeader.biBitCount := 32;
   dstdibmap.bmiHeader.biCompression := BI_RGB;
   SetDIBits(0, dstbmp, 0, height, dstdib, dstdibmap, DIB_RGB_COLORS);

   SetLength(dstdib, 0);

   result := dstbmp;
end;

function AARotatedBMP(SrcBitmap : TBitmap; Rotation : double; BgColor : integer; AutoBlend : boolean) : TBitmap;
var
   res : HBITMAP;
   i : integer;
   mult : integer;
begin
   if SrcBitmap.Empty then
   begin
      result := nil;
      exit;
   end;

   for i := 0 to 3 do begin
      corners[i].x := dx[i];
      corners[i].y := dy[i];
   end;

  //Get rotation between (0, 360)
   mult := trunc(Rotation / 360);
   if (Rotation >= 0) then
      Rotation := Rotation - 360.0 * mult
   else
      Rotation := Rotation - 360.0 * (mult - 1);

  //Calculate the cos and sin values that will be used throughout the program
   coss := aar_cos(Rotation);
   sins := aar_sin(Rotation);

   res := dorotate(SrcBitmap.Handle, Rotation, BgColor, AutoBlend);

   if res <> 0 then
   begin
      Result := TBitmap.Create;
      Result.Handle := res;
   end else
      Result := nil;
end;

end.
