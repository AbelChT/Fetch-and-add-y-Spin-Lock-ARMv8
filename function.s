     .globl   myadd
     .globl   spin_lock
     .globl   spin_unlock
     .p2align 2
     .type    myadd,%function
     .type    spin_lock,%function
     .type    spin_unlock,%function

myadd:                     // Function "myadd" entry point.
     .fnstart
     add      r0, r0, r1   // Function arguments are in R0 and R1. Add together and put the result in R0.
     bx       lr           // Return by branching to the address in the link register.
     .fnend
spin_lock:                     // Function "myadd" entry point.
     .fnstart
     ldaxr r1, [r0]
     cmp r1, #0
     bne spin_lock
     strlxr r2, #1, [r0]
     cbnz r2, spin_lock
     bx       lr           // Return by branching to the address in the link register.
     .fnend
spin_unlock:                     // Function "myadd" entry point.
     .fnstart
     strlxr #0, [r0]
     bx       lr           // Return by branching to the address in the link register.
     .fnend
     