unit GMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ShellApi, IniFiles, ScktComp, mmsystem, Menus, GAEd;

const wm_GabberMsg=wm_app+400;

type
  TGMainF = class(TForm)
    editPan: TPanel;
    Edit: TEdit;
    clSock: TClientSocket;
    conTim: TTimer;
    Memo: TMemo;
    GNBox: TListBox;
    Splitter1: TSplitter;
    nulPM: TPopupMenu;
    pauseChB: TCheckBox;
    hideTim: TTimer;
    procedure editPanResize(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure clSockConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure clSockRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure clSockError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure conTimTimer(Sender: TObject);
    procedure clSockDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure GNBoxDblClick(Sender: TObject);
    procedure MemoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure clrRtIClick(Sender: TObject);
    procedure pauseChBClick(Sender: TObject);
    procedure hideTimTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
   procedure appActivate(Sender: TObject);
   procedure appMinimize(Sender: TObject);
   procedure GabMes(var aMes:tMessage);message wm_GabberMsg;
   procedure hk(var aMes:tMessage);message wm_hotkey;
   procedure ComeOn;
  public
    { Public declarations }
  end;

const sGabber='Gabber';
      sMainWindow='MainWindow';
      sGAEdWindow='AddressEditorWindow';
      sLeft='Left';
      sTop='Top';
      sHeight='Height';
      sGNBoxWidth='GabbyNicksBoxWidth';
      sWidth='Width';
      sTunes='Tunes';
      sAddresses='Addresses';
      sAddr='Addr';
      SgABBY='Gabby';
      sGabbyNick='GabbyNick';
      sBeepHeight='BeepHeight';
      sBeepLength='BeepLength';
      sServAddr='ServAddr';
      sPort='Port';
      sMaxLines='MaxLines';
      sCreoAddr='192.168.32.101';
      comsnum=18;
      command:array[1..comsnum] of string=('/A ','/X','/BH ',
      '/?','\N ','\G','\B ','/P ','/BL ','\ADD ','\DEL ','\REN ',
      '/CTB','/ML ','/CRT','/PRT','\NL ','/AE');
var
  GMainF: TGMainF;
  isCom,firstNick,firstShow,firstConnect,opened:boolean;
  beepHeight,beepLength,port,maxlines,lastCur,lastAdd,curSrvIdx:integer;
  nd:notifyicondata;
  inif:tIniFile;
  curNick,natdir,servaddr,rt,portS:string;
  last:array[1..7] of string;
  sl:tStringList;

implementation

{$R *.DFM}

procedure updTtl;
begin
 GMainF.caption:='Gabber ['+curNick+']';
end;

procedure TGMainF.ComeOn;
begin
 show;
 application.Restore;
 application.BringToFront;
 shell_notifyicon(nim_delete,@nd);
end;

procedure TGMainF.GabMes(var aMes:tMessage);
begin
 if (ames.LParam=514) or (ames.LParam=517) or (ames.LParam=520) then
  comeOn;
end;

procedure TGMainF.hk(var aMes:tMessage);
begin
 comeOn;
end;

procedure TGMainF.appActivate(Sender: TObject);
begin
 show;
 application.restore;
 shell_notifyicon(nim_delete,@nd);
end;

procedure TGMainF.appMinimize(Sender: TObject);
begin
 hide;
 shell_notifyicon(nim_add,@nd);
end;

procedure memOut(msg:string);
begin
 if GMainF.memo.lines.Count=maxlines then
  GMainF.memo.lines.Delete(0);
 msg:=msg{!-}+'  '{-!};
 GMainF.memo.lines.append(msg);{!-}
 GMainF.memo.selstart:=length(GMainF.memo.lines.text)-2;
 GMainF.memo.selLength:=2;
 GMainF.memo.seltext:='';{-!}
end;

procedure GabberSay(msg:string);
begin
 memOut('['+timetostr(now)+'] <Gabber> '+msg);
end;

procedure addLast(msg:string);
begin
 inc(lastAdd);
 if lastadd>7 then
  lastadd:=1;
 last[lastadd]:=msg;
end;

procedure say(msg:string);
begin
 if GMainF.clSock.Active then
  GMainF.clSock.Socket.sendtext('|'+msg)
 else
  begin
   GabberSay('Нет связи с сервером &(. Набери "/a IP_адрес_сервера" и "/p номер_порта"');
   GMainF.conTim.Enabled:=true;
  end;
 addLast(msg);
end;

procedure TGMainF.editPanResize(Sender: TObject);
begin
 edit.Width:=editPan.Width-20;
 pauseChB.Left:=editPan.Width-16;
end;

procedure comHndl(s:string);
var cs,ps,bigPs,renIdxS,deadNick:string;
    i:integer;
    beepLengthW,beepHeightW:word;

label l1,l2,l3;{for asm}

procedure readWord(var value:integer;errMsg,okMsg:string);
var wordBaq:integer;
procedure restoreV;
begin
 value:=wordBaq;
 GabberSay(errMsg);
end;
begin
 wordBaq:=value;
 try
  value:=strtoint(ps);
  if value<0 then
   restoreV
  else
   GabberSay(okMsg+' '+inttostr(value)+'.');
 except
  restoreV;;
 end;
end;

begin
 isCom:=false;
 {commands}
 for i:=1 to comsnum do
  begin
   cs:=command[i];
   ps:=copy(s,length(cs)+1,length(s)-length(cs));
   bigps:=ansiuppercase(ps);
   if ansiuppercase(copy(s,1,length(cs)))=cs then
    begin
     case i of
      1: begin {a}
          isCom:=true;
          GMainF.clSock.Close;
          try
           servaddr:=ps;
           GMainF.clSock.Address:=servaddr;
           GMainF.conTim.Enabled:=true;
          except
          end;
         end;

      2: begin {x}
          isCom:=true;
          GMainF.close;
         end;

      3: begin {bh}
          isCom:=true;
          readWord(beepHeight,'Какая высота тона ?!','Буду пищать с высотой тона');
         end;

      4: begin {?}
          isCom:=true;

          GabberSay('|(& Gabber 1.7 &) Микро-чат');
          GabberSay('Creosoft (c) 2000. All rights and glucks reserved');
          GabberSay('"/A IP_адрес_сервера" и "/P номер_порта" связывают твоего гэббера-клиента с сервером (Address, Port)');
          GabberSay('"/AE" редактор адресов серверов для автодозвона (Address Editor)');
          GabberSay('"/N новый_ник" меняет твой ник (Nick)');
          GabberSay('"/B ник_гэбби" зовёт гэбби звуком и месагой (Beep)');
          GabberSay('"/BH высота_тона" и "/BL длина_пика" устанавливают параметры пищания ТВОЕГО PC Хрюкера (Beep Height, Beep Length)');
          GabberSay('"/CTB" чистит буфер сообщений (Clear Text Buffer)');
          GabberSay('"/PRT" ставит или снимает паузу приёма текста (Pause Recieved Text)');
          GabberSay('"/CRT" чистит принятый текст (Clear Recieved Text)');
          GabberSay('"/ML макс_число_строк" устанавливает, сколько строк влезет в буфер сообщений (Max Length)');
          GabberSay('"/?" выводит эту справку');
          GabberSay('"/X" закрывает окно твоего гэббера (eXit)');
          GabberSay('- Регистр команд и параметров не имеет значения');
          GabberSay('- Щёлкните по гэбби в списке и он вас услышит');
          GabberSay('- Ctrl+Alt+Space вытаскивают гэббера на поверхность');
         end;

      5: begin {\n}
          isCom:=true;
          if curNick<>ps then
           GabberSay('Теперь ты '+ps+'')
          else
           begin
            if firstNick then
             begin
              firstNick:=false;
              GabberSay('Привет, '+ps+'! &) Справка - /?');
             end
            else
            GabberSay('Твой ник не изменился ;)');
           end;
          curNick:=ps;
          updTtl;
         end;

      6: begin {\G}
          isCom:=true;
          GabberSay(ps);
         end;

      7: begin {\B}
          isCom:=true;
          beepLengthW:=beepLength;
          beepHeightW:=beepHeight;
          asm
           pusha
           cli
           in   al, 61h
           mov  cx, beepLengthW
       L1: push cx
           or   al, 2
           out  61h, al
           mov  cx, beepHeightW
       L2: loop L2
           and  al, 11111101b
           out  61h, al
           mov  cx, beepHeightW
       L3: loop L3
           pop  cx
           loop L1
           sti
           popa
          end;
          playsound(pchar(natdir+'beep.wav'),0,SND_ASync);
          showMessage('['+timetostr(now)+'] Тебя зовёт '+ps);
         end;

      8: begin {/P}
          isCom:=true;
          GMainF.clSock.Close;
          try
           portS:=ps;
           port:=strtoint(ps);
           GMainF.clSock.Port:=port;
           GMainF.clSock.Open;
          except
          end;
         end;

      9: begin {bl}
          isCom:=true;
          readWord(beepLength,'Какая длина пика ?!','Теперь длина пика равна');
         end;

      10: begin {\ADD}
           isCom:=true;
           GMainF.GNBox.Items.Add(ps);
           if not firstNick then
            GabberSay('К нам присоеденился ещё один гэбби! &)');
          end;

      11: begin {\DEL}
           isCom:=true;
           deadNick:=GMainF.GNBox.Items.Strings[strtoint(ps)];
           GabberSay(deadNick+' ушёл &(');
           if deadNick<>curNick then
            GMainF.GNBox.Items.Delete(strtoint(ps));
          end;

      12: begin {\REN}
           isCom:=true;
           renIdxS:=copy(ps,1,pos('\',ps)-1);
           GMainF.GNBox.Items.Strings[strtoint(renIdxS)]:=
            copy(ps,length(renIdxS)+2,length(ps)-length(renIdxS)-1)
          end;

      13: begin {CMB}
           isCom:=true;
           GMainF.Memo.Clear;
          end;

      14: begin {ml}
           isCom:=true;
           readWord(maxLines,'Сколько строк влезет в буфер сообщений ?!','Теперь в буфер сообщений влезет строк эдак ');
          end;

      15: begin {CRT}
           isCom:=true;
           rt:='';
           gabberSay('Принятый текст ушёл в никуда ;)');
          end;

      16: begin {RP}
           isCom:=true;
           GMainF.pauseChB.Checked:=not GMainF.pauseChB.Checked;
          end;

      17: begin {NL}
           isCom:=true;
           GMainF.GNBox.Items.Text:=ps;
          end;

      18: begin {AE}
           isCom:=true;
           GAEdF.show;
          end;
     end;
    end;
  end;
end;

procedure TGMainF.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var s:string;
begin
 case key of
 vk_Return:
  begin
   s:=edit.text;
   comHndl(s);
   if isCom then
    addLast(s)
   else
    say(s);
   edit.SelectAll;
  end;

 vk_Up:
  begin
   dec(lastCur);
   if lastcur<1 then
    lastcur:=7;
   edit.text:=last[lastcur];
  end;

 vk_Down:
  begin
   inc(lastCur);
   if lastcur>7 then
    lastcur:=1;
   edit.text:=last[lastcur];
  end;
 end;
end;

procedure TGMainF.FormCreate(Sender: TObject);
begin
 firstNick:=true;
 natdir:=extractfilepath(paramstr(0));
 registerhotkey(handle,1,mod_control or mod_alt,integer(' '));
 lastadd:=0;
 lastcur:=1;
 rt:='';

 application.OnActivate:=appActivate;
 application.OnRestore:=appActivate;
 application.OnMinimize:=appMinimize;

 with nd do
  begin
   wnd:=handle;
   uid:=7;
   hicon:=extracticon(application.Handle,pchar(natdir+sGabber+'.exe'),0);
   szTip:=sGabber+' (Ctrl+Alt+Space)';
   ucallbackmessage:=wm_GabberMsg;
   uFlags:=nif_icon or nif_tip or nif_message;
   cbSize:=sizeof(nd);
  end;

 inif:=tIniFile.Create(natdir+sGabber+'.ini');

 left:=inif.ReadInteger(sMainWindow,sLeft,0);
 top:=inif.ReadInteger(sMainWindow,sTop,412);
 height:=inif.ReadInteger(sMainWindow,sHeight,166);
 width:=inif.ReadInteger(sMainWindow,sWidth,800);
 GNBox.width:=inif.ReadInteger(sMainWindow,sGNBoxWidth,50);
 beepHeight:=abs(inif.ReadInteger(sTunes,sBeepHeight,5000));
 beepLength:=abs(inif.ReadInteger(sTunes,sBeepLength,500));
 maxlines:=abs(inif.ReadInteger(sTunes,sMaxLines,255));
 curNick:=inif.ReadString(sTunes,sGabbyNick,sGabby);
 servaddr:=inif.ReadString(sTunes,sServAddr,sCreoAddr);
 port:=inif.ReadInteger(sTunes,sPort,6667);

 portS:=inttostr(port);
 updTtl;
 clSock.Socket.OnErrorEvent:=GMainF.clSockError;
 firstShow:=true;
end;

procedure TGMainF.EditKeyPress(Sender: TObject; var Key: Char);
begin
 if key=#13 then
  key:=#0;
end;

procedure TGMainF.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var i:integer;
begin
 clSock.Close;

 inif.WriteInteger(sMainWindow,sLeft,left);
 inif.WriteInteger(sMainWindow,sTop,top);
 inif.WriteInteger(sMainWindow,sHeight,height);
 inif.WriteInteger(sMainWindow,sWidth,width);
 inif.WriteInteger(sMainWindow,sGNBoxWidth,GNBox.Width);

 inif.WriteInteger(sGAEdWindow,sLeft,GAEdF.left);
 inif.WriteInteger(sGAEdWindow,sTop,GAEdF.top);
 inif.WriteInteger(sGAEdWindow,sHeight,GAEdF.height);
 inif.WriteInteger(sGAEdWindow,sWidth,GAEdF.width);

 inif.WriteString(sTunes,sGabbyNick,curNick);
 inif.WriteString(sTunes,sServAddr,servAddr);
 inif.WriteInteger(sTunes,sPort,port);
 inif.WriteInteger(sTunes,sBeepHeight,beepHeight);
 inif.WriteInteger(sTunes,sBeepLength,beepLength);
 inif.WriteInteger(sTunes,sMaxLines,maxLines);

 inif.EraseSection(sAddresses);
 for i:=1 to GAEdF.Memo.Lines.Count do
  inif.WriteString(sAddresses,sAddr+inttostr(i),GAEdF.Memo.Lines.strings[i-1]);

 inif.Free;
 unregisterhotkey(handle,1);
end;

procedure TGMainF.clSockConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
 firstConnect:=false;
 conTim.Enabled:=false;
 say('/n '+curNick);
end;

procedure TGMainF.clSockRead(Sender: TObject; Socket: TCustomWinSocket);
var s:string;
    splt:integer;
begin
 rt:=rt+clSock.Socket.ReceiveText;
 if not pauseChB.Checked then
  begin
   {split}
   rt:=copy(rt,2,length(rt)-1);
   repeat
    splt:=pos('|',rt);
    if splt=0 then
     begin
      s:=rt;
      rt:='';
     end
    else
     begin
      s:=copy(rt,1,splt-1);
      rt:=copy(rt,splt+1,length(rt)-splt);
     end;

    if s[1]<>'\' then
     memOut(s);

    comHndl(s);

   until rt='';
 end;
end;

procedure handleFirstConnection;
begin
 if curSrvIdx<=GAEdF.Memo.Lines.Count+1 then
  begin
   inc(curSrvIdx);
   if curSrvIdx>GAEdF.Memo.Lines.Count then
    begin
     winexec(pchar(natdir+'GabServ.exe'),sw_Show);
     firstConnect:=false;
    end
   else
    servaddr:=GAEdF.Memo.Lines.strings[curSrvIdx-1];
   try
    GMainF.clSock.Address:=servaddr;
    GMainF.clSock.Open;
   except
   end;
  end
end;

procedure hndlErr;
begin
 GabberSay('Не могу связаться с сервером '+servaddr+' по порту '+portS+' &(');
 GMainF.conTim.Enabled:=true;
 if firstConnect then
  handleFirstConnection;
end;

procedure TGMainF.clSockError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
 errorcode:=0;
 hndlErr;
end;

procedure TGMainF.conTimTimer(Sender: TObject);
begin
 try
  clSock.Open;
 except
  hndlErr;
 end;
end;

procedure TGMainF.clSockDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
 GMainF.conTim.Enabled:=true;
end;

procedure TGMainF.GNBoxDblClick(Sender: TObject);
begin
 say('/b '+GNBox.Items.Strings[GNBox.ItemIndex]);
 activecontrol:=edit;
end;

procedure TGMainF.MemoMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 memo.CopyToClipboard;
 memo.SelLength:=0;
 activecontrol:=edit;
end;

procedure TGMainF.clrRtIClick(Sender: TObject);
begin
 rt:='';
end;

procedure TGMainF.pauseChBClick(Sender: TObject);
begin
 if pauseChB.Checked then
  say('Я ставлю паузу')
 else
  say('Окей. Продолжим');
 updttl;
end;

procedure TGMainF.hideTimTimer(Sender: TObject);
begin
 application.Minimize;
 hideTim.Enabled:=false;
end;

procedure TGMainF.FormShow(Sender: TObject);
var i:integer;
begin
 if firstShow then
  begin
   hideTim.Enabled:=true;

   firstShow:=false;
   GAEdF.Left:=inif.ReadInteger(sGAEdWindow,sLeft,100);
   GAEdF.top:=inif.ReadInteger(sGAEdWindow,sTop,100);
   GAEdF.width:=inif.ReadInteger(sGAEdWindow,sWidth,200);
   GAEdF.height:=inif.ReadInteger(sGAEdWindow,sHeight,200);

   sl:=tStringList.Create;
   GAEdF.Left:=inif.ReadInteger(sGAEdWindow,sLeft,100);
   GAEdF.top:=inif.ReadInteger(sGAEdWindow,sTop,100);
   GAEdF.width:=inif.ReadInteger(sGAEdWindow,sWidth,400);
   GAEdF.height:=inif.ReadInteger(sGAEdWindow,sHeight,200);
   inif.ReadSection(sAddresses,sl);
   for i:=1 to sl.Count do
    GAEdF.Memo.Lines.Add(inif.readstring(sAddresses,sl.Strings[i-1],sCreoAddr));
   sl.Free;

   clSock.Port:=port;
   curSrvIdx:=0;
   firstConnect:=true;
   opened:=false;
   try
    clSock.Address:=servAddr;
    clSock.open;
   except
   end;
  end;
end;

end.
