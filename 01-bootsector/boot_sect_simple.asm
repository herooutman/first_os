; used in memory exercise
[org 0x7c00]

; print exercise
; ax = ah + al
mov ah, 0x0e ; tty mode
mov al, 'H'
; BIOS interrupt call, when ah=0x0e Teletype output, see https://en.wikipedia.org/wiki/INT_10H
int 0x10
mov al, 'e'
int 0x10
mov al, 'l'
int 0x10
int 0x10 ; 'l' is still on al, remember?
mov al, 'o'
int 0x10

; move cursor to the head of the row
mov al, 10
int 0x10
mov ah, 0x03
int 0x10
mov ah, 0x02
mov dl, 0
int 0x10
; end of print exercise

; memory exercise
mov ah, 0x0e 
; attempt 1
; Will fail again regardless of 'org' because we are still addressing the pointer
; and not the data it points to
mov al, "1"
int 0x10
mov al, the_secret
int 0x10

; attempt 2
; Having solved the memory offset problem with 'org', this is now the correct answer
mov al, "2"
int 0x10
mov al, [the_secret]
int 0x10

; attempt 3
; As you expected, we are adding 0x7c00 twice, so this is not going to work
mov al, "3"
int 0x10
mov bx, the_secret
add bx, 0x7c00
mov al, [bx]
int 0x10

; attempt 4
; This still works because there are no memory references to pointers, so
; the 'org' mode never applies. Directly addressing memory by counting bytes
; is always going to work, but it's inconvenient
mov al, "4"
int 0x10
mov al, [0x7c4f]
int 0x10

; move cursor to the head of the row
mov bx, 0
mov al, 10
int 0x10
mov ah, 0x03
int 0x10
mov ah, 0x02
mov dl, 0
int 0x10
; end of memory exercise



; stack exercise
; Remember that the bp register stores the base address (i.e. bottom) of the stack, and sp stores the top, and that the stack grows downwards from bp (i.e. sp gets decremented)
mov ah, 0x0e ; tty mode

mov bp, 0x8000 ; this is an address far away from 0x7c00 so that we don't get overwritten
mov sp, bp ; if the stack is empty then sp points to bp

push 'A' ; push to stack
push 'B'
push 'C'

; to show how the stack grows downwards
mov al, [0x7ffe] ; 0x8000 - 2
int 0x10

; however, don't try to access the bottom of stack [0x8000], because it won't work
; but you can access 0x7ffe, 0x7ffc, and 0x7ffa
mov al, [0x8000]
int 0x10


; recover our characters using the standard procedure: 'pop'
; We can only pop full words so we need an auxiliary register to manipulate
; the lower byte
pop bx
mov al, bl
int 0x10 ; prints C

pop bx
mov al, bl
int 0x10 ; prints B

pop bx
mov al, bl
int 0x10 ; prints A

; move cursor to the head of the row
mov bx, 0
mov al, 10
int 0x10
mov ah, 0x03
int 0x10
mov ah, 0x02
mov dl, 0
int 0x10
; end of stack exercise


; functions exercise
; The main routine makes sure the parameters are ready and then calls the function
mov bx, HELLO
call print

call print_nl

mov bx, GOODBYE
call print

call print_nl

mov dx, 0x12fe
call print_hex
call print_nl



; segmentation exercise
mov ah, 0x0e ; tty

mov al, [the_secret]
int 0x10 ; we already saw this doesn't work, right?

mov bx, 0x7c0 ; remember, the segment is automatically <<4 for you
mov ds, bx
; WARNING: from now on all memory references will be offset by 'ds' implicitly
mov al, [the_secret]
int 0x10

mov al, [es:the_secret]
int 0x10 ; doesn't look right... isn't 'es' currently 0x000?

mov bx, 0x7c0
mov es, bx
mov al, [es:the_secret]
int 0x10

; move cursor to the head of the row
mov ax, 0x0e0a
int 0x10
mov bx, 0
mov ah, 0x03
int 0x10
mov ah, 0x02
mov dl, 0
int 0x10
; end of segmentation exercise


jmp $ ; jump to current address = infinite loop

; remember to include subroutines below the hang
%include "boot_sect_print.asm"
%include "boot_sect_print_hex.asm"

; data
the_secret:
    ; ASCII code 0x58 ('X') is stored just before the zero-padding.
    ; On this code that is at byte 0x2d (check it out using 'xxd file.bin')
    db "X"

HELLO:
    db 'Hello, World', 0

GOODBYE:
    db 'Goodbye', 0
; end of functions exercise


; Pad with zeros till address 510
; times: operates on a number, loop for the number of times
; ($-$$): difference of address from the currently executed instruction to the beginning
; db: write a byte data
times 510-($-$$) db 0

; Magic number. To make sure that the "disk is bootable", the BIOS checks that bytes 511 and 512 of the alleged boot sector are bytes 0xAA55.
; (beware of endianness, x86 is little-endian)
; dw: write a word data (16 bits)
dw 0xaa55 