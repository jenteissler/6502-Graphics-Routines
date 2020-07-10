; Draws a pattern of lines using the simpleline algorithm, demonstrating
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
  BPL dsl_x_pos
  JSR twos_complement
  dsl_x_pos:
  STA $05

  LDA $03
  SEC
  SBC $01  ; dy = y1 - y0
  BPL dsl_y_pos
  JSR twos_complement
  dsl_y_pos:

  ; collapse all calculations into odd octants
  CMP $05
  BCC dsl_slope_normal
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
  dsl_slope_normal:

  ; collapse all calculations into the first octant
  LDA $00
  CMP $02
  BCC dsl_x_complement ; take twos-complement of xs if x1 < x0
  BEQ dsl_x_complement
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
  dsl_x_complement:

  LDA $01
  CMP $03
  BCC dsl_y_complement ; take twos-complement of ys if y1 < y0
  BEQ dsl_y_complement
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
  dsl_y_complement:

  LDA $02
  SEC
  SBC $00  ; dx = x1 - x0
  STA $05

  LDA $03
  SEC
  SBC $01 ; dy = y1 - y0
  STA $03

; convert data into floating point numbers
  LDA #0
  STA $16
  LDA $03
  STA $17
  JSR FLOAT
  LDA $15 ; store dy
  STA $30
  LDA $16
  STA $31
  LDA $17
  STA $32
  LDA $18
  STA $33 ; dy = $30

  LDA #0
  STA $16
  LDA $05
  STA $17
  JSR FLOAT ; dx = $15

  LDA $30 ; load dy
  STA $11
  LDA $31
  STA $12
  LDA $32
  STA $13
  LDA $33
  STA $14
  JSR FDIV ; calculate slope
  LDA $15
  STA $30
  LDA $16
  STA $31
  LDA $17
  STA $32
  LDA $18
  STA $33 ; dy/dx = $30

  LDY #00
  STY $16
  LDY $01
  STY $17
  JSR FLOAT
  LDA $15
  STA $34
  LDA $16
  STA $35
  LDA $17
  STA $36
  LDA $18
  STA $37 ; y = $34

  LDX $00 ; x

  dsl_loop:
    TXA
    PHA ; save register state

    LDA $30 ; load slope
    STA $15
    LDA $31
    STA $16
    LDA $32
    STA $17
    LDA $33
    STA $18
    LDA $34 ; load y
    STA $11
    LDA $35
    STA $12
    LDA $36
    STA $13
    LDA $37
    STA $14
    JSR FADD ; y += slope
    LDA $15
    STA $34
    LDA $16
    STA $35
    LDA $17
    STA $36
    LDA $18
    STA $37
    JSR FIX ; convert y to integer

    LDY $17 ; pass y param
    PLA 
    TAX     ; pass x param
    PHA     ; save register
    JSR handle_flags
    JSR draw_pixel
    PLA
    TAX ; restore register
    
    INX
    CPX $02
    BCC dsl_loop
    BEQ dsl_loop
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

; Extract from Dr.Dobb's Journal, August 1976 (pages 17-19)
; Authors: Roy Rankin & Steve Wozniak
; Modified by Jennifer Teissler
ADD:    CLC         ; CLEAR CARRY
        LDX #$02    ; INDEX FOR 3-BYTE ADD
ADD1:   LDA $16,X   ; 
        ADC $12,X   ; ADD A BYTE OF MANT2 TO MANT1
        STA $16,X   ; 
        DEX         ; ADVANCE INDEX TO NEXT MORE SIGNIF.BYTE
        BPL ADD1    ; LOOP UNTIL DONE.
        RTS         ; RETURN
MD1:    ASL $10     ; CLEAR LSB OF $10
        JSR ABSWAP  ; ABS VAL OF MANT1, THEN SWAP MANT2
ABSWAP: BIT $16     ; MANT1 NEG?
        BPL ABSWP1  ; NO,SWAP WITH MANT2 AND RETURN
        JSR FCOMPL  ; YES, COMPLIMENT IT.
        INC $10     ; INCR SIGN, COMPLEMENTING LSB
ABSWP1: SEC         ; SET CARRY FOR RETURN TO MUL/DIV
SWAP:   LDX #$04    ; INDEX FOR 4-BYTE SWAP.
SWAP1:  STY $18,X   ; 
        LDA $14,X   ; SWAP A BYTE OF EXP/MANT1 WITH
        LDY $10,X   ; EXP/MANT2 AND LEAVEA COPY OF
        STY $14,X   ; MANT1 IN E(3BYTES). E+3 USED.
        STA $10,X   ; 
        DEX         ; ADVANCE INDEX TO NEXT BYTE
        BNE SWAP1   ; LOOP UNTIL DONE.
        RTS         ;
FLOAT:  LDA #$8E    ;
        STA $15     ; SET EXPN TO 14 DEC
        LDA #0      ; CLEAR LOW ORDER BYTE
        STA $18     ;
        BEQ NORM    ; NORMALIZE RESULT
NORM1:  DEC $15     ; DECREMENT EXP1
        ASL $18     ;
        ROL $17     ; SHIFT MANT1 (3 BYTES) LEFT
        ROL $16     ;
NORM:   LDA $16     ; HIGH ORDER MANT1 BYTE
        ASL         ; UPPER TWO BITS UNEQUAL?
        EOR $16     ;
        BMI RTS1    ; YES,RETURN WITH MANT1 NORMALIZED
        LDA $15     ; EXP1 ZERO?
        BNE NORM1   ; NO, CONTINUE NORMALIZING
RTS1:   RTS         ; RETURN
FSUB:   JSR FCOMPL  ; CMPL MANT1 CLEARS CARRY UNLESS ZERO
SWPALG: JSR ALGNSW  ; RIGHT SHIFT MANT1 OR SWAP WITH MANT2 ON CARRY
FADD:   LDA $11     ;
        CMP $15     ; COMPARE EXP1 WITH EXP2
        BNE SWPALG  ; IF UNEQUAL, SWAP ADDENDS OR ALIGN MANTISSAS
        JSR ADD     ; ADD ALIGNED MANTISSAS
ADDEND: BVC NORM    ; NO OVERFLOW, NORMALIZE RESULTS
        BVS RTLOG   ; OV: SHIFT MANT1 RIGHT. NOTE CARRY IS CORRECT SIGN
ALGNSW: BCC SWAP    ; SWAP IF CARRY CLEAR, ELSE SHIFT RIGHT ARITH.
RTAR:   LDA $16     ; SIGN OF MANT1 INTO CARRY FOR
        ASL         ; RIGHT ARITH SHIFT
RTLOG:  INC $15     ; INCR EXP1 TO COMPENSATE FOR RT SHIFT
        BEQ OVFL    ; EXP1 OUT OF RANGE.
RTLOG1: LDX #$FA    ; INDEX FOR 6 BYTE RIGHT SHIFT
ROR1:   LDA #$80    ; 
        BCS ROR2    ; 
        ASL         ; 
ROR2:   LSR $1C,X   ; SIMULATE ROR E+3,X
        ORA $1C,X   ; 
        STA $1C,X   ; 
        INX         ; NEXT BYTE OF SHIFT
        BNE ROR1    ; LOOP UNTIL DONE
        RTS         ; RETURN
FMUL:   JSR MD1     ; ABS. VAL OF MANT1, MANT2
        ADC $15     ; ADD EXP1 TO EXP2 FOR PRODUCT EXPONENT
        JSR MD2     ; CHECK PRODUCT EXP AND PREPARE FOR MUL
        CLC         ; CLEAR CARRY
MUL1:   JSR RTLOG1  ; MANT1 AND E RIGHT.(PRODUCT AND MPLIER)
        BCC MUL2    ; IF CARRY CLEAR, SKIP PARTIAL PRODUCT
        JSR ADD     ; ADD MULTIPLICAN TO PRODUCT
MUL2:   DEY         ; NEXT MUL ITERATION
        BPL MUL1    ; LOOP UNTIL DONE
MDEND:  LSR $10     ; TEST SIGN (EVEN/ODD)
NORMX:  BCC NORM    ; IF EXEN, NORMALIZE PRODUCT, ELSE COMPLEMENT
FCOMPL: SEC         ; SET CARRY FOR SUBTRACT
        LDX #$03    ; INDEX FOR 3 BYTE SUBTRACTION
COMPL1: LDA #$00    ; CLEAR A
        SBC $15,X   ; SUBTRACT BYTE OF EXP1
        STA $15,X   ; RESTORE IT
        DEX         ; NEXT MORE SIGNIFICANT BYTE
        BNE COMPL1  ; LOOP UNTIL DONE
        BEQ ADDEND  ; NORMALIZE (OR SHIFT RIGHT IF OVERFLOW)
FDIV:   JSR MD1     ; TAKE ABS VAL OF MANT1, MANT2
        SBC $15     ; SUBTRACT EXP1 FROM EXP2
        JSR MD2     ; SAVE AS QUOTIENT EXP
DIV1:   SEC         ; SET CARRY FOR SUBTRACT
        LDX #$02    ; INDEX FOR 3-BYTE INSTRUCTION
DIV2:   LDA $12,X   ; 
        SBC $19,X   ; SUBTRACT A BYTE OF E FROM MANT2
        PHA         ; SAVE ON STACK
        DEX         ; NEXT MORE SIGNIF BYTE
        BPL DIV2    ; LOOP UNTIL DONE
        LDX #$FD    ; INDEX FOR 3-BYTE CONDITIONAL MOVE
DIV3:   PLA         ; PULL A BYTE OF DIFFERENCE OFF STACK
        BCC DIV4    ; IF MANT2<E THEN DONT RESTORE MANT2
        STA $15,X   ; 
DIV4:   INX         ; NEXT LESS SIGNIF BYTE
        BNE DIV3    ; LOOP UNTIL DONE
        ROL $18     ; 
        ROL $17     ; ROLL QUOTIENT LEFT, CARRY INTO LSB
        ROL $16     ; 
        ASL $14     ; 
        ROL $13     ; SHIFT DIVIDEND LEFT
        ROL $12     ; 
        BCS OVFL    ; OVERFLOW IS DUE TO UNNORMALIZED DIVISOR
        DEY         ; NEXT DIVIDE ITERATION
        BNE DIV1    ; LOOP UNTIL DONE 23 ITERATIONS
        BEQ MDEND   ; NORMALIZE QUOTIENT AND CORRECT SIGN
MD2:    STX $18     ; 
        STX $17     ; CLR MANT1 (3 BYTES) FOR MUL/DIV
        STX $16     ; 
        BCS OVCHK   ; IF EXP CALC SET CARRY, CHECK FOR OVFL
        BMI MD3     ; IF NEG NO UNDERFLOW
        PLA         ; POP ONE
        PLA         ; RETURN LEVEL
        BCC NORMX   ; CLEAR X1 AND RETURN
MD3:    EOR #$80    ; COMPLIMENT SIGN BIT OF EXP
        STA $15     ; STORE IT
        LDY #$17    ; COUNT FOR 24 MUL OR 23 DIV ITERATIONS
        RTS         ; RETURN
OVCHK:  BPL MD3     ; IF POS EXP THEN NO OVERFLOW
OVFL:   JMP FAIL
FIXJ:   JSR RTAR    ; SHIFT MANT1 RT AND INCREMENT EXPNT
FIX:    LDA $15     ; CHECK EXPONENT
        CMP #$8E    ; IS EXPONENT 14?
        BNE FIXJ    ; NO, SHIFT
RTRN:   RTS         ; RETURN

FAIL:
        LDY #$2
        STY $21
        LDY #00
        STY $20
        LDA #$2
        PHA
        FLOOP:
          PLA
          STA ($20),Y
          PHA
          CLC
          LDA $20
          ADC #1
          STA $20
          LDA $21
          ADC #0
          STA $21
          CMP #$05
          BCC FF_CHECK
          LDA $20
          CMP #$FF
          BEQ EXIT
          FF_CHECK:
          JMP FLOOP
EXIT:
