; Przykład wywoływania funkcji MessageBoxA i MessageBoxW
.686
.model flat
includelib libcmt.lib

	extern _ExitProcess@4 : PROC
	extern _MessageBoxA@16 : PROC
	extern _MessageBoxW@16 : PROC

public _main

.data
tytul_Unicode dw 'T','e','k','s','t',' ','w',' '
				dw 'f','o','r','m','a','c','i','e',' '
				dw 'U','T','F','-','1','6', '_', 0061h, 0

tekst_Unicode dw 'K','o','t',' ', 0D83Dh, 0DE82h, 0
u8 db 61h, 0, 0
et db    0F0H, 09FH, 09AH, 082H, 0   ; parowóz
u16 dw 10 dup(0)

len dw 48

ubufor dw 48 dup(0)

bufor       db    50H, 6FH, 0C5H, 82H, 0C4H, 85H, 63H, 7AH, 65H, 6EH, 69H, 61H, 20H

            db    0F0H, 9FH, 9AH, 82H   ; parowóz

            db    20H, 20H, 6BH, 6FH, 6CH, 65H, 6AH, 6FH, 77H, 6FH, 20H

            db    0E2H, 80H, 93H ; półpauza

            db    20H, 61H, 75H, 74H, 6FH, 62H, 75H, 73H, 6FH, 77H, 65H, 20H, 20H

            db    0F0H,  9FH,  9AH,  8CH ; autobus



.code

_main PROC
	;driver
	mov eax, 0
	mov ebx, 0
	mov ecx, 0
	mov edx, 0


	start_loop:
	mov bl, [bufor+ecx]

	is_1byte:
	cmp bl, 07FH
	ja is_2byte
	mov eax, 0
	mov al, bl
	mov [ubufor+edx], ax
	jmp continue

	is_2byte:
	cmp bl, 0E0H
	ja is_3byte
	mov eax, 0
	mov al, [bufor+ecx+1]
	shl ax, 2
	mov ah, bl
	sub ah, 0C0H
	shr ax, 2
	mov [ubufor+edx], ax
	add ecx, 1
	jmp continue

	is_3byte:
	cmp bl, 0F0H
	jae is_4byte
	mov eax, 0
	mov ebx, 0
	mov al, [bufor+ecx+1]
	shl ax, 2
	mov ah, [bufor+ecx]
	shl ax, 4
	mov bl, [bufor+ecx+2]
	sub bl, 80H
	or al, bl
	mov [ubufor+edx], ax
	add ecx, 2
	jmp continue

	is_4byte:
	;cmp bl, 0F0H
	;ja error
	mov eax, 0

	mov al, [bufor+ecx+2]
	shl ax, 2
	mov ah, [bufor+ecx+1]
	sub ah, 80h
	shr ax, 6
	sub al, 40h
	or ah, 11011000b
	;shl eax, 16
	mov [ubufor+edx], ax
	add edx, 2

	mov eax, 0
	mov al, [bufor+ecx+3]
	shl al, 2
	mov ah, [bufor+ecx+2]
	sub ah, 80h
	shr ax, 2
	or ah, 11011100b
	mov [ubufor+edx], ax
	add ecx, 3
	jmp continue

	continue:
	add edx, 2
	inc ecx
	cmp cx, [len]
	jb start_loop


	mov [ubufor+edx+2], 0
	;wypisanie
	push 0  ; stala MB_OK
			; adres obszaru zawierającego tytuł
	push OFFSET tytul_Unicode
			; adres obszaru zawierającego tekst
	push OFFSET ubufor
	push 0  ; NULL
	call _MessageBoxW@16

	push 0  ; kod powrotu programu
	call _ExitProcess@4

	error:
	push edx
	call _ExitProcess@4
_main ENDP
END
