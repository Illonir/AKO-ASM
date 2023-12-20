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


;============================================================
; procedura obs³ugi przerwania zegarowego
obsluga_zegara PROC
	; przechowanie u¿ywanych rejestrów
	push ax
	push bx
	push es

	mov ax, cs:timer
	inc ax

	cmp ax, 18
	push ax
	jb update_timer
	add sp,2
	push word ptr 0


	; wpisanie adresu pamiêci ekranu do rejestru ES - pamiêæ
	; ekranu dla trybu tekstowego zaczyna siê od adresu B8000H,
	; jednak do rejestru ES wpisujemy wartoœæ B800H,
	; bo w trakcie obliczenia adresu procesor ka¿dorazowo mno¿y
	; zawartoœæ rejestru ES przez 16
	mov ax, 0B800h ;adres pamiêci ekranu
	mov es, ax

	; zmienna 'licznik' zawiera adres bie¿¹cy w pamiêci ekranu
	mov bx, cs:licznik


	mov ax, 0
	ptl_rzad:

	add bx, ax

	; przes³anie do pamiêci ekranu kodu ASCII wyœwietlanego znaku
	; i kodu koloru: bia³y na czarnym tle (do nastêpnego bajtu)
	mov byte PTR es:[bx], '*' ; kod ASCII
	mov byte PTR es:[bx+1], 00011110B ; kolor


	sub bx, ax

	; zwiêkszenie o 2 adresu bie¿¹cego w pamiêci ekranu
	;add bx, 2

	add ax, 4
	cmp ax, 159
	jb ptl_rzad

	add bx, 160


	; sprawdzenie czy adres bie¿¹cy osi¹gn¹³ koniec pamiêci ekranu
	cmp bx, 4000

	jb wysw_dalej ; skok gdy nie koniec ekranu

	; wyzerowanie adresu bie¿¹cego, gdy ca³y ekran zapisany
	mov bx, 0

	;zapisanie adresu bie¿¹cego do zmiennej 'licznik'
	wysw_dalej:
	mov cs:licznik,bx

	update_timer:
	pop ax
	mov cs:timer,ax

	; odtworzenie rejestrów
	pop es
	pop bx
	pop ax

	; skok do oryginalnej procedury obs³ugi przerwania zegarowego
	jmp dword PTR cs:wektor8

	; dane programu ze wzglêdu na specyfikê obs³ugi przerwañ
	; umieszczone s¹ w segmencie kodu
	licznik dw 0 ; wyœwietlanie pocz¹wszy od 2. wiersza
	timer dw 0 ; licznik przerwañ zegarowych
	wektor8 dd ?
obsluga_zegara ENDP

klw PROC
	push ax

	in al, 60h
	cmp al, 28d
	jne reset
	mov al, 1
	mov byte ptr cs:zakoncz, al
	reset:
	mov ax, 0
	mov word ptr cs:licznik, ax

	pop ax

	jmp dword PTR cs:wektor9

	zakoncz db 0
	wektor9 dd ?
klw ENDP


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
mov ax, SEG obsluga_zegara ; czêœæ segmentowa adresu
mov bx, OFFSET obsluga_zegara ; offset adresu
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
mov ax, SEG klw ; czêœæ segmentowa adresu
mov bx, OFFSET klw ; offset adresu
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