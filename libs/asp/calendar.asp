<%' calendar.asp version 1.0 Copyright (C) 2001 Denis Ryzhkov. %>

<table>
 <tr>
<%
 iMonth = 2 ' number of month
 iFirstWeekDay = weekday( CDate( "1/"&iMonth&"/2001" ), vbMonday)
 iLastDay = array( 31,28,31,30,31,30,31,30,31,30,31,30 )( iMonth-1 )
 for iI = 1 to iFirstWeekDay-1
%>
  <td>&nbsp;</td>
<%
 next
 iCurWeekDay = iFirstWeekDay
 for iI = 1 to iLastDay
%>
  <td><%=iI%></td>
<%
 iCurWeekDay = iCurWeekDay + 1
 if iCurWeekDay = 8 then
%>
 </tr>
 <tr>
<%
  iCurWeekDay = 1
 end if
 next
%>
 </tr>
</table>

<%' end of calendar.asp %>