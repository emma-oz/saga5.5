      SUBROUTINE CONVRG(ERR1A,ERR1R,ERR2A,ERR2R,MODQTY,NMES,
     & MY,MODEN,DH0SQ,H0,EK,EXTPOL,WNMIN)

      INTEGER EXTPOL

      DOUBLE PRECISION H0
      DOUBLE PRECISION ERR1R, ERR1A, ERR2R, ERR2A, EXTA, ZL, WNMIN
      DOUBLE PRECISION MY(MAXMSH,MODEN), DH0SQ(8), EK(MODEN) 

      COMMON /LUNIT/ LUPLP, LUPLT, LUPRT
      COMMON /PARA2/ NPOINT, MAXMSH

  200 FORMAT(1X,//,' *** WARNING :  MODE CUTOFF AFTER EXTRAPOLATION',/,
     & ' DETECTED IN SUB CONVRG. ',/,
     & ' EXECUTION TERMINATED FOR THIS SOURCE FREQUENCY.')

      IF(NMES .EQ. 1)   THEN 
        DO 1000   M= 1, MODQTY
        EK(M)= SQRT(MY(NMES,M))/H0
 1000   CONTINUE
        RETURN
      END IF

      IF(EXTPOL .GT. 0)   THEN

        ERR1A= 0.0
        ERR1R= 0.0
        DO 4000   M= 1, MODQTY
        EK(M)= 0.0
        DO 2200  J= 1, NMES
        ZL= 1.0
        DO 2000  K= 1, NMES
        IF(K.NE.J)  ZL= ZL*DH0SQ(K)/(DH0SQ(K)-DH0SQ(J))
 2000   CONTINUE
        EK(M)= EK(M)+ZL*MY(J,M)
 2200   CONTINUE

        IF( EK(M) .LE. WNMIN )  THEN
          MODQTY= M-1
          IF(MODQTY .GT. 0)   GO TO 5000
          WRITE(LUPRT,200)
          RETURN
        END IF

        EK(M)= SQRT(EK(M))/H0

        EXTA= 0.0
        DO 3200  J= 1, NMES-1
        ZL= 1.0
        DO 3000  K= 1, NMES-1
        IF(K.NE.J)  ZL= ZL*DH0SQ(K)/(DH0SQ(K)-DH0SQ(J))
 3000   CONTINUE
        EXTA= EXTA+ZL*MY(J,M)
 3200   CONTINUE

        IF( EXTA .LE. WNMIN )  THEN
          MODQTY= M-1
          IF(MODQTY .GT. 0)   GO TO 5000
          WRITE(LUPRT,200)
          RETURN
        END IF

        EXTA= SQRT(EXTA)/H0

        IF(ERR1A .LT. ABS(EXTA-EK(M)))    THEN
          M1SAVE= M
          ERR1A= ABS(EXTA-EK(M))
        END IF
 4000   CONTINUE   
 5000   CONTINUE
        ERR1R= ERR1A/EK(M1SAVE)

      END IF

      ERR2A= 0.0
      ERR2R= 0.0
      DO 6000   M= 1, MODQTY
      IF(ERR2A .LT. ABS(MY(NMES,M)-MY(NMES-1,M)))   THEN
        ERR2A= ABS(MY(NMES,M)-MY(NMES-1,M))
        M2SAVE= M
      END IF
 6000 CONTINUE
      ERR2A= ABS( SQRT(MY(NMES,M2SAVE)) - SQRT(MY(NMES-1,M2SAVE)) )
      ERR2R= ERR2A/SQRT(MY(NMES,M2SAVE))
      ERR2A= ERR2A/H0

      RETURN
      END