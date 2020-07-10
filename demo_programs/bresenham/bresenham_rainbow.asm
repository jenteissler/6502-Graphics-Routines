; Draws a pattern of lines using the bresenham line algorithm, demonstrating
; the implementation's line drawing capabilities
; Author: Jennifer Teissler

LDA #16 ; 1
STA $00 
LDA #16 
STA $01
LDA #28
STA $02
LDA #16
STA $03
LDA #$a
STA $04 
JSR draw_line

LDA #16 ; 2
STA $00 
LDA #16 
STA $01
LDA #28
STA $02
LDA #11
STA $03
LDA #$2
STA $04 
JSR draw_line

LDA #16 ; 3
STA $00 
LDA #16 
STA $01
LDA #28
STA $02
LDA #03
STA $03
LDA #$8
STA $04 
JSR draw_line

LDA #16 ; 4
STA $00 
LDA #16 
STA $01
LDA #20
STA $02
LDA #03
STA $03
LDA #$7
STA $04 
JSR draw_line

LDA #16 ; 5
STA $00 
LDA #16 
STA $01
LDA #16
STA $02
LDA #03
STA $03
LDA #$d
STA $04 
JSR draw_line

LDA #16 ; 6
STA $00 
LDA #16 
STA $01
LDA #11
STA $02
LDA #03
STA $03
LDA #$5
STA $04 
JSR draw_line

LDA #16 ; 7
STA $00 
LDA #16 
STA $01
LDA #03
STA $02
LDA #03
STA $03
LDA #$e
STA $04 
JSR draw_line

LDA #16 ; 8
STA $00 
LDA #16 
STA $01
LDA #03
STA $02
LDA #11
STA $03
LDA #$4
STA $04 
JSR draw_line

LDA #16 ; 9
STA $00 
LDA #16 
STA $01
LDA #03
STA $02
LDA #16
STA $03
LDA #$a
STA $04 
JSR draw_line

LDA #16 ; 10
STA $00 
LDA #16 
STA $01
LDA #03
STA $02
LDA #21
STA $03
LDA #$2
STA $04 
JSR draw_line

LDA #16 ; 11
STA $00 
LDA #16 
STA $01
LDA #03
STA $02
LDA #28
STA $03
LDA #$8
STA $04 
JSR draw_line

LDA #16 ; 12
STA $00 
LDA #16 
STA $01
LDA #11
STA $02
LDA #28
STA $03
LDA #$7
STA $04 
JSR draw_line

LDA #16 ; 13
STA $00 
LDA #16 
STA $01
LDA #16
STA $02
LDA #28
STA $03
LDA #$d
STA $04 
JSR draw_line

LDA #16 ; 14
STA $00 
LDA #16 
STA $01
LDA #20
STA $02
LDA #28
STA $03
LDA #$5
STA $04 
JSR draw_line

LDA #16 ; 15
STA $00 
LDA #16 
STA $01
LDA #28
STA $02
LDA #28
STA $03
LDA #$e
STA $04 
JSR draw_line

LDA #16 ; 16
STA $00 
LDA #16 
STA $01
LDA #28
STA $02
LDA #22
STA $03
LDA #$4
STA $04 
JSR draw_line
JMP EXIT

draw_line: ; $00 = x0, $01 = y0, $02 = x1, $03 = y1, $04 = color
  LDA #0
  STA $07 ; initialize x flag
  STA $08 ; initialize y flag
  STA $09 ; initialize slope flag

  LDA $02
  SEC
  SBC $00  ; dx = x1 - x0
  BPL dbl_x_pos
  JSR twos_complement
  dbl_x_pos:
  STA $05
  LDX #1

  LDA $03
  SEC
  SBC $01  ; dy = y1 - y0
  BPL dbl_y_pos
  JSR twos_complement
  dbl_y_pos:
  LDX #2

  ; collapse all calculations into odd octants
  CMP $05
  BCC dbl_slope_normal
  LDX #3
  LDX $00
  LDY $01
  STY $00
  STX $01
  LDX $02
  LDY $03
  STY $02
  STX $03
  LDX #1 ; set slope flag
  STX $09
  dbl_slope_normal:
  LDX #4

  ; collapse all calculations into the first octant
  LDA $00
  CMP $02
  BCC dbl_x_complement ; take twos-complement of xs if x1 < x0
  BEQ dbl_x_complement
  LDA $00
  JSR twos_complement
  CLC
  ADC #31
  STA $00
  LDA $02
  JSR twos_complement
  CLC
  ADC #31
  STA $02
  LDA #1
  STA $07 ; set x flag
  dbl_x_complement:

  LDA $01
  CMP $03
  BCC dbl_y_complement ; take twos-complement of ys if y1 < y0
  BEQ dbl_y_complement
  LDA $01
  JSR twos_complement
  CLC
  ADC #31
  STA $01
  LDA $03
  JSR twos_complement
  CLC
  ADC #31
  STA $03
  LDA #1 
  STA $08 ; set y flag
  dbl_y_complement:
  
  LDA $02
  SEC
  SBC $00  ; dx = x1 - x0
  STA $05

  LDA $03
  TAY ; save y1 to set as loop end
  SEC
  SBC $01 ; dy = y1 - y0
  STA $03

  ASL A
  SEC
  SBC $05
  STA $06 ; E = 2dy - dx 

  LDA $03
  SEC
  SBC $05
  ASL A
  STA $05 ; k = 2 (dy - dx) 
  ASL $03 ; i = 2dy

  LDX $00 ; transfer loop variables to registers
  LDY $01
  LDA $06

  dbl_loop:
    CPX $02
    BCS dbl_loop_end
    PHA ; save register state
    TXA
    PHA
    TYA
    PHA
    JSR handle_flags
    JSR draw_pixel
    PLA ; restore register state
    TAY 
    PLA
    TAX 
    PLA

    CMP #0 ; E < 0
    BMI dbll_error_i ; error (k) E >= 0
    INY
    CLC
    ADC $05 ; E = E + k
    JMP dbll_error_skip

    dbll_error_i: ; error (i) E < 0
    CLC
    ADC $03 ; E = E + i
    dbll_error_skip:
    INX

    JMP dbl_loop
    dbl_loop_end:
  RTS
             
draw_pixel: ; X = [0,31], Y = [0,31]
  STY $0A
  LDA #0
  STA $0B
  LDY #0
  dp_loop: ; add y offset (x32)
    ASL $0A
    ROL $0B
    INY
    CPY #5
    BNE dp_loop
  CLC
  TXA
  ADC $0A ; add x offset
  STA $0A
  LDA $0B
  ADC #$02 ; add display buffer offset
  STA $0B
  LDA $04 ; color
  LDY #0
  STA ($0A),Y 
  RTS

handle_flags: ; undo transformations to get correct coordinates
  LDA $08
  CMP #0
  BEQ hf_end_y ; twos-complement y value if y flag set
  TYA 
  JSR twos_complement
  CLC
  ADC #31
  TAY
  hf_end_y:

  LDA $07
  CMP #0
  BEQ hf_end_x ; twos-complement x value if x flag set
  TXA
  JSR twos_complement
  CLC
  ADC #31
  TAX
  hf_end_x:

  LDA $09
  CMP #0
  BEQ hf_end_slope ; swap x and y if slope flag set
  TXA 
  PHA
  TYA
  TAX
  PLA
  TAY
  hf_end_slope:
  RTS

twos_complement:
  EOR #$FF
  SEC
  ADC #0
  RTS

EXIT:
