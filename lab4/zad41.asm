.686
.model flat

public _szukaj_max_4

.code

_szukaj_max_3 PROC
	push ebp	 ; zapisanie zawartości EBP na stosie
	mov ebp, esp ; kopiowanie zawartości ESP do EBP

	mov eax, [ebp+8] ; liczba x
	cmp eax, [ebp+12] ; porownanie liczb x i y
	jge x_wieksza ; skok, gdy x >= y

	; przypadek x < y
	mov eax, [ebp+12] ; liczba y
	cmp eax, [ebp+16] ; porownanie liczb y i z
	jge y_wieksza ; skok, gdy y >= z

	; przypadek y < z
	; zatem z jest liczbą najwiekszą
	wpisz_z: mov eax, [ebp+16] ; liczba z

	zakoncz:
	pop ebp
	ret

	x_wieksza:
	cmp eax, [ebp+16] ; porownanie x i z
	jge zakoncz ; skok, gdy x >= z
	jmp wpisz_z

	y_wieksza:
	mov eax, [ebp+12] ; liczba y
	jmp zakoncz
_szukaj_max_3 ENDP

_szukaj_max_4 PROC
	push ebp
	mov ebp, esp
	mov ecx, 0 ; licznik 

	mov eax, [ebp+4*ecx+8]
	pow:
	cmp eax, [ebp+4*ecx+12]
	jge cont
	mov eax, [ebp+4*ecx+12]
	cont:
	inc ecx
	cmp ecx, 3
	jb pow

	pop ebp
	ret

_szukaj_max_4 ENDP

END
