{ Created by Ery , 1997 }
Uses vgaHiGr,graph,rat,neoWins,d_crt,crt;
const pasw:array[1..5] of byte=(151,143,134,129,129);
var main,status,seq,rekl,resl,vieww,smth:neoWinType;
    adm,res,view,reklb,up,down:buttonType;
    px,pc,prc,l,xch:byte;
    ll,admy:boolean;
    x,y:word;
    dest:string;
    ch:char;
    ini:file of byte;
    resf:text;
    but:array[1..8] of buttonType;
    hand:shapeOfRatType;
begin
 assign(ini,'rovel.ini');
 if not fileexist('rovel.ini') then
  begin
   rewrite(ini);
   close(ini);
  end;
 reset(ini);
 dest:='';
 while not eof(ini) do
  begin
   read(ini,xch);
   dest:=dest+chr(xch xor 283);
  end;
 close(ini);
 grInit;
 loadshapeofrat(hand,'hand.rat');
 setshapeofrat(hand);
 admy:=false;
 main.make(3,3,638,478,'Тест Ровела',false);
 status.make(530,26,635,360,'Статус',false);
 smth.make(145,363,636,476,'',false);
 pull3d(5,25,353,47,true);
 pull3d(145,50,525,250,true);
 for px:=0 to 7 do
  begin
   but[px+1].make(10,52+px*53,140,101+px*53,'');
  end;
 adm.make(450,25,527,47,'Админ.');
 reklb.make(355,25,448,47,'Реклама');
 moveRatTo(100,100);
 showRat;
 repeat
  ll:=leftOfRat;
  x:=xOfRat;
  y:=yOfRat;
  adm.act(ll,x,y);
  main.act(ll,x,y);
  reklb.act(ll,x,y);
  for px:=1 to 8 do
   but[px].act(ll,x,y);
  if adm.pressed then
   begin
    hideRat;
    adm.pressed:=false;
    seq.make(190,300,500,350,'Охранник : -Введи пароль !',false);
    showRat;
    pc:=0;prc:=0;
    repeat
     seq.act(leftOfRat,xOfRat,yOfRat);
     if keypressed then
      begin
       inc(pc);
       if ord(readkey)=(pasw[pc] xor 238) then inc(prc);
       if pc=16 then seq.del else
       pull3d(195,325,195+pc*20,343,true);
      end;
     if prc=5 then
      begin
       seq.del;
       admy:=true;
       setfillstyle(1,3);
       bar(100,25,240,45);
       res.make(5,25,115,47,'(От)Куда ?');
       view.make(117,25,230,47,'Просмотр');
       pull3d(232,25,353,47,true);
      end;
    until not seq.acting;
    if seq.ex.pressed then
     begin
      pull3d(5,25,353,47,true);
      admy:=false;
     end;
   end;
  if reklb.pressed then
   begin
    rekl.make(145,255,528,360,'Реклама',false);
    setcolor(15);
    settextstyle(2,0,6);
    outtextxy(160,280,'Заказ выполнил для Лицея#1 г.Бреста ');
    settextstyle(2,0,4);
    outtextxy(350,340,'Copyright (c) 1997, PARADIGMA');
    settextstyle(8,0,4);
    setcolor(2);
    outtextxy(200,300,'Рыжков Денис ');
    repeat
     rekl.act(leftOfRat,xOfRat,yOfRat);
    until rekl.ex.pressed;
   end;
  if admy then
   begin
    res.act(ll,x,y);
    view.act(ll,x,y);
    if res.pressed then
     begin
      resl.make(180,300,500,340,'Куда писать? Откуда читать?',true);
      Settextstyle(2,0,6);
      setcolor(15);
      outtextxy(90,120,dest);
      repeat
       resl.act(leftOfRat,XofRat,yOfRat);
       if keypressed then
        begin
         ch:=readkey;
         l:=length(dest);
         if (ch=#8) and (l>0) then
          begin
           dest:=copy(dest,0,l-1);
           setfillstyle(1,3);
           bar(88+textwidth(dest),122,499,138);
          end;
         if (not (ch in [#13,#8])) and (textwidth(dest)<400)
          then dest:=dest+ch;
         outtextxy(90,120,dest);
         l:=length(dest);
         if ch=#13 then resl.del;
        end;
      until not resl.acting;
      settextstyle(8,0,1);
     end;
    if view.pressed then
     begin
      vieww.make(100,100,500,150,'Просмотр результатов',true);
      up.make(463,102,479,120,'>');
      down.make(443,102,461,120,'<');
      repeat
       vieww.act(leftofRat,xofRat,yOfRat);
       up.act(leftofRat,xofRat,yOfRat);
       down.act(leftofRat,xofRat,yOfRat);
      until vieww.ex.pressed;
     end;
   end;
 until main.ex.pressed;
 rewrite(ini);
 for px:=1 to length(dest) do
  begin
   xch:=ord(dest[px]) xor 283;
   write(ini,xch);
  end;
 close(ini);
 closegraph;
end.