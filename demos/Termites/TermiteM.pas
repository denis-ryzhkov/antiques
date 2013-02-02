unit TermiteM;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ShellApi, Menus;

type
  TTermiteMF = class(TForm)
    tim: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure timTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TermiteMF: TTermiteMF;
  x,y,wx,wy,xs,ys,xa,ya,live:longint;
  dc:hdc;
  c:tcanvas;
  xys:string;
  col:byte;

implementation

{$R *.DFM}

procedure TTermiteMF.FormCreate(Sender: TObject);
begin
 randomize;
 live:=0;
 application.ShowMainForm:=false;
 dc:=getdc(0);
 c:=tcanvas.Create;
 c.Handle:=dc;
 wx:=screen.Width;
 wy:=screen.Height;
 if paramcount=2 then
  begin
   x:=strtoint(paramstr(1));
   x:=strtoint(paramstr(1))
  end
 else
  begin
   x:=wx div 2;
   y:=wy div 2;
  end;
 xs:=1;
 ys:=1;
 xa:=0;
 ya:=0;
 c.MoveTo(x,y);
 col:=1;
end;

procedure TTermiteMF.timTimer(Sender: TObject);
begin
 if live=500 then
  close;
 inc(live);
 if random(500)=10 then
  begin
   xys:=inttostr(x)+' '+inttostr(y);
   shellexecute(handle,'open','termites.exe',pchar(xys),'',sw_show)
  end;
 xa:=random(3)-1;
 ya:=random(3)-1;
 xs:=xs+xa;
 ys:=ys+ya;
 if xs>5 then xs:=5;
 if ys>5 then ys:=5;
 if xs<-5 then xs:=-5;
 if ys<-5 then ys:=-5;
 x:=x+xs;
 y:=y+ys;
 if x>wx then
  begin
   x:=wx;
   xs:=-xs
  end;
 if y>wy then
  begin
   y:=wy;
   ys:=-ys
  end;
 if y<0 then
  begin
   y:=0;
   ys:=-ys
  end;
 if x<0 then
  begin
   x:=0;
   xs:=-xs
  end;
 col:=1-col;
 c.pen.Color:=col*16777215;
 c.LineTo(x,y);
end;

procedure TTermiteMF.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 if live<>maxint then
  begin
   xys:=inttostr(x)+' '+inttostr(y);
   shellexecute(handle,'open','termites.exe',pchar(xys),'',sw_show);
   shellexecute(handle,'open','termites.exe',pchar(xys),'',sw_show)
  end;
 c.free;
 releasedc(0,dc);
 canclose:=true;
end;

end.
