#include <stdio.h>
#include <math.h>
int main()
{
    int a = 200; // Assigned to R1
    int b = 20;  // Assigned to R2
    int diff;    // Assigned to R6
    int i;       // Assigned to R3
    int aSq = 0; // Assigned to R5
    int bSq = 0; // Assigned to R4

    if(b < a)
        goto endCode;

    // Calculate a^2
    i = 1; 
    loop1:
        if(i > a)
            goto endLoop1;
        aSq += a;
        i++;
        goto loop1;
    endLoop1:

    // Calculate b^2
    i = 1; 
    loop2:
        if(i > b)
            goto endLoop2;
        bSq += b;
        i++;
        goto loop2;

    // Compute diff and print
    endLoop2: 
    diff = aSq - bSq;
    printf("%i\n", diff);

    endCode: ;
}