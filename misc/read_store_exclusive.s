//
// Created by Abel Chils Trabanco
// On 12/12/18
//
    .globl   read_exclusive
    .p2align 2
    .type    read_exclusive,%function
read_exclusive:               // Function "read_exclusive" entry point.
    .cfi_startproc
    ldaxr w1, [x0]
    ret                     // Return by branching to the address in the link register.
    .cfi_endproc

    .globl   store_exclusive
    .p2align 2
    .type    store_exclusive,%function
store_exclusive:               // Function "store_exclusive" entry point.
    .cfi_startproc
    stlxr w0, w1, [x0]
    ret                     // Return by branching to the address in the link register.
    .cfi_endproc
    