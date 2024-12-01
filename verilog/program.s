.section ".text.init"
.globl _start
_start:
    # Load address for LED control (0x50000000)
    li t0, 0x50000000
    # Load the data word (0x00BE23F3)
    li t1, 0x00BE23F3
    # Store the value to the LED control address
    sw t1, 0(t0)
    # Stop the processor
    ebreak