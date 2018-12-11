     .globl   fetch_and_add
     .p2align 2
     .type    fetch_and_add,%function
fetch_and_add:               // Function "fetch_and_add" entry point.
     .cfi_startproc
     ldaxr w2, [x0]
     add w4, w1, w2
     stlxr w3, w4, [x0]
     cbnz w3, fetch_and_add
     mov w0, w2              // Return the value before execute fetch_and_add
     ret                     // Return by branching to the address in the link register.
     .cfi_endproc
