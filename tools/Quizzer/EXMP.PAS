uses nneowins,vgahigr,d_crt,graph,rat;

var
   w:NeoWinType;
   b:buttonType;
   x,y:word;
   l:boolean;

begin
 grInit;
 w.make(100,100,500,400,'My Window - NeoWin2-Type one !!!',no,yes);
 bevel(120,200,480,380,yes,yes,no);
 bevel(150,330,400,360,no,no,no);
 bevel(410,330,470,360,no,yes,yes);

 b.make(250,300,350,322,'My Button',no,no);

 showRat;

 repeat
  x:=xOfRat;
  y:=yOfRat;
  l:=leftOfRat;
  b.act(l,x,y);
  w.act(l,x,y);


 until not w.acting;

 closegraph;
end.