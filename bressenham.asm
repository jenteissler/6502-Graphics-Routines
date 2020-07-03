; Bressenham Line drawing

LDA #10 ; x0 [#00 - #31]
STA $00 
LDA #15 ; y0 [#00 - #31]
STA $01
LDA #20 ; x1 [#00 - #31]
STA $02
LDA #10 ; y1 [#00 - #31]
STA $03
LDA #05 ; color [#00 - #15]
STA $04

JSR draw_line
JMP exit

draw_line: ; $00 = x0, $01 = y0, $02 = x1, $03 = y1, $04 = color
  CLC
  LDA $02
  SBC $00  ; dx = x1 - x0
  BVC dl_x_pos
  JSR twos_complement
  STA $07
  dl_x_pos:

  CLC
  LDA $01
  SBC $03  ; dx = y1 - x1
  BVC dl_y_pos
  JSR twos_complement
  dl_y_pos:

  CMP $07
  BCC dl_slope_normal
  LDX $00
  LDY $01
  STY $00
  STX $01
  LDX $02
  LDY $03
  STY $02
  STX $03
  dl_slope_normal:

  LDA #0
  STA $07 ; initialize x flag
  STA $08 ; initialize y flag
  STA $09 ; initialize slope flag





  ; collapse all calculations into the first quadrant
  LDA $00
  CMP $02
  BCC dl_x_complement ; take twos-complement of xs if x1 < x0
  BEQ dl_x_complement
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
  BEQ dl_y_complement
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
  CLC
  SBC $01 ; dy = y1 - y0
  STA $03

  ; collapse all calculations into the first octant
  ;CMP $05 ; dy <= dx ?
  ;BCC dl_slope
  ;BEQ dl_slope
  ;STY $02 ; set y as end loop
  ;LDX $05 ; swap dy and dx
  ;STA $05
  ;STX $03
  ;LDX #1 ; set slope flag
  ;STX $09
  ;dl_slope:

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
    CPX $02
    BCS dl_loop_end
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
    PHA ; error (k) E >= 0
    INY
    CLC
    ADC $05 ; E = E + k
    JMP dll_error_skip

    dll_error_i: ; error (i) E < 0
    CLC
    ADC $03 ; E = E + i
    dll_error_skip:
    INX

    JMP dl_loop
    dl_loop_end:
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
  BEQ hf_end_slope ; swap x and y if slope flag set
  TXA 
  PHA
  TYA
  TAX
  PLA
  TAY
  hf_end_slope:

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
  RTS

twos_complement:
  EOR #$FF
  SEC
  ADC #0
  RTS

exit:
