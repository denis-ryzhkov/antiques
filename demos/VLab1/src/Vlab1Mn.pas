unit Vlab1Mn;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Forms, ShellApi, ExtCtrls,
  Controls, StdCtrls, MMSystem;

type
  TVLab1MnF = class(TForm)
    tim: TTimer;
    CPan: TPanel;
    monst: TStaticText;
    VPan: TPanel;
    Portrait: TImage;
    portrs: TShape;
    portl: TLabel;
    forthi: TImage;
    speedi: TImage;
    frthvagei: TImage;
    foodi: TImage;
    wearinessi: TImage;
    forthl: TLabel;
    speedl: TLabel;
    fvagel: TLabel;
    foodl: TLabel;
    wnessl: TLabel;
    closecpanb: TButton;
    exitb: TButton;
    pauseb: TButton;
    procedure FormActivate(Sender: TObject);
    procedure idleproc(Sender: TObject; var Done: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure timTimer(Sender: TObject);
    procedure monstMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure monstMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure closecpanbClick(Sender: TObject);
    procedure exitbClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pausebClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

tsprkind=(skpotherb,skbeast);  

tspr=
 class(tobject)
  kind:tsprkind;
  bmp:tbitmap;
  x,y:longint;
  w,h:word;
  xs,ys:shortint;
  age,time2die:cardinal;
  chckmeeting:boolean;
  mobjkind:tsprkind;
  mobjnum:word;
  constructor create(startx,starty:longint);
  procedure takebmp(fn:string);
  destructor destroy;override;
  procedure put(newx,newy:longint);
  procedure setspeed(newxs,newys:shortint);
  procedure move;
  procedure meet(amobjkind:tsprkind;amobjnum:word);
  procedure die;
 end;

talive=
 class(tspr)
  forth,speed,fvage,wness,food,deathtim,maxfvage:integer;
  going,dging,goPerWness,dgPerFood:cardinal;
  constructor create(startx,starty:longint);
  procedure move;
  procedure die;
 end;

tseln=
 class(tspr)
  objkind:tsprkind;
  num:word;
  constructor create;
  procedure move;
  procedure take(akind:tsprkind;anum:word);
  procedure left;
 end;

tstatic=
 class(tspr)
  procedure move;
 end;

tpotherb=
 class(tstatic)
  food:integer;
  constructor create(startx,starty:longint);
  procedure move;
 end;

thuman=
 class(talive)
  procedure move;
 end;

tbeast=
 class(talive)
  constructor create(startx,starty:longint);
  procedure move;
 end;

tman=
 class(thuman)
  procedure move;
 end;

twoman=
 class(thuman)
  procedure move;
 end;


const maxpotherbs=50;
      maxbeasts=50;
      crNorm=5;
      crTake=6;
      crPoint=7;
      p=3.1415926535897932385;
var
  VLab1MnF: TVLab1MnF;
  wdth,hght,dx,dy,curpotherb,curbeast,curnum,
  psblnum,lastnum,potherbs,beasts:word;
  potherb:array[1..maxpotherbs] of tpotherb;
  beast:array[1..maxbeasts] of tbeast;
  seln:tseln;
  buf,bg:tbitmap;
  dging,cantake,canshow:boolean;
  lastid:string;
implementation

{$R *.DFM}

procedure tspr.meet(amobjkind:tsprkind;amobjnum:word);
begin end;

procedure tspr.die;
begin end;

constructor tseln.create;
begin
 inherited create(10,10);
 bmp.FreeImage;
 num:=0;
 chckmeeting:=false;
end;

procedure talive.move;
begin
 if deathtim<>0 then
  begin
   dec(deathtim);
   if deathtim=1 then
    begin
     bmp.FreeImage;
     put(x,y);
     exit;
    end;
  end else

  begin
   if (xs<>0) or (ys<>0) then inc(going);
   if going=goPerWness then
    begin
     going:=0;
     inc(wness);
    end;

   inc(dging);
   if dging=dgPerFood then
    begin
     dging:=0;
     dec(food);
    end;

   fvage:=round(maxfvage*sin(p*age/time2die)); 
   if (x<10) or (x>wdth-10) then xs:=-xs;
   if (y<10) or (y>hght-10) then ys:=-ys;
   forth:=fvage+food-wness;
   speed:=(forth div 10)+1;
   if forth<=0 then die;
  end;
 inherited move;
end;

procedure snd(s:string);
var s1:string;
begin
 s1:='snd\'+s+'.wav';
 playsound(@s1[1],0,snd_Async);
end;


procedure talive.die;
begin
 deathtim:=10;
 xs:=0;
 ys:=0;
 takebmp('dead');
 snd('dthbeast');
end;

procedure tman.move;
begin
 inherited move;
end;

procedure tseln.move;
begin
 if num=0 then exit;
 if objkind=skpotherb then
  begin
   x:=potherb[num].x-5;
   y:=potherb[num].y-5;
  end else
  if objkind=skbeast then
   begin
    x:=beast[num].x-5;
    y:=beast[num].y-5;
   end else
    left;
 inherited move;
end;

procedure tseln.take(akind:tsprkind;anum:word);
begin
 objkind:=akind;
 num:=anum;
 takebmp('selction');
end;

procedure tseln.left;
begin
 num:=0;
 bmp.FreeImage;
end;

procedure tstatic.move;
begin
 inherited move;
end;

procedure tpotherb.move;
begin
 if ((age div 200)=(age/200)) and (food<200) then inc(food);
 inherited move;
end;

procedure twoman.move;
begin
 inherited move;
end;

procedure thuman.move;
begin
 inherited move;
end;

procedure tbeast.move;
begin
 if deathtim=0 then
  begin
   if random(50)=5 then xs:=-xs;
   if random(50)=5 then ys:=-ys;
   if random(50)=5 then xs:=random(speed+(speed div 2))-(speed div 2);
   if random(50)=5 then ys:=random(speed+(speed div 2))-(speed div 2);
  end;
 inherited move;
end;

procedure tspr.setspeed(newxs,newys:shortint);
begin
 xs:=newxs;
 ys:=newys;
end;

procedure tspr.takebmp(fn:string);
begin
 bmp.LoadFromFile('pic\'+fn+'.bmp');
 w:=bmp.Width;
 h:=bmp.Height;
end;

constructor tspr.create(startx,starty:longint);
begin
 inherited create;
 bmp:=tbitmap.create;
 x:=startx;
 y:=starty;
 xs:=0;
 ys:=0;
 age:=0;
 takebmp('dead');
 bmp.transparent:=true;
 chckmeeting:=true;
 mobjnum:=0;
 time2die:=1000000000;
end;

constructor talive.create(startx,starty:longint);
begin
 inherited create(startx,starty);
 speed:=1;
 forth:=10;
 fvage:=0;
 maxfvage:=50;
 food:=5;
 wness:=2;
 going:=0;
 goPerWness:=100;
 dging:=0;
 dgPerFood:=50;
end;

constructor tbeast.create(startx,starty:longint);
begin
 inherited create(startx,starty);
 kind:=skBeast;
 goPerWness:=500+random(100);
 dgPerFood:=300+random(100);
 time2die:=100+random(500);
 maxfvage:=100;
end;

constructor tpotherb.create(startx,starty:longint);
begin
 inherited create(startx,starty);
 kind:=skPotherb;
 food:=50;
 chckmeeting:=false;
end;

destructor tspr.destroy;
begin
 bmp.Free;
 inherited destroy;
end;

procedure tspr.put(newx,newy:longint);
begin
 x:=newx;
 y:=newy;
 buf.Canvas.Draw(x,y,bmp);
end;

procedure tspr.move;
var nx,ny:longint;
    a:word;
begin
 inc(age);
// if age=time2die then die;

 nx:=x+xs;
 ny:=y+ys;
 put(nx,ny);

 if chckmeeting then
  begin
   for a:=1 to potherbs do
    if (potherb[a].x>=x-7) and (potherb[a].y>=y-7) and
       (potherb[a].x<=x+7) and (potherb[a].y<=y+7) then
         meet(skPotherb,a);

   for a:=1 to beasts do
    if (beast[a].x>=x-7) and (beast[a].y>=y-7) and
       (beast[a].x<=x+7) and (beast[a].y<=y+7) then
         begin
          if (kind=skBeast) and (self=beast[a]) then continue;
          meet(skbeast,a);
         end;
  end;
end;

procedure TVLab1MnF.FormActivate(Sender: TObject);
var bg1:tbitmap;
    a:word;
begin
 screen.cursors[crnorm]:=LoadCursorfromfile('pic\normal.cur');
 screen.cursors[crtake]:=LoadCursorfromfile('pic\take.cur');
 screen.cursors[crpoint]:=LoadCursorfromfile('pic\point.cur');
 Cursor:=crnorm;
 cpan.Cursor:=crPoint;
 vpan.Cursor:=crPoint;
 monst.Cursor:=crPoint;
 exitb.Cursor:=crPoint;
 pauseb.Cursor:=crPoint;
 closecpanb.Cursor:=crPoint;

 wdth:=clientwidth;
 hght:=clientheight;
 bg:=tbitmap.Create;
 bg1:=tbitmap.Create;
 bg.LoadFromFile('noise2.bmp');
 bg1.Width:=wdth;
 bg1.Height:=hght;
 bg1.Canvas.StretchDraw(rect(0,0,wdth,hght),bg);

 bg.Width:=wdth;
 bg.Height:=hght;
 bg.Canvas.Draw(0,0,bg1);
 bg1.free;

 buf:=tbitmap.Create;
 application.OnIdle:=idleproc;
 buf.Width:=wdth;
 buf.Height:=hght;
 randomize;

 beasts:=10;
 potherbs:=10;

 for a:=1 to potherbs do
  begin
   potherb[a]:=tpotherb.create(random(wdth-20)+10,random(hght-20)+10);
   potherb[a].takebmp('potherb');
   potherb[a].setspeed(0,0);
  end;

 for a:=1 to beasts do
  begin
   beast[a]:=tbeast.create(random(wdth-20)+10,random(hght-20)+10);
   beast[a].takebmp('beast');
   beast[a].setspeed(random(3)-1,random(3)-1);
  end;

 seln:=tseln.create; 
end;

procedure TVLab1MnF.idleproc(Sender: TObject; var Done: Boolean);
begin
{}
end;

procedure TVLab1MnF.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=27 then application.Terminate;
 if key=32 then pausebclick(self);
end;

procedure TVLab1MnF.FormClose(Sender: TObject; var Action: TCloseAction);
var a:word;
begin
 for a:=1 to potherbs do
  potherb[a].destroy;
 for a:=1 to beasts do
  beast[a].destroy;
 seln.destroy;
 buf.free;
 bg.free;
end;

procedure TVLab1MnF.timTimer(Sender: TObject);
var a,b:word;
    x,y:integer;

  procedure portr(s:string);
  var l:string;
  begin
   if (lastid=s) and (lastnum=curnum) then exit;
   lastid:=s;
   lastnum:=curnum;

   if curpotherb<>0 then lastnum:=curpotherb else
    if curbeast<>0 then lastnum:=curbeast else
     lastnum:=0;
   portrait.Picture.LoadFromFile('pic\'+s+'.bmp');
   if s='potherb' then l:='Зелень' else
    if s='beast' then l:='Тварь' else
     l:='';
   portl.Caption:=l;
  end;

begin
 buf.canvas.Draw(0,0,bg);

 for a:=1 to beasts do
  if beast[a].deathtim=1 then
   begin
    if curbeast=a then closecpanbclick(self); 
    beast[a].destroy;
    for b:=a to beasts-1 do
     beast[b]:=beast[b+1];
    dec(beasts); 
   end;

 for a:=1 to potherbs do
  potherb[a].move;
 for a:=1 to beasts do
  beast[a].move;
 seln.move;
 
 if canshow and (not cpan.Visible) then cpan.show;

 if not cpan.Visible then
  begin
   cantake:=false;
   curpotherb:=0;
   curbeast:=0;
   curnum:=0;
   x:=mouse.cursorPos.x;
   y:=mouse.cursorPos.y;

   for a:=1 to potherbs do
    if (potherb[a].x>=x-7) and (potherb[a].y>=y-7) and
       (potherb[a].x<=x) and (potherb[a].y<=y) then
        begin
         cantake:=true;
         curpotherb:=a;
         curnum:=a;
         break;
        end;

   if curpotherb=0 then
     for a:=1 to beasts do
      if (beast[a].x>=x-7) and (beast[a].y>=y-7) and
         (beast[a].x<=x) and (beast[a].y<=y) then
          begin
           cantake:=true;
           curbeast:=a;
           curnum:=a;
           break;
          end;

   if cantake then cursor:=crTake else
    if cursor=crTake then cursor:=crNorm;
  end else
  begin
   if cursor=crTake then cursor:=crNorm;
   if (curpotherb<>0) then
    begin
     portr('potherb');
     forthl.Caption:='0';
     speedl.Caption:='0';
     fvagel.Caption:='0';
     wnessl.Caption:='0';
     foodl.Caption:=inttostr(potherb[curpotherb].food);
    end else
     if (curbeast<>0) then
      begin
       portr('beast');
       forthl.Caption:=inttostr(beast[curbeast].forth);
       speedl.Caption:=inttostr(beast[curbeast].speed);
       fvagel.Caption:=inttostr(beast[curbeast].fvage);
       wnessl.Caption:=inttostr(beast[curbeast].wness);
       foodl.Caption:=inttostr(beast[curbeast].food);
      end else cpan.Hide;
  end;
 vlab1mnf.Canvas.Draw(0,0,buf);
end;

procedure TVLab1MnF.monstMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 dging:=true;
 dx:=x;
 dy:=y;
end;

procedure TVLab1MnF.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 if not dging then exit;
 cpan.Left:=mouse.CursorPos.x-dx-2;
 cpan.Top:=mouse.CursorPos.y-dy-2;
end;

procedure TVLab1MnF.monstMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 dging:=false;
end;

procedure TVLab1MnF.closecpanbClick(Sender: TObject);
begin
 cpan.hide;
 canshow:=false;
 seln.left;
end;

procedure TVLab1MnF.exitbClick(Sender: TObject);
begin
 application.Terminate;
end;

procedure TVLab1MnF.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if (button=mbRight) and (cpan.visible) then closecpanbclick(self) else
 if cantake then
  begin
   canshow:=true;
   if curpotherb<>0 then seln.take(skpotherb,curpotherb) else
   if curbeast<>0 then seln.take(skbeast,curbeast);
  end;
end;

procedure TVLab1MnF.pausebClick(Sender: TObject);
begin
 tim.Enabled:=not tim.Enabled;
end;

end.
