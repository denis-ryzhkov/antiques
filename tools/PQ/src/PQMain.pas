unit PQMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Gauges, Buttons, PQLeg, ComCtrls, StdCtrls, Menus, TeEngine,
  Series, TeeProcs, Chart, Printers;

type
  TPQMainF = class(TForm)
    Image1: TImage;
    Panel1: TPanel;
    Gauge1: TGauge;
    SpeedButton1: TSpeedButton;
    Panel2: TPanel;
    Panel3: TPanel;
    Image2: TImage;
    Image3: TImage;
    Panel4: TPanel;
    TrackBar1: TTrackBar;
    StaticText1: TStaticText;
    Edit1: TEdit;
    Edit2: TEdit;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    Button1: TButton;
    Panel5: TPanel;
    Panel6: TPanel;
    Memo1: TMemo;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    Panel7: TPanel;
    StaticText4: TStaticText;
    SpeedButton6: TSpeedButton;
    PopupMenu1: TPopupMenu;
    Image4: TImage;
    Panel9: TPanel;
    Memo2: TMemo;
    Panel10: TPanel;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    PopupMenu2: TPopupMenu;
    Panel8: TPanel;
    Chart1: TChart;
    Series1: TBarSeries;
    Panel11: TPanel;
    Chart2: TChart;
    BarSeries1: TBarSeries;
    Panel12: TPanel;
    Chart3: TChart;
    BarSeries2: TBarSeries;
    OpenDialog1: TOpenDialog;
    Panel13: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Panel14: TPanel;
    Memo3: TMemo;
    Panel15: TPanel;
    Image5: TImage;
    SpeedButton9: TSpeedButton;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    SpeedButton12: TSpeedButton;
    SpeedButton13: TSpeedButton;
    SpeedButton14: TSpeedButton;
    Panel16: TPanel;
    Memo4: TMemo;
    Button2: TButton;
    StaticText5: TStaticText;
    SaveDialog1: TSaveDialog;
    Bevel1: TBevel;
    SpeedButton16: TSpeedButton;
    Label3: TLabel;
    procedure SpeedButton1Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure Memo1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure PopupMenu2Popup(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SpeedButton10Click(Sender: TObject);
    procedure SpeedButton11Click(Sender: TObject);
    procedure SpeedButton14Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure SpeedButton12Click(Sender: TObject);
    procedure SpeedButton13Click(Sender: TObject);
    procedure SpeedButton15Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

tr8=record
     ki:array[1..13] of shortint;
     ddo:array[1..5] of shortint;
     gol:array[1..6] of shortint;
    end;

tr9=record
     ki:array[1..25] of shortint;
     k,o:byte;
    end;

tr10=record
     ki:array[1..29] of shortint;
    end;

tr11=record
     f:array[1..50] of byte;
    end;

const m1_='Вы успешно завершили первый тест.';
      ml_='Вы успешно выполнили все тесты.';
      tmpf_='pq_tmp$$.$$$';
      psw='pqsv';
      prn_='(-PRN-)*';
      cbi_='Picts\chrtbgim.bmp';
      n8_:array[1..13] of string=('Физика и математика',
       'Химия','Электро- и радиотехника','Геология и география',
       'Техника','Филология и журналистика','Биология и с/х',
       'Педагогика и воспитание','История, общественная деятельность',
       'Медицина','Сфера обслуживания','Искусство','Военное дело');
      nddo_:array[1..5] of string=('Природа','Техника',
      'Человек','Знаковая система','Художественный образ');
      ngol_:array[1..6] of string=('Реалистический',
      'Интеллектуальный','Социальный','Конвенциальный',
      'Предприимчивый','Артистический');
      n9_:array[1..25] of string=('Физика','Математика','Химия',
      'Астрономия','Биология','Медицина','С/Х','Лесхоз','Финансы',
      'Журналистика','История','Искусство','Геология','География',
      'Общественная работа','Право','Транспорт','Педагогика',
      'Рабочий','Сфера обслуживания','Строительство',
      'Легкая промышленность','Техника','Электротехника',
      'Экономика');
      n10_:array[1..29] of string=('Биология','География','Геология',
       'Медицина','Легкая и пищевая промышленность','Физика',
       'Химия','Техника','Электро- и радиотехника','Металлообработка',
       'Деревообработка','Строительство','Транспорт','Авиация, морское дело',
       'Военные специальности','История','Литература','Журналистика',
       'Общественная деятельность','Педагогика','Право',
       'Сфера обслуживания','Математика','Экономика',
       'Инотранные языки','Изобразительное искусство',
       'Сценическое искусство','Музыка','Физкультура и спорт');

      n11_:array[1..50] of string=('Артист','Литератор','Исследователь',
      'Изобретатель','Разработчик','Доводчик','Сборщик','Монтажник',
      'Наладчик','Оператор','Водитель','Манипулятор','Ремонтник',
      'Регистратор','Контролёр','Измеритель','Корректировщик','Сортировщик',
      'Охранник','Хранитель','Смотритель','Наблюдатель','Обозреватель',
      'Оценщик','Изыскатель','Собиратель','Расследователь','Арбитр',
      'Разносчик','Информатор','Распределитель','Распространитель',
      'Сопровождающий','Помощник','Справочник','Советник','Обслуживающий',
      'Лечащий','Ухаживающий','Блюститель','Воспитатель','Лектор',
      'Организатор людей','Организатор труда','Организатор хозяйства',
      'Организатор управления','Диспетчер','Распорядитель','Координатор','Руководитель');
      f50_:array[1..82] of set of byte=([1,50+6,9,10,11,12,50+16,17,18,19,27,28,35,47],
      [1,50+21],[1,50+25,50+33],[1,36,50+38,50+39],[50+4,8,33,37,46],
      [4,50+45],[7,10,50+11],[50+33,39,11],[50+10,50+17,50+19,42],
      [1,4,5,6],[1,2,3,4,5,6,9,12,13,27,38,42,48,49],[1,2,23,32,38,40],
      [1,30,32],[1,9,12,13,15,19,22,27],[1,3,4,5,6,23,25,26,27,32,36,42,44,45,46,48,49],
      [2,22,30,36],[2,3],[2,3,5,9,13,18,22,23,24,27,28,36,38,44,45,46,48,49],
      [2,23,30,35,36,41,42],[2,41,46],[2,3,22],[2,23,42],[2,21,22],
      [3,9,15,21,23,24,28,34,44,46,47,49],[3,5,7,8,9,23,24,27,42,44,46,48,49,50],
      [3,4,5,16,46],[3,11,13,22,24,27,43,45,46],[3,4,5,28,36,42,44,49],
      [4],[4,5,6,11,13,24,29,31,32,36,37,44,45,46,49],[4,50+25,50+26,50+32,50+33,50+45,50+50],
      [5,26,27,28,32,34,37,44,45,46,49,50],[5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,24,27,31,34,35,37,38,39,41,43,47,50],
      [6,7,10,11,12,14,16,17,18,19,20,47],[6,7,10,12,13,14,16,17,18,19,33,34,37,38,39,41],
      [6,7,8,9,12,13,14,15,16,17,18,20,21,24,28,31,34,35,45,47],
      [6,7,10,13,14,16,17,18,20,35],[7,8],[7,10,11,12,15,16,17,18,20,21,24,33,34,40],
      [7,8,15,16,17,18,19,20,24,28,31,37,40,45,47],[8,26],
      [8,13,29,31,32,35,37,38,39,41,43,47],[8,22,23],[8,25],
      [9,11,12,15,29,31,34,35,36,37,39,40,41,42,43,47,50],
      [9,11,12,19,23,29,35,36,38,42,44,48,19,50],[10,14,15],[10,17,49,50],
      [11,26,29,30,43,44,48],[14,20],[14,15,16,18,28,40],[14],
      [14],[15,19,21,40],[20,22,23,24,30,34,35,36,42,47],[20],
      [20,21],[21,25,26,27,29,30,32,33],[21,25,26,29,30,31,32,33,37,43,47,48,50],
      [21],[25,26,29,30,33],[25],[25,38,39],[25,33,43],[26,29,30,31,32,35,37,38,39,43],
      [26],[28,41,43,48],[28],[29,30,31,34,44],[31],[19],[11],[34],
      [39,40,41],[39],[40],[40,41],[40],[43],[48,50],[48],[50]);

var
  PQMainF: TPQMainF;
  t,ci,pn,tst,qi,l,r:byte;
  f:textfile;
  cdate,uname,clss,s,natdir:string;
  r8:tr8;
  r9:tr9;
  r10:tr10;
  r11:tr11;
  vr,mm,sv,skipall:boolean;
implementation

{$R *.DFM}
procedure TPQMainF.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 if mm or sv then
  begin
   canclose:=true;
   exit;
  end;
 canclose:=(messageDlg('Вы действительно хотите преждевтеменно завершить работу с PQ ?',
 mtConfirmation,[mbYes,mbNo],0)=mrYes);
end;

procedure hlopdown(m:boolean);
var f8:file of tr8;
    f9:file of tr9;
    f10:file of tr10;
    f11:file of tr11;
    ds,fk,fk1:string;
begin
 mm:=m;
 if m then
  begin
   if (t<>0) then closefile(f);
   ds:='Results\'+pqmainf.edit1.text;
   fk:=pqmainf.edit2.Text+'.pq';
   fk1:=natdir+'\Results\'+pqmainf.Edit1.text+'\'+fk;
   {$i-}
   chdir(ds);
   if ioresult<>0 then mkdir(ds);
   {$i+}
   chdir(natdir);
   chdir(ds);
   case t of
    1: begin
        pqmainf.opendialog1.filename:=fk1+'8';
        assignfile(f8,fk+'8');
        rewrite(f8);
        write(f8,r8);
        closefile(f8);
       end;

    2: begin
        pqmainf.opendialog1.filename:=fk1+'9';
        assignfile(f9,fk+'9');
        rewrite(f9);
        write(f9,r9);
        closefile(f9);
       end;

    3: begin
        pqmainf.opendialog1.filename:=fk1+'0';
        assignfile(f10,fk+'0');
        rewrite(f10);
        write(f10,r10);
        closefile(f10);
       end;

    4: begin
        pqmainf.opendialog1.filename:=fk1+'1';
        assignfile(f11,fk+'1');
        rewrite(f11);
        write(f11,r11);
        closefile(f11);
       end;
   end;
   chdir(natdir);
   messagedlg(ml_,mtInformation,[mbOk],0);
   vr:=true;
   pqmainf.panel7.visible:=false;
   pqmainf.panel10.visible:=false;
   pqmainf.panel6.visible:=false;
   pqmainf.panel5.visible:=false;
   pqmainf.speedbutton9click(application);
   exit;
  end;
 pqmainf.Close;
end;

procedure TPQMainF.SpeedButton1Click(Sender: TObject);
begin
 pqmainf.Close;
end;

procedure TPQMainF.Image1Click(Sender: TObject);
begin
 inc(ci);
 if ci=(pn+1) then ci:=1;
 image1.Picture.LoadFromFile('picts\'+inttostr(ci)+'.bmp');
end;

procedure TPQMainF.FormCreate(Sender: TObject);
var f:textfile;
    x:byte;
begin
 getdir(0,natdir);
 opendialog1.InitialDir:=natdir+'\Results';
 vr:=false;
 skipall:=false;
 sv:=false;
 t:=0;
 ci:=1;
 mm:=false;
 assignfile(f,'picts\pqpicts#.prq');
 reset(f);
 readln(f,pn);
 closefile(f);
 for x:=1 to 13 do r8.ki[x]:=0;
 for x:=1 to 6 do r8.gol[x]:=0;
 for x:=1 to 5 do r8.ddo[x]:=0;
 for x:=1 to 25 do r9.ki[x]:=0;
 for x:=1 to 29 do r10.ki[x]:=0;
 for x:=1 to 50 do r11.f[x]:=0;
 r9.k:=0;
 r9.o:=0;
 chart1.BackImage.LoadFromFile(cbi_);
 chart2.BackImage.LoadFromFile(cbi_);
 chart3.BackImage.LoadFromFile(cbi_);
end;

procedure TPQMainF.FormShow(Sender: TObject);
begin
 image1.Picture.LoadFromFile('picts\'+inttostr(ci)+'.bmp');
end;

procedure TPQMainF.Image2Click(Sender: TObject);
begin
 pqlegf:=tpqlegf.Create(application);
 pqlegf.ShowModal;
 pqlegf.Free;
end;

procedure TPQMainF.Button1Click(Sender: TObject);
begin
 if edit2.Text=psw then
  begin
   sv:=true;
   gauge1.Visible:=false;
   panel4.Visible:=false;
   speedbutton10.Visible:=true;
   t:=0;
   pqmainf.Repaint;
   speedbutton10click(self);
   speedbutton9click(self);
   exit;
  end;
 t:=trackbar1.Position;
 if t=0 then pqmainf.ActiveControl:=trackbar1 else
 if edit2.Text='' then pqmainf.ActiveControl:=edit2 else
 if edit1.Text='' then pqmainf.ActiveControl:=edit1 else
 begin
//  fk:='Results\'+edit1.Text+'\'+edit2.Text+'.pq';
  panel4.Visible:=false;

  case t of
    1: begin
        tst:=1;
        assignfile(f,'ki1.prq');
        gauge1.MaxValue:=140;
       end;
    2: begin
        tst:=4;
        assignfile(f,'ki2.prq');
        gauge1.MaxValue:=190;
       end;
    3: begin
        tst:=6;
        assignfile(f,'ki3.prq');
        gauge1.MaxValue:=174;
       end;
    4: begin
        tst:=7;
        assignfile(f,'50f.prq');
        gauge1.MaxValue:=82;
        speedbutton2.Visible:=false;
        speedbutton4.Visible:=false;
        panel5.Left:=320;
        panel5.Width:=177;
        speedbutton3.left:=8;
        speedbutton5.left:=88;
        statictext4.Caption:='Вам свойственно это качество ?';
       end;
  end;
  panel4.Visible:=false;
  panel5.Visible:=true;
  panel6.Visible:=true;
  panel7.Visible:=true;
  reset(f);
  qi:=1;
  readln(f,s);
  memo1.Lines.CommaText:='"'+s+'"';
 end
end;

procedure TPQMainF.SpeedButton6Click(Sender: TObject);
begin
 application.Minimize;
end;

procedure TPQMainF.Memo1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if tst=2 then
  begin
   gauge1.AddProgress(1);
   if sender=memo1 then
    begin
     inc(r8.ddo[l]);
     dec(r8.ddo[r]);
    end else
    begin
     inc(r8.ddo[r]);
     dec(r8.ddo[l]);
    end;
    inc(qi);
    if (qi=21) or skipall then
     begin
      messagedlg('Поздравляем с завершением теста ДДО',mtInformation,[mbOk],0);
      panel6.Visible:=false;
      panel9.Visible:=false;
      statictext4.Caption:='Одно из двух. Какую профессию предпочтёте?';
      panel10.Visible:=true;
      tst:=3;
      closefile(f);
      assignfile(f,'golland.prq');
      reset(f);
      readln(f,l);
      readln(f,s);
      speedbutton7.Caption:=s;
      readln(f,r);
      readln(f,s);
      speedbutton8.Caption:=s;
      qi:=1;
      exit;
     end;
    readln(f,l);
    readln(f,s);
    memo1.lines.commatext:='"'+s+'"';
    readln(f,r);
    readln(f,s);
    memo2.lines.commatext:='"'+s+'"';
    pqmainf.ActiveControl:=panel2;
  end
 else pqmainf.ActiveControl:=panel2;
end;

procedure TPQMainF.SpeedButton5Click(Sender: TObject);
var t:byte;
begin
 gauge1.addProgress(1);
 case tst of
  1: begin
      t:=qi-13*(qi div 13);
      if t=0 then t:=13;
      inc(r8.ki[t],(sender as tspeedbutton).tag);
      inc(qi);
      if (qi=79) or skipall then
       begin
        messagedlg(m1_,mtInformation,[mbOk],0);
        panel5.Visible:=false;
        panel9.Visible:=true;
        panel6.left:=176;
        panel6.top:=264;
        panel6.BevelInner:=bvRaised;
        memo1.Cursor:=crHandPoint;
        qi:=1;
        closefile(f);
        assignfile(f,'ddo.prq');
        reset(f);
        readln(f,l);
        readln(f,s);
        memo1.lines.commatext:='"'+s+'"';
        readln(f,r);
        readln(f,s);
        memo2.lines.commatext:='"'+s+'"';
        statictext4.Caption:='Третьего не дано. Вы предпочтёте ...';
        tst:=2;
        exit;
       end;
     end;
  4: begin
      t:=qi-25*(qi div 25);
      if t=0 then t:=25;
      inc(r9.ki[t],(sender as tspeedbutton).tag);
      inc(qi);
      if (qi=151) or skipall then
       begin
        messagedlg(m1_,mtInformation,[mbOk],0);
        statictext4.Caption:='Это действительно так ?';
        tst:=5;
        qi:=1;
        speedbutton2.Visible:=false;
        speedbutton4.Visible:=false;
        panel5.Left:=320;
        panel5.Width:=177;
        speedbutton3.left:=8;
        speedbutton5.left:=88;
        closefile(f);
        assignfile(f,'kos.prq');
        reset(f);
        readln(f,s);
        memo1.Lines.CommaText:='"'+s+'"';
        exit;
       end;
     end;
  5: begin
      t:=qi-4*(qi div 4);
      if t=0 then t:=4;
      if sender=speedbutton3 then
       begin
        if t=1 then inc(r9.k);
        if t=2 then inc(r9.o);
       end else
       begin
        if t=3 then inc(r9.k);
        if t=4 then inc(r9.o);
       end;
      inc(qi);
      if (qi=41) or skipall then
       begin
        hlopdown(true);
        exit;
       end;
     end;
  6: begin
      t:=qi-29*(qi div 29);
      if t=0 then t:=29;
      inc(r10.ki[t],(sender as tspeedbutton).tag);
      inc(qi);
      if (qi=175) or skipall then
       begin
        hlopdown(true);
        exit;
       end;
     end;
  7: begin
      if (sender as tspeedbutton).tag=1 then
       begin
        for t:=1 to 50 do
         if t in f50_[qi] then inc(r11.f[t])
       end else
        for t:=51 to 100 do
         if t in f50_[qi] then inc(r11.f[t-50]);
      inc(qi);
      if (qi=83) or skipall then
       begin
        hlopdown(true);
        exit;
       end;
     end;
 end;
 if (tst=1) or (tst=4) or (tst=6) or (tst=5) or (tst=7) then
  begin
   readln(f,s);
   memo1.Lines.CommaText:='"'+s+'"';
  end;
end;

procedure TPQMainF.SpeedButton8Click(Sender: TObject);
begin
 gauge1.addProgress(1);
 if sender=speedbutton7 then
  begin
   inc(r8.gol[l]);
   dec(r8.gol[r]);
  end else
  begin
   inc(r8.gol[r]);
   dec(r8.gol[l]);
  end;
  inc(qi);
  if (qi=43) or skipall then
   begin
    hlopdown(true);
    exit;
   end; 
 readln(f,l);
 readln(f,s);
 speedbutton7.Caption:=s;
 readln(f,r);
 readln(f,s);
 speedbutton8.Caption:=s;
end;

procedure TPQMainF.PopupMenu2Popup(Sender: TObject);
begin
 skipall:=not skipall;
end;

procedure TPQMainF.SpeedButton9Click(Sender: TObject);
var fn,fe:string;
    f8:file of tr8;
    f9:file of tr9;
    f10:file of tr10;
    f11:file of tr11;
    x:byte;
function r:cardinal;
begin
 r:=rgb(random(200)+55,random(200)+55,random(200)+55);
end;

begin
 randomize;
 if not vr then
  begin
   opendialog1.FileName:='';
   if not opendialog1.Execute then exit;
   speedbutton13.Enabled:=true;
   speedbutton12.Enabled:=true;
  end;
 speedbutton14.Enabled:=true;
 fn:=opendialog1.FileName;
 fe:=extractfileext(fn);
 uname:=extractfilename(fn);
 clss:=copy(fn,1,length(fn)-length(uname)-1);
 for x:=length(clss) downto 1 do
  if clss[x]='\' then break;
 clss:=copy(clss,x+1,length(clss)-x);
 uname:=copy(uname,1,length(uname)-4);
 cdate:=datetostr(FileDateToDateTime(fileage(fn)));
 chart1.UndoZoom;
 chart2.UndoZoom;
 chart3.UndoZoom;
 if fe='.pq8' then
  begin
   t:=1;
   series1.Clear;
   barseries1.Clear;
   barseries2.Clear;
   assignfile(f8,fn);
   reset(f8);
   read(f8,r8);
   closefile(f8);
   for x:=1 to 13 do
    series1.AddBar(r8.ki[x],n8_[x],r);
   for x:=1 to 5 do
    barseries1.AddBar(r8.ddo[x],nddo_[x],r);
   for x:=1 to 6 do
    barseries2.AddBar(r8.gol[x],ngol_[x],r);
   panel13.Visible:=false;
   panel14.Visible:=false;
   panel8.Visible:=true;
   panel11.Visible:=true;
   panel12.Visible:=true;
  end;
 if fe='.pq9' then
  begin
   t:=2;
   memo3.Lines.LoadFromFile('kostxt.prq');
   series1.Clear;
   assignfile(f9,fn);
   reset(f9);
   read(f9,r9);
   closefile(f9);
   for x:=1 to 25 do
    series1.AddBar(r9.ki[x],n9_[x],r);
   label1.Caption:='Коэфициент коммуникативности : '+inttostr(r9.k);
   label2.Caption:='..организаторских способностей  : '+inttostr(r9.o);
   panel8.Visible:=true;
   panel13.Visible:=true;
   panel14.Visible:=true;
   panel11.Visible:=false;
   panel12.Visible:=false;
  end;
 if fe='.pq0' then
  begin
   t:=3;
   series1.Clear;
   assignfile(f10,fn);
   reset(f10);
   read(f10,r10);
   closefile(f10);
   for x:=1 to 29 do
    series1.AddBar(r10.ki[x],n10_[x],r);
   panel8.Visible:=true;
   panel13.Visible:=false;
   panel14.Visible:=false;
   panel11.Visible:=false;
   panel12.Visible:=false;
  end;
 if fe='.pq1' then
  begin
   t:=4;
   series1.Clear;
   assignfile(f11,fn);
   reset(f11);
   read(f11,r11);
   closefile(f11);
   for x:=1 to 50 do
    series1.AddBar(r11.f[x],n11_[x],r);
   panel8.Visible:=true;
   panel13.Visible:=false;
   panel14.Visible:=false;
   panel11.Visible:=false;
   panel12.Visible:=false;
  end;
 if vr then
  begin
   speedbutton10.Visible:=true;
   speedbutton9.Enabled:=false;
   speedbutton10click(self);
  end;
end;

procedure TPQMainF.SpeedButton10Click(Sender: TObject);
var a:byte;
begin
 panel15.Height:=1;
 panel15.Visible:=true;
 for a:=1 to 34 do
  begin
   panel15.Height:=a*2;
   panel15.Repaint;
  end;
 speedbutton9.Visible:=true;
 speedbutton12.Visible:=true;
 speedbutton13.Visible:=true;
 speedbutton10.Visible:=false;
 speedbutton11.Visible:=true;
 speedbutton14.Visible:=true;
end;

procedure TPQMainF.SpeedButton11Click(Sender: TObject);
begin
 speedbutton9.Visible:=false;
 speedbutton12.Visible:=false;
 speedbutton13.Visible:=false;
 speedbutton14.Visible:=false;
 panel15.Visible:=false;
 speedbutton10.Visible:=true;
 speedbutton11.Visible:=false;
end;

procedure writef(fn:string);
var tf:textfile;
    b:byte;
begin
 if fn=prn_ then assignPrn(tf) else assignfile(tf,fn);
 rewrite(tf);
 writeln(tf,'<<< Результаты Profession Quizzer >>>');
 writeln(tf);
 writeln(tf,'Тестируемый : '+uname);
 writeln(tf,'Название класса : '+clss);
 writeln(tf,'Номер класса : '+inttostr(t+7));
 writeln(tf,'Дата тестирования : '+cdate);
 writeln(tf);
 case t of
  1: begin
      writeln(tf,'Карта интересов 1 (-6..12)');
      writeln(tf);
      for b:=1 to 13 do
       writeln(tf,n8_[b]+' : '+inttostr(r8.ki[b]));
      writeln(tf);
      writeln(tf,'Тест ДДО (-8..8)');
      writeln(tf);
      for b:=1 to 5 do
       writeln(tf,nddo_[b]+' : '+inttostr(r8.ddo[b]));
      writeln(tf);
      writeln(tf,'Тест Голланда (-14..14)');
      writeln(tf);
      for b:=1 to 6 do
       writeln(tf,ngol_[b]+' : '+inttostr(r8.gol[b]));
      end;
  2: begin
      writeln(tf,'Карта интересов 2 (-6..12)');
      writeln(tf);
      for b:=1 to 25 do
       writeln(tf,n9_[b]+' : '+inttostr(r9.ki[b]));
      writeln(tf);
      writeln(tf,'Тест КОС (0..20)');
      writeln(tf,'Коммуникативные способности :'+inttostr(r9.k));
      writeln(tf,'Организаторские способности :'+inttostr(r9.o));
     end;
  3: begin
      writeln(tf,'Карта интересов 3 (-6..12)');
      writeln(tf);
      for b:=1 to 29 do
       writeln(tf,n10_[b]+' : '+inttostr(r10.ki[b]));
     end;
  4: begin
      writeln(tf,'50 функций профориентации (0..10)');
      writeln(tf);
      for b:=1 to 50 do
       writeln(tf,n11_[b]+' : '+inttostr(r11.f[b]));
     end;
  end;
 closefile(tf);
end;



procedure TPQMainF.SpeedButton14Click(Sender: TObject);
begin
 writef(tmpf_);
 memo4.Lines.LoadFromFile(tmpf_);
 panel16.Visible:=true;
 deletefile(tmpf_);
end;

procedure TPQMainF.Button2Click(Sender: TObject);
begin
 panel16.Visible:=false;
end;

procedure TPQMainF.SpeedButton12Click(Sender: TObject);
begin
 savedialog1.FileName:=uname;
 if not savedialog1.Execute then exit;
 writef(savedialog1.FileName);
end;

procedure TPQMainF.SpeedButton13Click(Sender: TObject);
//var a,h:byte;
begin
 writef(prn_);
 {writef(tmpf_);
 memo4.Lines.LoadFromFile(tmpf_);
 deletefile(tmpf_);
 with printer do
  begin
   Title:='PQ Doc';
   begindoc;
   Canvas.Font:=memo4.Font;
   h:=Canvas.TextHeight('X');
   for a:=0 to memo4.Lines.Count-1 do
    Canvas.TextOut(0,a*h,memo4.lines[a]);
   enddoc;
  end;}
end;

procedure TPQMainF.SpeedButton15Click(Sender: TObject);
var p,i:byte;
begin
 speedbutton16.Enabled:=false;
 speedbutton16.ShowHint:=false;
 speedbutton16.cursor:=crDefault;
 p:=gauge1.Progress;
 for i:=1 to 100 do
  begin
   beep;
   gauge1.Progress:=random(100);
   gauge1.repaint;
   if (i/10)=(i div 10) then
    begin
     image1.Picture.LoadFromFile('picts\'+inttostr(random(pn)+1)+'.bmp');
     image1.Repaint;
    end;
  end;
 gauge1.progress:=p;
 image1.Picture.LoadFromFile('picts\'+inttostr(ci)+'.bmp');
end;

end.
