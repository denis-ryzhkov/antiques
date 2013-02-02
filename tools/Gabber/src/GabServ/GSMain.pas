unit GSMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ScktComp, StdCtrls, iniFiles, Menus, ShellApi;

const wm_GabServMsg=wm_app+400;

type
  TGSMainF = class(TForm)
    srvSock: TServerSocket;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure srvSockClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure srvSockClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure srvSockClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure srvSockClientError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
  private
    { Private declarations }
   procedure GabServMes(var aMes:tMessage);message wm_GabServMsg;
  public
    { Public declarations }
  end;

type tGabby=
 record
  nick:string;
  sockH:integer;
 end;

const commandsnum=3;
      sGabber='Gabber';
      sBigGabber='GABBER';
      sTunes='Tunes';
      sPort='Port';
      command:array[1..commandsnum] of string=('/N ','/L','/B ');

var
  GSMainF: TGSMainF;
  Gabby:array[0..255] of tGabby;
  Gabsnum,curGabbyIdx:integer;
  gabRawIdx:integer;
  iniF:tIniFile;
  nd:notifyicondata;
  natdir:string;

implementation

{$R *.DFM}

procedure TGSMainF.GabServMes(var aMes:tMessage);
begin
 if (ames.LParam=514) or (ames.LParam=517) or (ames.LParam=520) then
  if messageDlg('Закрыть GabServ ?',mtConfirmation,[mbYes,mbNo],0)=mrYes then
   close;
end;

procedure TGSMainF.FormCreate(Sender: TObject);
begin
 application.ShowMainForm:=false;
 Gabsnum:=0;
 gabRawIdx:=0;
 natdir:=extractfilepath(paramstr(0));

 with nd do
  begin
   wnd:=handle;
   uid:=7;
   hicon:=extracticon(application.Handle,pchar(natdir+'GabServ.exe'),0);
   szTip:='GabServ';
   ucallbackmessage:=wm_GabServMsg;
   uFlags:=nif_icon or nif_tip or nif_message;
   cbSize:=sizeof(nd);
  end;

 shell_notifyicon(nim_add,@nd);
 iniF:=tIniFile.Create(natdir+'GabServ.ini');
 srvSock.port:=inif.ReadInteger(sTunes,sPort,6667);
 srvSock.Open;
end;

procedure TGSMainF.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 shell_notifyicon(nim_delete,@nd);
 inif.WriteInteger(sTunes,sPort,srvSock.Port);
 inif.Free;
 srvSock.Close;
end;

procedure TGSMainF.srvSockClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
var i:integer;
    s:string;
begin
 inc(Gabsnum);
 curGabbyIdx:=Gabsnum-1;
 inc(gabRawIdx);
 if gabRawIdx>32000 then
  gabRawIdx:=0;
 Gabby[curGabbyIdx].nick:='Gabby#'+inttostr(gabRawIdx);
 Gabby[curGabbyIdx].sockH:=socket.SocketHandle;

 s:='|\NL ';//send list to new
 for i:=0 to Gabsnum-1 do
  s:=s+Gabby[i].nick+#13#10;
 srvSock.Socket.Connections[curGabbyIdx].SendText(copy(s,1,length(s)-2));

 for i:=0 to Gabsnum-2 do //broadcast ADD to all
  srvSock.Socket.Connections[i].SendText('|\ADD '+Gabby[curGabbyIdx].nick);
end;

procedure updCurGabbyIdx(sockH:integer);
var i:integer;
begin
 i:=0;
 while (i<gabsnum) and (GSMainF.srvSock.Socket.Connections[i].SocketHandle<>sockH) do
  inc(i);
 CurGabbyIdx:=i;
end;

procedure TGSMainF.srvSockClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
var i:integer;
begin
 updCurGabbyIdx(Socket.SocketHandle);
 for i:=curGabbyIdx to Gabsnum-2 do
  Gabby[i]:=Gabby[i+1];
 Gabby[Gabsnum-1].nick:='';
 for i:=0 to Gabsnum-1 do //broadcast DEL
  srvSock.Socket.Connections[i].SendText('|\DEL '+inttostr(curGabbyIdx));
 dec(Gabsnum);
end;

procedure TGSMainF.srvSockClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var i,j:integer;
    s,cs,ps,bigPS,outS:string;
    isNew:boolean;

begin
 updCurGabbyIdx(Socket.SocketHandle);
 s:=socket.ReceiveText;
 s:=copy(s,2,length(s)-1);

 //make [00:00:00] <XXXX> YYYYYY form
 outS:='|['+timetostr(now)+'] <'+Gabby[curGabbyIdx].nick+'> '+s;
 for i:=0 to Gabsnum-1 do //broadcast
  srvSock.Socket.Connections[i].SendText(outS);

 //coms
 for j:=1 to commandsnum do
  begin
   cs:=command[j];
   ps:=copy(s,length(cs)+1,length(s)-length(cs));
   bigps:=ansiuppercase(ps);
   if ansiuppercase(copy(s,1,length(cs)))=cs then
    begin
     case j of

      1: begin {nick}
          isNew:=true;
          if copy(bigps,1,6)=sBigGabber then
           isNew:=false;

          if isNew then
           for i:=0 to Gabsnum-1 do
            if ansiuppercase(Gabby[i].nick)=bigPs then
             isNew:=(i=curGabbyIdx);

          if isNew then
           begin
            Gabby[curGabbyIdx].nick:=ps;
            for i:=0 to Gabsnum-1 do //broadcast REN
             srvSock.Socket.Connections[i].SendText('|\REN '+inttostr(curGabbyIdx)+'\'+Gabby[curGabbyIdx].nick);
           end;
          srvSock.Socket.Connections[curGabbyIdx].SendText('|\n '+Gabby[curGabbyIdx].nick);
         end;

      2: begin {list Gabs}
          outS:='';
          for i:=0 to Gabsnum-1 do
           outS:=outS+Gabby[i].nick+', ';
          srvSock.Socket.Connections[curGabbyIdx].SendText('|\G Cейчас болтают '+outS+sGabber+'.');
         end;

      3: begin  {beep}
          i:=0;
          while (i<gabsnum) and (ansiuppercase(gabby[i].nick)<>bigPs) do
           inc(i);
          if bigPs=sBigGabber then
           srvSock.Socket.Connections[curGabbyIdx].SendText('|\G Зачем меня звать ?! Я и так на чеку.')
          else

          if (i=gabsnum) then
           srvSock.Socket.Connections[curGabbyIdx].SendText('|\G Кого позвать ?!')
          else
           begin
            srvSock.Socket.Connections[curGabbyIdx].SendText('|\G Надеюсь, '+ps+' услышит.');
            srvSock.Socket.Connections[i].SendText('|\B '+Gabby[curGabbyIdx].nick);
           end;
         end;
     end;
    end;
  end;
end;

procedure TGSMainF.srvSockClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
 errorCode:=0;
 srvSock.Close;
 winexec(pchar(natdir+'GabServ.exe'),sw_Show);
 close;
end;

end.
