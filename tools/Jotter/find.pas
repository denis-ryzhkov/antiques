unit find;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, iniFiles;

type
  TFindForm = class(TForm)
    findCB: TComboBox;
    caseChB: TCheckBox;
    wholeChB: TCheckBox;
    replChB: TCheckBox;
    replCB: TComboBox;
    okB: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure okBClick(Sender: TObject);
    procedure findCBKeyPress(Sender: TObject; var Key: Char);
    procedure writeTunes(inif:tIniFile);
    procedure readTunes(inif:tIniFile);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
 ft_='FindTunes';
 cs_='CaseSensitive';
 wwo_='WholeWordsOnly';
 dr_='DoReplace';
 fi_='FindItem';
 ri_='ReplaceItem';

var
  FindForm: TFindForm;

implementation

{$R *.DFM}

procedure TFindForm.writeTunes(inif:tIniFile);
var i:integer;
begin
 inif.EraseSection(ft_);
 inif.WriteBool(ft_,cs_,caseChB.Checked);
 inif.WriteBool(ft_,wwo_,wholeChB.Checked);
 inif.WriteBool(ft_,dr_,replChB.Checked);
 for i:=1 to 7 do
  begin
   inif.WriteString(ft_,fi_+inttostr(i),findCB.Items.Strings[i-1]);
   inif.WriteString(ft_,ri_+inttostr(i),replCB.Items.Strings[i-1]);
  end;
end;

procedure TFindForm.readTunes(inif:tIniFile);
var i:integer;
begin
 caseChB.Checked:=inif.readBool(ft_,cs_,false);
 wholeChB.Checked:=inif.readBool(ft_,wwo_,false);
 replChB.Checked:=inif.readBool(ft_,dr_,replChB.Checked);
 for i:=1 to 7 do
  begin
   findCB.Items.Add(inif.ReadString(ft_,fi_+inttostr(i),''));
   replCB.Items.Add(inif.ReadString(ft_,ri_+inttostr(i),''));
  end;
end;

procedure TFindForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=vk_Escape then
  modalresult:=2;
end;

procedure TFindForm.okBClick(Sender: TObject);
var i,oldi:integer;
begin
 oldi:=-1;
 for i:=1 to 7 do
  if findCB.Text=findCb.Items.Strings[i-1] then
   oldi:=i;
 if oldi=-1 then
  begin
   findCB.Items.Insert(0,findCB.Text);
   findCB.Items.Delete(7);
  end
 else
  findCB.Items.Move(oldi-1,0); 

 oldi:=-1;
 for i:=1 to 7 do
  if replCB.Text=replCb.Items.Strings[i-1] then
   oldi:=i;
 if oldi=-1 then
  begin
   replCB.Items.Insert(0,replCB.Text);
   replCB.Items.Delete(7);
  end
 else
  replCB.Items.Move(oldi-1,0);

 modalresult:=1;
end;

procedure TFindForm.findCBKeyPress(Sender: TObject; var Key: Char);
begin
 if key=#27 then
  key:=#0;
end;

procedure TFindForm.FormShow(Sender: TObject);
begin
 findCB.ItemIndex:=0;
 replCB.ItemIndex:=0;
 activeControl:=findCB;
end;

end.
