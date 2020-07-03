LDX #$00
LDA #$01
loop:
STA $0200,X
INX
CPX #$20
BCC loop

