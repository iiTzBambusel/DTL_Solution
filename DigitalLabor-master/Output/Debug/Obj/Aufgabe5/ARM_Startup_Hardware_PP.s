# 0 "C:\\Users\\torbe\\Downloads\\DigitalLabor-master\\System\\ARM_Startup_Hardware.s"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "C:\\Users\\torbe\\Downloads\\DigitalLabor-master\\System\\ARM_Startup_Hardware.s"
# 58 "C:\\Users\\torbe\\Downloads\\DigitalLabor-master\\System\\ARM_Startup_Hardware.s"
        .syntax unified




        .equ Mode_USR, 0x10
        .equ Mode_FIQ, 0x11
        .equ Mode_IRQ, 0x12
        .equ Mode_SVC, 0x13
        .equ Mode_ABT, 0x17
        .equ Mode_UND, 0x1B
        .equ Mode_SYS, 0x1F

        .equ I_Bit, 0x80
        .equ F_Bit, 0x40



# Phase Locked Loop (PLL) definitions
        .equ PLL_BASE, 0xE01FC080
        .equ PLLCON_OFS, 0x00
        .equ PLLCFG_OFS, 0x04
        .equ PLLSTAT_OFS, 0x08
        .equ PLLFEED_OFS, 0x0C
        .equ PLLCON_PLLE, (1<<0)
        .equ PLLCON_PLLC, (1<<1)
        .equ PLLCFG_MSEL, (0x1F<<0)
        .equ PLLCFG_PSEL, (0x03<<5)
        .equ PLLSTAT_PLOCK, (1<<10)

        .equ PLL_SETUP, 1
        .equ PLLCFG_Val, 0x00000024
# 102 "C:\\Users\\torbe\\Downloads\\DigitalLabor-master\\System\\ARM_Startup_Hardware.s"
.macro ISR_HANDLER Name=



        .section .vectors, "ax"
        ldr PC, =\Name



        .section .init.\Name, "ax"
        .code 32
        .type \Name, function
        .weak \Name
        .balign 4
\Name:
        1: b 1b
        END_FUNC \Name
.endm




.macro ISR_RESERVED
        .section .vectors, "ax"
        nop
.endm




.macro END_FUNC name
        .size \name,.-\name
.endm


.macro blx reg
  mov lr, pc
  bx \reg
.endm
# 154 "C:\\Users\\torbe\\Downloads\\DigitalLabor-master\\System\\ARM_Startup_Hardware.s"
        .section .vectors, "ax"
        .code 32
        .balign 4
        .global _vectors
_vectors:
        ldr PC, =Reset_Handler
        ISR_HANDLER undef_handler
        ISR_HANDLER swi_handler
        ISR_HANDLER pabort_handler
        ISR_HANDLER dabort_handler
        ISR_RESERVED
        ldr PC, =IRQ_Handler
        ldr PC, =FIQ_Handler

        .section .vectors, "ax"
        .size _vectors, .-_vectors
_vectors_end:
# 186 "C:\\Users\\torbe\\Downloads\\DigitalLabor-master\\System\\ARM_Startup_Hardware.s"
        .section .init.Reset_Handler, "ax"
        .code 32
        .balign 4
        .global reset_handler
        .global Reset_Handler
        .equ reset_handler, Reset_Handler
        .type Reset_Handler, function
Reset_Handler:



        mrs R0, CPSR
        bic R0, R0, #0x1F

        orr R1, R0, #0x1B
        msr CPSR_cxsf, R1
        ldr SP, =__stack_und_end__
        bic SP, SP, #0x7
        orr R1, R0, #0x17
        msr CPSR_cxsf, R1
        ldr SP, =__stack_abt_end__
        bic SP, SP, #0x7
        orr R1, R0, #0x12
        msr CPSR_cxsf, R1
        ldr SP, =__stack_irq_end__
        bic SP, SP, #0x7
        orr R1, R0, #0x11
        msr CPSR_cxsf, R1
        ldr SP, =__stack_fiq_end__
        bic SP, SP, #0x7
        orr R1, R0, #0x13
        msr CPSR_cxsf, R1
        ldr SP, =__stack_svc_end__
        bic SP, SP, #0x7
# 235 "C:\\Users\\torbe\\Downloads\\DigitalLabor-master\\System\\ARM_Startup_Hardware.s"
        orr R1, R0, #0x1F
        msr CPSR_cxsf, R1
        ldr SP, =__stack_end__
        bic SP, SP, #0x7
# 263 "C:\\Users\\torbe\\Downloads\\DigitalLabor-master\\System\\ARM_Startup_Hardware.s"
       .equ MEMMAP, 0xE01FC040




                LDR R0, =PLL_BASE
                MOV R1, #0xAA
                MOV R2, #0x55


                MOV R3, #PLLCFG_Val
                STR R3, [R0, #PLLCFG_OFS]
                MOV R3, #PLLCON_PLLE
                STR R3, [R0, #PLLCON_OFS]
                STR R1, [R0, #PLLFEED_OFS]
                STR R2, [R0, #PLLFEED_OFS]


PLL_Loop: LDR R3, [R0, #PLLSTAT_OFS]
                ANDS R3, R3, #PLLSTAT_PLOCK


# Switch to PLL Clock
                MOV R3, #(PLLCON_PLLE | PLLCON_PLLC)
                STR R3, [R0, #PLLCON_OFS]
                STR R1, [R0, #PLLFEED_OFS]
                STR R2, [R0, #PLLFEED_OFS]



         LDR R0, =MEMMAP
         MOV R1, #2
         STR R1, [R0]


         MSR CPSR_c, #Mode_USR
         MOV SP, R0


        bl _start
END_FUNC Reset_Handler
# 313 "C:\\Users\\torbe\\Downloads\\DigitalLabor-master\\System\\ARM_Startup_Hardware.s"
        .section .init.IRQ_Handler, "ax"
        .code 32
        .balign 4
        .global irq_handler
        .global IRQ_Handler
        .equ irq_handler, IRQ_Handler
        .type IRQ_Handler, function
        .weak IRQ_Handler
   IRQ_Handler:
       ldr r1,=0xfffff030
       ldr PC,[R1]

END_FUNC IRQ_Handler
# 336 "C:\\Users\\torbe\\Downloads\\DigitalLabor-master\\System\\ARM_Startup_Hardware.s"
        .section .init.FIQ_Handler, "ax"
        .code 32
        .balign 4
        .global fiq_handler
        .global FIQ_Handler
        .equ fiq_handler, IRQ_Handler
        .type FIQ_Handler, function
        .weak FIQ_Handler
   FIQ_Handler:
       ldr r1,=0xfffff030
       ldr PC,[R1]

END_FUNC FIQ_Handler
