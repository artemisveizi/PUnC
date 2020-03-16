    // Initial block:
/*1*/LD R1, #38 // Load A into R1 from mem[]
/*2*/LD R2, #39 // Load B into R2 from mem[]

    // If (a<=b) goto notLess
/*3*/NOT R2, R2 // Load -B into R2
/*4*/ADD R2, R2, #1
/*5*/ADD R0, R1, R2 // Load a-b into R0
/*6*/BRzn #31  // goto less than  if equal to zero

    // Calculate a^2 into 4th register
/*7*/LD R3, #42 // Set R3 (index) to stored value of 1
    // loop1
/*8*/NOT R1, R1 // Load -A into R1
/*9*/ADD R1, R1, #1 
/*Need */ AND R0, R0, #0 // Set R0 to 0
/*10*/ADD R0, R1, R3 // calculate i-a
/*11*/BRp #5         // Branch if positive (CHANGE TO AND ZERO)
/*12*/ADD R1, R1, #-1 //  Load A into R1
/*13*/NOT R1, R1
/*14*/ADD R4, R4, R1 // Add A to Asq
/*15*/ADD R3, R3, #1 // Add index
/*16*/BRp #-9 // Branch to loop1
    // endLoop1

// Set R2 back to B
/*17*/ADD R2, R2, #-1
/*18*/NOT R2, R2

    // Calculate b^2 to the 5th register
/*19*/LD R3, #42 // Set R3 (index) to stored value of 1
    // loop2
/*20*/NOT R2, R2 // Load -B into R1
/*21*/ADD R2, R2, #1 
/*Need */ AND R0, R0, #0 // Set R0 to 0
/*22*/ADD R0, R2, R3 // calculate i-b
/*23*/BRp #5         // Branch if positive
/*24*/ADD R2, R2, #1 //  Load B into R1
/*25*/NOT R2, R2
/*26*/ADD R5, R5, R2 // Add B to Asq
/*27*/ADD R3, R3, #1 // Add index
/*28*/BRp #-9 // Branch to loop1
    // endLoop2

    // Compute diff between 4th and 5th register
/*29*/NOT R5, R5
/*30*/ADD R5, R5, #1
/*31*/ADD R6, R5, R4

    // And R1 and R2 for tests
/*32*/AND R1, R1, #2
/*33*/AND R2, R2, R1

    // ST R6 into mem
/*34*/LD R2, #38 // Set R1 to halt address for fun
/*35*/JMP R2
/*36*/ADD R6, R6, #1
/*37*/ST R6, #1

/*38*/HALT

    // Data
/*39*/0000 // Diff of Square
/*40*/000C // A
/*41*/000B // B
/*42*/0001 // #1 
