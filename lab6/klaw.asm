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

	in al, 60H ; odczytanie kodu pozycji z klawiatury

	; wyœwietlenie kodu na ekranie
	mov bx, 0B800h	;adres pamiêci ekranu
	mov es, bx		; segment pamiêci ekranu
	mov bx, 320		; przesuniêcie do 2. wiersza
	call wyswietl_AL ; wyœwietlenie kodu na ekranie

	
	pop bx
	pop ax

	; skok do oryginalnej procedury obs³ugi przerwania zegarowego
	jmp dword PTR cs:wektor9

	; dane programu ze wzglêdu na specyfikê obs³ugi przerwañ
	; umieszczone s¹ w segmencie kodu
	licznik dw 160 ; wyœwietlanie pocz¹wszy od 2. wiersza
	timer dw 0 ; licznik przerwañ zegarowych
	wektor9 dd ?
klaw ENDP


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

; odczytanie zawartoœci wektora nr 9 i zapisanie go
; w zmiennej 'wektor9' (wektor nr 9 zajmuje w pamiêci 4 bajty
; pocz¹wszy od adresu fizycznego 9 * 4 = 36)
mov eax,ds:[36] ; adres fizyczny 0*16 + 36 = 36
mov cs:wektor9, eax

; wpisanie do wektora nr 8 adresu procedury 'obsluga_zegara'
mov ax, SEG klaw ; czêœæ segmentowa adresu
mov bx, OFFSET klaw ; offset adresu
cli ; zablokowanie przerwañ

; zapisanie adresu procedury do wektora nr 9
mov ds:[36], bx ; OFFSET
mov ds:[38], ax ; cz. segmentowa
sti ;odblokowanie przerwañ

; oczekiwanie na naciœniêcie klawisza 'x'
aktywne_oczekiwanie:
mov ah,1
int 16H

; funkcja INT 16H (AH=1) BIOSu ustawia ZF=1 jeœli
; naciœniêto jakiœ klawisz
jz aktywne_oczekiwanie

; odczytanie kodu ASCII naciœniêtego klawisza (INT 16H, AH=0)
; do rejestru AL
mov ah, 0
int 16H
cmp al, 'x' ; porównanie z kodem litery 'x'

jne aktywne_oczekiwanie ; skok, gdy inny znak

; deinstalacja procedury obs³ugi przerwania zegarowego

; odtworzenie oryginalnej zawartoœci wektora nr 8
mov eax, cs:wektor9
cli
mov ds:[36], eax ; przes³anie wartoœci oryginalnej
				 ; do wektora 8 w tablicy wektorów
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

