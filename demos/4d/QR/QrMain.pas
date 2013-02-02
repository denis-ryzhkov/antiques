unit QrMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls;

type
  TMainF = class(TForm)
    mm: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N4D1: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type tQPoint=
 record
  x1,x2,x3,x4,c:integer;
 end;

var
  MainF: TMainF;
  qp:tQPoint;
  cx,cy,tx,ty:integer;
  started,hascxcy:boolean;
  cr:trect;

implementation

{$R *.DFM}

procedure TMainF.FormShow(Sender: TObject);
begin
 if not started then
  begin
   started:=true;
   canvas.Brush.color:=clBlack;
   cr:=rect(0,0,screen.width,screen.height);
   canvas.Font.Color:=clSilver;
   canvas.Font.Name:='System';
   qp.c:=clBlue;
  end;
end;

procedure qline(x11,x12,x13,x14,
                x21,x22,x23,x24,c:integer);
begin
 mainf.canvas.pen.color:=c;
 mainf.canvas.moveto(cx+x11-x13-x14,cy-x12-x13+x14);
 mainf.canvas.lineto(cx+x21-x23-x24,cy-x22-x23+x24);
end;

procedure TMainF.FormPaint(Sender: TObject);
begin
 canvas.FillRect(cr);
 canvas.TextOut(50,50,
                 inttostr(qp.x1)+':'+
                 inttostr(qp.x2)+':'+
                 inttostr(qp.x3)+':'+
                 inttostr(qp.x4));
{1}
 qline(0    ,0    ,0    ,0    ,  qp.x1,0    ,0    ,0    ,  clNavy);
 qline(0    ,0    ,0    ,0    ,  0    ,qp.x2,0    ,0    ,  clRed);
 qline(0    ,0    ,0    ,0    ,  0    ,0    ,qp.x3,0    ,  clGreen);
 qline(0    ,0    ,0    ,0    ,  0    ,0    ,0    ,qp.x4,  clPurple);
{2}
 if n5.Checked  or n6.Checked then
  begin
   qline(0    ,qp.x2,0    ,0    ,  qp.x1,qp.x2,0    ,0    ,  clNavy);
   qline(qp.x1,0    ,0    ,0    ,  qp.x1,qp.x2,0    ,0    ,  clRed);

   qline(0    ,qp.x2,0    ,0    ,  0    ,qp.x2,0    ,qp.x4,  clPurple);
   qline(0    ,qp.x2,0    ,qp.x4,  0    ,0    ,0    ,qp.x4,  clRed);

   qline(0    ,0    ,0    ,qp.x4,  qp.x1,0    ,0    ,qp.x4,  clNavy);
   qline(qp.x1,0    ,0    ,qp.x4,  qp.x1,0    ,0    ,0    ,  clPurple);

   qline(0    ,qp.x2,0    ,0    ,  0    ,qp.x2,qp.x3,0    ,  clGreen);
   qline(0    ,qp.x2,qp.x3,0    ,  0    ,0    ,qp.x3,0    ,  clRed);

   qline(0    ,0    ,qp.x3,0    ,  0    ,0    ,qp.x3,qp.x4,  clPurple);
   qline(0    ,0    ,qp.x3,qp.x4,  0    ,0    ,0    ,qp.x4,  clGreen);

   qline(0    ,0    ,qp.x3,0    ,  qp.x1,0    ,qp.x3,0    ,  clNavy);
   qline(qp.x1,0    ,qp.x3,0    ,  qp.x1,0    ,0    ,0    ,  clGreen);
  end;
{3}
 if n6.Checked then
  begin
   qline(qp.x1,qp.x2,0    ,qp.x4,  0    ,qp.x2,0    ,qp.x4,  clNavy);
   qline(qp.x1,qp.x2,0    ,qp.x4,  qp.x1,0    ,0    ,qp.x4,  clRed);
   qline(qp.x1,qp.x2,0    ,qp.x4,  qp.x1,qp.x2,0    ,0    ,  clPurple);

   qline(0    ,qp.x2,qp.x3,qp.x4,  0    ,0    ,qp.x3,qp.x4,  clRed);
   qline(0    ,qp.x2,qp.x3,qp.x4,  0    ,qp.x2,0    ,qp.x4,  clGreen);
   qline(0    ,qp.x2,qp.x3,qp.x4,  0    ,qp.x2,qp.x3,0    ,  clPurple);

   qline(qp.x1,0    ,qp.x3,qp.x4,  0    ,0    ,qp.x3,qp.x4,  clNavy);
   qline(qp.x1,0    ,qp.x3,qp.x4,  qp.x1,0    ,0    ,qp.x4,  clGreen);
   qline(qp.x1,0    ,qp.x3,qp.x4,  qp.x1,0    ,qp.x3,0    ,  clPurple);

   qline(qp.x1,qp.x2,qp.x3,0    ,  0    ,qp.x2,qp.x3,0    ,  clNavy);
   qline(qp.x1,qp.x2,qp.x3,0    ,  qp.x1,0    ,qp.x3,0    ,  clRed);
   qline(qp.x1,qp.x2,qp.x3,0    ,  qp.x1,qp.x2,0    ,0    ,  clGreen);

   qline(qp.x1,qp.x2,qp.x3,qp.x4,  0    ,qp.x2,qp.x3,qp.x4,  clNavy);
   qline(qp.x1,qp.x2,qp.x3,qp.x4,  qp.x1,0    ,qp.x3,qp.x4,  clRed);
   qline(qp.x1,qp.x2,qp.x3,qp.x4,  qp.x1,qp.x2,0    ,qp.x4,  clGreen);
   qline(qp.x1,qp.x2,qp.x3,qp.x4,  qp.x1,qp.x2,qp.x3,0    ,  clPurple);
  end;

 if n11.checked then
  begin
   canvas.pen.Color:=clYellow;
   canvas.Ellipse(cx+qp.x1-qp.x3-qp.x4-3,cy-qp.x2-qp.x3+qp.x4-3,
                  cx+qp.x1-qp.x3-qp.x4+3,cy-qp.x2-qp.x3+qp.x4+3);
  end;

 if n10.checked then
  begin
   canvas.pen.Color:=clAqua;
   canvas.Ellipse(cx-3,cy-3,cx+3,cy+3);
  end;

end;

procedure TMainF.N2Click(Sender: TObject);
begin
 close;
end;

procedure takeQP(x,y:integer; shift: tShiftState);
begin
 if ssLeft in shift then
  begin
   if ssRight in shift then
    begin
     qp.x3:=tx-x;
     qp.x4:=ty+y;
    end
   else
    begin
     qp.x1:=tx+x;
     qp.x2:=ty-y;
    end;
  mainf.repaint;
 end;
end;

procedure TMainF.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 takeQP(x,y,shift);
end;

procedure TMainF.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if ssLeft in shift then
  begin
   if not hascxcy then
    begin
     hascxcy:=true;
     cx:=x;
     cy:=y;
    end;


   if ssRight in shift then
    begin
     tx:=qp.x3+x;
     ty:=qp.x4-y;
    end
   else
    begin
     tx:=qp.x1-x;
     ty:=qp.x2+y;
    end;
  takeQP(x,y,shift);
 end;
end;

procedure TMainF.N4Click(Sender: TObject);
begin
 n4.Checked:=true;
 n5.Checked:=false;
 n6.Checked:=false;
 repaint;
end;

procedure TMainF.N5Click(Sender: TObject);
begin
 n5.checked:=true;
 n4.checked:=false;
 n6.checked:=false;
 repaint;
end;

procedure TMainF.N6Click(Sender: TObject);
begin
 n6.checked:=true;
 n4.checked:=false;
 n5.checked:=false;
 repaint;
end;

procedure TMainF.N8Click(Sender: TObject);
begin
 hascxcy:=false;
end;

procedure TMainF.N9Click(Sender: TObject);
var s,xs:string;
    ok:boolean;

procedure parse;
begin
 xs:=copy(s,1,pos(':',s)-1);
 ok:=(xs<>'');
 s:=copy(s,length(xs)+2,length(s)-length(xs));
end;

begin
 s:=inputbox('Координаты точки4D:','',inttostr(qp.x1)+':'+inttostr(qp.x2)+':'+
                   inttostr(qp.x3)+':'+inttostr(qp.x4));
 s:=s+':';                  
 parse;
 if ok then
  begin
   qp.x1:=strtoint(xs);
   parse;
   if ok then
    begin
     qp.x2:=strtoint(xs);
     parse;
     if ok then
      begin
       qp.x3:=strtoint(xs);
       parse;
       if ok then
        qp.x4:=strtoint(xs);
      end;
    end;
  end;
 repaint; 
end;

procedure TMainF.N10Click(Sender: TObject);
begin
 (sender as tmenuitem).Checked:=not (sender as tmenuitem).checked;
 repaint;
end;

end.
