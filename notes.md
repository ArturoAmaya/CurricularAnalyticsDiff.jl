IT'S BECAUSE OTHER CLASSES HAVE BE27 EVEN THOUGH THEY DEPEND ON MATH 20C/31BH. EXAMPLE: BENG 100. SO WHEN IT GOES IN IT GETS BOTH! 
CONSIDER CHANGING ALL THE METHODS TO WORK THIS WAY THIS IS ACTUALLY KINDA GOOD
Looking back on it these notes suck. Note to self to take better notes, I have to retest this now.

## Better notes:
This is a very interesting sample conundrum (not really but I like the word)
    Adding a course right before MATH 20C should affect everything that 20C is in, and everything that depends on it.
    Removing MATH 20C should affect the same number of plans (408)
    However, just looking at the MATH 20C major labels (what the true strict flag does) returns 376 affected plans
    Looking at the dependencies path for MATH 20C indeed returns the same number of affected plans as adding MATH 20B.5
    Let's dig deeper:
    BE27: The course is listed as "MATH 20C or 30BH". However, at least one course with a standard name (ex. BENG 100)
    has MATH 20C as a prereq and MATH 20C or 30BH as a prereq so looking through MATH 20C's centrality paths in the condensed document
    will include BENG 100. Since we union the major labels at each step, we include the labels where BENG 100 didn't really come from MATH 20C but 
    "MATH 20C or 30BH"

    BE27: FI, MU, RE, SI, SN, TH, WA, curriculum,
    BE29: FI, MU, RE, SI, SN, TH, WA, curriculum,
    CH35: FI, MU, RE, SI, SN, TH, WA, curriculum,
    CH38: FI, MU, RE, SI, SN, TH, WA, curriculum,
    These are the 32 plans that make up the difference. 

    BE29: Same MATH 20C or MATH 30BH stuff
    CH35: This is interesting. The curriculum has MATH 10C. Intuitively MATH 10C is unaffected by changes to MATH 20c
    maybe we should call the strict/not strict-option an upper and lower count
    what's interesting is the Revelle plan says MATH 10C or 20C. We could make a case for all 10 series being affected by 20 series changes, but I'm not sure how to proceed.
    CH38: Same as CH35

What to do?
This is also an interesting conundrum because it implies the adding algorithm is also over-counting >:(