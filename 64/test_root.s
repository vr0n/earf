BITS 64
global _start
section .text

_start:
  xor rax, rax ; clear the reg
  mov rax, 107 ; get uid -- if 0 seems root
  syscall
  cmp rax, 0   ; are we root?
  je is_root   ; if so, jump
  jmp not_root

is_root:       ; are we root?
  call root
  db "you ARE root", 0xa, 0x0
root:          ; custom write func
  xor rax, rax
  xor rdx, rdx
  inc al
  mov rdi, rax
  pop rsi
  mov dl, 13
  syscall
  jmp close

not_root:      ; are we not root?
  call noroot
  db "you are NOT root", 0xa, 0x0
noroot:        ; custom write func
  xor rax, rax
  xor rdx, rdx
  inc al
  mov rdi, rax
  pop rsi
  mov dl, 17
  syscall
  jmp close

close:
  xor rdx, rdx  ; must exit with this code all the time
