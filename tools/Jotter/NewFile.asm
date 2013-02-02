stk		segment	stack 'stack'
		dw		100 dup (0)
stk		ends

data		segment	'data'
data		ends

code		segment	'code'
		assume	ds:data, cs:code
main:		mov		ax, data
		mov		ds, ax

		mov		ax, 4C00h
		int		21h
code		ends
		end		main