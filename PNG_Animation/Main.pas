unit Main;

interface

uses
  Windows, SysUtils, Graphics, Controls, Forms, ExtCtrls, JPEG,
  StdCtrls, ComCtrls, TangentThread, PNGImage, Classes;

const
  W = 320; { Notre image fait 320 pixels de large sur 240 pixels de haut }
  H = 240;

type
  TMainForm = class(TForm)
    Img: TImage;
    ButtonPanel: TPanel;
    SpeedBar: TTrackBar;
    SpeedLbl: TLabel;
    QuitBtn: TButton;
    PauseBtn: TButton;
    CreditsLbl: TLabel;
    DoubleCrossBox: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TimerTimer(Sender: TObject);
    procedure SpeedBarChange(Sender: TObject);
    procedure QuitBtnClick(Sender: TObject);
    procedure PauseBtnClick(Sender: TObject);
    procedure ImgMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DoubleCrossBoxClick(Sender: TObject);
  private
    { D�clarations priv�es }
  public
    { D�clarations publiques }
    procedure RequestBackground(FileName: String);
    procedure InitPNG;
    procedure InitPos;
    procedure DrawAll;
    procedure SetAlpha;
    procedure MovePos(var Pos: Integer; var Dir: Boolean; Tag: Integer);
  end;

const
  OriginPt: TPoint = (x: 0; y: 0); { Repr�sente un point M(0; 0) }

var
  MainForm: TMainForm;
  Thread: TTangentThread; { Le thread d'affichage   }
  Bkgnd: TBitmap;         { L'image en arri�re-plan }
  Png: TPngObject;        { L'objet PNG             }
  PosX: Integer;          { Position X de la lumi�re }
  PosY: Integer;          { Position Y de la lumi�re }
  DirX: Boolean;          { Direction X de la lumi�re }
  DirY: Boolean;          { Direction Y de la lumi�re }
  Speed: Integer=1;       { Vitesse de l'animation }
  DoubleCross: Boolean;   { Indique si l'on affiche en simple cross ou en double cross }

implementation

{$R *.dfm}

function Clamp(Value: Integer): Byte; { Limite un type Integer � son �quivalent Byte }
Var
 Min: Integer;
begin
 if DoubleCross then Min := 27 else Min := 0; { On s'arr�te � 27 minimum en double-crossing }
 if Value < Min then Value := Min;
 if Value > 254 then Value := 254;  { On limite � 0 (ou 27) .. 254 }
 Result := Value;                   { On prend le r�sultat }
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
 Thread := TTangentThread.Create(nil);
 Thread.Interval := 1;
 Thread.OnExecute := TimerTimer;       { On cr�e le thread, on le param�tre ...   }
 Thread.Active := True;
 InitPos;                              { On initialise les positions des lumi�res }
 DoubleBuffered := True;
 InitPNG;                              { On initialise le PNG (tout noir ...      }
 RequestBackground(ExtractFilePath(Application.ExeName) + 'Images\Bkgnd-Kitten.jpg');
 { On r�cup�re le background des chatons }
end;

procedure TMainForm.RequestBackground(FileName: String);  { R�cup�re un arri�re-plan }
Var
 JPEGImage: TJPEGImage;
begin
 JPEGImage := TJPEGImage.Create;
 JPEGImage.LoadFromFile(FileName);         { On ouvre le JPEG, et on donne l'image au bitmap }
 Bkgnd.Assign(JPEGImage);
 JPEGImage.Free;
end;

procedure TMainForm.InitPNG;               { Pr�paration du PNG }
Var
 X, Y: Integer;
 Pix: PRGBTRIPLE;
begin
 Pix := PNG.Scanline[H - 1];
 for X := 0 to W - 1 do
  for Y := 0 to H - 1 do
   begin
    Pix^.rgbtRed := 0;
    Pix^.rgbtGreen := 0;                   { On parcourt le PNG et on le remplit de noir }
    Pix^.rgbtBlue := 0;
    Inc(Pix);
    Png.AlphaScanline[Y][X] := 254;        { 254 - totalement opaque pour le moment      }
   end;
end;

procedure TMainForm.InitPos;               { Initialisation des positions }
Var
 C: Integer;
begin
 C := random(2);
 case C of
  0: DirX := False;                        { On choisit une direction au hasard ... }
  1: DirX := True;
 end;

 C := random(2);
 case C of
  0: DirY := False;
  1: DirY := True;
 end;

 PosX := random(W - 2) + 1;
 PosY := random(H - 2) + 1;                { Ainsi qu'une position de d�part ... }
end;

procedure TMainForm.SetAlpha;              { Calcul des valeurs alpha pour faire la "lumi�re" }
Var
 X, Y: Integer;
 DX, DY: Byte;
begin
 for X := 0 to W - 1 do                    { Pour chaque pixel de largeur }
  begin
   DX := Clamp(Abs(PosX - X));             { On calcule sa diff�rence avec le milieu horizontal }
   for Y := 0 to H - 1 do                  { Pour chaque pixel de hauteur }
    begin
     DY := Clamp(Abs(PosY - Y));           { On calcule sa diff�rente avec le milieu vertical }
     Png.AlphaScanline[Y][X] := Clamp(DX + DY);
     { Finalement, on se retrouve avec deux diff�rences, qui correspondent en fait � une indication
       de distance entre le pixel M(X; Y) et le centre de l'image. On fait alors la somme des 2.
       On pourrait aussi faire la moyenne mais l'aire de lumi�re serait trop grande ... }
    end;
  end;
end;

procedure TMainForm.DrawAll;              { On dessine tout - proc�dure d'affichage }
begin
 Img.Canvas.Draw(0, 0, Bkgnd);            { On dessine l'image en arri�re-plan }
 Png.DrawUsingPixelInformation(Img.Canvas, OriginPt);
 { On colle le PNG par-dessus : selon la position de la lumi�re, les valeurs de transparence de
   chaque pixel sont calcul�es dans SetAlpha. A ce moment-l�, les pixels transparents laisseront
   voir l'image d'arri�re-plan derri�re eux. }
end;

procedure TMainForm.MovePos(var Pos: Integer; var Dir: Boolean; Tag: Integer);
Var
 Ref: Integer;
begin
 case Dir of
  False: Dec(Pos, Speed); { False : vers la gauche / le haut }
  True:  Inc(Pos, Speed); { True : vers la droite  / le bas }
 end;

 case Tag of
  1: Ref := W - 1;
  2: Ref := H - 1;       { 1 : on utilise la largeur comme r�f�rence. 2 : la hauteur. }
  else Ref := H - 1;
 end;

 if Pos >= Ref then Dir := False; { On voit si l'on est pas sorti des limites, on change de ... }
 if Pos <= 0 then Dir := True;    { ... direction le cas �ch�ant. }
end;

procedure TMainForm.TimerTimer(Sender: TObject);  { Proc�dure du thread }
begin
 SetAlpha;                                        { On calcule les lumi�res }
 DrawAll;                                         { On affiche tout }
 MovePos(PosX, DirX, 1);                          { On bouge les positions des lumi�res }
 MovePos(PosY, DirY, 2);                          { Idem }
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);  { Fermeture de l'appli. }
begin
 Thread.Free;
 { On lib�re notre thread (il n'est propri�taire de personne, m�me pas de la fiche, et c'est bien
   mon intention : une lib�ration propre est critique ici ! }
end;

procedure TMainForm.SpeedBarChange(Sender: TObject);  { Changement de la barre de vitesse }
begin
 Speed := SpeedBar.Position;                          { On change la variable Speed, �a suffit }
end;

procedure TMainForm.QuitBtnClick(Sender: TObject);    { Bouton Quitter ... }
begin
 Close;                                               { On ferme l'application }
end;

procedure TMainForm.PauseBtnClick(Sender: TObject);   { Bouton "Pause/Relancer" }
begin
 Thread.Active := not Thread.Active;                  { On permute On/Off }
 Img.Enabled := Thread.Active;                        { Egalement pour l'image }
 case Thread.Active of                                { On adapte le libell� en cons�quence }
  False: PauseBtn.Caption := 'Relancer';
  True:  PauseBtn.Caption := 'Pause';
 end;
end;

procedure TMainForm.ImgMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);                  { On a cliqu� sur l'image ! }
begin
 PosX := X;                                            { On va d�placer les lumi�res l� ... }
 PosY := Y;
end;

procedure TMainForm.DoubleCrossBoxClick(Sender: TObject);   { Clic sur la checkbox }
begin
 DoubleCross := DoubleCrossBox.Checked;                     { On change la variable DoubleCross }
end;

initialization                                              { Au commencement ... }
 randomize;                                                 { Initialisation du moteur al�atoire }
 Bkgnd := TBitmap.Create;                                   { Cr�ation du bitmap arri�re-plan }
 Png := TPngObject.CreateBlank(COLOR_RGBALPHA, 16, W, H);   { Cr�ation de l'objet PNG         }

finalization                                                { A l'aube de l'apocalypse ... }
 Png.Free;                                                  { On lib�re le PNG }
 Bkgnd.Free;                                                { On lib�re le bitmap arri�re-plan }

end.