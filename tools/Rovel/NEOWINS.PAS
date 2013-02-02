Unit neoWins;
 interface
  const t=50;
  type buttonType=
   object
        xx1,yy1,xx2,yy2:word;
        pressed,is:boolean;
        name:string;
    procedure make(x1,y1,x2,y2:word;s:string);
    procedure act(ratKey:boolean;ratX,ratY:word);
   end;
  type neoWinType=
   object
        xx1,yy1,xx2,yy2:word;
        acting,saved:boolean;
        filename:string;
        size:integer;
        f:file;
        ex:buttonType;
    procedure make(x1,y1,x2,y2:word;s:string;save:boolean);
    procedure act(ratKey:boolean;ratX,ratY:word);
    procedure del;
   end;

  procedure pull3d(x1,y1,x2,y2:word;fill:boolean);
  procedure push3d(x1,y1,x2,y2:word;fill:boolean);
 implementation
  Uses graph,subgraph,rat,crt;
  Var pal:boolean;

  procedure neoIni;
   begin
    pal:=false;
    setrgbpalette(4,25,25,30);
    setrgbpalette(2,35,35,35);
    setpalette(11,33);
    setrgbpalette(1,28,28,33);
    setrgbpalette(5,15,6,10);
    setpalette(6,8);
    setrgbpalette(3,15,15,20);
    setpalette(9,49);
   end;

  procedure pull3d(x1,y1,x2,y2:word;fill:boolean);
   begin
    if pal then neoIni;
    setcolor(2);
    line(x1,y1,x1,y2);
    line(x1,y1,x2,y1);
    setcolor(8);
    line(x2,y1,x2,y2);
    line(x1,y2,x2,y2);
    setfillstyle(1,4);
    if fill then bar(x1+1,y1+1,x2-1,y2-1);
   end;

  procedure push3d(x1,y1,x2,y2:word;fill:boolean);
   begin
    if pal then neoIni;
    setcolor(8);
    line(x1,y1,x1,y2);
    line(x1,y1,x2,y1);
    setcolor(2);
    line(x2,y1,x2,y2);
    line(x1,y2,x2,y2);
    setfillstyle(1,4);
    if fill then bar(x1+1,y1+1,x2-1,y2-1);
   end;


  procedure neoWinType.make(x1,y1,x2,y2:word;s:string;save:boolean);
  var b:word;
      p:pointer;
  begin
   if pal then neoIni;
   if acting then exit;
   acting:=true;
   if x2<x1 then begin b:=x1;x1:=x2;x2:=b; end;
   if y2<y1 then begin b:=y1;y1:=y2;y2:=b; end;
   xx1:=x1-1;xx2:=x2+1;yy1:=y1-1;yy2:=y2+1;
   if save then
    begin
     filename:=copy(s,1,8)+'.$$$';
     assign(f,filename);
     size:=imagesize(xx1,yy1,xx2,yy2);
     getmem(p,size);
     rewrite(f,1);
     getimage(xx1,yy1,xx2,yy2,p^);
     blockwrite(f,p^,size);
     close(f);
     freemem(p,size);
     saved:=true;
    end else
     saved:=false;
   setcolor(9);
   rectangle(x1,y1,x2,y2);
   setcolor(11);
   rectangle(x1-1,y1-1,x2+1,y2+1);
   rectangle(x1+1,y1+1,x2-1,y2-1);
   setfillstyle(1,3);
   bar(x1+2,y1+2,x2-2,y2-2);
   pull3d(x1+2,y1+2,x2-22,y1+20,true);
   ex.make(x2-19,y1+2,x2-3,y1+20,'X');
   settextstyle(8,0,1);
   setcolor(6);
   outtextxy(x1+5,y1+1,s);
  end;

  procedure neoWinType.act(ratKey:boolean;ratX,ratY:word);
  begin
   if not acting then exit;
   ex.act(ratKey,ratX,ratY);
   if ex.pressed then del;
  end;

  procedure neoWinType.del;
  var p:pointer;
  begin
   if not acting then exit;
   if saved then
    begin
     saved:=false;
     reset(f,1);
     getmem(p,size);
     blockread(f,p^,size);
     close(f);
     system.erase(f);
     hideRat;
     putimage(xx1,yy1,p^,copyput);
     showRat;
     freemem(p,size);
    end else
   begin
    hideRat;
    setfillstyle(1,3);
    bar(xx1,yy1,xx2,yy2);
    showRat;
   end;
   acting:=false;
  end;



 procedure buttonType.make(x1,y1,x2,y2:word;s:string);
 var b:word;
 begin
  if pal then neoIni;
  if x2<x1 then begin b:=x1;x1:=x2;x2:=b; end;
  if y2<y1 then begin b:=y1;y1:=y2;y2:=b; end;
  xx1:=x1;xx2:=x2;yy1:=y1;yy2:=y2;
  name:=s;pressed:=false;is:=false;
  pull3d(x1,y1,x2,y2,true);
  setcolor(5);
  settextstyle(8,0,1);
  outtextxy(x1+3,y1-1,s);
 end;

 procedure buttonType.act(ratKey:boolean;ratX,ratY:word);
 begin
  if (ratx>xx1) and (ratx<xx2) and (raty>yy1) and (raty<yy2)
   then
   begin
    if ratKey then
     begin
      hideRat;
      setcolor(4);
      rectangle(xx1,yy1,xx2,yy2);
      delay(t+20);
      push3d(xx1,yy1,xx2,yy2,false);
      delay(t+30);
      setcolor(4);
      rectangle(xx1,yy1,xx2,yy2);
      delay(t+20);
      pull3d(xx1,yy1,xx2,yy2,false);
      showRat;
      delay(t+30);
      pressed:=true;
      exit;
     end;
    if is then exit;
    is:=true;
    setbkcolor(4);
    setfillstyle(6,1);
    hideRat;
    bar(xx1+1,yy1+1,xx2-1,yy2-1);
    setcolor(5);
    settextstyle(8,0,1);
    outtextxy(xx1+3,yy1-1,name);
    showRat;
    exit;
   end;
  if is=true then
   begin
    is:=false;
    setfillstyle(1,4);
    hideRat;
    bar(xx1+1,yy1+1,xx2-1,yy2-1);
    setcolor(5);
    settextstyle(8,0,1);
    outtextxy(xx1+3,yy1-1,name);

    showRat;
   end;
  pressed:=false;
 end;
begin
 pal:=true;
end.
