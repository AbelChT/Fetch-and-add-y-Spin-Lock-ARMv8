//
// Created by Abel Chils Trabanco
// On 12/12/18
//
     .globl   spin_lock_ee_b_ne
     .p2align 2
     .type    spin_lock_ee_b_ne,%function
spin_lock_ee_b_ne:              // Function "spin_lock" entry point.
     .cfi_startproc
     // send ourselves an event, so we don't stick on the wfe at the
     // top of the loop
     mov w3, #1
     sevl
spin_lock_ee_loop:
     wfe
     ldaxrb w1, [x0]
     cmp w1, #0
     bne spin_lock_ee_loop
     stlxrb w2, w3, [x0]
     cbnz w2, spin_lock_ee_loop   
     ret                  // Return by branching to the address in the link register.
     .cfi_endproc

     .globl   spin_unlock_ee_b_ne
     .p2align 2
     .type    spin_unlock_ee_b_ne,%function
spin_unlock_ee_b_ne:
     .cfi_startproc               // Function "spin_unlock" entry point.
     mov w1, #0
     strb w1, [x0]                // Store 0 in the spin_lock variable
     sev                          // Send sev
     ret                          // Return by branching to the address in the link register.
     .cfi_endproc
