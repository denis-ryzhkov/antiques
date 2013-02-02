unit vLab;{virtual 3D lab}
interface
 const p=pi;
       pi2=p*2;
       g2r=p/180;

{tPoint}

 type tPoint=
  object
   rx,ry,rz,xc,yc,zc,ax,ay,az:integer;
   x,y,z,cax,cay,caz,sax,say,saz:real;
   procedure moveTo(newx,newy,newz:integer);
   procedure setCentres(newxc,newyc,newzc:integer);
   procedure setTurnAngs(newaz,neway,newax:integer);
   procedure turn;
  end;

 type tpPoint=^tPoint;
 procedure createPoint(var p:tpPoint;
                       newxc,newyc,newzc,
                       newx,newy,newz,
                       newax,neway,newaz:integer);
 procedure destroyPoint(var p:tpPoint);

{tDot}

 type tDot=
  object
   p:tpPoint;
   c:byte;
   procedure put;
   procedure putTurn;
  end;

 type tpDot=^tDot;
 procedure createDot(var d:tpDot;
                     newxc,newyc,newzc,
                     newx,newy,newz,
                     newax,neway,newaz:integer;newc:byte);
 procedure destroyDot(var d:tpDot);

{tTetr}

 type tTetr=
  object
   p,p1,p2,p3,p4:tpPoint;
   c1,c2,c3,c4:byte;
   p1x,p1y,p1z,
   p2x,p2y,p2z,
   p3x,p3y,p3z,
   p4x,p4y,p4z:integer;
   procedure put;
   procedure calcCoords;
   procedure setTurnAngs(newaz,neway,newax:integer);
   procedure putTurn;
  end;

 type tpTetr=^tTetr;
 procedure createTetr(var t:tpTetr;
  newxc,newyc,newzc,
  newx,newy,newz,
  newx1,newy1,newz1,
  newx2,newy2,newz2,
  newx3,newy3,newz3,
  newx4,newy4,newz4,
  newax,neway,newaz:integer;
  newc1,newc2,newc3,newc4:byte);
 procedure destroyTetr(var t:tpTetr);



implementation
uses Gr13h3d;
{----------------------------------------------------------------------------}

{----------------------------T P O I N T-------------------------------------}

procedure createPoint(var p:tpPoint;
                      newxc,newyc,newzc,
                      newx,newy,newz,
                      newax,neway,newaz:integer);
begin
 new(p);
 with p^ do
  begin
   setCentres(newxc,newyc,newzc);
   moveTo(newx,newy,newz);
   setTurnAngs(newax,neway,newaz);
  end
end;

procedure destroyPoint(var p:tpPoint);
begin
 dispose(p);
end;

procedure tPoint.moveTo(newx,newy,newz:integer);
begin
 x:=xc+newx;
 y:=yc+newy;
 z:=zc+newz;
 rx:=newx;
 ry:=newy;
 rz:=newz;
end;

procedure tPoint.setCentres(newxc,newyc,newzc:integer);
begin
 xc:=newxc;
 yc:=newyc;
 zc:=newzc;
end;

procedure tPoint.setTurnAngs(newaz,neway,newax:integer);
begin
 ax:=newax;
 ay:=neway;
 az:=newaz;
 cax:=cos(ax*g2r);
 cay:=cos(ay*g2r);
 caz:=cos(az*g2r);
 sax:=sin(ax*g2r);
 say:=sin(ay*g2r);
 saz:=sin(az*g2r);
end;

procedure tPoint.turn;
var t:real;
begin
 {z}
  t:=x*caz-y*saz;
  y:=x*saz+y*caz;
  x:=t;
 {y}
  t:=x*cay-z*say;
  z:=x*say+z*cay;
  x:=t;
 {x}
  t:=y*cax-z*sax;
  z:=y*sax+z*cax;
  y:=t;

 rx:=trunc(x);
 ry:=trunc(y);
 rz:=trunc(z);
end;

{----------------------------T D O T-----------------------------------------}

procedure createDot(var d:tpDot;
                    newxc,newyc,newzc,
                    newx,newy,newz,
                    newax,neway,newaz:integer;newc:byte);
begin
 new(d);
 with d^ do
  begin
   c:=newc;
   createPoint(p,newx,newy,newz,newxc,newyc,newzc,newax,neway,newaz);
  end;
end;

procedure destroyDot(var d:tpdot);
begin
 dispose(d^.p);
 dispose(d);
end;

procedure tDot.put;
begin
 with p^ do
  putpix(xc+rx,yc+ry,zc+rz,c);
end;

procedure tDot.putTurn;
begin
 with p^ do
  begin
   turn;
   putpix(xc+rx,yc+ry,zc+rz,c);
  end;
end;

{----------------------------T T E T R---------------------------------------}

procedure createTetr(var t:tpTetr;
  newxc,newyc,newzc,
  newx,newy,newz,
  newx1,newy1,newz1,
  newx2,newy2,newz2,
  newx3,newy3,newz3,
  newx4,newy4,newz4,
  newax,neway,newaz:integer;
  newc1,newc2,newc3,newc4:byte);
var xx,yy,zz:integer;
begin
 new(t);
 with t^ do
  begin
   c1:=newc1;
   c2:=newc2;
   c3:=newc3;
   c4:=newc4;
   createPoint(p,newx,newy,newz,newxc,newyc,newzc,newax,neway,newaz);
   createPoint(p1,newx1,newy1,newz1,newx,newy,newz,newax,neway,newaz);
   createPoint(p2,newx2,newy2,newz2,newx,newy,newz,newax,neway,newaz);
   createPoint(p3,newx3,newy3,newz3,newx,newy,newz,newax,neway,newaz);
   createPoint(p4,newx4,newy4,newz4,newx,newy,newz,newax,neway,newaz);
   calcCoords;
  end;
end;

procedure destroyTetr(var t:tpTetr);
begin
{ dispose(t^.p);
 dispose(t^.p1);
 dispose(t^.p2);
 dispose(t^.p3);
 dispose(t^.p4);
 dispose(t);}
end;

procedure tTetr.put;
begin
  triangle(p1x,p1y,p1z,
           p2x,p2y,p2z,
           p3x,p3y,p3z,c4);

  triangle(p1x,p1y,p1z,
           p2x,p2y,p2z,
           p4x,p4y,p4z,c3);

  triangle(p1x,p1y,p1z,
           p3x,p3y,p3z,
           p4x,p4y,p4z,c2);

  triangle(p2x,p2y,p2z,
           p3x,p3y,p3z,
           p4x,p4y,p4z,c1);

{ line(p1x,p1y,p1z,p2x,p2y,p2z,c1);
 line(p1x,p1y,p1z,p3x,p3y,p3z,c1);
 line(p1x,p1y,p1z,p4x,p4y,p4z,c1);
 line(p2x,p2y,p2z,p3x,p3y,p3z,c1);
 line(p2x,p2y,p2z,p4x,p4y,p4z,c1);
 line(p3x,p3y,p3z,p4x,p4y,p4z,c1);}
end;

procedure tTetr.putTurn;
begin
 p1^.turn;
 p2^.turn;
 p3^.turn;
 p4^.turn;
 calcCoords;
 put;
end;

procedure tTetr.setTurnAngs(newaz,neway,newax:integer);
begin
 p^.setTurnAngs(newaz,neway,newax);
 p1^.setTurnAngs(newaz,neway,newax);
 p2^.setTurnAngs(newaz,neway,newax);
 p3^.setTurnAngs(newaz,neway,newax);
 p4^.setTurnAngs(newaz,neway,newax);
end;

procedure tTetr.calcCoords;
begin
 p1x:=p1^.rx+p^.rx;
 p1y:=p1^.ry+p^.ry;
 p1z:=p1^.rz+p^.rz;

 p2x:=p2^.rx+p^.rx;
 p2y:=p2^.ry+p^.ry;
 p2z:=p2^.rz+p^.rz;

 p3x:=p3^.rx+p^.rx;
 p3y:=p3^.ry+p^.ry;
 p3z:=p3^.rz+p^.rz;

 p4x:=p4^.rx+p^.rx;
 p4y:=p4^.ry+p^.ry;
 p4z:=p4^.rz+p^.rz;
end;


{----------------------------------------------------------------------------}

begin
end.