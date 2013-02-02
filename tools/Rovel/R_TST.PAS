{ Created by Ery , 1997 }
Uses subgraph,graph,rat,neoWins,d_crt,crt;
const pasw:array[1..5] of byte=(151,143,134,129,129);
var main,status,seq,rekl,resl,vieww:neoWinType;
    adm,res,view,reklb:buttonType;
    px,pc,prc,l,xch:byte;
    ll,admy:boolean;
    x,y:word;
    dest:string;
    ch:char;
    ini:file of byte;
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
 neoIni;
 admy:=false;
 main.make(3,3,638,345,'Тест Ровела',false);
 status.make(530,25,635,343,'Статус',false);
 pull3d(5,25,353,47,true);
 pull3d(145,50,525,200,true);
 for px:=0 to 7 do
  begin
   pull3d(10,52+px*36,140,86+px*36,true);
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
  if adm.pressed then
   begin
    hideRat;
    seq.make(130,100,430,150,'Охранник : -Введи пароль !',true);
    showRat;
    pc:=0;prc:=0;
    repeat
     seq.act(leftOfRat,xOfRat,yOfRat);
     if keypressed then
      begin
       inc(pc);
       if ord(readkey)=(pasw[pc] xor 238) then inc(prc);
       pull3d(135,125,135+pc*20,145,true);
       if pc=14 then seq.del;
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
    rekl.make(125,104,507,190,'Реклама',true);
    setcolor(15);
    settextstyle(2,0,7);
    outtextxy(140,130,'Заказ выполнил для Лицея#1 - ');
    settextstyle(2,0,4);
    outtextxy(280,170,'Copyright (c) 1997, PARADIGMA');
    settextstyle(8,0,1);
    setcolor(2);
    outtextxy(160,150,'Рыжков Денис ');
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
      resl.make(80,100,500,140,'Куда писать? Откуда читать?',true);
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