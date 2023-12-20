.386
rozkazy SEGMENT use16
    ASSUME cs:rozkazy

obsluga_klawiatury PROC
    push ax
    push cx
    push dx
    in al, 60h
    cmp al, 19
    je wcisniete
    cmp al, 147
    je zwolnione
    jmp koniec_klawiatury
wcisniete:
    mov cs:wcisniete_r, 1
    jmp koniec_klawiatury
zwolnione:
    mov cs:wcisniete_r, 0
koniec_klawiatury:
    pop dx
    pop cx
    pop ax
    jmp dword PTR cs:wektor9

wcisniete_r db 0
wektor9 dd ?
obsluga_klawiatury ENDP

linia PROC

    push ax
    push bx
    push cx
    push dx
    push di
    push es

    cmp cs:wcisniete_r, 1
    jne r_niewcisniete
    dec cs:counter_r
    cmp cs:counter_r, 0
    je zmien_kolor
    jmp jeszcze_nie_zmieniaj
zmien_kolor:
    mov cs:migajacy_kolor, 4
r_niewcisniete:
    mov cs:counter_r, 32 ; okolo 2 sekundy
jeszcze_nie_zmieniaj:
; co 5 przerwan
    dec cs:counter
    cmp cs:counter, 0
    je koniecprogramiku

    mov ax, 0A090H
    mov es, ax
    mov al, cs:kolor
    mov bx, 0 ; x
    mov di, 0 ; y
    mov cx, cs:wielkosc ; petla
petla_kwadrat:
    ; gora i dol:
    mov es:[bx], al
    mov ax, cs:wielkosc
    mov dx, 0
    mov ax, 320
    mul cs:wielkosc ; przemnozenie zeby zejsc nizej
    mov di, bx ; przechowanie bx
    xchg ax, bx
    add bx, ax
    mov al, cs:kolor
    mov es:[bx], al ; wstawienie dolnej czesci
    mov bx, di
    ; lewy i prawy bok:
    mov dx, 0
    mov ax, bx
    mul cs:dlugosc_lini
    mov bx, ax
    mov al, cs:kolor
    mov es:[bx], al
    add bx, cs:wielkosc
    mov es:[bx], al
    mov bx, di

    inc bx
    loop petla_kwadrat
    ; fix ostatniego pixela:
    mov cs:wielkosc, bx
    mov ax, cs:dlugosc_lini
    mov dx, 0
    mul bx
    add bx, ax
    mov al, cs:kolor
    mov es:[bx], al
    mov cs:counter, 5
    cmp cs:kolor, 0
    je kolorzolty
    mov al, cs:czarny_kolor
    mov cs:kolor, al
    jmp koniecprogramiku
kolorzolty:
    mov al, cs:migajacy_kolor
    mov cs:kolor, al
koniecprogramiku:
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax

    jmp dword PTR cs:wektor8

; zmienne
kolor       db 14
migajacy_kolor  db 14
czarny_kolor    db 0
dlugosc_lini    dw 320
counter     dw 5
counter_r   dw 36
wielkosc    dw 10
wektor8     dd ?

linia ENDP

; int 10h - funkcja nr 0 ustawia tryb sterownika graficznego
zacznij:
    mov ah, 0
    mov al, 13h
    int 10h
    mov bx, 0
    mov es, bx
    mov eax, es:[32]
    mov cs:wektor8, eax

    mov ax, SEG linia
    mov bx, OFFSET linia
    cli
    mov es:[32], bx
    mov es:[32+2], ax
    sti

    ; podmiana przerwan klawiatury
    mov eax,es:[36]
    mov cs:wektor9, eax

    mov ax, SEG obsluga_klawiatury ; czêœæ segmentowa adresu
    mov bx, OFFSET obsluga_klawiatury ; offset adresu

    cli ; zablokowanie przerwañ
    mov es:[36], bx ; OFFSET
    mov es:[38], ax ; cz. segmentowa
    sti ;odblokowanie przerwañ

czekaj:
    mov ah, 1
    int 16h
    jz czekaj
    mov ah, 0
    int 16H
    cmp al, 'x' ; porównanie z kodem litery 'x'
    jne czekaj ; skok, gdy inny znak
    mov ah, 0
    mov al, 3h
    int 10h
    mov eax, cs:wektor8
    cli
    mov es:[32], eax
    sti
    mov eax, cs:wektor9
    cli
    mov es:[36], eax
    sti

    mov ax, 4C00h
    int 21h
rozkazy ENDS

stosik  SEGMENT stack
    db 256 dup (?)
stosik ENDS
END zacznij