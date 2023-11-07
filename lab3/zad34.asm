.686
.model flat

;includelib libcmt.lib

extern __read : PROC
extern __write : PROC
extern _ExitProcess@4 : PROC

public _main

.data
	; wczytywanie liczby dziesiętnej z klawiatury – po
	; wprowadzeniu cyfr należy nacisnąć klawisz Enter
	; liczba po konwersji na postać binarną zostaje wpisana
	; do rejestru EAX
	; deklaracja tablicy do przechowywania wprowadzanych cyfr
	; (w obszarze danych)
	;obszar db 12 dup (?)
	dziesiec dd 10 ; mnożnik

	;znaki db 12 dup (?)
	dekoder db '0123456789ABCDEF'

.code

wyswietl_EAX PROC
	pusha
	mov esi, 10 ; indeks w tablicy 'znaki'
	mov ebx, 10 ; dzielnik równy 10
	sub esp, 12
	mov edi, esp

	konwersja:
	mov edx, 0 ; zerowanie starszej części dzielnej
	div ebx ; dzielenie przez 10, reszta w EDX,
	; iloraz w EAX
	add dl, 30H ; zamiana reszty z dzielenia na kod
	; ASCII
	mov [edi] [esi], dl; zapisanie cyfry w kodzie ASCII
	dec esi ; zmniejszenie indeksu
	cmp eax, 0 ; sprawdzenie czy iloraz = 0
	jne konwersja ; skok, gdy iloraz niezerowy

	; wypełnienie pozostałych bajtów spacjami i wpisanie
	; znaków nowego wiersza
	wypeln:
	or esi, esi
	jz wyswietl ; skok, gdy ESI = 0
	mov byte PTR [edi] [esi], 20H ; kod spacji
	dec esi ; zmniejszenie indeksu
	jmp wypeln

	wyswietl:
	mov byte PTR [edi] [0], 0AH ; kod nowego wiersza
	mov byte PTR [edi] [11], 0AH ; kod nowego wiersza
	; wyświetlenie cyfr na ekranie
	push dword PTR 12 ; liczba wyświetlanych znaków
	push dword PTR edi ; adres wyśw. obszaru
	push dword PTR 1; numer urządzenia (ekran ma numer 1)
	call __write ; wyświetlenie liczby na ekranie

	add esp, 12 ; usunięcie parametrów ze stosu
	add esp, 12

	popa
	ret
wyswietl_EAX ENDP

wczytaj_EAX PROC
	push ebx
	push ecx
	sub esp, 12
	mov edi, esp

	;max ilość znaków wczytywanej liczby
	push dword PTR 12
	push dword PTR [esi] ; adres obszaru pamięci
	push dword PTR 0; numer urządzenia (0 dla klawiatury)
	call __read ; odczytywanie znaków z klawiatury
	; (dwa znaki podkreślenia przed read)
	add esp, 12 ; usunięcie parametrów ze stosu
	; bieżąca wartość przekształcanej liczby przechowywana jest
	; w rejestrze EAX; przyjmujemy 0 jako wartość początkową
	mov eax, 0
	mov ebx, [esi] ; adres obszaru ze znakami
	pobieraj_znaki:
	mov cl, [ebx] ; pobranie kolejnej cyfry w kodzie
	; ASCII
	inc ebx ; zwiększenie indeksu
	cmp cl,10 ; sprawdzenie czy naciśnięto Enter
	je byl_enter ; skok, gdy naciśnięto Enter
	sub cl, 30H ; zamiana kodu ASCII na wartość cyfry
	movzx ecx, cl ; przechowanie wartości cyfry w
	; rejestrze ECX
	; mnożenie wcześniej obliczonej wartości razy 10
	mul dword PTR dziesiec
	add eax, ecx ; dodanie ostatnio odczytanej cyfry
	jmp pobieraj_znaki ; skok na początek pętli
	byl_enter:
	; wartość binarna wprowadzonej liczby znajduje się teraz w
	;rejestrze EAX
	add esp, 12
	pop ecx
	pop ebx
	ret
wczytaj_EAX ENDP

wyswietl_EAX_hex PROC
	; wyświetlanie zawartości rejestru EAX
	; w postaci liczby szesnastkowej
	pusha ; przechowanie rejestrów
	; rezerwacja 12 bajtów na stosie (poprzez zmniejszenie
	; rejestru ESP) przeznaczonych na tymczasowe przechowanie
	; cyfr szesnastkowych wyświetlanej liczby
	sub esp, 12
	mov edi, esp ; adres zarezerwowanego obszaru
	; pamięci
	; przygotowanie konwersji
	mov ecx, 8 ; liczba obiegów pętli konwersji
	mov esi, 1 ; indeks początkowy używany przy
	; zapisie cyfr

	; pętla konwersji
	ptl3hex:
	; przesunięcie cykliczne (obrót) rejestru EAX o 4 bity w lewo
	; w szczególności, w pierwszym obiegu pętli bity nr 31 - 28
	; rejestru EAX zostaną przesunięte na pozycje 3 - 0
	rol eax, 4
	; wyodrębnienie 4 najmłodszych bitów i odczytanie z tablicy
	; 'dekoder' odpowiadającej im cyfry w zapisie szesnastkowym
	mov ebx, eax ; kopiowanie EAX do EBX
	and ebx, 0000000FH ; zerowanie bitów 31 - 4 rej.EBX
	mov dl, dekoder[ebx] ; pobranie cyfry z tablicy
	; przesłanie cyfry do obszaru roboczego
	mov [edi][esi], dl
	inc esi ;inkrementacja modyfikatora
	loop ptl3hex ; sterowanie pętlą
	; wpisanie znaku nowego wiersza przed i po cyfrach

	mov esi, 1
	zera:
	mov ecx, 0
	mov cl, byte PTR [edi][esi]
	cmp byte PTR [edi][esi], "0"
	jne dalej
	mov byte PTR [edi][esi], " "
	inc esi
	jmp zera
	dalej:

	mov byte PTR [edi][0], 10
	mov byte PTR [edi][9], 10
	; wyświetlenie przygotowanych cyfr
	push 10 ; 8 cyfr + 2 znaki nowego wiersza
	push edi ; adres obszaru roboczego
	push 1 ; nr urządzenia (tu: ekran)
	call __write ; wyświetlenie
	; usunięcie ze stosu 24 bajtów, w tym 12 bajtów zapisanych
	; przez 3 rozkazy push przed rozkazem call
	; i 12 bajtów zarezerwowanych na początku podprogramu
	add esp, 24
	popa ; odtworzenie rejestrów
	ret ; powrót z podprogramu
wyswietl_EAX_hex ENDP


_main PROC
	mov eax, 1234d
	;call wyswietl_EAX_hex
	call wczytaj_EAX
	call wyswietl_EAX_hex
	push 0
	call _ExitProcess@4
_main ENDP
END
