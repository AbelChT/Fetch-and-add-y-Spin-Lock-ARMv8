//
// Created by Abel Chils Trabanco
// On 12/12/18
//
     .globl   spin_lock_ee
     .p2align 2
     .type    spin_lock_ee,%function
spin_lock_ee:              // Function "spin_lock" entry point.
     .cfi_startproc
     // send ourselves an event, so we don't stick on the wfe at the
     // top of the loop
     mov w3, #1
     sevl
spin_lock_ee_loop:
     wfe
     ldaxr w1, [x0]
     cmp w1, #0
     bne spin_lock_ee_loop
     stlxr w2, w3, [x0]
     cbnz w2, spin_lock_ee_loop   
     ret                  // Return by branching to the address in the link register.
     .cfi_endproc

     .globl   spin_unlock_ee
     .p2align 2
     .type    spin_unlock_ee,%function
spin_unlock_ee:
     .cfi_startproc               // Function "spin_unlock" entry point.
     mov w1, #0
spin_unlock_loop_ee:
     ldaxr w2, [x0]               // Needed to perform later stlxr w2, w1, [x0]
     stlxr w2, w1, [x0]           // Store 0 in the spin_lock variable and automatic send sev
     cbnz w2, spin_unlock_loop_ee // This will be taken if a context change happens between ldaxr and stlxr. Read proyect README for more info
     ret                          // Return by branching to the address in the link register.
     .cfi_endproc
