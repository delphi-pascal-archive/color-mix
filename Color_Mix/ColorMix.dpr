//  ColorMix:  Additive and Subtractive Colors
//  efg, January 1999

program ColorMix;

uses
  Forms,
  ScreenColorMix in 'ScreenColorMix.pas' {FormColorMix};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormColorMix, FormColorMix);
  Application.Run;
end.
