Uses graph,subgraph,d_crt;
var a,b:byte;
begin
 grinit;
 for a:=0 to 7 do
  begin
  bar_(10,70,600,90,0);
  for b:=1 to 8 do
   begin
    setpalette(b,a*8+b);
    bar_(b*60,100,50+b*60,200,b);
    outtextxy(b*60+10,80,strn(a*8+b));
   end;
   wait;
  end;
 wait;
 closegraph;
end.