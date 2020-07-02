; Bressenham Line drawing

LDA #03 ; x0 [#00 - #31]
STA $00 
LDA #04 ; y0 [#00 - #31]
STA $01
LDA #30 ; x1 [#00 - #31]
STA $02
LDA #20 ; y1 [#00 - #31]
STA $03
LDA #05 ; color [#00 - #15]
STA $04

JSR draw_line
JMP exit

draw_line: ; $00 = x0, $01 = y0, $02 = x1, $03 = y1, $04 = color
  LDA #0
  STA $07 ; initialize x flag
  STA $08 ; initialize y flag
  STA $09 ; initialize slope flag

  LDA $00
  CMP $02
  BCC dl_x_complement ; take twos-complement of xs if x1 < x0
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
  dl_x_complement:

  LDA $01
  CMP $03
  BCC dl_y_complement ; take twos-complement of ys if y1 < y0
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
  dl_y_complement:

  CLC
  LDA $02
  SBC $00  ; dx = x1 - x0
  STA $05

  CLC
  LDA $03
  TAY ; save y1 to set as loop end
  SBC $01 ; dy = y1 - y0
  STA $03

  ; swap x and y to handle slope > 0.5
  CMP $05
  BCC dl_slope
  BEQ dl_slope
  STY $02 ; set y as end loop
  LDX $05 ; swap dy and dx
  STA $05
  STX $03
  LDX #1 ; set slope flag
  STX $09
  dl_slope:

  CLC
  ASL A
  SBC $05
  STA $06 ; E = 2dy - dx 

  CLC
  LDA $03
  SBC $05
  ASL A
  STA $05 ; k = 2 (dy - dx) 
  ASL $03 ; i = 2dy

  LDX $00 ; transfer loop variables to registers
  LDY $01
  LDA $06

  dl_loop:
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
    BMI dll_error_i 
    PHA ; error (k) E > 0
    TYA
    CLC
    ADC #1 ; y = y + 1
    TAY
    PLA
    CLC
    ADC $05 ; E = E + k
    JMP dll_error_skip

    dll_error_i: ; error (i) E > 0
    ADC $03 ; E = E + i
    dll_error_skip:
    PHA
    TXA
    CLC
    ADC #1 ; x = x + 1
    TAX
    PLA

    CPX $02
    BCC dl_loop
    BEQ dl_loop
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
  LDA $04 ; color
  LDY #0
  STA ($10),Y 
  RTS

handle_flags:
  LDA $09
  CMP #0
  BEQ hf_end_slope
  TXA
  PHA
  TYA
  TAX
  PLA
  TAY
  hf_end_slope:

  LDA $07
  CMP #0
  BEQ hf_end_x
  TXA
  JSR twos_complement
  CLC
  ADC #31
  TAX
  hf_end_x:

  LDA $08
  CMP #0
  BEQ hf_end_y
  TYA 
  JSR twos_complement
  CLC
  ADC #31
  TAY
  hf_end_y:
  RTS

twos_complement:
  EOR #$FF
  SEC
  ADC #0
  RTS

exit:
