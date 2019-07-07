.set IRQ_BASE, 0x20
.section .text

.extern _ZN16InterruptManager15handleInterruptEhj
.global _ZN16InterruptManager22IgnoreInterruptRequestEv

.macro HandleException num
.global _ZN16InterruptManager16HandleException\num\()Ev

_ZN16InterruptManager16HandleException\num\()Ev:
	movb $\num, (interruptnumber)
	jmp int_bottom
	
.endm

# asm function for handling interrupt by the cpu
.macro HandleInterruptRequest num
.global _ZN16InterruptManager26HandleInterruptRequest\num\()Ev

_ZN16InterruptManager26HandleInterruptRequest\num\()Ev:
	movb $\num + IRQ_BASE, (interruptnumber)
	jmp int_bottom

.endm

# we copy this as many times we need interrupts
# keyboard/misc
HandleInterruptRequest 0x00
HandleInterruptRequest 0x01
# mouse
HandleInterruptRequest 0x0C

int_bottom:

	pusha
	pushl %ds
	pushl %es
	pushl %fs
	pushl %gs

	pushl %esp
	push (interruptnumber)
	call _ZN16InterruptManager15handleInterruptEhj
	add %esp, 6
	movl %eax, %esp
	
	popl %gs
	popl %fs
	popl %es
	popl %ds
	popa

_ZN16InterruptManager22IgnoreInterruptRequestEv:

	iret

.data
	interruptnumber: .byte 0