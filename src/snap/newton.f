      SUBROUTINE NEWTON(*,*,MY,MODQTY,DH0,MH0I,I,DSED,MSEDI,
     & ADA,SPEED,CREF,C0,Z0,C1,Z1,MINMOD)

C____________________________________________________________
C                                                            |
C     This routine finds the zeroes in the characteristic    |
C     equation for the second and subsequent meshes.         |
C____________________________________________________________|

      DOUBLE PRECISION CREF, CMIN, H0, H1, ROB, ROS
      DOUBLE PRECISION TWOPI, PI, OMEGA
      DOUBLE PRECISION MY(MAXMSH, MODEN)
      DOUBLE PRECISION DH0(8), DSED(8)
      DOUBLE PRECISION EPS, EPS10, X, S2, X0, X1, X2
      DOUBLE PRECISION F0, F1, STIFF
      DOUBLE PRECISION EIGVAL, EIGREF, EIGMIN, EIGMAX, EIGDH0, 
     &                 EIGDSED, MINEIG
      DOUBLE PRECISION HRAT, HRATSQ
      DOUBLE PRECISION F00, F11
      DOUBLE PRECISION CON1, CON2, CON3, CON4, CON5, SEDK
      DOUBLE PRECISION ADA(NPOINT), SPEED(NPOINT)
      DOUBLE PRECISION C0(NDEP), Z0(NDEP), C1(NDEP), Z1(NDEP)

      COMMON /CONST/ CON1, CON2, CON3, CON4, CON5, SEDK
      COMMON /DENS/ R0, R1, R2
      COMMON /DENS8/ ROB, ROS
      COMMON /GSNAP/ H0, H1, TWOPI, PI, OMEGA
      COMMON /GEN/ EIGREF, EIGMIN, EIGMAX, STIFF
      COMMON /LUNIT/ LUPLP, LUPLT, LUPRT
      COMMON /NA/ ND0, ND1, CMIN
      COMMON /PARA1/ NFF, MSP, NDEP, NOPT, ICF, NDP, KSRD, MODEN
      COMMON /PARA2/ NPOINT, MAXMSH

      DATA MAXIT/ 20 /

C  200 FORMAT(1X,/,' TRIAL EIGENVALUE NOT SUFFICIENTLY ACCURATE ',/,
C     & ' AT MESH ',I2,' AND MODE ',I4,/,
C     &  ' *** SEARCH WILL BE PERFORMED WITH BRENT *** ',/)
  300 FORMAT(1X,/,' *** MAX ITERATIONS EXCEEDED FOR MODE ',
     & I4,' ***',/,
     &  ' *** SEARCH WILL BE REPEATED WITH BRENT *** ',/)
CF8  320 FORMAT(1X,' *** WARNING: MAXIMUM ORDER MODE=',I4,' AT MESH',I4)
CF8  400 FORMAT(1X,' *** WARNING: MODE ',I4,' NOT FOUND.', 
CF8     & ' SEARCH WILL BE REPEATED WITH SUB BRENT. ') 
  500 FORMAT(1X,' TRIAL EIGENVALUE BEYOND CUTOFF FOR MODE ',I4)

      EPS=1.0D-11
      EPS10=10.0*EPS
C
C     DEFINE MATRIX DIAGONAL
C
      CALL VELOCITY(MH0I,MSEDI,CREF,SPEED,DH0(I),DSED(I),
     &              C0,Z0,C1,Z1,NPOINT,NDEP)
      EIGDH0=EIGREF*DH0(I)
      DO 1000   N=1,MH0I
      ADA(N)=(EIGDH0/SPEED(N+1))**2-2.
 1000 CONTINUE
      EIGDSED=EIGREF*DSED(I)
      DO 1200   N=MH0I+1,MH0I+MSEDI
      ADA(N)=(EIGDSED/SPEED(N+2))**2-2.
 1200 CONTINUE
C     MODES WHICH ARE TOO CLOSE TO THE CUTOFF REGION ARE
C     DISCARDED BY SLIGHTLY INCREASING EIGMIN.
      MINEIG=EIGMIN*1.00001D0
      EIGMAX=( (OMEGA*H0)/(MH0I*CMIN) )**2
      IF(MSEDI.EQ.0) THEN
       HRAT=1.
       HRATSQ=1
       CON3=1.
      ELSE
C       HRAT=DH0(I)/DSED(I)
       HRAT=(MSEDI*H0)/(MH0I*H1)
       HRATSQ=HRAT**2
       CON3=(MH0I*H1)**2/(MSEDI*H0)**2
      ENDIF

      CON1=2.*(STIFF-HRATSQ/ROS)/(STIFF+HRAT)
      CON4=2./ROS*HRATSQ/(STIFF+HRAT)
      CON5=ROS/(ROB*HRAT)
C
C   CHECKING TRIAL EIGENVALUES BEFORE SEARCH
C

C   MAXIMUM ORDER MODE FOR THE ACTUAL MESH
      MAXMOD=MINMOD+MODQTY-1
      CALL STURM(MINEIG,MH0I,MSEDI,DH0(I),DSED(I),S2,NCROSS,ADA,
     & NPOINT)
      IF(NCROSS .LT. MAXMOD)   THEN
CF8    WRITE(08,320) NCROSS, I
       MAXMOD=NCROSS
       MODQTY=MAXMOD-MINMOD+1
       IF(MODQTY .LE. 0)   RETURN
      END IF

      IF(MODQTY .GE. 2)   THEN
       DO 2000   M=2,MODQTY
       IF(  MY(I,M-1)  .LE. MY(I,M) )   THEN
CF8     WRITE(08,*) ' TRIAL EIGENVALUES NOT PROPERLY ORDERED ',
CF8  &  ' SEARCH WILL BE DONE WITH SUB BRENT '
        RETURN 2
       END IF
 2000  CONTINUE
      END IF
C
      DO 2200   M=MODQTY,1,-1
      IF(MY(I,M) .GE. MINEIG)   THEN
       MODQTY=M
       MAXMOD=MINMOD+MODQTY-1
       GO TO 2400
      END IF
        WRITE(LUPRT,500)   MINMOD+M-1
CF8     WRITE(08,500)  MINMOD+M-1
 2200 CONTINUE
      MODQTY=0
      MAXMOD=0
      RETURN
 2400 CONTINUE 
C
C     FIND THE EIGENVALUES
C
      DO 4000 M=1,MODQTY
      X0=MY(I,M)
      CALL INIT(X0,MH0I,MSEDI,DH0(I),DSED(I),F0,NOVFL0,MM,ADA,
     & NPOINT)
       IF(MM .EQ. MINMOD+M-1)   THEN
        X1=X0+2.0D0*EPS10*X0
       ELSE IF (MM .EQ. MINMOD+M-2)   THEN
        X1=X0-2.0D0*EPS10*X0
       ELSE
CF8     WRITE(08,*) ' WARNING FOR MODE ',MINMOD+M-1,MM,' AT MESH ',I
CF8     WRITE(08,*) ' POORLY ESTIMATED TRIAL EIGENVALUE. BRENT IS USED'
        RETURN 2
       END IF
      NITER=0
 3000 CONTINUE
      CALL CHARAC(X1,MH0I,MSEDI,DH0(I),DSED(I),F1,NOVFL1,
     & ADA,NPOINT)
      NODIF=NOVFL1-NOVFL0
      F00=F0
      F11=F1
      IF (NODIF.NE.0) THEN
       IF (NODIF.GT.0) THEN
        F00=F0*(1E-20)**NODIF
       ELSE
        F11=F1*(1E-20)**(-NODIF)
       END IF
      END IF
      IF(F11-F00.EQ.0.D0) THEN
       X2=(X0+X1)/2.D0
      ELSE
       X2=(X0*F11-X1*F00)/(F11-F00)
      ENDIF
      NITER=NITER+1
      IF (NITER.GT.MAXIT) THEN
       WRITE(LUPRT,300)   MINMOD+M-1
CF8    WRITE(08,300) MINMOD+M-1
       RETURN 2
      END IF
      IF(ABS(X1-X2).GT.ABS(EPS*X2)) THEN
       X0=X1
       F0=F1
       NOVFL0=NOVFL1
       X1=X2
       GO TO 3000
      ENDIF
      IF( X2 .LT. MINEIG )   THEN
CF8    WRITE(08,400) MINMOD+M-1
       RETURN 2
      END IF
      MY(I,M)=X2
 4000 CONTINUE

C   CHECKING OF EXTREME EIGENVALUES AND MONOTONICITY
C
      MAXMOD=MINMOD+MODQTY-1
      IF( MY(I,1) .GT. EIGMAX )   THEN
CF8    WRITE(08,*) ' ***  WARNING : POOR ACCURACY ON FIRST MODE.',
CF8     & ' SEARCH IS REPEATED WITH SUB BRENT '
       RETURN 2
      END IF
      EIGVAL=MY(I,1) + EPS10*MY(I,1)
      CALL STURM(EIGVAL,MH0I,MSEDI,DH0(I),DSED(I),S2,NCROSS,ADA,
     & NPOINT)
     
      IF( NCROSS+1 .NE. MINMOD )   THEN
CF8    WRITE(08,*) ' FIRST MODE NOT FOUND.',
CF8  & ' SEARCH IS NOW REPEATED WITH SUB BRENT '
       RETURN 2
      END IF
      EIGVAL=MY(I,MODQTY) - EPS10*MY(I,MODQTY)
      CALL STURM(EIGVAL,MH0I,MSEDI,DH0(I),DSED(I),S2,NCROSS,ADA,
     & NPOINT)
      IF( NCROSS .NE. MAXMOD )   THEN
CF8    WRITE(08,400) MINMOD+MODQTY-1
       RETURN 2
      END IF
      IF(MODQTY.GT.2)   THEN
       DO 6000   M=2,MODQTY-1
       IF(  MY(I,M)-MY(I,M+1) .LT. 2.0D0*EPS )   THEN
CF8     WRITE(08,*) ' WN NOT PROPERLY ORDERED ',
CF8  &  ' SEARCH IS NOW REPEATED WITH SUB BRENT '
        RETURN 2
       END IF
 6000  CONTINUE
      END IF        
      RETURN
      END