.686
.XMM
.model flat

public _obj_stozka
public _szybki_max
public _tangensy
public _wyznacz_max
public _find_max_range
public _mul_at_once
public _oblicz_potege
public _dziel

.data
	earth_g dd 9.81

.code

_obj_stozka PROC
	push ebp
	mov ebp, esp

	finit
	fild dword ptr[ebp+8]
	fmul st(0), st(0)
	fild dword ptr[ebp+12]
	fmul st(0), st(0)
	faddp st(1), st(0)
	fild dword ptr[ebp+8]
	fild dword ptr[ebp+12]
	fmulp st(1), st(0)
	faddp st(1), st(0)
	fldpi
	fmulp st(1), st(0)
	fld dword ptr[ebp+16]
	fmulp st(1), st(0)
	push dword ptr 3
	fild dword ptr [esp]
	add esp, 4
	fdivp st(1), st(0)

	pop ebp
	ret 
_obj_stozka ENDP

_szybki_max PROC
	push ebp
	mov ebp, esp

	mov eax, [ebp+8]
	mov edx, [ebp+12]
	mov edi, [ebp+16]

	mov ecx, 0
	start_ptl:
	cmp ecx, [ebp+20]
	jae end_ptl
	movdqu xmm1, [eax+4*ecx]
	movdqu xmm2, [edx+4*ecx]
	pmaxsd xmm1, xmm2
	movdqu [edi+4*ecx], xmm1
	add ecx, 4
	jmp start_ptl
	end_ptl:

	pop ebp
	ret
_szybki_max ENDP

_tangensy PROC
	push ebp
	mov ebp, esp

	mov eax, [ebp+8]

	finit

	fldz
	fptan
	fstp st(0)
	fst dword ptr [eax]
	fstp st(0)

	fldpi
	push dword ptr 12
	fild dword ptr [esp]
	add esp, 4
	fdivp st(1), st(0)
	fptan 
	fstp st(0)
	fst dword ptr [eax+4]
	fstp st(0)

	fldpi
	push dword ptr 6
	fild dword ptr [esp]
	add esp, 4
	fdivp st(1), st(0)
	fptan 
	fstp st(0)
	fst dword ptr [eax+8]
	fstp st(0)

	fldpi
	push dword ptr 4
	fild dword ptr [esp]
	add esp, 4
	fdivp st(1), st(0)
	fptan 
	fstp st(0)
	fst dword ptr [eax+12]
	fstp st(0)

	fldpi
	push dword ptr 3
	fild dword ptr [esp]
	add esp, 4
	fdivp st(1), st(0)
	fptan 
	fstp st(0)
	fst dword ptr [eax+16]
	fstp st(0)

	pop ebp
	ret
_tangensy ENDP

_wyznacz_max PROC
	push ebp
	mov ebp, esp

	mov eax, [ebp+8]

	finit
	fild dword ptr [ebp+12]
	sub esp, 4
	fst dword ptr [esp]

	pop ecx
	push ecx
	push ecx
	push ecx
	push ecx

	movdqu xmm1, [esp]
	movups xmm2, [eax]
	maxps xmm1, xmm2
	movups [eax], xmm1

	add esp, 16

	pop ebp
	ret
_wyznacz_max ENDP

_find_max_range PROC
	push ebp
	mov ebp, esp

	fld dword ptr [ebp+12]
	fldpi
	fmulp
	push dword ptr 90
	fild dword ptr [esp]
	add esp, 4
	fdivp st(1), st(0)
	fsincos
	fstp st(0)
	fld dword ptr [ebp+8]
	fmul st(0), st(0)
	fmulp st(1), st(0)
	fld dword ptr earth_g
	fdivp st(1), st(0)

	pop ebp
	ret
_find_max_range ENDP

_mul_at_once PROC
	pmulld xmm0, xmm1
	ret
_mul_at_once ENDP

_oblicz_potege PROC
	push ebp
	mov ebp, esp

	finit 
	fild dword ptr [ebp+8]
	fld1
	fscale
	fild dword ptr [ebp+12]
	faddp st(1), st(0)

	pop ebp
	ret
_oblicz_potege ENDP

_dziel PROC
	push ebp
	mov ebp, esp
	push esi

	mov esi, [ebp+8]
	mov ecx, 0
	mov edx, [ebp+16]
	push edx
	push edx
	push edx
	push edx
	movups xmm1, [esp]
	add esp, 16

	mov edx, [ebp+12]
	mov eax, 16
	mul edx


	start_dziel:
	cmp ecx, eax
	jae end_dziel
	movups xmm0, [esi+ecx]
	divps xmm0, xmm1
	movups [esi+ecx], xmm0
	add ecx, 16
	jmp start_dziel
	end_dziel:

	pop esi
	pop ebp
	ret
_dziel ENDP

END
