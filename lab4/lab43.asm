.686
.model flat

	public _odejmij_jeden
.code

_odejmij_jeden PROC
	push ebp	; zapisanie zawartości EBP na stosie
	mov ebp,esp ; kopiowanie zawartości ESP do EBP
	push ebx	; przechowanie zawartości rejestru EBX

	; wpisanie do rejestru EBX adresu zmiennej zdefiniowanej
	; w kodzie w języku C, zawierającej adres zmiennej docelowej
	mov ebx, [ebp+8]
	mov edx, [ebx]	; wpisanie do EDX adresu zmiennej docelowej
	mov eax, [edx]	; wpisanie do EAX wartości zmiennej docelowej
	dec eax		; zmniejszenie wartości o 1
	mov [edx], eax ; odesłanie wyniku do zmiennej
	pop ebx
	pop ebp
	ret
_odejmij_jeden ENDP

END
