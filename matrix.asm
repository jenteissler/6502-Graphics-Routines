; Matrix multiplication
define  MatrixA   $0010 ; Matrix A
define  MatrixB   $0019 ; Matrix B
define  CellSum   $0022 ;
define  CellIndex $0023 ;
define  MultLow   $0024 ; multiply A
define  MultHigh  $0025 ; multiply B
define  RowIndex  $0026 ; 

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
    BCS MMRM_SAVE
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
    CLC
    ADC CellSum
    STA CellSum
    INX
    INY
    CPX CellIndex
    BCC MMCM_LOOP
  LDA CellSum
  RTS

MULT: ; MultLow x MultHigh = MultHigh MultLow
  LDA #0
  LDX #8
  LSR MLTA
  M_L1:
  BCC M_L2
  CLC
  ADC MLTB
  M_L2:
  ROR
  ROR MLTA
  DEX
  BNE M_L1
  STA MLTB
  RTS

  EXIT: