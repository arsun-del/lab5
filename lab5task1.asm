;make a program that sums 5 numbers from a list
; like a normal for loop
; for (int i = 0; i < 5; i++)
; sum += m[i]
;label  opcode  registers  ; comment

        .ORG $5000
LENGTH  .DW $4
SUM     .DW $0000 ; more significant digits
        .DW $0000 ; less significant digits

        .ORG $5A00
ARRAY   .DW $1 ; more significant digits
        .DW $1 ; less significant digits
        .DW $2
        .DW $3
        .DW $5
        .DW $8
        .DW $d
        .DW $15
        .DW $dead
        .DW $beef
        .DW $1234
        .DW $5678

        .ORG $0010         
        LI r1, $0          ; r1 = sum
        LI r2, $0          ; r2 = addr
        LI r3, $0          ; r3 = carry_sum
        LW r4, r0, LENGTH  
        SLLI r4, r4, $2    ; r4 = 4*length
        LI r5, $0          ; mem[ARRAY+addr] curr element

; start summing the lowers and the carry bits from the lowers       
        LI r2, $2          ; start at addr = 2
lowers  SLT r0, r4, r2     ; (addr >= 4*length)? (r4-r2)
        BRNZ ldone
        LW r5, r2, ARRAY   ;
        ADD r1, r1, r5     ; sum += r5
        ; we have a carry flag here, so use it
        ; if carry, go to carry, else, nothing
        BRC carry
        BRA none1
carry   ADDI r3, r3, $1    ; carrysum += 1
        ; at this point I should have summed into my registers
none1   ADDI r2, r2, $4    ; addr += 4
        BRA lowers

ldone   LI r5, $2
        SW r5, r1, SUM     ; store lower sum into lower sum
        MV r5, r0          ; clear r5 

; reset important values
        LI r1, $0          ; r1 = sum
        LI r2, $0          ; r2 = addr

; start summing the uppers
        
upper   SLT r0, r4, r2     ; if(rs4 < rs2) r0 ← 16’b1 set flags N or Z
        BRNZ udone
        LW r5, r2, ARRAY
        ADD r1, r1, r5
        ADDI r2, r2, $4
        BRA upper

udone   SW r0, r1, SUM
        MV r1, r0
        

; sum the uppers and carries from the lowers.
; use r1 to get the upper sum, then add r1 and r3
; restore into upper SUM

        LW r1, r0, SUM
        ADD r1, r1, r3
        SW r0, r1, SUM

done    stop               ; 0022
