//
// Created by Abel Chils Trabanco
// On 12/12/18
//
     .globl   spin_lock
     .p2align 2
     .type    spin_lock,%function
spin_lock:                 // Function "spin_lock" entry point.
     .cfi_startproc
     mov w3, #1
spin_lock_loop:       
     ldaxr w1, [x0]
     cmp w1, #0
     bne spin_lock_loop
     stlxr w2, w3, [x0]
     cbnz w2, spin_lock_loop   
     ret                  // Return by branching to the address in the link register.
     .cfi_endproc

     .globl   spin_unlock
     .p2align 2
     .type    spin_unlock,%function
spin_unlock:
     .cfi_startproc       // Function "spin_unlock" entry point.
     mov w1, #0
spin_unlock_loop:
     ldaxr w2, [x0]              // Needed to perform later stlxr w2, w1, [x0]
     stlxr w2, w1, [x0]          // Store 0 in the spin_lock variable
     cbnz w2, spin_unlock_loop   // This will be taken if a context change happens between ldaxr and stlxr. Read proyect README for more info
     ret                         // Return by branching to the address in the link register.
     .cfi_endproc
     
