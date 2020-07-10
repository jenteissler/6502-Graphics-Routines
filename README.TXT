6502 Line Drawing Graphics routines
Author: Jennifer Teissler
--------------------------------------------------------------------
WHERE TO RUN THE CODE

These 6502 assembly routines have been modified to run on the online
6502 emulator (https://skilldrick.github.io/easy6502/simulator.html)
to allow for easy execution.

All files (except fp.asm) included can be pasted directly into the
text-field of the emulator. To run them just click "Assemble" then
"Run". Let it be noted that the floating point algorithms only draw 
horizontal and vertical lines very slowly.

-------------------------------------------------------------------
INCLUDED ALGORITHMS & DEMOS

> algorithms - contains the standalone line drawing algorithms as
               well as a library "fp.asm" for doing floating
               point arithmetic (not native to the 6502)

               These lines at the top of these bresenham.asm and 
               simple.asm files can be changed to change the line
               that is drawn (the "function header" essentially).

                LDA #10 ; x0 [#00 - #31]
                LDA #10 ; y0 [#00 - #31]
                LDA #30 ; x1 [#00 - #31]
                LDA #20 ; y1 [#00 - #31]
                LDA #05 ; color [#01 - #15]

> demo_programs - contains 3 identical demonstration programs for 
                  each algorithm. The "provided" files run the
                  provided test cases. The "rainbow" files draw a 
                  series of lines in and on the borders of all 
                  octants. The "random" files draw a specified 
                  number of lines at random locations with
                  random colors.

                  For the random demos, the number of lines drawn
                  can be changed by adjusting this line at the
                  top of the file.

                   LDA #10 ; N number of lines (base-10, up to 255)

-------------------------------------------------------------------