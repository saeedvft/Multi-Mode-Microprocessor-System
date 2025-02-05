.INCLUDE "m32def.inc"
.ORG 0

LDI R16, 0xFF
OUT DDRC, R16
OUT DDRD, R16
OUT PORTA, R16

LDI R16, 0x00
OUT DDRA, R16

.def temp = R20            ; Temporary register
.def counter = R21         ; Seconds counter
.def loop_count = R22      ; Loop counter for 1-second delay
.def tens = R23            ; Tens place
.def ones = R24            ; Ones place

.equ OCR_VALUE = 15        ; OCR0 value for 16 ms delay
.equ ITERATIONS = 15       ; Number of iterations for 1 second


mode_a:
    ; Initialize Timer0 in CTC mode
    
    ldi temp, 0x00         ; Clear TCNT0
    out TCNT0, temp

    ldi temp, OCR_VALUE    ; Load OCR0 with 15
    out OCR0, temp

    ldi temp, 0x0D         ; Set Timer0 in CTC mode, prescaler = 1024
    out TCCR0, temp

    ; Initialize counters
    clr counter            ; Clear seconds counter
    clr loop_count         ; Clear loop counter
    a_MAIN_LOOP:
    ; Delay for 1 second using Timer0
    ldi loop_count, ITERATIONS
    

    
    a_DELAY_LOOP:
    in temp, TIFR          ; Read TIFR
    sbrs temp, OCF0        ; Check if OCF0 is set
    rjmp a_DELAY_LOOP        ; Wait for compare match

    ldi temp, 1 << OCF0    ; Clear OCF0 flag
    out TIFR, temp

    dec loop_count         ; Decrement loop counter
    BRNE a_DELAY_LOOP        ; Repeat until 61 iterations

    ; Extract tens and ones places
    a_EXTRACT_TENS_AND_ONES:
        clr tens             ; Clear tens register
        clr ones             ; Clear ones register

        ; Calculate tens = counter / 10
        mov temp, counter    ; Copy counter to temp
        ldi tens, 0          ; Initialize tens to 0

    a_DIVIDE_BY_TEN:
        subi temp, 10        ; Subtract 10 from temp
        brmi a_DONE_DIVIDE     ; If temp < 0, division is complete
        inc tens             ; Increment tens counter
        rjmp a_DIVIDE_BY_TEN   ; Repeat

    a_DONE_DIVIDE:
        LDI R26, 10
        add temp, R26         ; Add back 10 to temp to get the remainder
        mov ones, temp       ; Store remainder (ones digit) in ones register
        ;ret                  ; Return to main program

    ; Display tens place (left 7-segment display)
    call a_DISPLAY_TENS

    ; Display ones place (right 7-segment display)
    call a_DISPLAY_ONES
    
    ; Increment counter
    inc counter            ; Increment seconds counter
    cpi counter, 100        ; Check if 60 seconds reached
    brne a_MAIN_LOOP         ; If not, repeat

    clr counter            ; Reset counter after 60 seconds
    rjmp a_MAIN_LOOP         ; Repeat

a_DISPLAY_TENS:
    ; Map tens digit to 7-segment code
    ldi temp, 0
    cpi tens, 0
    breq a_SET_SEGMENTS
    ldi temp, 1
    cpi tens, 1
    breq a_SET_SEGMENTS
    ldi temp, 2
    cpi tens, 2
    breq a_SET_SEGMENTS
    ldi temp, 3
    cpi tens, 3
    breq a_SET_SEGMENTS
    ldi temp, 4
    cpi tens, 4
    breq a_SET_SEGMENTS
    ldi temp, 5
    cpi tens, 5
    breq a_SET_SEGMENTS
    ldi temp, 6
    cpi tens, 6
    breq a_SET_SEGMENTS
    ldi temp, 7
    cpi tens, 7
    breq a_SET_SEGMENTS
    ldi temp, 8
    cpi tens, 8
    breq a_SET_SEGMENTS
    ldi temp, 9
    cpi tens, 9
    breq a_SET_SEGMENTS
    
a_SET_SEGMENTS:
    IN R27, PINA
    MOV R28, R27
    LDI R29, 0b11111111
    EOR R29, R28
    BREQ here1
    out PORTC, temp          ; Output to 7-segment display
    RET

here1:
    LDI R28, 9
    SUB R28, temp
    out PORTC, R28          ; Output to 7-segment display
    RET

; Display ones place on the right 7-segment display
a_DISPLAY_ONES:
    ; Map ones digit to 7-segment code
    ldi temp, 0
    cpi ones, 0
    breq a_SET_SEGMENTS_ONES
    ldi temp, 1
    cpi ones, 1
    breq a_SET_SEGMENTS_ONES
    ldi temp, 2
    cpi ones, 2
    breq a_SET_SEGMENTS_ONES
    ldi temp, 3
    cpi ones, 3
    breq a_SET_SEGMENTS_ONES
    ldi temp, 4
    cpi ones, 4
    breq a_SET_SEGMENTS_ONES
    ldi temp, 5
    cpi ones, 5
    breq a_SET_SEGMENTS_ONES
    ldi temp, 6
    cpi ones, 6
    breq a_SET_SEGMENTS_ONES
    ldi temp, 7
    cpi ones, 7
    breq a_SET_SEGMENTS_ONES
    ldi temp, 8
    cpi ones, 8
    breq a_SET_SEGMENTS_ONES
    ldi temp, 9
    cpi ones, 9
    breq a_SET_SEGMENTS_ONES
a_SET_SEGMENTS_ONES:
    IN R27, PINA
    MOV R28, R27
    LDI R29, 0b11111111
    EOR R29, R28
    BREQ here2
    out PORTD, temp          ; Output to 7-segment display
    RET

here2:
    LDI R28, 9
    SUB R28, temp
    out PORTD, R28          ; Output to 7-segment display
    RET