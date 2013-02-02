g13Init   macro                         ;ax,*es	открывает видеорежим 13h
          mov       ax, 0013h
          int       10h
          mov       ax, 0A000h
          mov       es, ax
          endm

g13Close  macro                         ;ax	закрывает видеорежим 13h
          mov       ax, 0003h
          int       10h
          endm

g13calcY  macro     y                   ;bx,*di	рассчитывает y и запоминает в di
          mov       di, y
          shl       di, 8
          mov       bx, di
          mov       di, y
          shl       di, 6
          add       di, bx
          endm

g13PutPix macro     x, c                ;al	рисует точку x,y цвета c
          add       di, x
          mov       al, c
          mov       byte ptr es:[di], al
          sub       di, x
          endm

g13HLine  macro     x1, x2, c           ;al,cx	рисует горизонтальную линию
          local     PutHPix
          dec       di
          mov       cx, x2
          sub       cx, x1
          inc       cx
          add       di, x1
          mov       al, c
putHPix:  inc       di
          mov       byte ptr es:[di], al
          loop      putHPix
          sub       di, x2
          endm

g13FHLine macro     y, x1, x2, c        ;al,cx,di без предварительного g13calcY
          g13CalcY  y
          g13HLine  x1, x2, c
          endm

g13VLine  macro     x, y1, y2, c        ;al,cx,di рисует вериткальную линию
          local     PutVPix
          g13CalcY  y1
          add       di, x
          sub       di, 140h
          mov       cx, y2
          sub       cx, y1
          inc       cx
          mov       al, c
putVPix:  add       di, 140h
          mov       byte ptr es:[di], al
          loop      putVPix
          endm
