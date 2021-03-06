      SUBROUTINE TURNPT(K,ZI,CI,NL,Q,Z1,Z2,ZM,IERR)
      INTEGER I,IERR,J,K,NL
      COMMON/DATA/OMEGA,CMIN,CMAX
      INTEGER Z1,Z2,ZM
      DIMENSION ZI(NL),CI(NL)
      DOUBLE PRECISION ZI,CI,Q,CMIN,CMAX,OMEGA
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C       THIS SUBROUTINE DOES THE FOLLOWING:
C       -CHECKS IF Q IS WITHIN THE ALLOWABLE RANGE
C       -SEARCHES THE INTERPOLATED PROFILE TO FIND THE UPPER &
C         LOWER TURNING POINTS
C
C       INPUT VARIABLES:
C         K,ZI(NL),CI(NL),NL,Q
C
C       OUTPUT VARIABLES:
C         Z1,Z2
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C       CHECK IF Q IS IN THE ALLOWABLE RANGE
C
      IF(Q.GT.CMIN)CALL ERROR(28,IERR,FLOAT(K),0.0,0.0)
      IF(Q.LT.CMAX)CALL ERROR(29,IERR,FLOAT(K),0.0,0.0)
      IF(IERR.EQ.1)GO TO 400
C
C       DEFINE THE UPPER AND LOWER TURNING POINTS IF Q IS EQUAL TO
C        CMIN OR CMAX
C
      IF(Q.NE.CMIN.AND.Q.NE.CMAX)GO TO 90
      IF(Q.NE.CMIN)GO TO 50
      Z1=ZM
      Z2=ZM+1
      RETURN
   50 Z1=1
      Z2=NL
      RETURN
C
C       FIND Z1=UPPER TURNING POINT
C
  90  IF(Q.LE.CI(1))GO TO 130
      DO 100 I=1,NL-1
      IF(CI(I).LE.Q.AND.CI(I+1).GT.Q)GO TO 110
  100 IF(CI(I).GE.Q.AND.CI(I+1).LT.Q)GO TO 110
      CALL ERROR(26,IERR,FLOAT(K),0.0,0.0)
      RETURN
  110 Z1=I+1
      GO TO 200
  130 Z1=1
C
C       FIND Z2=LOWER TURNING POINT
C
  200 DO 300 J=0,NL-2
      I=NL-J
      IF(Q.LT.CI(I).AND.Q.GE.CI(I-1))GO TO 210
  300 IF(Q.GT.CI(I).AND.Q.LE.CI(I-1))GO TO 210
      CALL ERROR(27,IERR,FLOAT(K),0.0,0.0)
      RETURN
  210 Z2=I
  400 RETURN
      END
