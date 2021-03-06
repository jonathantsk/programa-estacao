program pibic2
implicit none
real,dimension(:),allocatable:: TMAX,TMED,TMIN, HORA,UR,VEL,LT  !!!
integer,dimension(:),allocatable::ANO, MES, DIA  ! Tem q ser integer porque são parametros da funcao DJ e sao integers
real,parameter:: pi = 3.1415927
real,parameter:: Gsc = 0.0820
real,parameter:: as = 0.25
real,parameter:: bs = 0.5
real,parameter:: cstefan = 0.000004903
REAL,PARAMETER:: Y = 0.063
Character DTA*12 ! data
!integer DJ ! dia juliano >>> === Erro: deletar. DJ já é nome de função. Ta havendo conflito
INTEGER DJi  ! Representa o valor de DJ para cada iteração I
INTEGER I
INTEGER N_dados
integer DM ! dia mes
REAL BIX
REAL LAT  ! LAT = Latitude tem q ser escalar e  nao vetor
REAL T
REAL ESTMAX
REAL ESTMIN
REAL ES
REAL S
REAL EA
REAL G
REAL D
REAL DR
REAL WS
REAL RADC
REAL NZ
REAL NE
REAL RS
REAL RSO
REAL RNL
REAL ETP

! ABRINDO ARQUIVO COM DADOS DE ENTRADA

CALL read_f("datar.txt",N_dados)


do I = 1,N_dados
   T = (TMAX(I) +TMIN(I) ) / 2.

   ESTMAX = 0.6108 * EXP ( ( 17.27 * TMAX (I) ) / ( 237.3 + TMAX (I)))
   ESTMIN = 0.6108 * EXP ( ( 17.27 * TMIN (I) )/ ( 237.3 + TMIN(I)))
   ES= ( ESTMAX + ESTMIN ) / 2.
   S = ( 4098 * ES ) / ( ( T + 237.3 ) **2 )
   EA = ( UR(I) * ES ) / 100.
   G = TMAX(I) - TMIN(I) ! Aqui ta estrnho.
 ! G é o fluxo de calor do solo??? Se for, esse calculo esta errado


 ! OBS Não tinha valor atribuido para DM
 ! MES e ANO são vetores. Deve-se pegar o valor do vetor para cada iteração. Ou seja: MES(I), ANO(I)
 ! Eu modifiquei para USAR o DJi, porqur assim a funcão DJ só é chamada uma vez
   DJi = DJ(DIA(I), MES(I), ANO(I))
   DM = DIA(I) ! Valor do dia do mes
   D = ( 0.409 *SIN ( ( ( PI * 2 / 365. ) * DJi ) - 1.39 ) ) ! Radiano
   
   
   ! Distancia relativa inversa Terra-Sol
   
   Dr = 1 + ( 0.033 * ( cos ( 2 * pi / 365. * DJi ) ) ) ! Mesmo erro acima. Usei DJi
   
   ! latitude
   
   LAT = LT(I) * ( PI / 180. )
   
   ! angulo da hora do por do sol
   
   WS= ACOS ( - TAN ( LAT ) * TAN ( D ) ) !! Aqui tinha um erro: o era pq LAT estava como vetor
   
   ! Radiacao extraterrestre por periodos diarios
   
   RADC = (( 24 * 60 ) / PI ) * Gsc  * DR  * ((( WS * SIN ( LAT ) * SIN ( D )) + ( COS ( LAT ) * COS ( D ) * SIN ( WS ))))
   
   ! Calcular radiacao solar
   NZ = HORA(I) / DM  ! DM foi calculado acima
   NE = ( 24 / PI ) * WS
   RS = ( ( AS  + BS ) * ( NE / NZ ) ) * RADC
   !calcular radiacao solar em ceu claro
   
   RSO = ( AS + BS ) * RADC
   
   ! calcular radiação liquida de ondas longas
   
   RNL = cstefan* ( ( TMAX(I) + TMIN(I)) / 2. ) * (( 0.34 - 0.14 ) * sqrt(EA)) * ((1.35 * (RS/RSO)) - 0.35)
   
   
   ETP = (((0.408 * S * (RNL - G)) + ((Y * 900 * VEL(I) * (ES - EA)) / (T + 273))) / (S + (Y *( 1+ 0.34) * VEL(I))))
   print*, ETP
!  Note que tem um valor negativo de ETP. Verificar o porque?
   

enddo


CONTAINS



SUBROUTINE read_f(dd,Nout)
INTEGER,intent(out):: Nout
CHARACTER(*):: dd
INTEGER::IO,n
CHARACTER(LEN=20):: DTA
! REAL:: TMAX, TMIN,LT, HORA, TMED, UR, VEL

IO=0

OPEN(1,FILE=dd,STATUS="OLD")

READ(1,*)


N=0
DO WHILE (IO == 0)
   READ (1, *, IOSTAT = IO)
   N = N + 1  
ENDDO

N = N-1
Nout = N

CLOSE(1)

ALLOCATE(TMAX(N))
ALLOCATE(TMIN(N))
ALLOCATE(LT(N))
ALLOCATE(HORA(N))
ALLOCATE(TMED(N))
ALLOCATE(UR(N))
ALLOCATE(VEL(N))

!! Faltou alocar: ANO, MES e DIA

ALLOCATE(ANO(N))
ALLOCATE(MES(N))
ALLOCATE(DIA(N))

! Erro aqui. Deve colocar a extensao do arquivo: datar.txt.
! Melhor colocar a variavel dd, q ja tem esse nome armazenado
!OPEN(1,FILE="datar",STATUS="OLD")
OPEN(1,FILE=dd,STATUS="OLD")

READ(1,*)


!OPEN(2,FILE="sds.txt",STATUS="replace") !!!! Para que abir esse arquivo????
DO I=1,N
   READ(1,*)DTA,TMAX(I),TMIN(I),LT(I), HORA(I), TMED(I), UR(I), VEL(I)
!!! ERRO >>> A conversão estava errada. O formato da data no arquivo é: 30-03-2016
!!! Logo, o ANO é do 7 ao 10.
   READ(DTA(7:10),"(I4)") ANO(I)
   
   READ(DTA(4:5),"(I2)") MES(I)
   
   READ(DTA(1:2),"(I2)") DIA(I)
   
ENDDO


CLOSE(1)


END SUBROUTINE

function DJ(DM,MES,ANO)
integer::  DJ  ! Nome de função não requer intent(out). Por padrao, tem q ser out
integer,intent(in):: DM, MES, ANO

bix = mod (ANO, 4) !Condição para definir se o ano e bissexto ou não da divisão (ano/4)

If (bix /= 0) then

    select case (mes)
  case (1) !Jan
    dj = dm
  case (2) !Fev
    dj = 31 + dm
  case (3) !Mar
      dj = 59 + dm
  case (4) !Abr
    dj = 90 + dm
  case (5) !Mai
    dj = 120 + dm
  case (6) !Jun
    dj = 151 + dm
  case (7) !Jul
    dj = 181 + dm
  case (8) !Ago
    dj = 212 + dm
  case (9) !Set
    dj = 243 + dm
  case (10) !Out
    dj = 273 + dm
  case (11) !Nov
    dj = 304 + dm
  case (12) !Dez
    dj = 334 + dm

end select

Else
   
    select case (mes)
  case (1) !Jan
    dj = dm
  case (2) !Fev
    dj = 31 + dm+1
  case (3) !Mar
      dj = 60 + dm
  case (4) !Abr
    dj = 91 + dm
  case (5) !Mai
    dj = 121 + dm
  case (6) !Jun
    dj = 152 + dm
  case (7) !Jul
    dj = 182 + dm
  case (8) !Ago
    dj = 213 + dm
  case (9) !Set
    dj = 244 + dm
  case (10) !Out
    dj = 274 + dm
  case (11) !Nov
    dj = 305 + dm
  case (12) !Dez
    dj = 335 + dm
end select

end if
end function
end program
