Uses vgahigr,graph,d_crt,pcxfile;
var a:byte;
    f:file;
begin
 grinit;
 pcxread(1,1,'dp.qz',0);
 assign(f,'source\applecon\pictures\qzr2_1.pcx');
 erase(f);
 pcxwrite(1,40,485,416,'source\applecon\pictures\qzr2_1.pcx',0);
 wait;
 closegraph;
end.