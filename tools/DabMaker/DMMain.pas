unit DMMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus;

type
  TDMMainF = class(TForm)
    pm: TPopupMenu;
    newI: TMenuItem;
    iPan: TPanel;
    SBox: TScrollBox;
    Img: TImage;
    cPan: TPanel;
    bSB: TScrollBar;
    gSB: TScrollBar;
    rSB: TScrollBar;
    ssBox: TScrollBox;
    split: TSplitter;
    sImg: TImage;
    subcPan: TPanel;
    RColSh: TShape;
    LColSh: TShape;
    sbL: TLabel;
    nulPM: TPopupMenu;
    saveasI: TMenuItem;
    saveDlg: TSaveDialog;
    openI: TMenuItem;
    exitI: TMenuItem;
    saveI: TMenuItem;
    N1: TMenuItem;
    openDlg: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure rSBChange(Sender: TObject);
    procedure newIClick(Sender: TObject);
    procedure LColShMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RColShMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure splitMoved(Sender: TObject);
    procedure ImgMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImgMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure saveasIClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure exitIClick(Sender: TObject);
    procedure saveIClick(Sender: TObject);
    procedure openIClick(Sender: TObject);
  private
    { Private declarations }
   procedure saveDab;
   procedure takeWH;
   procedure drawGrid;
  public
    { Public declarations }
  end;

var
  DMMainF: TDMMainF;
  leftCol,canSBChange:boolean;
  lR,lG,lB,rR,rG,rB,lCC,rCC:byte;
  lC,rC,w,h:longint;
  c256:array of byte;
  fn:string;
implementation

{$R *.DFM}

procedure TDMMainF.FormCreate(Sender: TObject);
begin
 lR:=0;
 lG:=0;
 lB:=0;
 rR:=5;
 rG:=5;
 rB:=5;
 canSBChange:=true;
 w:=0;
 h:=0;
 leftCol:=true;
 rSBChange(self);
 RColShMouseDown(Self,mbLeft,[],1,1);
 LColShMouseDown(Self,mbLeft,[],1,1);
 fn:='';
end;

procedure TDMMainF.rSBChange(Sender: TObject);
begin
 if canSBChange then
  begin
   sbL.Caption:=inttostr(rSB.Position)+inttostr(gSB.Position)+inttostr(bSB.Position);
   if leftCol then
    begin
     lR:=rSB.Position;
     lG:=gSB.Position;
     lB:=bSB.Position;
     if (lR<>6) and (lG<>6) and (lB<>6) then
      begin
       lC:=rgb(lR*50,lG*50,lB*50);
       lCC:=40+lR*36+lG*6+lB;
      end
     else
      begin
       lC:=clBtnFace;
       lCC:=39;
      end;
     LColSh.Brush.Color:=lC;
    end
   else
    begin
     rR:=rSB.Position;
     rG:=gSB.Position;
     rB:=bSB.Position;
     if (rR<>6) and (rG<>6) and (rB<>6) then
      begin
       rC:=rgb(rR*50,rG*50,rB*50);
       rCC:=40+rR*36+rG*6+rB;
      end
     else
      begin
       rC:=clBtnFace;
       rCC:=39;
      end;
     RColSh.Brush.Color:=rC;
    end;
  end;
end;

procedure updTtl;
begin
 DMMainF.caption:='DabMaker ['+extractfilename(fn)+']';
end;

procedure TDMMainF.takeWH;
begin
 sImg.Picture.Bitmap.Width:=w;
 sImg.Picture.Bitmap.Height:=h;
 setlength(c256,w*h);
 Img.Picture.Bitmap.Width:=10*w+1;
 Img.Picture.Bitmap.Height:=10*h+1;
end;

procedure TDMMainF.drawGrid;
var x,y:integer;
begin
 Img.Picture.Bitmap.Canvas.pen.Mode:=pmNot;
 for x:=0 to w do
  begin
   Img.Picture.Bitmap.Canvas.MoveTo(x*10,0);
   Img.Picture.Bitmap.Canvas.LineTo(x*10,h*10);
  end;
 for y:=0 to h do
  begin
   Img.Picture.Bitmap.Canvas.MoveTo(0,y*10);
   Img.Picture.Bitmap.Canvas.LineTo(w*10,y*10);
  end;
 Img.Picture.Bitmap.Canvas.pen.Mode:=pmCopy;
end;

procedure TDMMainF.newIClick(Sender: TObject);
var x:integer;
begin
 try
  w:=strtoint(inputbox('Ширина','','16'));
  h:=strtoint(inputbox('Высота','','16'));
  takeWH;
  for x:=0 to w*h-1 do
   c256[x]:=rCC;
  sImg.Picture.Bitmap.Canvas.brush.Color:=rC;
  Img.Picture.Bitmap.Canvas.brush.Color:=rC;
  sImg.Picture.Bitmap.Canvas.FillRect(rect(0,0,w,h));
  Img.Picture.Bitmap.Canvas.FillRect(rect(0,0,w*10+1,h*10+1));
  drawGrid;
  fn:='';
  updTtl;
 except
 end;
end;

procedure TDMMainF.LColShMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 leftCol:=true;
 LColSh.Height:=50;
 RColSh.Height:=25;
 canSBChange:=false;
 rSB.Position:=lR;
 gSB.Position:=lG;
 bSB.Position:=lB;
 canSBChange:=true;
 rSBChange(self);
end;

procedure TDMMainF.RColShMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 leftCol:=false;
 LColSh.Height:=25;
 RColSh.Height:=50;
 canSBChange:=false;
 rSB.Position:=rR;
 gSB.Position:=rG;
 bSB.Position:=rB;
 canSBChange:=true;
 rSBChange(self);
end;

procedure TDMMainF.splitMoved(Sender: TObject);
begin
 if split.Left<50 then
  split.Left:=60;
end;

procedure TDMMainF.ImgMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var x1,y1,sx1,sy1:integer;
begin
 sx1:=x div 10;
 x1:=sx1*10+1;
 sy1:=y div 10;
 y1:=sy1*10+1;
 if button=mbLeft then
  begin
   Img.Picture.Bitmap.Canvas.Brush.Color:=lC;
   sImg.Picture.Bitmap.Canvas.Pixels[sx1,sy1]:=lC;
   c256[sy1*w+sx1]:=lCC;
  end
 else
  begin
   Img.Picture.Bitmap.Canvas.Brush.Color:=rC;
   sImg.Picture.Bitmap.Canvas.Pixels[sx1,sy1]:=rC;
   c256[sy1*w+sx1]:=rCC;
  end;
 Img.Picture.Bitmap.Canvas.FillRect(rect(x1,y1,x1+9,y1+9));
end;

procedure TDMMainF.ImgMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 if (x>=0) and (y>=0) and (x<=w*10-1) and (y<=h*10-1) then
  if ssLeft in shift then
   ImgMouseDown(self,mbLeft,shift,x,y)
  else
   if ssRight in shift then
    ImgMouseDown(self,mbRight,shift,x,y);
end;

procedure TDMMainF.saveDab;
var f:textfile;
    y,y1,x:integer;
    s:string;
begin
 assignfile(f,fn);
 rewrite(f);
 writeln(f,'data      segment   para ''data''');
 s:=extractfilename(fn);
 s:=copy(s,1,length(s)-length(extractfileext(s)));
 writeln(f,s+'      db        '+inttostr(w)+', '+
                                      inttostr(h));
 for y:=0 to h-1 do
  begin
   write(f,'          db        ');
   y1:=y*w;
   for x:=0 to w-1 do
    begin
     s:=inttostr(c256[y1+x]);
     s:=stringofchar(' ',3-length(s))+s;
     write(f,s);
     if x<>w-1 then
      write(f,',')
     else
      writeln(f);
    end;
  end;
 writeln(f,'data      ends');
 closefile(f);
end;

procedure TDMMainF.saveasIClick(Sender: TObject);
begin
 if saveDlg.Execute then
  begin
   fn:=saveDlg.FileName;
   if pos('.',fn)=0 then
    fn:=fn+'.dab';
   saveDab;
   updTtl;
  end;
end;

procedure TDMMainF.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 canclose:=true;
end;

procedure TDMMainF.exitIClick(Sender: TObject);
begin
 close;
end;

procedure TDMMainF.saveIClick(Sender: TObject);
begin
 if fn<>'' then
  saveDab
 else
  saveasIClick(Self);
end;

procedure TDMMainF.openIClick(Sender: TObject);
var f:textfile;
    s,s1:string;
    x,y,y1:integer;
    r,g,b:byte;
    c:longint;
begin
 if openDlg.Execute then
  begin
   fn:=openDlg.FileName;
   assignfile(f,fn);
   reset(f);
   readln(f);
   readln(f,s);//Dab1 db 3, 4
   x:=pos(' db ',s)+11;
   s:=copy(s,x,length(s)-x+1);//'3, 4'
   s1:=copy(s,1,pos(',',s)-1);//'3'
   w:=strtoint(s1);
   s:=copy(s,length(s1)+3,length(s)-length(s1)-1);//'4'
   h:=strtoint(s);
   takeWH;
   for y:=0 to h-1 do
    begin
     readln(f,s);
     x:=pos(' db ',s)+11;
     s:=copy(s,x,length(s)-x+1);
     y1:=y*w;
     for x:=0 to w-1 do
      begin
       s1:=copy(s,1,3);
       s:=copy(s,5,length(s)-4);
       while s1[1]=' ' do
        s1:=copy(s1,2,length(s1)-1);
       c:=strtoint(s1);
       c256[y1+x]:=c;
       if c=39 then
        c:=clBtnFace
       else
        begin
         dec(c,40);
         r:=c div 36;
         c:=c-r*36;
         g:=c div 6;
         b:=c-g*6;
         c:=rgb(r*50,g*50,b*50);
        end;
       sImg.Picture.Bitmap.Canvas.Pixels[x,y]:=c;
       Img.Picture.Bitmap.Canvas.Brush.Color:=c;
       Img.Picture.Bitmap.Canvas.FillRect(rect(x*10+1,y*10+1,x*10+10,y*10+10));
      end;
    end;
   closefile(f);
   updTtl;
  end;
end;

end.
