subroutine Inital_strategies_not_equal()
    use global
    implicit none
    !randomly selected initialFrequencyA A-players
    integer::indexC(NINT(initialFrequencyA * Ntotal))
    !the nodes(index) that initially are A-players 
    integer::indexTotal(Ntotal)
    integer::indexCount
    !loop parameters
    integer::iLoop, jLoop
    !random numbers
    real:: randReal
    integer::randIntegerArray(1)
    integer::randInteger
    !!!!
    do iLoop = 1, Ntotal
        indexTotal(iLoop) = iLoop
    end do
    !
    indexCount = 1

    ! A players
    do while (indexCount <= NINT(initialFrequencyA * Ntotal))
        call RNUND(Ntotal, randIntegerArray)
        randInteger = randIntegerArray(1)
        if(indexTotal(randInteger) /= -1)then
            indexC(indexCount) = randInteger
            indexCount = indexCount + 1
            indexTotal(randInteger) = -1
        end if
    end do
    
    !set the strategy arrary
    strategyGame = 0 
    do jLoop = 1, NINT(initialFrequencyA * Ntotal)
        ! A player
        strategyGame(indexC(jLoop)) = 1
    end do

    !write(*,*) "Initial frequency of A:", sum(strategyGame) * 1.0 / Ntotal
    !pause
    return
    end subroutine Inital_strategies_not_equal