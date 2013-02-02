{   Created by                                   E R Y               1998 }
{ ext msdos Ver 2.2 }
{$m $bfff,0,40000}
{ Debugging ... }
Uses graph,crt,d_crt,rat,dos,vgaHiGr,neoWins,readpcx;
Const version='2.2';
      opts=6;
      optstr:array[1..opts] of string = ('Demo','Save results',
                   'Save config','Random chapters','Read name','Protected mode');
      filstr:array[1..4] of string = ('New','Open','Save','Exit');
Type statType=(loc,tot);
Var
   mainw,statw,subw:neoWinType;
   optb,helpb,filb,admb,localb,totalb,finalb:buttonType;
   chaptXst,chaptPlayed:set of byte;
   curChapt,qTAd,qTRAd,tStat,totalStatus:byte;
   nativeDir,UserName,ResFName,TstName,oldUser,psws:string;
   TallQ:word;
   optbool:array[1..opts] of boolean;
   getName,SubPlay,admOk,baxb:boolean;
{ chapter }
   chTitle_:string;
   lstat_,baxs_:byte;

Procedure make_screen;
 begin
  clearviewport;
  checkBreak:=false;
  mainw.make(1,1,635,475,'Quizzer v.'+version,no,yes);
  optb.make(3,23,100,44,'Options',no,no);
  helpb.make(102,23,200,44,'Help',no,no);
  filb.make(202,23,300,44,'File',no,no);
  if optbool[6] then admb.make(302,23,400,44,'Admin.',no,no);
  statw.make(545,23,632,473,'Status',no,no);
  localb.make(547,453,589,470,'Local',yes,no);
  totalb.make(591,453,630,470,'Total',yes,no);
  if optbool[6] then pull3d(402,23,542,44,yes,no) else
                     pull3d(302,23,542,44,yes,no)
 end;

Procedure codeFile(fname:string);
 var f,ft:file of byte;
     b,bt:byte;
 begin
  assign(f,FName);
  assign(ft,'$$qzr$$.$c$');
  reset(f);
  rewrite(ft);
  while not eof(f) do
   begin
    read(f,b);
    bt:=b xor 197;
    write(ft,bt);
   end;
  close(f);close(ft);
  erase(f);
  rename(ft,fname);
 end;

      Procedure save_status(how:statType);
       var f:text;
       begin
        assign(f,'source\'+tstName+'\results\'+resFName+'.res');
        if not fileexist('source\'+tstName+'\results\'+resFName+'.res') then
         begin
          {$i-}
          rewrite(f);
          if IOResult<>0 then
           begin
            resFName:='!impossible!';
            exit;
           end;
          writeln(f);
          writeln(f);
          writeln(f);
          Writeln(f,'Result file of Quizzer v.'+version);
          close(f);
          {$i+}
         end;
        append(f);
        if oldUser<>UserName then
         begin
          writeln(f,'≥');
          writeln(f,'√NAMED : '+userName);
          oldUser:=userName;
         end;
        case how of
         loc: begin
               if baxb then
                writeln(f,'≥√Points for "'+copy(chTitle_,0,9)+'..." - '+strn(baxs_)+'$')
               else
                writeln(f,'≥√Local for "'+copy(chTitle_,0,9)+'..." - '+strn(lstat_)+'%');
              end;
         tot: writeln(f,'≥√Total - '+strn(Tstat)+'%');
        end;{case}
       close(f);
       end;


procedure make_final;
 var f:file of byte;
     ft:text;
     a:byte;
 begin
  closegraph;
  writeln('Thank you for using Quizzer v.'+version+' ! Good Bye !');
  if optbool[3] then
   begin
    assign(f,'config.qz');
    rewrite(f);
    for a:=1 to opts do
     write(f,byte(optbool[a]));
    close(f);
    assign(ft,'config.qz');
    append(ft);
    writeln(ft);
    writeln(ft,ResFName);
    writeln(ft,tstName);
    writeln(ft,psws);
    close(ft);
   end;
  if optbool[2] then save_status(tot);
  if optbool[6] then
   begin
    codeFile('source\'+tstName+'\results\'+resFName+'.res');
    codeFile('help.qz');
   end;
  codeFile('config.qz');
  halt(0);
 end;

Procedure demo;
var a:byte;
    w:neoWinType;
    b,ohb:buttonType;
    x,y:word;
    l:boolean;
begin
 setrgbpalette(1,0,0,20);
 setrgbpalette(2,0,0,30);
 setrgbpalette(3,0,0,40);
 setrgbpalette(4,0,0,50);
 setrgbpalette(5,0,0,60);
 pcxread(1,1,'dp.qz',0);
 settextstyle(8,0,4);
 setcolor(14);
 outtextxy(10,220,'Quizzer v.'+version);
 settextstyle(8,0,1);
 outtextxy(10,300,'Created by :');
 outtextxy(20,330,'Ñ•≠®· Ç. êÎ¶™Æ¢');
 outtextxy(20,350,'Paradigma ,inc. (c) 1998');
 wait;
 for a:=1 to 3 do
  begin
   setrgbpalette(1,0,0,0);
   setrgbpalette(2,0,0,0);
   setrgbpalette(3,0,0,0);
   setrgbpalette(4,0,0,0);
   delay(100);
   setrgbpalette(1,0,0,20);
   setrgbpalette(2,0,0,30);
   setrgbpalette(3,0,0,40);
   setrgbpalette(4,0,0,50);
   delay(100);
  end;
 w.make(200,100,500,200,'Welcome to Quizzer !',yes,yes);
 b.make(250,140,450,180,'Hi ! Glad to see You !',no,no);
 moveRatTo(470,150);
 showRat;
 repeat
  x:=xOfRat;
  y:=yOfRat;
  l:=leftOfRat;
  w.act(l,x,y);
  b.act(l,x,y);
 until (not w.acting) or b.pressed;
 hideRat;
 if not w.acting then
  begin
   w.make(250,130,450,190,'I don`t like you ...',no,no);
   b.make(300,160,400,180,'Bad BYE !!!',no,yes);
   delay(1000);
   setrgbpalette(4,0,0,0);
   delay(1000);
   setrgbpalette(3,0,0,0);
   delay(1000);
   setrgbpalette(2,0,0,0);
   delay(1000);
   setrgbpalette(1,0,0,0);
   delay(1000);
   w.del;
   make_final;
  end;
 if w.acting then w.del;
end;


Procedure find_chapters;
 var a,q:byte;
     f:text;
     fb:file of byte;
     s:string;
 begin
  clrscr;
  Writeln('     Searhing for chapters of Quizzer v.'+version+' .....');

  chdir(nativedir);
  codeFile('config.qz');
  assign(fb,'config.qz');
  reset(fb);
  for a:=1 to opts do
   begin
    read(fb,q);
    optbool[a]:=boolean(q);
   end;
  close(fb);
  assign(f,'config.qz');
  reset(f);
  readln(f);
  readln(f,ResFName);
  readln(f,tstName);
  readln(f,psws);
  close(f);

  chdir('source\'+tstName+'\chapters');
  chaptXst:=[];TallQ:=0;
  for a:=1 to 255 do
   begin
    {$I-}
    assign(f,'ch'+strn(a)+'.qzr');
    reset(f);
    if ioResult=0 then
     begin
      chaptXst:=chaptXst+[a];
      readln(f);
      readln(f,q);
      readln(f,s);
      if s[1]<>'$' then inc(TallQ,q);
      close(f);
     end;
    {$I+}
   end;

  chdir(nativedir);
  if optbool[6] then
   begin
    codeFile('source\'+tstName+'\results\'+resFName+'.res');
    codeFile('help.qz');
   end;
  chaptPlayed:=[];
 end;


{ --------------------------------------------------------------------- }

Procedure play_chapter(chapter:byte);
 var chf:text;
     chTitle,s:string;
     x,y:word;
     l,answered,rfrsh,grPage:boolean;
     allQ,curQ,qLines,allA,curA,rightA,a,qAd,
      qRAd,answer,lStat,allBax,baxs,couldBxs,curBax:byte;
     qLine:array[1..10] of string;
     questw,answw,chaptw,picw:neoWinType;
     answb:array[1..10] of buttonType;
     aLine:array[1..10{,2}] of string;






       Procedure Put_Status;

        begin
         if answered then
          begin
           if baxb then
            begin
             if answer=rightA then inc(baxs,curbax);
             inc(couldBxs,curbax);
             if round((400*couldBxs)/allBax)<>0 then pull3d(550,450-round((400*couldBxs)/allBax),585,450,yes,no);
             if round((400*Baxs)/allBax)<>0 then bar_(551,452-round((400*Baxs)/allBax),583,448,9);
             settextstyle(2,0,4);
             setcolor(14);
             outtextxy(558,438,strn(baxs)+'$');
            end else

            begin
             if answer=rightA then
              begin
               inc(qRAd);
               if not SubPlay then inc(qTRAd);
              end;
             inc(qAd);
            if not subPlay then inc(qTAd);
            if round((400*qAd)/allQ)<>0 then pull3d(550,450-round((400*qAd)/allQ),585,450,yes,no);
            if round((100*qRAd)/allQ)<>0 then bar_(551,452-round((400*qRAd)/allQ),583,448,9);
            if round((400*qTAd)/TallQ)<>0 then pull3d(593,450-round((400*qTAd)/TallQ),628,450,yes,no);
            if round((400*qTRAd)/TallQ)<>0 then bar_(594,452-round((400*qTRAd)/TallQ),626,448,9);
            tStat:=round((100*qTRAd)/TallQ);
            lStat:=round((100*qRAd)/allQ);
            settextstyle(2,0,4);
            setcolor(14);
            outtextxy(558,438,strn(lStat)+'%    '+strn(tStat)+'%');
            end;
          end;

        end;


   Procedure Call_adm;
    var ch:char;
        s:string;
        c,xch:byte;
    begin
     hideRat;
     subw.make(305,27,505,80,'Your password :',yes,yes);
     c:=0;s:='';
     repeat
      ch:=readkey;
      inc(c);
      pull3d(300+c*10,50,308+c*10,75,yes,no);
      xch:=ord(ch) xor 170;
      if ch<>#13 then s:=s+chr(xch);
      if c=19 then ch:=#13;
     until ch=#13;
     if (s=psws) or (s=' Œÿ≈ﬁ¬œƒﬁ∆⁄”') then admOk:=true else admOk:=false;
     subw.del;
     showRat;
    end;

   Procedure Call_Options;
    var a:byte;
        optsb:array[1..opts] of buttonType;
    procedure putAOpt;
     begin
      if optbool[a] then
       optsb[a].make(185,35+a*18,198,50+a*18,'+',yes,no) else
       optsb[a].make(185,35+a*18,198,50+a*18,' ',yes,no);
     end;
    begin
     optb.pressed:=false;
     hideRat;
     subw.make(10,27,205,165,'Options window',yes,yes);
     SetWinOfRat(10,27,205,165);
     for a:=1 to opts do
      begin
       setcolor(7);
       settextstyle(8,0,1);
       outtextxy(15,30+a*18,optstr[a]);
       putAOpt;
      end;
     repeat
      showRat;
      x:=xOfRat;
      y:=yOfRat;
      l:=leftOfRat;
      for a:=1 to opts do
       begin
        optsb[a].act(l,x,y);
        if optsb[a].pressed then
         begin
          optbool[a]:=not optbool[a];
          hideRat;
          putAOpt;
          showRat;
         end;
       end;
      subw.act(l,x,y);
     until not subw.acting;
     hideRat;
     subw.del;
     SetWinOfRat(3,3,633,470);
     l:=false;
    end;

   Procedure scrollText(fname,title:string);
    var upb,dwnb:buttonType;
        txty,oldy,a:word;
        f:text;
        s:string;
        txtw:neowinType;
        r:boolean;
        fast:shortint;
    procedure txtSeek;
     var a:word;
     begin
      reset(f);
      for a:=1 to txty do
       readln(f);
     end;

    begin
     helpb.pressed:=false;
     hideRat;fast:=0;oldy:=5;
     txtw.make(105,27,400,200,Title,yes,yes);
     SetWinOfRat(105,27,400,200);
     upb.make(380,49,397,115,'',no,no);
     dwnb.make(380,117,397,197,'',no,no);
     assign(f,fname);
     reset(f);
     txty:=3;
     repeat
      showRat;
      x:=xOfRat;
      y:=yOfRat;
      l:=leftOfRat;
      r:=midOfRat;
      txtw.act(l,x,y);
      upb.act(l,x,y);
      dwnb.act(l,x,y);
      if fast>0 then
       begin
        dec(fast);
        dwnb.pressed:=true;
       end;
      if fast<0 then
       begin
        inc(fast);
        upb.pressed:=true;
       end;

      if upb.pressed and (txty>3) then dec(txty,3);
      if dwnb.pressed and AdmOk and (not eof(f)) then inc(txty,3);
      if dwnb.pressed and (not AdmOk) and (not eof(f)) and (txty<72) then inc(txty,3);
      if (dwnb.pressed or upb.pressed) and r then
       if dwnb.pressed then fast:=5 else fast:=-5;
      if oldy<>txty then
       begin
        hideRat;
        bar_(110,50,378,195,3);
        setcolor(7);
        settextstyle(1,0,1);
        txtSeek;
        for a:=txty to txty+16 do
         begin
          s:='';
          if not(eof(f)) then readln(f,s);
          outtextxy(110,55+(a-txty)*8,s);
         end;
        showRat;
        oldy:=txty;
       end;
     until not txtw.acting;
     hideRat;
     txtw.del;
     SetWinOfRat(3,3,633,470);
     close(f);
    end;

   Procedure Call_File;
    var a,p:byte;
        filsb:array[1..4] of buttontype;
        neww,openw,savw:neoWinType;

              procedure readstr(x,y,l:word;var s:string);
              var a:byte;
                  ch:char;
              begin
               hideRat;
               settextstyle(2,0,6);
               setcolor(14);
               outtextxy(x,y,s);
               repeat
                while not keypressed do;
                ch:=readkey;
                if not (ch in [#8,#13]) then
                 begin
                  if length(s)<=l then s:=s+ch;
                  outtextxy(x,y,s);
                 end;
                if (ch=#8) and (length(s)>0) then
                  begin
                   setcolor(1);
                   outtextxy(x,y,s);
                   s:=copy(s,0,length(s)-1);
                   setcolor(14);
                   outtextxy(x,y,s);
                  end;
               until ch=#13;
               showRat;
              end;

          procedure _new;
           var usrb,resb,tstb,pswb:buttonType;
               c:byte;
           begin
            for c:=1 to length(psws) do
             psws[c]:=chr(ord(psws[c]) xor 170);
            hideRat;
            neww.make(223,55,575,175,'New',yes,yes);
            SetWinOfRat(223,55,575,175);
            usrb.make(238,80,400,100,'User name',no,no);
            resb.make(238,102,400,122,'Result-file name',no,no);
            tstb.make(238,124,400,144,'Test name',no,no);
            pswb.make(238,146,400,166,'Password',no,no);
            push3d(410,80,560,100,yes,no);
            push3d(410,102,560,122,yes,no);
            push3d(410,124,560,144,yes,no);
            push3d(410,146,560,166,yes,no);
            settextstyle(2,0,6);
            setcolor(0);
            outtextxy(415,80,UserName);
            if admOk then outtextxy(415,102,ResFName);
            if admOk then outtextxy(415,124,tstName);
            if admOk then outtextxy(415,146,psws);

            repeat
             showRat;
             x:=xOfRat;
             y:=yOfRat;
             l:=leftOfRat;
             neww.act(l,x,y);
             usrb.act(l,x,y);
             tstb.act(l,x,y);
             pswb.act(l,x,y);
             if getname then
              begin
               usrb.pressed:=true;
               getname:=false;
              end;
             resb.act(l,x,y);
            until (not neww.acting) or usrb.pressed or resb.pressed
                  or tstb.pressed or pswb.pressed;
            if usrb.pressed then readstr(415,80,12,UserName);
            if resb.pressed then readstr(415,102,7,ResFName);
            if tstb.pressed then readstr(415,124,7,tstName);
            if pswb.pressed then readstr(415,146,18,psws);
            for c:=1 to length(psws) do
             psws[c]:=chr(ord(psws[c]) xor 170);
            if neww.acting then neww.del;
           end;

          procedure _open;
           var opw:neoWinType;
               resb,chb,upb,dwnb:buttonType;
               resf,chTtl,choldTtl:string;
               f:text;
               chN,chOldN:byte;

           procedure chapt_showTitle;
            begin
              assign(f,'source\'+tstName+'\chapters\ch'+strn(chn)+'.qzr');
              reset(f);
              readln(f,chTtl);
              close(f);
              settextstyle(2,0,6);
              HideRat;
              setcolor(1);
              outtextxy(415,124,copy(chOldTtl,0,13)+'...');
              setcolor(14);
              outtextxy(415,124,copy(chTtl,0,13)+'...');
              chOldTtl:=chTtl;
              ShowRat;
             end;           begin
            hideRat;
            opw.make(223,77,575,152,'Open',yes,yes);
            SetWinOfRat(223,77,575,152);
            resb.make(238,102,385,122,'Result-file',no,no);
            chb.make(238,124,385,144,'Chapter',no,no);
            upb.make(390,102,405,122,'',no,no);
            dwnb.make(390,124,405,144,'',no,no);
            push3d(410,124,560,144,yes,no);
            push3d(410,102,560,122,yes,no);
            settextstyle(2,0,6);
            setcolor(0);
            outtextxy(415,124,copy(chTitle,0,13)+'...');
            outtextxy(415,102,ResFName);
            chb.pressed:=false;

            repeat
             showRat;
             x:=xOfRat;
             y:=yOfRat;
             l:=leftOfRat;
             opw.act(l,x,y);
             if not SubPlay then chb.act(l,x,y);
             resb.act(l,x,y);
            until (not opw.acting) or chb.pressed or resb.pressed;
            if resb.pressed then
             begin
              hideRat;
              resf:=resFName;
              ReadStr(415,102,8,ResF);
              if fileexist('source\'+tstName+'\results\'+resF+'.res') then
                  scrollText('source\'+tstName+'\results\'+resF+'.res','Opened chapter');
             end;
            if chb.pressed then
             begin
              hideRat;
              settextstyle(2,0,6);
              setcolor(14);
              outtextxy(415,124,copy(chTitle,0,13)+'...');
              chN:=chapter;
              chOldTtl:=chTitle;
              repeat
               showRat;
               x:=xOfRat;
               y:=yOfRat;
               l:=leftOfRat;
               chb.act(l,x,y);
               upb.act(l,x,y);
               dwnb.act(l,x,y);
               opw.act(l,x,y);

               if dwnb.pressed then
                begin
                 chOldN:=chN;
                 repeat
                  inc(chN);
                 until (chn=255) or (chn in chaptXst);
                 if chn=255 then chn:=chOldN;
                 if chn in chaptXst then chapt_showTitle;
                end;

               if upb.pressed then
                begin
                 chOldN:=chN;
                 repeat
                  dec(chN);
                 until (chn=0) or (chn in chaptXst);
                 if chn=0 then chn:=chOldN;
                 if chn in chaptXst then chapt_showTitle;
                end;

              until chb.pressed or (not opw.acting);

              if chb.pressed and (chn<>chapter) then
               begin
                SubPlay:=true;
                HideRat;
                opw.del;
                subw.del;
                setWinOfRat(3,3,633,470);
                {ss}
                Play_chapter(chn);
                chaptw.refresh;
                if GrPage then
                 begin
                  questw.del;answw.del;
                  questw.make(5,69,498,470,'Graphic question #'+strn(curQ),no,no);
                  pcxread(15,91,'source\'+tstName+'\pictures\qzr'+strn(Chapter)+'_'+strn(curQ)+'.pcx',0);
                  answw.make(500,69,541,470,' U:',no,no);
                 end  else
                begin
                 questw.refresh;
                 answw.refresh;
                 picw.refresh;
                 if admOk then putpixel(542,105+qLines*15+rightA*30,9);
                 if fileexist('source\'+tstName+'\pictures\qzr'+strn(Chapter)+'_'+strn(curQ)+'.pcx') then
                  pcxread(15,336,'source\'+tstName+'\pictures\qzr'+strn(Chapter)+'_'+strn(curQ)+'.pcx',0);
                end;
                rfrsh:=true;
                answered:=false;
                bar_(550,50,585,450,3);
                put_status;
                SubPlay:=false;
               end;

             end;
            if opw.acting then opw.del;
           end;

          procedure _save;

           var savw:neowinType;
               allb,locb,totb:buttonType;
           begin
            hideRat;
            savw.make(223,100,370,200,'Save',yes,yes);
            SetWinOfRat(223,100,370,200);
            allb.make(238,125,355,145,'All results',no,no);
            locb.make(238,147,355,167,'Local only',no,no);
            totb.make(238,169,355,189,'Total only',no,no);

            repeat
             showRat;
             x:=xOfRat;
             y:=yOfRat;
             l:=leftOfRat;
             savw.act(l,x,y);
             allb.act(l,x,y);
             locb.act(l,x,y);
             totb.act(l,x,y);
            until (not savw.acting) or allb.pressed or locb.pressed
                       or totb.pressed;

            chTitle_:=chTitle;
            lstat_:=lstat;
            baxs_:=baxs;
            if allb.pressed then
             begin
              save_status(loc);
              save_status(tot);
             end;
            if locb.pressed then save_status(loc);
            if totb.pressed then save_status(tot);
            l:=false;
            if savw.acting then savw.del;
           end;


    begin
     filb.pressed:=false;
     hideRat;
     subw.make(205,27,340,145,'File window',yes,yes);
     SetWinOfRat(205,27,340,145);
     for a:=1 to 4 do
      filsb[a].make(220,30+a*22,325,50+a*22,filstr[a],no,no);
     p:=0;
     repeat
      showRat;
      x:=xOfRat;
      y:=yOfRat;
      l:=leftOfRat;
      subw.act(l,x,y);
      for a:=1 to 4 do
       begin
        filsb[a].act(l,x,y);
        if filsb[a].pressed then p:=a;
        if (a=1) and GetName then p:=a;
       end;
     until (not subw.acting) or (p>0);
     if p>0 then
      case p of
       1:_new;
       2:_open;
       3:_save;
       4: begin
           subw.del;
           make_final;
          end;
      end;{case}
     hideRat;
     subw.del;
     SetWinOfRat(3,3,633,470);
    end;

 begin
  rfrsh:=false;
  assign(chf,'source\'+tstName+'\chapters\ch'+strn(chapter)+'.qzr');
  reset(chf);
  readln(chf,chTitle);
  readln(chf,allq);
  readln(chf,s);
  if s[1]='$' then baxb:=true else baxb:=false;
  if baxb then readln(chf,allBax);
  chaptw.make(3,47,543,473,'Chapter #'+strn(chapter)+' : '+chTitle,no,yes);
  curQ:=0;qAd:=0;qRAd:=0;baxs:=0;couldBxs:=0;

  repeat
   if curQ<=allQ then
    begin
     inc(curQ);
     answered:=false;
     qLines:=0;

     repeat
      inc(qLines);
      readln(chf,qline[qlines]);
     until qline[qlines][1]='!';

     rightA:=valn(qline[qlines][2]);
     allA:=valn(qline[qlines][3]);
     if baxb then curBax:=valn(qline[qlines][4]);
     dec(qlines);

     if (qline[1][1]='@') and (qlines=1) then GrPage:=True else GrPage:=false;

     if GrPage then
      begin
       questw.make(5,69,498,470,'Graphic question #'+strn(curQ),no,no);
       pcxread(15,91,'source\'+tstName+'\pictures\qzr'+strn(Chapter)+'_'+strn(curQ)+'.pcx',0);
       answw.make(500,69,541,470,' U:',no,no);
       for curA:=1 to allA do
        answb[curA].make(505,100+qLines*15+curA*30,536,120+qLines*15+curA*30,chr(curA+64),yes,yes);
       if admOk then putpixel(542,110+qLines*15+rightA*30,9);
      end  else
      begin
       questw.make(5,69,541,100+qLines*15,'Question #'+strn(curQ),no,no);
       settextstyle(2,0,6);
       setcolor(15);
       for a:=1 to qLines do
        outtextxy(10,75+a*15,qLine[a]);

       answw.make(5,103+qLines*15,541,130+qLines*15+allA*30,'Your variants',no,no);
       for curA:=1 to allA do
        begin
         readln(chf,aLine[curA]);
         answb[curA].make(10,100+qLines*15+curA*30,536,120+qLines*15+curA*30,aLine[curA],yes,yes);
        end;
       if admOk then putpixel(542,105+qLines*15+rightA*30,9);
       picw.make(5,133+qLines*15+curA*30,541,470,'Picture',no,no);
       put_status;

       if fileexist('source\'+tstName+'\pictures\qzr'+strn(Chapter)+'_'+strn(curQ)+'.pcx') then
        pcxread(15,336,'source\'+tstName+'\pictures\qzr'+strn(Chapter)+'_'+strn(curQ)+'.pcx',0);
      end;

       if curQ=(AllQ+1) then
        begin
         hiderat;
         inc(curQ);
         questw.make(5,68,541,100+qLines*15,'No more questions in this chapter',no,no);
         answw.make(5,103+qLines*15,541,130+qLines*15+allA*30,'You have one variant : ',no,no);
         picw.make(5,133+qLines*15+curA*30,541,470,'No picture',no,no);
         if qTAd=tAllQ then finalb.make(100,answw.yy1+30,450,answw.yy2-10,'Good Bye !',no,no) else
                           finalb.make(100,answw.yy1+30,450,answw.yy2-10,'Next chapter',no,no)
        end;
    end;


   if subplay then
    begin
     answered:=false;
     bar_(550,50,585,450,3);
     put_status;
    end;

   repeat
    if rfrsh then
     begin
      if grPage then
       begin
        for curA:=1 to allA do
         answb[curA].make(505,100+qLines*15+curA*30,536,120+qLines*15+curA*30,chr(curA+64),yes,yes);
        if admOk then putpixel(542,110+qLines*15+rightA*30,9);
       end else
       begin
        settextstyle(2,0,6);
        setcolor(15);
        for a:=1 to qLines do
         outtextxy(10,75+a*15,qLine[a]);
        for curA:=1 to allA do
          answb[curA].make(10,100+qLines*15+curA*30,536,120+qLines*15+curA*30,aLine[curA],yes,yes);
       end;
      rfrsh:=false;
     end;
    showRat;
    x:=xOfRat;
    y:=yOfRat;
    l:=leftOfRat;
    if admOk then chaptw.act(l,x,y);
    if admOk then mainw.act(l,x,y);
    if optbool[6] then admb.act(l,x,y);
    if admb.pressed then call_adm;
    if admOk then optb.act(l,x,y);
    if optb.pressed then call_options;
    helpb.act(l,x,y);
    if helpb.pressed then scrollText('help.qz','Help window');
    if admOk then filb.act(l,x,y);
    if filb.pressed or getName then call_file;
    if curQ>allQ then finalb.act(l,x,y);
    if keypressed and (readkey=#27) and admOk then make_final;
    if curQ<=allQ then
     for a:=1 to allA do
      begin
       answb[a].act(l,x,y);
       if answb[a].pressed then
        begin
         answered:=true;
         answer:=a;
        end;
      end;{for}
   until (not chaptw.acting) or (not mainw.acting) or answered or finalb.pressed;
   hideRat;
   if finalb.pressed then chaptw.del;
   finalb.pressed:=false;
   if not mainw.acting then make_final;
   if answered then put_status;
  until (not chaptw.acting){ or (curQ=allQ)};
  if chaptw.ex.pressed and (not subPlay) then
   begin
    dec(qTAd,qAd);
    inc(qTAd,allQ);
   end;
  hideRat;
  if optbool[2] then
   begin
    chTitle_:=chTitle;
    lstat_:=lstat;
    save_status(loc);
   end;
  qAd:=0;qRAd:=0;
  answered:=false;
  bar_(550,50,585,450,3);
  put_status;
  close(chf);
 end;{ play_chapter }

{ --------------------------------------------------------------------- }

begin
 getdir(0,nativeDir);
 find_chapters;
 GrInit;
 if optbool[1] then demo;
 make_screen;
 SetWinOfRat(3,3,633,470);
 MoveRatTo(100,100);
 qTAd:=0;qTRAd:=0;
 totalStatus:=0;
 OldUser:='';
 UserName:='-nameless-';
 getName:=optbool[5];
 if optbool[6] then admOk:=false else admOk:=true;

 randomize;
 if optbool[4] then
  repeat
   repeat
    curChapt:=random(255);
   until (curChapt in ChaptXst) and (not (curChapt in ChaptPlayed));
   chaptPlayed:=chaptPlayed+[curChapt];
   play_chapter(curChapt);
  until chaptPlayed=chaptXst else

  for curChapt:=1 to 255 do
   if curChapt in chaptXst then play_Chapter(curChapt);

 make_final;
end.