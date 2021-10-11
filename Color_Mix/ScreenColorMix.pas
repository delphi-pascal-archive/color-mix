//  ColorMix:  Additive and Subtractive Colors
//  efg, January 1999

unit ScreenColorMix;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ExtDlgs;

type
  TFormColorMix = class(TForm)
    CheckBoxRed: TCheckBox;
    CheckBoxGreen: TCheckBox;
    CheckBoxBlue: TCheckBox;
    ComboBoxPrimaries: TComboBox;
    ButtonSaveToFile: TButton;
    ButtonPrint: TButton;
    Image: TImage;
    SavePictureDialog: TSavePictureDialog;
    LabelLab1: TLabel;
    LabelLab2: TLabel;
    LabelDescribe: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure ButtonSaveToFileClick(Sender: TObject);
    procedure ButtonPrintClick(Sender: TObject);
  private
    PROCEDURE UpdateEverything;
  public
    { Public declarations }
  end;

var
  FormColorMix: TFormColorMix;

implementation
{$R *.DFM}

  USES
    Printers;   // Printer

  CONST
    PixelCountMax = 32768;

  TYPE
    TRGBTripleArray = ARRAY[0..PixelCountMax-1] OF TRGBTriple;
    pRGBTripleArray = ^TRGBTripleArray;

 //==  Bitmap Manipulations  ==============================================

  // Based on posting to borland.public.delphi.winapi by Rodney E Geraghty,
  // 8/8/97.  Used to print bitmap on any Windows printer.
  PROCEDURE PrintBitmap(Canvas:  TCanvas; DestRect:  TRect;  Bitmap:  TBitmap);
    VAR
      BitmapHeader:  pBitmapInfo;
      BitmapImage :  POINTER;
      HeaderSize  :  DWORD;    // Use DWORD for compatibility with D3 and D4
      ImageSize   :  DWORD;
  BEGIN
    GetDIBSizes(Bitmap.Handle, HeaderSize, ImageSize);
    GetMem(BitmapHeader, HeaderSize);
    GetMem(BitmapImage,  ImageSize);
    TRY
      GetDIB(Bitmap.Handle, Bitmap.Palette, BitmapHeader^, BitmapImage^);
      StretchDIBits(Canvas.Handle,
                    DestRect.Left, DestRect.Top,     // Destination Origin
                    DestRect.Right  - DestRect.Left, // Destination Width
                    DestRect.Bottom - DestRect.Top,  // Destination Height
                    0, 0,                            // Source Origin
                    Bitmap.Width, Bitmap.Height,     // Source Width & Height
                    BitmapImage,
                    TBitmapInfo(BitmapHeader^),
                    DIB_RGB_COLORS,
                    SRCCOPY)
    FINALLY
      FreeMem(BitmapHeader);
      FreeMem(BitmapImage)
    END
  END {PrintBitmap};


// Use parametric assignment of fitting circles inside cube
// of specified size.
FUNCTION CreateRGBCircles(CONST size:  INTEGER;
                          CONST Rflag, Gflag, Bflag:  BOOLEAN):  TBitmap;
  VAR
    AdjustedSize :  INTEGER;
    Border       :  INTEGER;
    i, iR,iG,iB  :  INTEGER;
    j, jR,jG,jB  :  INTEGER;
    jOffset      :  INTEGER;
    RadiusSquared:  INTEGER;
    row          :  pRGBTripleArray;

  FUNCTION DistanceSquared(CONST x1,y1, x2,y2:  INTEGER):  INTEGER;
  BEGIN
    RESULT :=   SQR(x1 - x2) + SQR(y1 - y2)
  END {DistanceSquared};

BEGIN
  Border := MulDiv(size, 5, 1000);

  AdjustedSize := size - 2*Border;

  RadiusSquared := SQR( MulDiv(AdjustedSize, 2,6) );

  iR := Border + MulDiv(AdjustedSize, 2, 6);
  iG := Border + MulDiv(AdjustedSize, 3, 6);
  iB := Border + MulDiv(AdjustedSize, 4, 6);

  jOffset := ROUND(AdjustedSize * (2 - SQRT(3))/12);
  jR := jOffset + Border + Round(AdjustedSize * (2 + SQRT(3)) / 6);
  jG := jOffset + Border + MulDiv(AdjustedSize, 2, 6);
  jB := jR;

  RESULT := TBitmap.Create;
  RESULT.Width  := size;
  RESULT.Height := size;
  RESULT.PixelFormat := pf24bit;

  RESULT.Canvas.Brush.Color := RGB(0,0,0);  // black
  RESULT.Canvas.FillRect(RESULT.Canvas.ClipRect);

  FOR j := 0 TO RESULT.Height-1 DO
  BEGIN
    row := RESULT.Scanline[j];

    FOR i := 0 TO RESULT.Width-1 DO
    BEGIN
      WITH row[i] DO
      BEGIN
        IF   Rflag AND (DistanceSquared(i,j, iR,jR) < RadiusSquared)
        THEN rgbtRed := 255;

        IF   GFlag AND (DistanceSquared(i,j, iG,jG) < RadiusSquared)
        THEN rgbtGreen := 255;

        IF   BFlag AND (DistanceSquared(i,j, iB,jB) < RadiusSquared)
        THEN rgbtBlue := 255
      END
    END

  END
END {CreateRGBCircles};


// Use parametric assignment of fitting circles inside cube
// of specified size.
FUNCTION CreateCMYCircles(CONST size:  INTEGER;
                          CONST Cflag, Mflag, Yflag:  BOOLEAN):  TBitmap;
  VAR
    AdjustedSize :  INTEGER;
    Border       :  INTEGER;
    i, iC,iM,iY  :  INTEGER;
    j, jC,jM,jY  :  INTEGER;
    jOffset      :  INTEGER;
    RadiusSquared:  INTEGER;
    row          :  pRGBTripleArray;

  FUNCTION DistanceSquared(CONST x1,y1, x2,y2:  INTEGER):  INTEGER;
  BEGIN
    RESULT :=   SQR(x1 - x2) + SQR(y1 - y2)
  END {DistanceSquared};

BEGIN
  Border := MulDiv(size, 5, 1000);

  AdjustedSize := size - 2*Border;

  RadiusSquared := SQR( MulDiv(AdjustedSize, 2,6) );

  iC := Border + MulDiv(AdjustedSize, 2, 6);
  iM := Border + MulDiv(AdjustedSize, 3, 6);
  iY := Border + MulDiv(AdjustedSize, 4, 6);

  jOffset := ROUND(AdjustedSize * (2 - SQRT(3))/12);
  jC := jOffset + Border + Round(AdjustedSize * (2 + SQRT(3)) / 6);
  jM := jOffset + Border + MulDiv(AdjustedSize, 2, 6);
  jY := jC;

  RESULT := TBitmap.Create;
  RESULT.Width  := size;
  RESULT.Height := size;
  RESULT.PixelFormat := pf24bit;

  RESULT.Canvas.Brush.Color := RGB(255,255,255);  // white
  RESULT.Canvas.FillRect(RESULT.Canvas.ClipRect);

  FOR j := 0 TO RESULT.Height-1 DO
  BEGIN
    row := RESULT.Scanline[j];

    FOR i := 0 TO RESULT.Width-1 DO
    BEGIN
      WITH row[i] DO
      BEGIN
        IF   Cflag AND (DistanceSquared(i,j, iC,jC) < RadiusSquared)
        THEN rgbtRed := 0;

        IF   MFlag AND (DistanceSquared(i,j, iM,jM) < RadiusSquared)
        THEN rgbtGreen := 0;

        IF   YFlag AND (DistanceSquared(i,j, iY,jY) < RadiusSquared)
        THEN rgbtBlue := 0;
      END
    END

  END
END {CreateCMYCircles};



PROCEDURE TFormColorMix.UpdateEverything;
  VAR
    Bitmap:  TBitmap;
BEGIN
  IF  ComboBoxPrimaries.ItemIndex = 0
  THEN Bitmap := CreateRGBCircles(Image.Width,
                                  CheckBoxRed.Checked,
                                  CheckBoxGreen.Checked,
                                  CheckBoxBlue.Checked)
  ELSE Bitmap := CreateCMYCircles(Image.Width,
                                  CheckBoxRed.Checked,
                                  CheckBoxGreen.Checked,
                                  CheckBoxBlue.Checked);
  TRY
    Image.Picture.Graphic := Bitmap;
  FINALLY
    Bitmap.Free
  END;
END;


procedure TFormColorMix.FormCreate(Sender: TObject);
begin
  ComboBoxPrimaries.ItemIndex := 0;
  UpdateEverything
end;


procedure TFormColorMix.CheckBoxClick(Sender: TObject);
begin
  IF   ComboBoxPrimaries.ItemIndex = 0
  THEN LabelDescribe.Caption := 'Add to Black'
  ELSE LabelDescribe.Caption := 'Subtract from White';

  UpdateEverything
end;


procedure TFormColorMix.ButtonSaveToFileClick(Sender: TObject);
  CONST
    ImageSizeForFile = 512;

  VAR
    Bitmap:  TBitmap;
BEGIN
  IF   SavePictureDialog.Execute
  THEN BEGIN

    IF  ComboBoxPrimaries.ItemIndex = 0
    THEN Bitmap := CreateRGBCircles(ImageSizeForFile,
                                    CheckBoxRed.Checked,
                                    CheckBoxGreen.Checked,
                                    CheckBoxBlue.Checked)
    ELSE Bitmap := CreateCMYCircles(ImageSizeForFile,
                                    CheckBoxRed.Checked,
                                    CheckBoxGreen.Checked,
                                    CheckBoxBlue.Checked);
    TRY
      Bitmap.SavetoFile(SavePictureDialog.Filename);
      ShowMessage('File ' + SavePictureDialog.Filename + ' written.')
    FINALLY
      Bitmap.Free
    END

  END
end;


procedure TFormColorMix.ButtonPrintClick(Sender: TObject);
  CONST
    iMargin =  8;  //  8% margin left and right
    jMargin = 10;  // 10% margin top and bottom

  VAR
    iFromLeftMargin    :  INTEGER;
    iPrintedImageWidth :  INTEGER;
    jFromPageMargin    :  INTEGER;
    jPrintedImageHeight:  INTEGER;
    s                  :  STRING;
    TargetRectangle    :  TRect;
begin
  Printer.Orientation := poPortrait;
  Printer.BeginDoc;
  TRY
    iFromLeftMargin := MulDiv(Printer.PageWidth,  iMargin, 100);
    jFromPageMargin := MulDiv(Printer.PageHeight, jMargin, 100);

    iPrintedImageWidth  := MulDiv(Printer.PageWidth, 100-2*iMargin, 100);
    jPrintedImageHeight := iPrintedImageWidth;  // Aspect ratio is 1 for these images

    TargetRectangle := Rect(iFromLeftMargin, jFromPageMargin,
                            iFromLeftMargin + iPrintedImageWidth,
                            jFromPageMargin + jPrintedImageHeight);

    // Header
    Printer.Canvas.Font.Size := 14;
    Printer.Canvas.Font.Name := 'Arial';
    Printer.Canvas.Font.Color := clBlack;
    Printer.Canvas.Font.Style := [fsBold];
    s := ComboBoxPrimaries.Text;
    Printer.Canvas.TextOut(
      (Printer.PageWidth - Printer.Canvas.TextWidth(s)) DIV 2,  // center
      jFromPageMargin - 3*Printer.Canvas.TextHeight(s) DIV 2,
      s);

    // Bitmap
    PrintBitmap(Printer.Canvas, TargetRectangle, Image.Picture.Bitmap);

    // Footer
    Printer.Canvas.Font.Size := 12;
    Printer.Canvas.Font.Name := 'Arial';
    Printer.Canvas.Font.Color := clBlue;
    Printer.Canvas.Font.Style := [fsBold, fsItalic];
    s := 'efg''s Computer Lab';
    Printer.Canvas.TextOut(iFromLeftMargin,
                           Printer.PageHeight -
                           Printer.Canvas.TextHeight(s),
                           s);

    Printer.Canvas.Font.Style := [fsBold];
    s := 'www.efg2.com/lab';
    Printer.Canvas.TextOut(Printer.PageWidth -
                           iFromLeftMargin   -
                           Printer.Canvas.TextWidth(s),
                           Printer.PageHeight -
                           Printer.Canvas.TextHeight(s),
                           s)
  FINALLY
    Printer.EndDoc
  END;

  ShowMessage ('Image Printed')
end;

end.
