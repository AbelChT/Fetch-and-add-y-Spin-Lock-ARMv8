     .globl   spin_lock
     .p2align 2
     .type    spin_lock,%function
spin_lock:                 // Function "spin_lock" entry point.
     .cfi_startproc
     ldaxr w1, [x0]
     cmp w1, #0
     bne spin_lock
     mov w1, #1
     stlxr w2, w1, [x0]
     cbnz w2, spin_lock   
     ret                  // Return by branching to the address in the link register.
     .cfi_endproc

     .globl   spin_unlock
     .p2align 2
     .type    spin_unlock,%function
spin_unlock:
     .cfi_startproc       // Function "spin_unlock" entry point.
     mov w1, #0
     ldaxr w2, [x0]       // Needed to perform later stlxr w2, w1, [x0]
     stlxr w2, w1, [x0]   // Store 0 in the spin_lock variable
     ret                  // Return by branching to the address in the link register.
     .cfi_endproc
     
