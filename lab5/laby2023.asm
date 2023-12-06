.686
.XMM
.model flat

public _single_neuron
public _progowanie_sredniej_kroczacej
public _uint48float

extern _malloc : PROC

.data

.code

_exp PROC
	; na start mamy w ST(0) wartość x

	fldl2e				; log 2 e
	fmulp st(1), st(0)  ; obliczenie x * log 2 e

	; kopiowanie obliczonej wartości do ST(1)
	fst st(1)

	; zaokrąglenie do wartości całkowitej
	frndint

	fsub st(1), st(0)	; obliczenie części ułamkowej
	fxch				; zamiana ST(0) i ST(1)

	; po zamianie: ST(0) - część ułamkowa, ST(1) - część całkowita
	; obliczenie wartości funkcji wykładniczej dla części
	; ułamkowej wykładnika
	f2xm1
	fld1				; liczba 1
	faddp st(1), st(0)  ; dodanie 1 do wyniku

	; mnożenie przez 2^(część całkowita)
	fscale
	; przesłanie wyniku do ST(1) i usunięcie wartości
	; z wierzchołka stosu

	fstp st(1)
	; w rezultacie wynik znajduje się w ST(0)

	ret
_exp ENDP

_single_neuron PROC
	push ebp
	mov ebp, esp

	finit
	fldz
	mov ecx, 0					; iterator
	mov eax, [ebp+8]			; wskaznik na tablice doubli
	mov edx, [ebp+12]			; wskaznik na tablice wag (float)

	suma_waz:
	cmp ecx, [ebp+16]
	jae suma_waz_end
	fld qword ptr [eax+8*ecx]	; wczytanie xi
	fld dword ptr [edx+4*ecx]	; wczytanie wi
	fmulp						; xi*wi
	faddp						; suma w st(0)
	inc ecx
	jmp suma_waz
	suma_waz_end:

	push dword ptr 4			; rezerwowanie pamieci na 1 floata wyniku
	call _malloc				; w eax jest wskaznik na zaalokowana pamiec
	add esp, 4

	fldz						; porownanie sumy z 0
	fxch 
	fcomi st(0), st(1)
	jb ustaw_0
	jae koniec

	ustaw_0:					; wpisujemy 0 na szczyt stosu koprocesora
	fstp st(0)					; i usuwamy sume
	fldz						; zeby posprzatac po sobie (niepotrzebne)
	jmp koniec

	koniec:
	fstp dword ptr [eax]		; zapisanie wyniku do pamieci
	
	pop ebp
	ret
_single_neuron ENDP

_progowanie_sredniej_kroczacej PROC
	push ebp
	mov ebp, esp
	push ebx
	push esi
	push edi

	finit

	mov eax, [ebp+12]
	mov ebx, [ebp+16]
	div bx						; eax = k / m
	mov ecx, eax				; ecx = k / m	

	mov ebx, [ebp+12]
	mov eax, [ebp+16]
	sub ebx, eax
	mov eax, 0
	mov esi, [ebp+8]			; wskaznik na tablice 


	push dword ptr 5
	push dword ptr 3
	fild dword ptr [esp]
	add esp, 4
	fild dword ptr [esp]
	add esp, 4
	fdivp st(1), st(0)			; st(0) = 3/5
	fldz
	;fldz

	; zewnetrzna petla tutaj
	zew_ptl:
	cmp eax, ebx				; eax = indeks pierwszego elementu sumy
								; ebx = k - m
	fldz
	jae zew_ptl_end
	mov edx, 0					; ile liczb zsumowano = 0
	mov edi, eax				; index = start
	suma:
	cmp edi, [ebp+12]
	jae suma_end
	fld dword ptr [esi+4*edi]	; wczytanie xi
	faddp						; aktualna suma w st(0)	
	inc edx						; zwiekszenie licznika zsumowanych liczb
	add edi, ecx				; wyznaczeniue kolejnej liczby do zsumowania
	jmp suma
	suma_end:

	push edx
	fild dword ptr [esp]
	add esp, 4
	fdivp st(1), st(0)			; obliczenie aktualnej sredniej	( srednia = suma / ile_liczb )

	; progowanie roznicy srednich
	fld st(0)					; skopiowanie aktualnej sredniej na szczyt stosu
	fsub st(0), st(2)			; roznica = aktualna srednia - poprzednia_srednia
	fabs						; roznica = |roznica|	
	fcomi st(0), st(3)			; porownanie roznicy z progiem (0.6) w st(3)
	jb ustaw_srednia
	fstp st(0)					; usuniecie roznicy ze stosu
	fxch st(1)					; zamiana sredniej z poprzednia_srednia
	fstp st(0)					; usuniecie poprzedniej sredniej ze stosu


	inc eax
	jmp zew_ptl
	zew_ptl_end:

	ustaw_srednia:
	fstp st(0)					; usuniecie roznicy ze stosu
	fxch st(2)					; zamiana sredniej progiem
	fstp st(0)					; usuniecie progu
	fstp st(0)					; usuniecie poprzedniej sredniej ze stosu


	pop edi
	pop esi
	pop ebx

	pop ebp
	ret
_progowanie_sredniej_kroczacej ENDP

_uint48float PROC
	push ebp
	mov ebp, esp
	push ebx
	push esi
	push edi
	finit

	mov eax, [ebp+8]
	mov edx, [ebp+12]
	and edx, 0000ffffh

	xor ebx, ebx
	xor ecx, ecx

ptl:
	clc
	rcr edx, 1
	rcr eax, 1
	rcr ecx, 1
	inc ebx
	cmp eax, 1
	jne ptl
	cmp edx, 0
	jne ptl				; w ebx mamy liczbe przesuniec, w ecx mantyse
	add ebx, 127-16		; dodaje bias uwzgledniajac format stalo przecinkowy (stad - 16)
	shl ebx, 23			; przesuwam wykladnik o 23 miejsca w lewo zeby byl zgodnie z formatem float
	xor eax, eax		; w eax bede mial wynik
	shr ecx, 32-23		; przesuwam mantyse o 9 miejsc w prawo zeby byl zgodnie z formatem float
	or eax, ebx			
	or eax, ecx			; nakladam wykladnik z mantysa
	push eax
	fld dword ptr [esp]
	add esp, 4			; wrzucam wynika na koprocesor
	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
_uint48float ENDP


_neuron2 PROC
push ebp
	mov ebp, esp

	finit
	fldz
	mov ecx, 0					; iterator
	mov eax, [ebp+8]			; wskaznik na tablice doubli
	mov edx, [ebp+12]			; wskaznik na tablice wag (float)

	suma_waz:
	cmp ecx, [ebp+16]
	jae suma_waz_end
	fld qword ptr [eax+8*ecx]	; wczytanie xi
	fld dword ptr [edx+4*ecx]	; wczytanie wi
	fmulp						; xi*wi
	faddp						; suma w st(0)
	inc ecx
	jmp suma_waz
	suma_waz_end:

	; niepotrzebne
	;push dword ptr 4			; rezerwowanie pamieci na 1 floata wyniku
	;call _malloc				; w eax jest wskaznik na zaalokowana pamiec
	;add esp, 4

	; funkcja aktywacji
	call _exp
	fld1
	fadd st(0), st(1)
	fdivp

	; niepotrzebne
	;koniec:
	;fstp dword ptr [eax]		; zapisanie wyniku do pamieci
	
	pop ebp
	ret
_neuron2 ENDP



END
