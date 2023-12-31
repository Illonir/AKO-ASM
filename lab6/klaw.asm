; Program gwiazdki.asm
; Wy�wietlanie znak�w * w takt przerwa� zegarowych
; Uruchomienie w trybie rzeczywistym procesora x86
; lub na maszynie wirtualnej
; zako�czenie programu po naci�ni�ciu klawisza 'x'
; asemblacja (MASM 4.0): masm gwiazdki.asm,,,;
; konsolidacja (LINK 3.60): link gwiazdki.obj;
.386
rozkazy SEGMENT use16
ASSUME CS:rozkazy

; podprogram 'wyswietl_AL' wy�wietla zawarto�� rejestru AL
; w postaci liczby dziesi�tnej bez znaku
wyswietl_AL PROC
	; wy�wietlanie zawarto�ci rejestru AL na ekranie wg adresu
	; podanego w ES:BX
	; stosowany jest bezpo�redni zapis do pami�ci ekranu

	; przechowanie rejestr�w
	push ax
	push cx
	push dx
	mov cl, 10 ; dzielnik
	mov ah, 0 ; zerowanie starszej cz�ci dzielnej
	; dzielenie liczby w AX przez liczb� w CL, iloraz w AL,
	; reszta w AH (tu: dzielenie przez 10)
	div cl
	add ah, 30H ; zamiana na kod ASCII
	mov es:[bx+4], ah ; cyfra jedno�ci
	mov ah, 0
	div cl ; drugie dzielenie przez 10
	add ah, 30H ; zamiana na kod ASCII
	mov es:[bx+2], ah ; cyfra dziesi�tek
	add al, 30H ; zamiana na kod ASCII
	mov es:[bx+0], al ; cyfra setek
	; wpisanie kodu koloru (intensywny bia�y) do pami�ci ekranu
	mov al, 00001111B
	mov es:[bx+1],al
	mov es:[bx+3],al
	mov es:[bx+5],al
	; odtworzenie rejestr�w
	pop dx
	pop cx
	pop ax
	ret ; wyj�cie z podprogramu
wyswietl_AL ENDP

;============================================================
; procedura obs�ugi przerwania zegarowego
klaw PROC
	; odczytanie kodu ASCII naci�ni�tego klawisza (INT 16H, AH=0)
	; do rejestru AL
	; mov ah, 0
	; int 16H
	push ax
	push bx

	in al, 60H ; odczytanie kodu pozycji z klawiatury

	; wy�wietlenie kodu na ekranie
	mov bx, 0B800h	;adres pami�ci ekranu
	mov es, bx		; segment pami�ci ekranu
	mov bx, 320		; przesuni�cie do 2. wiersza
	call wyswietl_AL ; wy�wietlenie kodu na ekranie

	
	pop bx
	pop ax

	; skok do oryginalnej procedury obs�ugi przerwania zegarowego
	jmp dword PTR cs:wektor9

	; dane programu ze wzgl�du na specyfik� obs�ugi przerwa�
	; umieszczone s� w segmencie kodu
	licznik dw 160 ; wy�wietlanie pocz�wszy od 2. wiersza
	timer dw 0 ; licznik przerwa� zegarowych
	wektor9 dd ?
klaw ENDP


;============================================================
; program g��wny - instalacja i deinstalacja procedury
; obs�ugi przerwa�

; ustalenie strony nr 0 dla trybu tekstowego
zacznij:
mov al, 0
mov ah, 5
int 10

mov ax, 0
mov ds,ax ; zerowanie rejestru DS

; odczytanie zawarto�ci wektora nr 9 i zapisanie go
; w zmiennej 'wektor9' (wektor nr 9 zajmuje w pami�ci 4 bajty
; pocz�wszy od adresu fizycznego 9 * 4 = 36)
mov eax,ds:[36] ; adres fizyczny 0*16 + 36 = 36
mov cs:wektor9, eax

; wpisanie do wektora nr 8 adresu procedury 'obsluga_zegara'
mov ax, SEG klaw ; cz�� segmentowa adresu
mov bx, OFFSET klaw ; offset adresu
cli ; zablokowanie przerwa�

; zapisanie adresu procedury do wektora nr 9
mov ds:[36], bx ; OFFSET
mov ds:[38], ax ; cz. segmentowa
sti ;odblokowanie przerwa�

; oczekiwanie na naci�ni�cie klawisza 'x'
aktywne_oczekiwanie:
mov ah,1
int 16H

; funkcja INT 16H (AH=1) BIOSu ustawia ZF=1 je�li
; naci�ni�to jaki� klawisz
jz aktywne_oczekiwanie

; odczytanie kodu ASCII naci�ni�tego klawisza (INT 16H, AH=0)
; do rejestru AL
mov ah, 0
int 16H
cmp al, 'x' ; por�wnanie z kodem litery 'x'

jne aktywne_oczekiwanie ; skok, gdy inny znak

; deinstalacja procedury obs�ugi przerwania zegarowego

; odtworzenie oryginalnej zawarto�ci wektora nr 8
mov eax, cs:wektor9
cli
mov ds:[36], eax ; przes�anie warto�ci oryginalnej
				 ; do wektora 8 w tablicy wektor�w
				 ; przerwa�

sti

; zako�czenie programu
mov al, 0
mov ah, 4CH
int 21H

rozkazy ENDS

nasz_stos SEGMENT stack
	db 128 dup (?)
nasz_stos ENDS

END zacznij

