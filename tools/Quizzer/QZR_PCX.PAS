Uses vgahigr,graph,d_crt,pcxfile;
var a:byte;
    f:file;
begin
 if paramcount<>2 then exit;
 grinit;
 pcxread(1,1,paramstr(1),0);
 assign(f,paramstr(2));
 rewrite(f);
 close(f);
 erase(f);
 pcxwrite(1,40,485,416,paramstr(2),0);
 wait;
 closegraph;
 writeln('Converted successfully !');
end.