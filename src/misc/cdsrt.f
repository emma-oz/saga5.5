      COMPLEX*16 FUNCTION CDSRT(Z)
C
C     THIS FUNCTION PROVIDES A SQUARE ROOT WITH A 
C     NON-NEGATIVE IMAGINARY PART.
C
CHS     H. SCHMIDT, 14.APR.87. CHANGED TO WORK CORRECTLY FOR
CHS     SMALL NEGATIVE IMAGINARY PART OF THE ARGUMENT BY MOVING
CHS     THE BRANCH CUT TO THE NEGATIVE IMAGINARY AXIS.
C 
      IMPLICIT REAL*8 (A-H,O-Z)
      COMPLEX*16 Z,U,W,CDSQRT
C
CHS      IF (DREAL(Z) .LE. 0.0D0) THEN
CHS        CDSRT=DCMPLX(0.0D0,1.0D0)*CDSQRT(-Z)
CHS      ELSE
CHS        CDSRT=CDSQRT(Z)
CHS      END IF
C
      U=CDSQRT(Z)
      W=DCMPLX(-1.0D0,0.0D0)
      IF(DIMAG(U) .LT. 0.0D0) U=W*U
      CDSRT=U
C 
      RETURN
      END
