; Matrix multiplication
define  MatrixA   $0010 ; Matrix A
define  MatrixB   $0019 ; Matrix B
define  CellSum   $0022 ;
define  CellIndex $0023 ;
define  MultLow   $0024 ; multiply A
define  MultHigh  $0025 ; multiply B
define  RowIndex  $0026 ; 

LDX #1
LDA #1
STA $10
LDA #2
STA $11
LDA #3
STA $12
LDA #1
STA $13
LDA #2
STA $14
LDA #3
STA $15
LDA #1
STA $16
LDA #2
STA $17
LDA #3
STA $18
LDA #1
STA $19
LDA #2
STA $1a
LDA #3
STA $1b
LDA #1
STA $1c
LDA #2
STA $1d
LDA #3
STA $1e
LDA #1
STA $1f
LDA #2
STA $20
LDA #3
STA $21
LDY #0
LDX #0


MATRIX_MULT: ; MatrixA x MatrixB -> MatrixA
  LDX #0
  JSR MM_ROW_MULT
  LDX #3
  JSR MM_ROW_MULT
  LDX #6
  JSR MM_ROW_MULT
  RTS

MM_ROW_MULT: ; X = starting cell number
  STX RowIndex
  LDY #0
  MMRM_LOOP:
    JSR MM_CELL_MULT
    PHA ; save cell result
    LDX RowIndex
    CPY #8
    BCC MMRM_LOOP
  INX
  INX
  MMRM_SAVE:
    PLA
    STA MatrixA,X 
    DEX
    CPX RowIndex
    BPL MMRM_SAVE
  RTS

MM_CELL_MULT: ; X = Matrix A Cell, Y = Matrix B Cell, A = Result
  TXA
  CLC
  ADC #2
  STA CellIndex
  LDA #0
  STA CellSum
  MMCM_LOOP:
    LDA MatrixA,X 
    STA MultLow
    LDA MatrixB,Y
    STA MultHigh
    JSR MULT
    LDA MultLow
    CLC
    ADC CellSum
    STA CellSum
    INX
    INY
    CPX CellIndex
    BCC MMCM_LOOP
    BEQ MMCM_LOOP
  LDA CellSum
  RTS

MULT: ; MultLow x MultHigh = MultHigh MultLow
  TXA
  PHA
  LDA #0
  LDX #8
  LSR MultLow
  M_L1:
  BCC M_L2
  CLC
  ADC MultHigh
  M_L2:
  ROR
  ROR MultLow
  DEX
  BNE M_L1
  STA MultHigh
  PLA
  TAX
  RTS

  EXIT: