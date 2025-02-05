.INCLUDE "m32def.inc"
.ORG 0

.def temp = R20            ; Temporary register
.def counter = R21         ; Seconds counter
.def loop_count = R22      ; Loop counter for 1-second delay
.def tens = R23            ; Tens place
.def ones = R24            ; Ones place

.equ OCR_VALUE = 15        ; OCR0 value for 16 ms delay
.equ ITERATIONS = 61       ; Number of iterations for 1 second



LDI R16, HIGH(RAMEND)  ; Load high byte of end of RAM
OUT SPH, R16           ; Set stack pointer high byte
LDI R16, LOW(RAMEND)   ; Load low byte of end of RAM
OUT SPL, R16           ; Set stack pointer low byte

CALL RESET


main:
    RJMP mode_a

mode_a:
    CALL switch_modes

    LDI R21, 0b00000000 ;clear
    OUT PORTB, R21
    LDI R21, 0b01111010 ;d
    OUT PORTA, R21
    CALL delay
    LDI R21, 0b11011110 ;e
    OUT PORTA, R21
    LDI R21, 0b01111010 ;d
    OUT PORTB, R21
    CALL delay
    LDI R21, 0b00011100 ;L
    OUT PORTA, R21
    LDI R21, 0b11011110 ;e
    OUT PORTB, R21
    CALL delay
    LDI R21, 0b01100000 ;i
    OUT PORTA, R21
    LDI R21, 0b00011100 ;L
    OUT PORTB, R21
    CALL delay
    LDI R21, 0b00000000 ;clear
    OUT PORTA, R21
    LDI R21, 0b01100000 ;i
    OUT PORTB, R21
    CALL delay
    
    JMP mode_a

mode_b:
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
    MAIN_LOOP:
    ; Delay for 1 second using Timer0
    CALL switch_modes
    ldi loop_count, ITERATIONS
    
    DELAY_LOOP:
    LDI R16, 0b00000000
    OUT PORTC, R16
    in temp, TIFR          ; Read TIFR
    sbrs temp, OCF0        ; Check if OCF0 is set
    rjmp DELAY_LOOP        ; Wait for compare match

    ldi temp, 1 << OCF0    ; Clear OCF0 flag
    out TIFR, temp

    dec loop_count         ; Decrement loop counter
    BRNE DELAY_LOOP        ; Repeat until 61 iterations

    ; Extract tens and ones places
    EXTRACT_TENS_AND_ONES:
        clr tens             ; Clear tens register
        clr ones             ; Clear ones register

        ; Calculate tens = counter / 10
        mov temp, counter    ; Copy counter to temp
        ldi tens, 0          ; Initialize tens to 0

    DIVIDE_BY_TEN:
        subi temp, 10        ; Subtract 10 from temp
        brmi DONE_DIVIDE     ; If temp < 0, division is complete
        inc tens             ; Increment tens counter
        rjmp DIVIDE_BY_TEN   ; Repeat

    DONE_DIVIDE:
        LDI R26, 10
        add temp, R26         ; Add back 10 to temp to get the remainder
        mov ones, temp       ; Store remainder (ones digit) in ones register
        ;ret                  ; Return to main program

    ; Display tens place (left 7-segment display)
    call DISPLAY_TENS

    ; Display ones place (right 7-segment display)
    call DISPLAY_ONES
    
    ; Increment counter
    inc counter            ; Increment seconds counter
    cpi counter, 60        ; Check if 60 seconds reached
    brne MAIN_LOOP         ; If not, repeat

    clr counter            ; Reset counter after 60 seconds
    rjmp MAIN_LOOP         ; Repeat

DISPLAY_TENS:
    ; Map tens digit to 7-segment code
    ldi temp, 0b11111100
    cpi tens, 0
    breq SET_SEGMENTS
    ldi temp, 0b01100000
    cpi tens, 1
    breq SET_SEGMENTS
    ldi temp, 0b11011010
    cpi tens, 2
    breq SET_SEGMENTS
    ldi temp, 0b11110010
    cpi tens, 3
    breq SET_SEGMENTS
    ldi temp, 0b01100110
    cpi tens, 4
    breq SET_SEGMENTS
    ldi temp, 0b10110110
    cpi tens, 5
    breq SET_SEGMENTS
    ldi temp, 0b10111110
    cpi tens, 6
    breq SET_SEGMENTS
    ldi temp, 0b11100000
    cpi tens, 7
    breq SET_SEGMENTS
    ldi temp, 0b11111110
    cpi tens, 8
    breq SET_SEGMENTS
    ldi temp, 0b11110110
    cpi tens, 9
    breq SET_SEGMENTS
    
SET_SEGMENTS:
    out PORTB, temp         ; Output to 7-segment display
    RET

; Display ones place on the right 7-segment display
DISPLAY_ONES:
    ; Map ones digit to 7-segment code
    ldi temp, 0b11111101
    cpi ones, 0
    breq SET_SEGMENTS_ONES
    ldi temp, 0b01100000
    cpi ones, 1
    breq SET_SEGMENTS_ONES
    ldi temp, 0b11011011
    cpi ones, 2
    breq SET_SEGMENTS_ONES
    ldi temp, 0b11110010
    cpi ones, 3
    breq SET_SEGMENTS_ONES
    ldi temp, 0b01100111
    cpi ones, 4
    breq SET_SEGMENTS_ONES
    ldi temp, 0b10110110
    cpi ones, 5
    breq SET_SEGMENTS_ONES
    ldi temp, 0b10111111
    cpi ones, 6
    breq SET_SEGMENTS_ONES
    ldi temp, 0b11100000
    cpi ones, 7
    breq SET_SEGMENTS_ONES
    ldi temp, 0b11111111
    cpi ones, 8
    breq SET_SEGMENTS_ONES
    ldi temp, 0b11110110
    cpi ones, 9
    breq SET_SEGMENTS_ONES
SET_SEGMENTS_ONES:
    out PORTA, temp         ; Output to 7-segment display
    RET

mode_c:
    ; Reset PORTC to deactivate all rows
    CLR R16
    OUT PORTC, R16

    ; Check Row 1
    LDI R18, 0xFF
    row1:
    LDI R16, 0b00000001    ; Activate row 1
    OUT PORTC, R16
    SBIC PIND, 0           ; Check if column 0 is pressed
    RJMP key_7
    SBIC PIND, 1           ; Check if column 1 is pressed
    RJMP key_8
    SBIC PIND, 2           ; Check if column 2 is pressed
    RJMP key_9
    
    DEC R18
    BRNE row1

    
    ; Check Row 2
    LDI R18, 0xFF
    row2:
    LDI R16, 0b00000010    ; Activate row 2
    OUT PORTC, R16
    SBIC PIND, 0
    RJMP key_4
    SBIC PIND, 1
    RJMP key_5
    SBIC PIND, 2
    RJMP key_6
    SBIC PIND, 3
    JMP key_star
    
    DEC R18
    BRNE row2

    ; Check Row 3
    LDI R18, 0xFF
    row3:
    LDI R16, 0b00000100    ; Activate row 3
    OUT PORTC, R16
    SBIC PIND, 0
    RJMP key_1
    SBIC PIND, 1
    RJMP key_2
    SBIC PIND, 2
    RJMP key_3
    SBIC PIND, 3
    JMP key_minus
    
    DEC R18
    BRNE row3
    
    ; Check Row 4
    LDI R18, 0xFF
    row4:
    LDI R16, 0b00001000    ; Activate row 3
    OUT PORTC, R16
    SBIC PIND, 1
    RJMP key_0
    SBIC PIND, 3
    JMP key_plus
    SBIC PIND, 0
    JMP key_clear
    
    DEC R18
    BRNE row4

    JMP mode_c              ; Continue looping if no key is pressed


key_plus:
    LDI R21, 0b11111010
    OUT PORTB, R21         ; Output segment data to display
    LDI R21, 0b00000000
    OUT PORTA, R21         ; Output segment data to display
    CALL delay          ; delay to avoid multiple detections
    CALL delay          ; delay to avoid multiple detections
    CALL delay          ; delay to avoid multiple detections
    CALL delay          ; delay to avoid multiple detections
    CALL delay          ; delay to avoid multiple detections
    CALL delay          ; delay to avoid multiple detections
    JMP mode_a ; should be replaced with mode_a

key_clear:
    CALL RESET
    JMP mode_c
    
key_star:
    LDI R21, 0b10011100
    OUT PORTB, R21         ; Output segment data to display
    LDI R21, 0b00000000
    OUT PORTA, R21         ; Output segment data to display
    CALL delay          ; delay to avoid multiple detections
    CALL delay          ; delay to avoid multiple detections
    CALL delay          ; delay to avoid multiple detections
    CALL delay          ; delay to avoid multiple detections
    CALL delay          ; delay to avoid multiple detections
    CALL delay          ; delay to avoid multiple detections
    
    CALL RESET
    JMP mode_c
    
key_minus:
    LDI R21, 0b00111110
    OUT PORTB, R21         ; Output segment data to display
    LDI R21, 0b00000000
    OUT PORTA, R21         ; Output segment data to display
    CALL delay          ; delay to avoid multiple detections
    CALL delay          ; delay to avoid multiple detections
    CALL delay          ; delay to avoid multiple detections
    CALL delay          ; delay to avoid multiple detections
    CALL delay          ; delay to avoid multiple detections
    CALL delay          ; delay to avoid multiple detections
    CALL RESET
    JMP mode_b; should be replaced with mode_b
    

key_0:
    LDI R20, 0
    ST Z+, R20
    LDI R21, 0b11111100
    
    RJMP display_digit


key_1:
    LDI R20, 1
    ST Z+, R20
    LDI R21, 0b01100000
    
    RJMP display_digit

key_2:
    LDI R20, 2
    ST Z+, R20
    LDI R21, 0b11011010
    RJMP display_digit

key_3:
    LDI R20, 3
    ST Z+, R20
    LDI R21, 0b11110010
    RJMP display_digit

key_4:
    LDI R20, 4
    ST Z+, R20
    LDI R21, 0b01100110
    RJMP display_digit

key_5:
    LDI R20, 5
    ST Z+, R20
    LDI R21, 0b10110110
    RJMP display_digit

key_6:
    LDI R20, 6
    ST Z+, R20
    LDI R21, 0b10111110
    RJMP display_digit

key_7:
    LDI R20, 7
    ST Z+, R20             ; Save digit value
    LDI R21, 0b11100000    ; Segment encoding for 7
    RJMP display_digit

key_8:
    LDI R20, 8
    ST Z+, R20
    LDI R21, 0b11111110
    RJMP display_digit

key_9:
    LDI R20, 9
    ST Z+, R20
    LDI R21, 0b11110110
    RJMP display_digit

; ======== Display Digit ========
display_digit:
    CPI R30, 0x0066
    BREQ display_digit_1
    ;BCLR SREG_Z ;it is not neccessary because SREG_Z will be cleared if values are not equal
    CPI R30, 0x0067
    BREQ display_digit_2
    ;BCLR SREG_Z

display_digit_1:
    OUT PORTB, R21         ; Output segment data to display
    CALL delay          ; delay to avoid multiple detections   
    CALL delay          ; delay to avoid multiple detections   
    CALL delay          ; delay to avoid multiple detections   
    JMP mode_c              ; Return to mode_c routine
    
display_digit_2:
    OUT PORTA, R21         ; Output segment data to display
    CALL delay          ; delay to avoid multiple detections
    CALL delay          ; delay to avoid multiple detections
    JMP check_password             ; Return to check_password routine

delay:
    LDI R19, 0xFF
    deb_loop:
        NOP
        NOP
        DEC R19
        BRNE deb_loop
        DEC R18
        BRNE delay
        RET

check_password:
    LD R17, -Z
    LDS R18, 0x0081
    CP R17, R18
    BRNE light_red_up
    LD R17, -Z
    LDS R18, 0x0080
    CP R17, R18
    BRNE light_red_up
    JMP light_green_up
    
light_red_up:
    SBI PORTC, 5
    CALL delay
    CALL delay
    CALL RESET
    JMP mode_C
light_green_up:
    SBI PORTC, 4
    CALL delay
    CALL delay
    CALL RESET
    JMP mode_C
    
    
RESET:
    ; Set PORTC and PORTA as output
    LDI R16, 0xFF
    OUT DDRC, R16
    OUT DDRA, R16
    OUT DDRB, R16
    ;OUT PORTD, R16

    ; Set PORTD as input with pull-up resistors enabled
    LDI R16, 0x00
    OUT DDRD, R16
    
    
    OUT PORTC, R16
    OUT PORTA, R16
    OUT PORTB, R16
    
    ;OUT PORTD, R16
    

    LDI R25, 0x0065 ;initialize ram loc
    MOV R30, R25 ;Z now points to 0x0065
    CLR R31
    
    LDI R16, 8 ;our password stored here
    STS 0x0080, R16
    LDI R16, 2
    STS 0x0081, R16
    
    CLR R21                ; Clear R21 (segment control register)
    RET


switch_modes:
    CLR R16
    OUT PORTC, R16
    
    ; Check Row 2
    LDI R18, 0xFF
    arow2:
    LDI R16, 0b00000010    ; Activate row 2
    OUT PORTC, R16
    SBIC PIND, 3
    JMP key_star
    
    DEC R18
    BRNE arow2

    ; Check Row 3
    LDI R18, 0xFF
    arow3:
    LDI R16, 0b00000100    ; Activate row 3
    OUT PORTC, R16
    SBIC PIND, 3
    JMP key_minus
    
    DEC R18
    BRNE arow3
    
    ; Check Row 4
    LDI R18, 0xFF
    arow4:
    LDI R16, 0b00001000    ; Activate row 3
    OUT PORTC, R16
    SBIC PIND, 3
    JMP key_plus
    
    DEC R18
    BRNE arow4
    RET