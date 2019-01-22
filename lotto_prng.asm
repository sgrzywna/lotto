; lotto_prng.asm
; nasm -f elf lotto_prng.asm
; gcc -m32 -Wall -s -nostdlib -Wl,--build-id=none lotto_prng.o -o lotto_prng

;
; http://burtleburtle.net/bob/rand/smallprng.html
;
; typedef unsigned long int  u4;
; typedef struct ranctx { u4 a; u4 b; u4 c; u4 d; } ranctx;
;
;#define rot(x,k) (((x)<<(k))|((x)>>(32-(k))))
;u4 ranval( ranctx *x ) {
;    u4 e = x->a - rot(x->b, 27);
;    x->a = x->b ^ rot(x->c, 17);
;    x->b = x->c + x->d;
;    x->c = x->d + e;
;    x->d = e + x->a;
;    return x->d;
;}
;
;void raninit( ranctx *x, u4 seed ) {
;    u4 i;
;    x->a = 0xf1ea5eed, x->b = x->c = x->d = seed;
;    for (i=0; i<20; ++i) {
;        (void)ranval(x);
;    }
;}

BITS 32

SECTION .data

ranctx:                 dd 0, 0, 0, 0
print_buf:              db 0

SECTION .text

GLOBAL _start

print_single_char:
        push    edx
        push    ecx
        push    ebx
        push    eax

        mov     edx, 1          ; length of string to print
        mov     ecx, print_buf
        mov     [ecx], al
        mov     ebx, 0x01       ; write to screen
        mov     eax, 0x04       ; syscall for write
        int     0x80            ; call kernel

        pop     eax
        pop     ebx
        pop     ecx
        pop     edx
        ret

; ax = number to display
print_number:
        xor     dx, dx
        mov     bx, 10
        div     bx
        test    ax, ax
        jz      print_units
print_tens:
        add     al, 0x30
        call    print_single_char
print_units:
        mov     al, dl
        add     al, 0x30
        call    print_single_char
        mov     al, 0x0a
        call    print_single_char
        ret

ranval:
        mov     ecx, ranctx
        mov     ebx, dword [ecx]        ; ebx = a
        mov     edx, dword [ecx + 4]    ; edx = b
        mov     esi, dword [ecx + 8]    ; esi = c
        mov     eax, edx
        ror     eax, 5                  ; eax = rot(b, 27)
        sub     ebx, eax                ; ebx = e = a - rot(b, 27)
        mov     eax, esi
        ror     eax, 15                 ; eax = rot(c, 17)
        xor     eax, edx                ; eax = b ^ rot(c, 17)
        mov     edx, dword [ecx + 12]   ; edx = d
        mov     dword [ecx], eax        ; a = b ^ rot(c, 17)
        add     eax, ebx                ; eax = a + e
        mov     dword [ecx + 12], eax   ; d = a + e
        add     esi, edx                ; esi = c + d
        add     edx, ebx                ; edx = d + e
        mov     dword [ecx + 4], esi    ; b = c + d
        mov     dword [ecx + 8], edx    ; c = d + e
        ret

; eax = seed
raninit:
        mov     edi, ranctx
        mov     dword [edi], 0xf1ea5eed
        mov     dword [edi + 4], eax
        mov     dword [edi + 8], eax
        mov     dword [edi + 12], eax
        mov     edi, 20
raninit_loop:
        call    ranval
        dec     edi
        jnz     raninit_loop
        ret

_start:
        rdtsc
        call    raninit
        mov     edi, 6
loop:
        call    ranval
        shr     eax, 24
        cmp     eax, 49
        jg      loop
        or      eax, eax
        jnz     print
        inc     eax
print:
        call    print_number
        dec     edi
        jnz     loop

exit:
        xor     ebx, ebx        ; exit code, 0=normal
        mov     eax, 1          ; syscall for exit
        int     0x80            ; call kernel
