
<%' DatePicker.asp version 1.1 Copyright (C) 2001 Denis Ryzhkov.
  ' Usage: <form> ... server.execute("DatePicker.asp") ... </form>

  language="VBScript" %>
<select name="dp_day"><%
  for i = 1 to 31
   response.write "<option"

   if day(now) = i then
    response.write " selected"
   end if

   response.write ">"&i
  next
                      %></select> 
<select name="dp_month"><%
  dim a
  a = array("Январь", "Февраль", "Март", "Апрель", "Май", "Июнь",_
   "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь")

  for i = 1 to 12
   response.write "<option"

   if month(now) = i then
    response.write " selected"
   end if

   response.write " value="""&i&""">"&a(i-1)
  next
                       %></select>
<select name="dp_year"><%
  for i = 2000 to 2010
   response.write "<option"

   if year(now) = i then
    response.write " selected"
   end if

   response.write ">"&i
  next
                      %></select>
<%' end of DatePicker.asp %>
