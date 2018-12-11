     .globl   spin_lock_ee
     .p2align 2
     .type    spin_lock_ee,%function
spin_lock_ee:              // Function "spin_lock" entry point.
     .cfi_startproc
     // send ourselves an event, so we don't stick on the wfe at the
     // top of the loop
     sevl
spin_lock_ee_loop:
     wfe
     ldaxr w1, [x0]
     cmp w1, #0
     bne spin_lock_ee_loop
     mov w1, #1
     stlxr w2, w1, [x0]
     cbnz w2, spin_lock_ee_loop   
     ret                  // Return by branching to the address in the link register.
     .cfi_endproc

     .globl   spin_unlock_ee
     .p2align 2
     .type    spin_unlock_ee,%function
spin_unlock_ee:
     .cfi_startproc       // Function "spin_unlock" entry point.
     mov w1, #0
     ldaxr w2, [x0]       // Needed to perform later stlxr w2, w1, [x0]
     stlxr w2, w1, [x0]   // Store 0 in the spin_lock variable
     sev                  // Wake-up processors in wfe
     ret                  // Return by branching to the address in the link register.
     .cfi_endproc
     
