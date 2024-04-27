%macro multipush_ymm 1-*
%rep %0
    sub rsp, 32;expand stack by 32 bytes or 256 bits aka size of a ymm register
    vmovdqu yword [rsp], %1;
%rotate 1
%endrep
%endmacro

%macro multipop_ymm 1-*
%rep %0
%rotate -1
    vmovdqu    %1, yword [rsp]
    add    rsp, 32
%endrep
%endmacro