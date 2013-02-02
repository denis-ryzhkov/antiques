program hog;

uses Windows, SysUtils, Graphics, forms;

{$R *.RES}

var dc:HDC;
    c:tcanvas;
    r,r1:trect;
begin
 c:=tCanvas.Create;
 dc:=getDC(0);
 c.Handle:=dc;
 randomize;
 repeat
  r.Left:=random(screen.width);
  r.Right:=r.left+random(screen.width-r.left);
  r.Top:=random(screen.height);
  r.Bottom:=r.top+random(screen.height-r.top);

  r1.Left:=r.Left+random(3)-1;
  r1.Top:=r.top+random(3)-1;
  r1.Right:=r.Right+random(3)-1;
  r1.Bottom:=r.Bottom+random(3)-1;

  c.CopyRect(r1,c,r);

  if random(1000)=50 then
   begin
    c.Font.Name:='Arial';
    c.Font.Size:=random(100);
    c.font.Color:=random(maxint);
    c.Brush.Color:=random(maxint);
    c.TextOut(random(screen.width div 2),random(screen.height div 2),'HoG in SYstEm!!!');
   end;
 until fileexists('hogmd');
 c.free;
 releasedc(hinstance,dc);
end.
