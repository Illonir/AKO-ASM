public suma_siedmiu_liczb
public szukaj64_max
public suma_tablicy

.code
suma_siedmiu_liczb PROC
	push rbp ; przechowanie rejestrów
	mov rbp, rsp
	add rbp, 32	; przeskoczyć shadow space

	mov rax, 0
	add rax, rcx
	add rax, rdx
	add rax, r8
	add rax, r9
	add rax, [rbp+16]
	add rax, [rbp+24]
	add rax, [rbp+32]

	pop rbp
	ret
suma_siedmiu_liczb ENDP

szukaj64_max PROC
	push rbx ; przechowanie rejestrów
	push rsi
	mov rbx, rcx ; adres tablicy
	mov rcx, rdx ; liczba elementów tablicy
	mov rsi, 0 ; indeks bieżący w tablicy
	; w rejestrze RAX przechowywany będzie największy dotychczas
	; znaleziony element tablicy - na razie przyjmujemy, że jest
	; to pierwszy element tablicy
	mov rax, [rbx + rsi*8]
	; zmniejszenie o 1 liczby obiegów pętli, bo ilość porównań
	; jest mniejsza o 1 od ilości elementów tablicy
	dec rcx
	ptl: inc rsi ; inkrementacja indeksu
	; porównanie największego, dotychczas znalezionego elementu
	; tablicy z elementem bieżącym
	cmp rax, [rbx + rsi*8]
	jge dalej; skok, gdy element bieżący jest
	; niewiększy od dotychczas znalezionego
	; przypadek, gdy element bieżący jest większy
	; od dotychczas znalezionego
	mov rax, [rbx+rsi*8]
	dalej: loop ptl ; organizacja pętli
	; obliczona wartość maksymalna pozostaje w rejestrze RAX
	; i będzie wykorzystana przez kod programu napisany w języku C
	pop rsi
	pop rbx
	ret
szukaj64_max ENDP

suma_tablicy PROC
	push rdi

	mov rax, 0
	mov rdi, 0

	petla:
	add rax, [rcx + 8*rdi]
	inc rdi
	cmp rdi, rdx
	jl petla

	pop rdi
	ret
suma_tablicy ENDP
END
