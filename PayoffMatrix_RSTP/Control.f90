!-----------------2021-4-27-------------------------------------------------------------!
! Aspiration dynamics generate robust predictions in heterogeneous populations         !
!- Coauther with BinWu, Jinming Du, Long Wang                                          !
!- For R=1, P=0 games, arbitrary update functions                                      !
!--------------------------------------------------------------------------------------!
INCLUDE 'mkl_vsl.f90'
module global
    !!!! using the MKL lib
	use MKL_VSL_TYPE
	use MKL_VSL
    implicit none
    !!!! Ntotal: the number of indiviudals (or the population size)
    integer,parameter::Ntotal = 100
    !!! isPayoffAveraged: the way of payoff calculation 
    !!! (averaged payofff, isPayoffAveraged = 1)
    !!! (accumulated payofff, isPayoffAveraged = 0)
    integer,save::isPayoffAveraged = 1
    !!! selectionIntensity: the intensity of selection 
    real(8),save::selectionIntensity
    !!!!! payoff matrix: AA = a, AB = b, BA = c, BB = d
    !!!!              or AA = 1, AB = S, BA = T, BB = 0
    real(8),save::SSBeg, SSEnd, SSGap
    real(8),save::TTBeg, TTEnd, TTGap
    !!!
    !!! strategyGame: A Player -- 1; B Player -- 0
    integer,save::strategyGame(Ntotal)
    !!!! In each run, the number of generations (time steps) in total is totalNumLoopSimulation*generationNumPerLoop
    !!!! totalNumLoopSimulation: total number of simulation loops in each run
    integer,save::totalNumLoopSimulation
    !!!! generationNumPerLoop: the number of generations in each loop
    integer,save::generationNumPerLoop
    !!!! sampleStartLoopIndex: the time step at which the sampling for stationary distribution is started
    integer,save::sampleStartLoopIndex
    !!! aspirationValueNode: the first column stores the aspiration values when using strategy B for each individual
    !!!                      the second column stores the aspiration values when using strategy A for each individual
    real(8),save::aspirationValueNode(Ntotal, 2)
    !
    !!!! base update function #1: 1 /(1 + exp(-u))
    !!!! base update function #2: 1 /(1 + 10*exp(-u))
    !!!! base update function #3: 1 /(1 + 0.1*exp(-u))
    !!!! each individual's update function is 
    !!!! param1* baseUpdateFunction1 + param2* baseUpdateFunction2 + (1-param1-param2)*baseUpdateFunction3
    !!!! all update function parameters should be in [0,1]
    real(8),save::updateFunctionParams(Ntotal, 2)
    !!!! initial frequency of strategy A 
    real,save::initialFrequencyA = 0.4
    !!!! the degree of each node (i.e., the number of neighbors each individual has)
    integer,save::degreeMain(Ntotal)
    !!! payoff matrix entries 
    real(8), save:: AA, AB, BA, BB
    !!
    !!! networkType: the type of networks (random, regular, or scale-free)
    character(4),save::networkType
    !!! weightsDistType: the type of edge weight distributions (homogeneous, uniform, or power-law)
    character(20),save::weightsDistType
    !!! random number generator parameters
	type(VSL_STREAM_STATE):: streamRand
	integer, save:: methodRand = VSL_RNG_METHOD_UNIFORM_STD
	integer, save:: errcodeRand
    !!!
    type structuredPopulations
        !!!!! neighbor index
        integer,allocatable::neighborNode(:)
        !!!!! neighbor weight
        integer, allocatable::neighborNodeTimesInteraction(:)
    end type
    !!!
    !
end module
    
program main
    use global
    implicit none
    !!!! timesRepeated: the number of runs (or repetitions) in one simulation
    integer::timesRepeated
    real(8)::updateFunctionParam3(Ntotal)
    !!!! input file names  
    character(32)::inputFileNameAspDyn
    character(24)::inputFileNameSimulation
    logical::alive
	!!!
	integer::currentCPUTime
	integer::brngRand, seedRand
    !!!
    namelist /keyParameters/ networkType, weightsDistType, SSBeg, SSEnd, SSGap, &
                            & TTBeg, TTEnd, TTGap, timesRepeated, &
                            & initialFrequencyA, isPayoffAveraged, totalNumLoopSimulation, &
                            & generationNumPerLoop, sampleStartLoopIndex
    !!! reset all aspration values
    aspirationValueNode = -1.0
    !!!! defaut setting:
    !!!! the number of time steps in total is 2*10^8
    !!!! and the sampling of stationary disbribution is started at 1*10^8
    !!!! (Depending on the hardware of computers in use, especially the size of the RAM, 
    !!!  generationNumPerLoop should be adjusted to a proper number, here, it is 10^7)
    totalNumLoopSimulation = 20
    generationNumPerLoop = 10000000
    sampleStartLoopIndex = 10
    !!
    !!! ------ Read parameters for overall simulation setting------ !!!
    inputFileNameSimulation = 'simulationParameters.inp'
    inquire(file = inputFileNameSimulation, exist = alive)
    if(.not. alive)then
        write(*,*) "ERROR: File "//inputFileNameSimulation//" is NOT found!"
        stop
    end if
    open(unit = 166, file = inputFileNameSimulation,status = 'old')
    read(166, nml = keyParameters) 
    close(166)       
    !!! ----- Read aspiration dynamics Parameters Line By Line ----- !!!
    inputFileNameAspDyn = 'AspirationDynamicsParameters.txt'
    !
    inquire(file = inputFileNameAspDyn, exist = alive)
    if(.not. alive)then
        write(*,*) "ERROR: File "//inputFileNameAspDyn//" is NOT found!"
        stop
    end if
    open(unit = 188, file = inputFileNameAspDyn,status = 'old')
    !!! skip the first four lines
    read(188,*)
    read(188,*)
    read(188,*)
    read(188,*)
    !!! skip the title of payoff parameters
    read(188,*) 
    !!! read payoff parameters
    read(188,*) AA, AB, BA, BB

    !!!
    !!!! skip the title of selection intensity
    read(188,*) 
    !!!! read selection intensity
    read(188,*) selectionIntensity
    
    !!!! skip the title of aspiration values
    read(188,*)
    !!!! read aspiration values (2*Ntotal lines, first Ntotal lines for strategy B for each individual)
    read(188,*) aspirationValueNode
    !write(*,*) aspirationValueNode(1, 1)
    !write(*,*) aspirationValueNode(Ntotal, 2)
    !!!! skip the title of update function parameters (now 2 parameters)
    read(188,*)
    !!!! read update function parameters (first Ntotal lines for update function #1 for each individual)
    read(188,*) updateFunctionParams
    !stop
    close(188)
    !write(*,*) updateFunctionParams(1, 1)
    !write(*,*) updateFunctionParams(Ntotal, 2)
    !stop
    
    !!! output input parameters for check
    write(*,*)  "**************---Displaying Input Parameters---**************"
    write(*,"(' Population Size = ', I4)") Ntotal
    write(*,*) "----------------"
    write(*,"('  Payoff Parameters')")
    write(*,*) "AA, AB:", AA, AB
    write(*,*) "BA, BB:", BA, BB
    write(*,*) "----------------"
    write(*,*) "Maximum and minimum Aspiration values for B strategy:"
    write(*,*) maxval(aspirationValueNode(:,1)), minval(aspirationValueNode(:,1))
    write(*,*) "----------------"
    write(*,*) "Maximum and minimum Aspiration values for A strategy:"
    write(*,*) maxval(aspirationValueNode(:,2)), minval(aspirationValueNode(:,2))
    write(*,*) "----------------"
    write(*,*) "Maximum and minimum Update parameters for base update function #1:"
    write(*,*) maxval(updateFunctionParams(:,1)), minval(updateFunctionParams(:,1))
    write(*,*) "----------------"
    write(*,*) "Maximum and minimum Update parameters for base update function #2:"
    write(*,*) maxval(updateFunctionParams(:,2)), minval(updateFunctionParams(:,2))
    write(*,*) "----------------"
    write(*,"(' Selection Intensity = ', F8.5)") selectionIntensity
    write(*,*) "----------------"
    write(*,"(2X,'RepeatedTimes = ', I5)") timesRepeated
    write(*,*) "----------------"
    write(*,"(2X,'Initial fraction of A = ', F5.3)") initialFrequencyA
    write(*,*)  "***********---(end of displaying input paraterms)---***********"
    write(*,*)

    if(any(aspirationValueNode == -1.0))then
        write(*,*) "The number of Aspiration Values MUST equal to the population size!"
        stop
    elseif(selectionIntensity < 0)then
        write(*,*) "The Selection Intensity MUST be Non-nagetive!"
        stop
    end if
    
    updateFunctionParam3 = 1.0 - updateFunctionParams(:,1) - updateFunctionParams(:,2)
    
    !!! check the reading of update function parameters
    if(any(updateFunctionParams < 0))then
        write(*,*) "Parameters of update functions is LESS THAN zero!"
        stop
    elseif(any(updateFunctionParam3 < 0))then
        write(*,*) "Parameters of update functions is LESS THAN zero!"
        stop
	end if

	!!! the setting of random number generators
    call system_clock(currentCPUTime)
    !!!WRITE(*,*) 'cpu time', currentCPUTime
	seedRand = currentCPUTime
	!!!! Mersenne Twister generator
	brngRand = VSL_BRNG_MT19937
	methodRand = VSL_RNG_METHOD_UNIFORM_STD
	!!!! initialize the random number generator
	errcodeRand = vslnewstream(streamRand, brngRand, seedRand)
    !!!!
    call frequencyCalculationStationaryDist(timesRepeated)
	!!!
	errcodeRand = vsldeletestream(streamRand)
    !stop
end
    