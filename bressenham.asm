; Bressenham Line drawing

LDA #30; x0 
STA $00 
LDA #04 ; y0
STA $01
LDA #03 ; x1
STA $02
LDA #20 ; y1
STA $03

JSR draw_line
JMP exit

draw_line: ; $00 = x0, $01 = y0, $02 = x1, $03 = y1
  LDA #1
  STA $06 ; initialize x counter
  STA $07 ; initialize y counter
  STA $08 ; initalize slope flag

; swap start and end coords if any delta is negative
;  LDA $00
;  CMP $02
;  BCC dl_no_x_swap
 ; LDA $00
 ; PHA
;  LDA $02
;  STA $00
;  PLA
;  STA $02
;  dl_no_x_swap:

;  LDA $01
 ; CMP $03
;  BCC dl_no_y_swap
;  LDA $01
;  PHA
;  LDA $03
 ; STA $01
  ;PLA
  ;STA $03
  ;dl_no_y_swap:
  ; END CHANGE

  CLC
  LDA $02
  SBC $00  ; dx = x1 - x0
  BPL dl_dx_positive 
  JSR twos_complement ; correct negative delta
  LDX #$FF
  STA $06
  ;PHA
  ;LDA #$FF ; set x counter to -1
  ;STA $06
  ;PLA
  dl_dx_positive:
  STA $04

  CLC
  LDA $03
  TAY ; save y1
  SBC $01 ; dy = y1 - y0
  BPL dl_dy_positive
  JSR twos_complement ; correct negative delta
  STX $07
  ;PHA
  ;LDA #$FF ; set y counter to -1
  ;STA $07
  ;PLA
  dl_dy_positive:
  STA $03

  ; if dy greater swap?
  CMP $04
  BCC dl_swap_skip
  STY $02 ; set y as end loop

  LDX $04 ; swap dy and dx
  STA $04
  STX $03

  LDY $07 ; swap x and y counters
  LDX $06
  STY $06
  STX $07

  LDX #0 ; set slope flag
  STX $08


  dl_swap_skip:


  CLC
  ASL A
  SBC $04
  STA $05 ; E = 2dy - dx 

  CLC
  LDA $03
  SBC $04
  ASL A
  STA $04 ; k = 2 (dy - dx) 

  ASL $03 ; i = 2dy

  LDX $00
  LDY $01
  LDA $05

; loop should be whichever delta is greater
  dl_loop:
    PHA ; push registers to stack
    TXA
    PHA
    TYA
    PHA

    LDA #1
    CMP $08
    BEQ dll_invert_skip
    TXA
    PHA
    TYA
    TAX
    PLA
    TAY
    dll_invert_skip:

    JSR draw_pixel
    PLA ; pull registers from stack
    TAY 
    PLA
    TAX 
    PLA

    CMP #0 ; E < 0
    BMI dll_error_i 
    PHA ; error (k) E > 0
    TYA
    CLC
    ADC $07 ; y = y +- 1
    TAY
    PLA
    ;INY
    CLC
    ADC $04 ; E = E + k
    JMP dll_error_skip

    dll_error_i: ; error (i) E > 0
    ADC $03 ; E = E + i
    dll_error_skip:
    PHA
    TXA
    CLC
    ADC $06 ; x = x +- 1
    TAX
    PLA
    ;INX

    CPX $02
    BEQ dl_loop_exit
    JMP dl_loop ; 
    dl_loop_exit:
  RTS

draw_pixel: ; X = [0,31], Y = [0,31]
  STY $10
  LDA #0
  STA $11
  LDY #0
  dp_loop: ; add y offset (x32)
    ASL $10
    ROL $11
    INY
    CPY #5
    BNE dp_loop
  CLC
  TXA
  ADC $10 ; add x offset
  STA $10
  LDA $11
  ADC #$02 ; add display buffer offset
  STA $11
  LDA #$1 ; color
  LDY #0
  STA ($10),Y 
  RTS

twos_complement:
  EOR #$FF
  SEC
  ADC #0
  RTS

multiply_unsigned:
  


exit:
