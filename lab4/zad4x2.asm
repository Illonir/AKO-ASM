.686
.model flat

public _szukaj_znaku
public _wyszukaj_znak
public _tablica_np
public _np

extern _malloc : PROC

.code

_szukaj_znaku PROC
	push ebp
	mov ebp, esp

	push ebx
	push esi
	push edx
		
	mov ecx, 0			; indeks obecnego miejsca w tablicy
	mov ebx, [ebp+8]	; adres tablicy
	mov esi, 0			; pierwsze wystąpienie znaku
	mov eax, [ebp+16]	
	mov edx, [eax]		; szukany znak
	mov eax, 0			; licznik znalezionych znakow

	petla:
	cmp dx, [ebx+2*ecx]
	jne dalej
	inc eax
	or esi, esi
	jnz dalej
	lea esi, [ebx+2*ecx]
	dalej:
	inc ecx
	cmp ecx, [ebp+12]
	jl petla

	mov [ebp+16], esi

	pop edx
	pop esi
	pop ebx
	pop ebp
	ret
_szukaj_znaku ENDP

_wyszukaj_znak PROC
	push ebp
	mov ebp, esp ; prolog

	push ebx
	push esi
	push edi

	mov ebx,[ebp+8] ; adres pierwszego znaku

	mov edi,[ebp+12] ; adres na znak
	mov cx,[edi] ; znak
	mov edx,0 ; tu wpiszemy adres pierwszego wystapienia znaku
	mov eax,0 ; tu zapiszemy ilosc wystapien znaku

	ptl:
	mov si, [ebx] ; przenosimy kolejny znak
	cmp si,cx ; porownujemy 
	jne dalej

	inc eax ; zwiekszamy ilosc wystapien
	cmp edx,0 ; jesli nie przypisano adresu to pierwsze wystapienie
	jne dalej
	mov edx,ebx ; przypisujemy adres
	mov [edi],edx

	dalej:
	add ebx,2 ; zwiekszamy indeks
	cmp si,0
	jne ptl



	pop edi
	pop esi
	pop ebx

	pop ebp
	ret
_wyszukaj_znak ENDP

_tablica_np PROC
	push ebp
	mov ebp, esp

	push esi
	push ebx
	push edx
	push edi
	
	mov ecx, 0	; licznik elementów np
	mov ebx, [ebp+8]	; adres tablicy
	mov esi, 0	; licznik elementów tablicy
	mov eax, [ebp+12]	; adres N
	mov edx, [eax]	; N - rozmiar tablicy
	mov eax, 0	; adres nieprzydzelionej tablicy

	szukaj_np:
	mov eax, [ebx+4*esi]
	and al, 00000001b
	cmp al, 0
	je szukaj_dalej
	inc ecx
	szukaj_dalej:
	inc esi
	cmp esi, edx
	jl szukaj_np

	mov eax, [ebp+12]
	sub edx, ecx		; liczba parzsystych elementów
	mov [ebp+12], edx	; czy działa ???
	add edx, ecx		; w edx znowu N

	mov eax, ecx
	mov edi, ecx
	mov cl, 4
	mul cl
	mov ecx, edi
	mov ecx, eax	; ecx = 4*ecx
	mov eax, 0		; żeby sprawdzić czy działa
	push ecx		; arg do malloaca
	call _malloc	; teoretycznie w eax jest adres nowej tablicy
	add esp, 4		; czyszczenie stosu

	mov ecx, 0	; znak
	mov edi, 0	; limit nowej tablicy
	mov esi, 0
	wpisz_np:
	mov ecx, [ebx+4*esi]
	and cl, 00000001b
	cmp cl, 0
	je pisz_dalej
	mov [eax+4*edi], ecx
	inc edi
	pisz_dalej:
	inc esi
	cmp esi, edx
	jl wpisz_np


	pop edi
	pop edx
	pop ebx
	pop esi
	pop ebp
	ret
_tablica_np ENDP

_np PROC
	push ebp
	mov ebp, esp

	push ebx
	push edx
	push esi
	push edi

	mov eax, 0
	mov esi, 0
	mov ebx, [ebp+8]
	mov ecx, [ebp+12]
	mov ecx, [ecx]			; w ecx jest N
	nszukaj:
	mov edx, [ebx+4*esi]
	bt edx, 0
	jnc nszukaj_dalej
	inc eax
	push edx
	nszukaj_dalej:
	inc esi
	cmp esi, ecx
	jl nszukaj

	sub ecx, eax
	mov ebx, [ebp+12]
	mov [ebx], ecx
	add ecx, eax
	mov ebx, eax	; w ebx jest liczba nieparzystych elementów

	mov cl, 4
	mul cl


	push eax
	call _malloc
	add esp, 4

	mov edi, 0
	nwpisz:
	pop ecx
	mov [eax+4*edi], ecx
	inc edi
	cmp edi, ebx
	jl nwpisz


	pop edi
pop esi
	pop edx
pop ebx
	pop ebp
	ret
_np ENDP

END
