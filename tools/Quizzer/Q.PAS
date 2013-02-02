uses graph,subgraph,d_crt;
const xx=320;
      yy=175;
      kx=100;
      ky=20;
var
    x,y:real;
    a,b:shortint;
begin
 grinit;
 setbkcolor(15);
 clearviewport;
 setcolor(1);
 line(320,0,320,480);
 line(0,175,640,175);
 outtextxy(630,180,'x');
 outtextxy(330,0,'y');
 outtextxy(330,180,'0');


 x:=-5;
 repeat
  x:=x+0.0001;
  y:=-(-x*x*x*x+5*x*x-4);
  if round(y*ky)=0 then
   begin
    line(round(x*kx+xx),170,round(x*kx+xx),180);
    outtextxy(round(x*kx+xx),190,strn(round(x)));
   end;
  if round(x*kx)=0 then
   begin
    line(315,round(y*ky+yy)+5,325,round(y*ky+yy)-5);
    outtextxy(330,round(y*ky+yy),strn(-round(y)));
   end;
  if not( (y*ky+yy>480) or (y*ky+yy<1)) then
  putpixel(round(x*kx+xx),round(y*ky+yy),8);
 until x>5;
 wait;
end.