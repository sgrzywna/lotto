; lotto_urandom.asm
; nasm -f elf lotto_urandom.asm
; gcc -m32 -Wall -s -nostdlib -Wl,--build-id=none lotto_urandom.o -o lotto_urandom

BITS 32

SECTION .data

filename:               db "/dev/urandom", 0
print_buf:              db 0
buffer:                 db 0, 0, 0, 0, 0, 0
buflen:                 equ $ - buffer

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

_start:
        mov     ebx, filename   ; open urandom
        mov     eax, 0x05       ; syscall for open
        xor     ecx, ecx        ; O_RDONLY = 0
        xor     edx, edx        ; ignore mode for O_RDONLY
        int     0x80            ; call kernel
        test    eax, eax        ; check for open error
        jns     read_file

exit:
        xor     ebx, ebx        ; exit code, 0=normal
        mov     eax, 1          ; syscall for exit
        int     0x80            ; call kernel

read_file:
        mov     ebx, eax        ; eax = file descriptor
        mov     eax, 0x03       ; syscall for read
        mov     ecx, buffer     ; read buffer
        mov     edx, buflen     ; size of read buffer
        int     0x80            ; call kernel

        mov     eax, 0x06       ; syscall for close
        int     0x80            ; call kernel

        mov     edi, buffer     ; dump buffer
        mov     ecx, buflen     ; size of dump buffer

dump_buffer:
        xor     dx, dx          ; dx:ax / bx
        xor     ah, ah
        mov     al, [edi]       ; buffer[edi] mod 49
        mov     bx, 49
        div     bx
        inc     dx              ; 49 mod 49 = 0
        mov     ax, dx

        call    print_number

        inc     edi             ; next byte from dump buffer
        dec     ecx             ; update counter
        jnz     dump_buffer

        jmp     exit
