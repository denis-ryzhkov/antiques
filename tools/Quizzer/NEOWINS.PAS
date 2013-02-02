{ Created by                                    ERY             1998     }
{ Unit for creating a NeoWindows design }
{ ver.2.2 }
Unit neoWins;
 interface
  const t=50;
        no=false;
        yes=true;
  type buttonType=
   object
        xx1,yy1,xx2,yy2:word;
        pressed,is,ex,slm,bright:boolean;
        name:string;
    procedure make(x1,y1,x2,y2:word;s:string;slim,brght:boolean);
    procedure act(ratKey:boolean;ratX,ratY:word);
    procedure refresh;
   end;
  type neoWinType=
   object
        xx1,yy1,xx2,yy2:word;
        acting,saved,extbl:boolean;
        filename,name:string;
        size:integer;
        f:file;
        ex:buttonType;
    procedure make(x1,y1,x2,y2:word;s:string;save,exitable:boolean);
    procedure act(ratKey:boolean;ratX,ratY:word);
    procedure refresh;
    procedure del;
   end;

  procedure pull3d(x1,y1,x2,y2:word;fill,green:boolean);
  procedure push3d(x1,y1,x2,y2:word;fill,green:boolean);
 implementation
  Uses graph,subgraph,rat,crt;
  Var pal:boolean;

  procedure neoIni;
   begin
    pal:=false;
    setrgbpalette(1,28,28,33);
    setrgbpalette(4,20,25,25);
    setpalette(11,33);
    setrgbpalette(7,30,30,35);
    setrgbpalette(5,15,6,10);
    setpalette(6,8);
    setrgbpalette(3,10,10,20);
    setrgbpalette(2,23,28,28);
    setpalette(9,49);
   end;

  procedure pull3d(x1,y1,x2,y2:word;fill,green:boolean);
   begin
    if pal then neoIni;
    setcolor(7);
    line(x1,y1,x1,y2);
    line(x1,y1,x2,y1);
    setcolor(8);
    line(x2,y1,x2,y2);
    line(x1,y2,x2,y2);
    if green then setfillstyle(1,4) else setfillstyle(1,1);
    if fill then bar(x1+1,y1+1,x2-1,y2-1);
   end;

  procedure push3d(x1,y1,x2,y2:word;fill,green:boolean);
   begin
    if pal then neoIni;
    setcolor(8);
    line(x1,y1,x1,y2);
    line(x1,y1,x2,y1);
    setcolor(7);
    line(x2,y1,x2,y2);
    line(x1,y2,x2,y2);
    if green then setfillstyle(1,4) else setfillstyle(1,1);
    if fill then bar(x1+1,y1+1,x2-1,y2-1);
   end;


  procedure neoWinType.make(x1,y1,x2,y2:word;s:string;save,exitable:boolean);
  var b:word;
      p:pointer;
  begin
   if pal then neoIni;
   acting:=true;
   if x2<x1 then begin b:=x1;x1:=x2;x2:=b; end;
   if y2<y1 then begin b:=y1;y1:=y2;y2:=b; end;
   xx1:=x1-1;xx2:=x2+1;yy1:=y1-1;yy2:=y2+1;
   name:=s;extbl:=exitable;
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
   if extbl then
    begin
     pull3d(x1+2,y1+2,x2-21,y1+20,true,no);
     ex.make(x2-19,y1+2,x2-3,y1+20,'X',no,no);
    end else
    begin
     pull3d(x1+2,y1+2,x2-2,y1+20,true,no);
    end;
   settextstyle(8,0,1);
   setcolor(6);
   outtextxy(x1+5,y1+1,s);
  end;

  procedure neoWinType.act(ratKey:boolean;ratX,ratY:word);
  begin
   if not (acting and extbl) then exit;
   ex.act(ratKey,ratX,ratY);
   if ex.pressed then del;
   if keypressed and (readkey=#27) then del;
  end;

  procedure neoWinType.refresh;
  begin
   del;
   make(xx1,yy1,xx2,yy2,name,saved,extbl);
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



 procedure buttonType.make(x1,y1,x2,y2:word;s:string;slim,brght:boolean);
 var b:word;
 begin
  if pal then neoIni;
  if x2<x1 then begin b:=x1;x1:=x2;x2:=b; end;
  if y2<y1 then begin b:=y1;y1:=y2;y2:=b; end;
  xx1:=x1;xx2:=x2;yy1:=y1;yy2:=y2;
  name:=s;pressed:=false;is:=false;bright:=brght;
  pull3d(x1,y1,x2,y2,true,yes);
  if bright then setcolor(10)
   else setcolor(5);
  slm:=slim;
  if slim then settextstyle(2,0,5) else settextstyle(8,0,1);
  if slim then outtextxy(x1+3,y1+3,s) else outtextxy(x1+3,y1-1,s);
 end;

 procedure buttonType.act(ratKey:boolean;ratX,ratY:word);
 begin
  if (ratx>xx1) and (ratx<xx2) and (raty>yy1) and (raty<yy2)
   then
   begin
    pressed:=false;
    if ratKey then
     begin
      hideRat;
      setcolor(3);
      rectangle(xx1,yy1,xx2,yy2);
      delay(t+20);
      push3d(xx1,yy1,xx2,yy2,false,yes);
      showrat;
      repeat
       ratx:=xofrat;
       raty:=yofrat;
       ratkey:=leftofrat;
       if not ratkey then begin ex:=false;pressed:=true end;
       if not ((ratx>xx1) and (ratx<xx2) and (raty>yy1) and (raty<yy2))
        then begin ex:=true;pressed:=true end;
      until pressed;
      if ex then pressed:=false;
      hiderat;
      setcolor(4);
      rectangle(xx1,yy1,xx2,yy2);
      delay(t+20);
      pull3d(xx1,yy1,xx2,yy2,false,yes);
      showRat;
      delay(t+30);
      exit;
     end;
    if is then exit;
    is:=true;
    hideRat;
    bar_(xx1+1,yy1+1,xx2-1,yy2-1,2);
    if bright then setcolor(10)
     else setcolor(5);
    if slm then settextstyle(2,0,5) else settextstyle(8,0,1);
    if slm then outtextxy(xx1+3,yy1+3,name) else outtextxy(xx1+3,yy1-1,name);
    showRat;
    exit;
   end;
  if is=true then
   begin
    is:=false;
    hideRat;
    bar_(xx1+1,yy1+1,xx2-1,yy2-1,4);
    if bright then setcolor(10)
     else setcolor(5);
    if slm then settextstyle(2,0,5) else settextstyle(8,0,1);
    if slm then outtextxy(xx1+3,yy1+3,name) else outtextxy(xx1+3,yy1-1,name);
    showRat;
   end;
  pressed:=false;
 end;

 procedure buttonType.refresh;
 begin
  make(xx1,yy1,xx2,yy2,name,slm,bright);
 end;

begin
 pal:=true;
end.
