; Bressenham Line drawing

LDA #3
STA $00 ; x0 
LDA #4
STA $01 ; y0
LDA #30
STA $02 ; x1
LDA #20
STA $03 ; y1

JSR draw_line
JMP exit

draw_line: ; $00 = x0, $01 = y0, $02 = x1, $03 = y1
  CLC
  LDA $02
  SBC $00
  STA $04 ; dx = x1 - x0

  CLC
  LDA $03
  SBC $01
  STA $03 ; dy = y1 - y0

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

  dl_loop:
    PHA ; push registeres to stack
    TXA
    PHA
    TYA
    PHA
    JSR draw_pixel
    PLA ; pull registers from stack
    TAY 
    PLA
    TAX 
    PLA

    CMP #0
    BCC dll_error_k

    CLC ; E < 0 
    INY ; y = y + 1
    ADC $04 ; E = E + k
    JMP dll_error_i

    dll_error_k: ; E > 0
    ADC $03 ; E = E + i
    dll_error_i:

    INX ; ++x
    CPX $02
    BCC dl_loop
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

exit:
