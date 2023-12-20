; Program gwiazdki.asm
; Wyœwietlanie znaków * w takt przerwañ zegarowych
; Uruchomienie w trybie rzeczywistym procesora x86
; lub na maszynie wirtualnej
; zakoñczenie programu po naciœniêciu klawisza 'x'
; asemblacja (MASM 4.0): masm gwiazdki.asm,,,;
; konsolidacja (LINK 3.60): link gwiazdki.obj;
.386
rozkazy SEGMENT use16
ASSUME CS:rozkazy

; podprogram 'wyswietl_AL' wyœwietla zawartoœæ rejestru AL
; w postaci liczby dziesiêtnej bez znaku
wyswietl_AL PROC
	; wyœwietlanie zawartoœci rejestru AL na ekranie wg adresu
	; podanego w ES:BX
	; stosowany jest bezpoœredni zapis do pamiêci ekranu

	; przechowanie rejestrów
	push ax
	push cx
	push dx
	mov cl, 10 ; dzielnik
	mov ah, 0 ; zerowanie starszej czêœci dzielnej
	; dzielenie liczby w AX przez liczbê w CL, iloraz w AL,
	; reszta w AH (tu: dzielenie przez 10)
	div cl
	add ah, 30H ; zamiana na kod ASCII
	mov es:[bx+4], ah ; cyfra jednoœci
	mov ah, 0
	div cl ; drugie dzielenie przez 10
	add ah, 30H ; zamiana na kod ASCII
	mov es:[bx+2], ah ; cyfra dziesi¹tek
	add al, 30H ; zamiana na kod ASCII
	mov es:[bx+0], al ; cyfra setek
	; wpisanie kodu koloru (intensywny bia³y) do pamiêci ekranu
	mov al, 00001111B
	mov es:[bx+1],al
	mov es:[bx+3],al
	mov es:[bx+5],al
	; odtworzenie rejestrów
	pop dx
	pop cx
	pop ax
	ret ; wyjœcie z podprogramu
wyswietl_AL ENDP

;============================================================
; procedura obs³ugi przerwania zegarowego
klaw PROC
	; odczytanie kodu ASCII naciœniêtego klawisza (INT 16H, AH=0)
	; do rejestru AL
	; mov ah, 0
	; int 16H
	push ax
	push bx


	
	;in al, 60H ; odczytanie kodu pozycji z klawiatury

	cmp cs:wczytano, byte ptr 0
	jne czy_wyjscie

	in al, 60h
	; konwersja do ASCII
	cmp al, 2d
	jb klaw_koniec
	cmp al, 53d
	ja klaw_koniec
	movzx bx, al
	mov al, byte ptr cs:dekoder[bx]
	cmp al, '.'
	je klaw_koniec
	mov bx, word ptr cs:licznik
	mov byte ptr cs:bufor[bx], al
	inc bx
	mov word ptr cs:licznik, bx

	cmp bx, 5
	jb klaw_koniec
	mov byte ptr cs:wczytano, 1


	jmp klaw_koniec

	czy_wyjscie:
	in al, 60h
	cmp byte ptr cs:key_down_code, al
	jne reset_key_down

	mov bl, byte ptr cs:key_down_timer
	inc bl
	mov byte ptr cs:key_down_timer, bl
	cmp bl, 90
	jb klaw_koniec
	mov byte ptr cs:zakoncz, 1
	jmp klaw_koniec

	reset_key_down:
	mov byte ptr cs:key_down_timer, 1
	mov byte ptr cs:key_down_code, al


	klaw_koniec:
	pop bx
	pop ax

	; skok do oryginalnej procedury obs³ugi przerwania zegarowego
	jmp dword PTR cs:wektor9

	dekoder db "..1234567890..qwertyuiop....asdfghjkl.....zxcvbnm"
	key_down_timer db 0
	key_down_code db 0
	key_down db 0
	zakoncz db 0
	wektor9 dd ?
klaw ENDP

tekst PROC
	push ax
	push bx
	push cx
	push es

	cmp byte ptr cs:wczytano, 0
	jne wyswietl

	mov al, byte ptr cs:timer_wczytania
	inc al
	mov byte ptr cs:timer_wczytania, al
	cmp al, 90
	jb tekst_koniec
	mov byte ptr cs:wczytano, 1
	jmp tekst_koniec

	wyswietl:

	mov ax, 0B800h ;adres pamiêci ekranu
	mov es, ax

	mov bx, 10 ;pierwsza pozycja ekranu
	mov cx, 0
	ptl_wyswietl:
	xchg cx, bx
	mov al, byte ptr cs:[bufor + bx]
	xchg cx, bx
	mov byte ptr es:[bx], al
	mov byte ptr es:[bx+1], 00001111B
	add bx, 2
	inc cx
	cmp cx, 5
	jb ptl_wyswietl

	tekst_koniec:
	pop es
	pop cx
	pop bx
	pop ax

	jmp dword ptr cs:wektor8

	licznik dw 0
	bufor db 'abcde'
	timer_wczytania db 0
	wczytano db 0
	wektor8 dd ?
tekst ENDP

;============================================================
; program g³ówny - instalacja i deinstalacja procedury
; obs³ugi przerwañ

; ustalenie strony nr 0 dla trybu tekstowego
zacznij:
mov al, 0
mov ah, 5
int 10

mov ax, 0
mov ds,ax ; zerowanie rejestru DS

; odczytanie zawartoœci wektora nr 8 i zapisanie go
; w zmiennej 'wektor8' (wektor nr 8 zajmuje w pamiêci 4 bajty
; pocz¹wszy od adresu fizycznego 8 * 4 = 32)
mov eax,ds:[32] ; adres fizyczny 0*16 + 32 = 32
mov cs:wektor8, eax

; wpisanie do wektora nr 8 adresu procedury 'obsluga_zegara'
mov ax, SEG tekst ; czêœæ segmentowa adresu
mov bx, OFFSET tekst ; offset adresu
cli ; zablokowanie przerwañ

; zapisanie adresu procedury do wektora nr 8
mov ds:[32], bx ; OFFSET
mov ds:[34], ax ; cz. segmentowa
sti ;odblokowanie przerwañ

mov ax, 0
mov ds,ax ; zerowanie rejestru DS

; odczytanie zawartoœci wektora nr 8 i zapisanie go
; w zmiennej 'wektor8' (wektor nr 8 zajmuje w pamiêci 4 bajty
; pocz¹wszy od adresu fizycznego 8 * 4 = 32)
mov eax,ds:[36] ; adres fizyczny 0*16 + 32 = 32
mov cs:wektor9, eax

; wpisanie do wektora nr 9 adresu procedury 'obsluga_zegara'
mov ax, SEG klaw ; czêœæ segmentowa adresu
mov bx, OFFSET klaw ; offset adresu
cli ; zablokowanie przerwañ

; zapisanie adresu procedury do wektora nr 9
mov ds:[36], bx ; OFFSET
mov ds:[38], ax ; cz. segmentowa
sti ;odblokowanie przerwañ


; oczekiwanie na naciœniêcie klawisza ENTER
aktywne_oczekiwanie:
cmp cs:zakoncz, byte ptr 1
jne aktywne_oczekiwanie

; deinstalacja procedury obs³ugi przerwania zegarowego

; odtworzenie oryginalnej zawartoœci wektora nr 8
mov eax, cs:wektor8
cli
mov ds:[32], eax ; przes³anie wartoœci oryginalnej
				 ; do wektora 8 w tablicy wektorów
				 ; przerwañ

sti

; odtworzenie oryginalnej zawartoœci wektora nr 9
mov eax, cs:wektor9
cli
mov ds:[36], eax ; przes³anie wartoœci oryginalnej
				 ; do wektora 9 w tablicy wektorów
				 ; przerwañ

sti

; zakoñczenie programu
mov al, 0
mov ah, 4CH
int 21H

rozkazy ENDS

nasz_stos SEGMENT stack
	db 128 dup (?)
nasz_stos ENDS

END zacznij

