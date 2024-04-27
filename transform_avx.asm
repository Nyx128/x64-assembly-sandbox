%include "macros.inc"

default rel
bits 64

segment .data
  result times 4 dd 0.0;result is a 4 float vector

segment .text
global transform_avx

;ymm0 ->r12
;ymm1 ->r34
;ymm2 ->vec
;ymm3 ->m12
;ymm4 ->m34
;xmm5 ->extraction utility

transform_avx:
  push rbp
  mov rbp, rsp

  vmovups ymm0, [rcx]
  vmovups ymm1, [rcx + 32]

  movups xmm2, [rdx]
  vinsertf128 ymm2, ymm2, xmm2, 1

  vmulps ymm3, ymm0, ymm2
  vmulps ymm4, ymm1, ymm2

  vhaddps ymm3, ymm3
  vhaddps ymm3, ymm3

  vhaddps ymm4, ymm4
  vhaddps ymm4, ymm4

  mov rax, result

  vextractf128 xmm5, ymm3, 0
  movss [rax], xmm5

  vextractf128 xmm5, ymm3, 1
  movss [rax + 4], xmm5

  vextractf128 xmm5, ymm4, 0
  movss [rax + 8], xmm5

  vextractf128 xmm5, ymm4, 1
  movss [rax + 12], xmm5

  leave
  ret