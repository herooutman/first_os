[org 0x7c00]

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
mov al, 10
int 0x10

; move cursor to the head of the row
mov ah, 0x03
int 0x10
mov ah, 0x02
mov dl, 0
int 0x10

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

jmp $ ; jump to current address = infinite loop

the_secret:
    ; ASCII code 0x58 ('X') is stored just before the zero-padding.
    ; On this code that is at byte 0x2d (check it out using 'xxd file.bin')
    db "X"

; Pad with zeros till address 510
; times: operates on a number, loop for the number of times
; ($-$$): difference of address from the currently executed instruction to the beginning
; db: write a byte data
times 510-($-$$) db 0

; Magic number. To make sure that the "disk is bootable", the BIOS checks that bytes 511 and 512 of the alleged boot sector are bytes 0xAA55.
; (beware of endianness, x86 is little-endian)
; dw: write a word data (16 bits)
dw 0xaa55 