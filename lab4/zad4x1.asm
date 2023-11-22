.686
.model flat

public _to_i 
public _dwa

extern _malloc : PROC
extern _wcstoll : PROC

.data
	dziesiec dd 10
	zwei db 2

.code

_dwa PROC
	push ebp
	mov ebp, esp

	mov edi, [ebp+8]	; "liczba" 1
	mov esi, [ebp+12]	; "liczba" 2

	push 10
	push 0
	push edi
	call _wcstoll
	add esp, 12

	push eax
	push edx

	push 10
	push 0
	push esi
	call _wcstoll
	add esp, 12

	pop ecx
	pop ebx

	clc
	add eax, ebx
	;jnc dal
	adc edx, ecx
	dal:


	pop ebp
	ret
_dwa ENDP

_to_i PROC
	push ebp
	mov ebp, esp

	push ebx
	push edx
	push edi
	push esi

	mov eax, 0
	mov esi, 0
	mov edx, 0
	mov ecx, 0
	mov edi, 0

	mov ebx, [ebp+8]	; adres obszaru ze znakami
	pobieraj_znaki:
	mov cl, [ebx+esi]	; pobranie kolejnej cyfry w kodzie
						; ASCII
	inc esi				; zwiększenie indeksu
	cmp cl, 32d			; sprawdzenie czy naciśnięto Enter
	je spacja			; skok, gdy naciśnięto Enter
	cmp cl, 30h
	jb skip
	cmp cl, 39h
	ja skip
	sub cl, 30H			; zamiana kodu ASCII na wartość cyfry
	movzx ecx, cl		; przechowanie wartości cyfry w
						; rejestrze ECX
						; mnożenie wcześniej obliczonej wartości razy 10
	mul dword PTR dziesiec
	add eax, ecx		; dodanie ostatnio odczytanej cyfry
	jmp dalej			; skok na początek pętli

	spacja:
	inc edi				; w EDX ile liczb zapisano
	push eax
	mov eax, 0
	jmp dalej

	skip:
	jmp dalej

	dalej:
	cmp esi, 254
	jne pobieraj_znaki
	inc edi
	push eax

	mov eax, 4
	mul edi
	push edi
	push eax
	call _malloc
	add esp, 4
	pop edi

	mov edx, 0
	wpisz:
	pop ebx
	mov [eax+4*edx], ebx
	inc edx
	cmp edx, edi
	jne wpisz

	pop esi
	pop edi
	pop edx
	pop ebx

	pop ebp
	ret
_to_i ENDP
END
