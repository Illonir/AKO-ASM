.686
.XMM
.model flat

public _srednia_harm
public _nowy_exp
public _suma_rownolegla16x8bit
public _int2float

.data
	cztery1 dd 4 dup(1.0)
	ALIGN 16
	tabl_A dd 1.0, 2.0, 3.0, 4.0
	tabl_B dd 2.0, 3.0, 4.0, 5.0
	liczba db 1
		   db 15 dup(?)
	tabl_C dd 3.0, 4.0, 5.0, 6.0

.code

_srednia_harm PROC
	push ebp
	mov ebp, esp

	; [ebp+8] - adres tablicy
	; [ebp+12] - ilosc elementow tablicy
	push esi
	mov esi, [ebp+8]	; adres tablicy
	finit

	mov ecx, 0			; zerowanie licznika
	fldz				; zerowanie sumy
	ptl:
	fld1				; ładowanie 1 na stos koprocesora
	fld dword ptr [esi+4*ecx]	; ładowanie elementu tablicy na stos koprocesora	
	fdivp				; dzielenie 1 przez element tablicy
	faddp				; dodawanie wyniku do sumy
	inc ecx				; inkrementacja licznika
	cmp ecx, [ebp+12]	; sprawdzenie czy licznik jest mniejszy od ilosci elementow tablicy
	jl ptl				; jesli tak to powrot do ptl
	
	fild dword ptr [ebp+12]		; ładowanie ilosci elementow tablicy na stos koprocesora
	fxch st(1)			; zamiana miejscami sumy i ilosci elementow tablicy
	fdivp				; dzielenie sumy przez ilosc elementow tablicy

	pop esi
	pop ebp
	ret
_srednia_harm ENDP

_nowy_exp PROC
	push ebp
	mov ebp, esp

	finit	
	mov ecx, 1
	mov eax, 1
	fldz
	ptl:
	mul ecx
	
	

	; obliczanie odpowiedniej potęgi x
	fld dword ptr [ebp+8]	
	mov edx, 0
	potega_x:
	cmp edx, ecx
	jae koniec_pot
	fmul dword ptr [ebp+8]
	inc edx
	jmp potega_x
	koniec_pot:

	; ładowanie silni na stos koprocesora
	; za pośrednictwem zwykłego stosu
	push eax
	fild dword ptr [esp]
	add esp, 4

	; dzielenie potęgi x przez silnię
	; wynik na szczycie stosu
	fdivp	

	; dodawanie wyniku do już obliczonej sumy
	; wynik na szczycie stosu
	faddp

	inc ecx
	cmp ecx, 20
	jna ptl

	pop ebp
	ret
_nowy_exp ENDP

_suma_rownolegla16x8bit PROC
	push ebp
	mov ebp, esp
	push esi
	push edi

	mov esi, [ebp+8]
	mov edi, [ebp+12]
	

	movdqu xmm5, [esi]
	movdqu xmm6, [edi]

	paddsb xmm5, xmm6

	movdqu [esi], xmm5

	pop edi
	pop esi
	pop ebp
	ret
_suma_rownolegla16x8bit ENDP

_int2float PROC
	push ebp
	mov ebp, esp
	push esi
	push edi

	mov esi, [ebp+8]
	mov edi, [ebp+12]

	cvtpi2ps xmm5, qword PTR [esi]
	movdqu [edi], xmm5

	pop edi
	pop esi
	pop ebp
	ret
_int2float ENDP

_pm_jeden PROC
	push ebp
	mov ebp, esp
	push esi

	mov esi, [ebp+8]
	movups xmm5, [esi]
	movups xmm6, [cztery1]

	addsubps xmm5, xmm6

	movups [esi], xmm5

	pop esi
	pop ebp
	ret
_pm_jeden ENDP

_dodawanie_SSE PROC
	push ebp
	mov ebp, esp

	mov eax, [ebp+8]
	movaps xmm2, tabl_A
	movaps xmm3, tabl_B
	movaps xmm4, tabl_C
	addps xmm2, xmm3
	addps xmm2, xmm4
	movups [eax], xmm2

	pop ebp
	ret
_dodawanie_SSE ENDP

END
