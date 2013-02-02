	.model	tiny
	.code
	org	100h
main:   mov	ah,	2ah
	int	21h
	mov	cx,	2003
	mov	ah,	2bh
	int	21h
	ret
	end	main