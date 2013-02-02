var f:file of byte;
    b:byte;
begin
 writeln(#13#10'Proffesional Minesweeper 1.2 Crack 1.0 by //Slasher//.');
 {$i-}
 assign(f,'profmine.exe');
 reset(f);
 {#i+}
 if ioresult=0 then
  begin
   seek(f,19613);
   b:=3;
   write(f,b);

   seek(f,19753);
   b:=117;
   write(f,b);
   close(f);
   writeln('profmine.exe was successfully patched.');
  end
 else
  writeln('profmine.exe file not found in current folder. Aborting.');
end.