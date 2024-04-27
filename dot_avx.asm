%include "macros.inc"

default rel
bits 64

;a single double is 64 bits so a ymm register can store 4 of these

;will take 3 arguments (const double x[], const double y[], int n)
;rcx -> x array
;rdx -> y array
;r8 -> sample size (n)
;r9 -> sample counter
;r10 -> loop_counter

segment .text
global dot_avx


;beats msvc compiler with /o2 avx2 enabled maximum optimisation release mode most of the time, its better or at worst has the same speed

dot_avx:
  multipush_ymm ymm6, ymm7, ymm8, ymm9, ymm10
  ;zero out all ymm registers
  vzeroall

  ;zero out sample counter
  xor r9 , r9 

  ;copy our vector size to our loop counter
  mov r10, r8

  push rbp
  mov rbp, rsp
.loop
  vmovupd ymm1, [rcx + r9] ;load 4 doubles from x array
  vmovupd ymm2, [rdx + r9] ;load 4 doubles from y array

  vmulpd ymm3, ymm1, ymm2 ; ymm3 = ymm1 * ymm2 (doing 4 at once)
  vhaddpd ymm3, ymm3, ymm3; now if ymm3 is [d1, d2, d3, d4] then ymm4 is [d1 + d2, d1 + d2, d3 + d4, d3 + d4]
  ;control byte is as such basically you have 4 indices from 0 to 3 or 00, 01, 10, 11 and on each position you want to specify which double from the source register do you want to copy over to the new register
  vpermpd ymm4, ymm3, 0b00100111
  vaddpd xmm5, xmm3, xmm4
  vaddpd xmm0, xmm0, xmm5

  vmovupd ymm6, [rcx + r9 + 32]
  vmovupd ymm7, [rdx + r9 + 32]

  vmulpd ymm8, ymm6, ymm7
  vhaddpd ymm8, ymm8, ymm8
  vpermpd ymm9, ymm8, 0b00100111
  vaddpd xmm10, xmm8, xmm9
  vaddpd xmm0, xmm0, xmm10

  add r9, 64; increment our sample counter by 32 bits
  sub r10, 8; increment our counter by 8 ;sets of zero flag when r10 is zero
  jnz .loop

  leave
  multipop_ymm ymm6, ymm7, ymm8, ymm9, ymm10
  ret

  


