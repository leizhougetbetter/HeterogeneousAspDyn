subroutine frequencyCalculationStationaryDist(timesRepeated)
    use global
    implicit none
    integer,intent(in)::timesRepeated
    !!!the index of current time step (i.e., generation) in one run
    integer::run
    !repeated times in one simulation 
    integer::indexRepeated    
    !!! timeRepeatFile: a string that represents the current index of the runs
    character(4)::timeRepeatFile
    !!! 
    !!! numA: number of A-players in the population
    integer::numA
    !!! nodeChosenUpdate: the current node that is chosen to update its strategy
    integer::nodeChosenUpdate
    !!! payoffUpdate: the current payoff of the node that is chosen to update
    real(8)::payoffUpdate
    !!! networkMain: network structure 
    type(structuredPopulations)::networkMain(Ntotal)
    !!! the value of the current TT or SS
    real(8)::TTValue, SSValue
    character(5)::TTvalueStr, SSvalueStr
    !!! numADist: the sampled distribution of the number of A-players 
    integer(8)::numADist(Ntotal+1)
    !!! nodeRandUpdate: the nodes that are randomly selected to update their strategies
    integer, allocatable::nodeRandUpdate(:)
    integer::numNodeRandExceedNtotal, indexNodeRandExceedNtotal
    integer::iNodeRandExceed, nodeRandReDraw(1)
    !! nodeUpdateNow: the current node that will update its strategies
    integer::nodeUpdateNow
    !! randNumUseUpdate: the random numbers that are used for strategy updating
    real(8), allocatable::randNumUseUpdate(:)
    !! indexGenerationLoop: the current index of the generation loop
    integer::indexGenerationLoop
    !!!!
    write(*,*) "For "//trim(adjustl(networkType))//"-"//trim(adjustl(weightsDistType))//" Networks!"
    !!!! read network structure from file
    call readNetwork(networkMain)
    !!!! output network structure statistics for a quick check
    write(*,*) "Average Degree = ", sum(degreeMain)*1.0/Ntotal
    write(*,*) "Max Degree = ", maxval(degreeMain)
    write(*,*) "Min Degree = ", minval(degreeMain)
    write(*,*)
    !!!! set the size of array nodeRandUpdate and randNumUseUpdate
    allocate(nodeRandUpdate(generationNumPerLoop))
    allocate(randNumUseUpdate(generationNumPerLoop))
    !!!
    TT_Loop: do TTValue = TTBeg, TTEnd + 0.001, TTGap
        write(TTvalueStr, "(F5.2)") TTValue
        BA = TTValue
        !!!!
        SS_Loop: do SSValue = SSBeg, SSEnd + 0.001, SSGap
            write(SSvalueStr, "(F5.2)") SSValue
            AB = SSValue
            !!! a quick check for the payoff values
            write(*,*) "----------------"
            write(*,"('  Payoff Parameters')")
            write(*,*) "AA, AB:",AA, AB
            write(*,*) "BA, BB:",BA, BB
            write(*,*) "----------------"
                
            !!!! open the output file
            open(unit = 121,file = "numA_Dist"//"_TT_"//trim(adjustl(TTvalueStr))//"_SS_"//trim(adjustl(SSvalueStr)))
            !!!
            timeRepeatedOneRealization:do indexRepeated=1, timesRepeated
                write(timeRepeatFile,"(I4)")  indexRepeated
                if(mod(indexRepeated,20) == 1)then
                    write(*,*) "-------------------"
                    write(*,*) "Repeat = "//timeRepeatFile
                end if
                    
                !-------Initialize strategies-------!
                call Inital_strategies_not_equal()
                !!!!
                numA = sum(strategyGame)
                !!!! reset the distribution of the number of A-players 
                numADist = 0
                !!! 
                wholeGenerationLoop: do indexGenerationLoop = 1, totalNumLoopSimulation
                    !!! reset the index of the time step  
                    run = 1
                    !!! reset the random numbers  
                    nodeRandUpdate = -1.0 
                    !!! generate random nodes that are chosen to update
                    errcodeRand = virnguniform(methodRand, streamRand, generationNumPerLoop, nodeRandUpdate, 1, Ntotal+1)
                    !!!! check if there is any node randomly sampled that exceeds the population size
                    if(any(nodeRandUpdate > Ntotal))then
                        !write(*,*) "Updated Nodes exceed Population size -- ReDraw!!"
                        numNodeRandExceedNtotal = count(nodeRandUpdate > Ntotal)
                        !write(*,*) "numNodeRandExceedNtotal", numNodeRandExceedNtotal
                        !!! redraw the nodes that exceed population size
                        do iNodeRandExceed = 1, numNodeRandExceedNtotal
                            indexNodeRandExceedNtotal = maxloc(nodeRandUpdate, dim=1)
							errcodeRand = virnguniform(methodRand, streamRand, generationNumPerLoop, nodeRandReDraw, 1, Ntotal+1)
                            nodeRandUpdate(indexNodeRandExceedNtotal) = nodeRandReDraw(1)
                        end do
                    end if
                    if(any(nodeRandUpdate > Ntotal))then
                        write(*,*) "Updated Nodes Still exceed Population size!!"
                        pause
                    end if                    
                    !!
                    !! Generate random numbers used in the strategy updating
                    randNumUseUpdate = -1.0
					errcodeRand = vdrnguniform(methodRand, streamRand, generationNumPerLoop, randNumUseUpdate, real(0.0,8), real(1.0,8))
                    !!!
                    generationLoop:do while(run <= generationNumPerLoop)
                        !!! ------Play games and Update strategies------- !!!
                        nodeUpdateNow = nodeRandUpdate(run)
                        !! Calculate the payoff of the chosen node on any weighted network
                        call PairwiseGame_AnyWeightedGraph(nodeUpdateNow, payoffUpdate, networkMain)
                        !! Using (heterogeneous) aspiration-based update rule to update strategies
                        call HeteroAspirationUpdateRule(nodeUpdateNow, payoffUpdate,randNumUseUpdate(run))
                        !!------------------------------!!
                        !!! calculate the current number of A-players in the population
                        numA = sum(strategyGame)
                        !! if the sampling begins, record the number of A-players
                        if(indexGenerationLoop > sampleStartLoopIndex)then
                            numADist(numA + 1) = numADist(numA + 1) + 1
                        end if
                        run = run + 1
                    end do generationLoop
                    !!!!
                end do wholeGenerationLoop
                !!!! output the distribution of the number of A-players for N=100
                write(121,"(101(1X,I10))") numADist
                    
                    
            end do timeRepeatedOneRealization
            !!! close the current output file
            close(121)
        end do SS_Loop
        !!!!  
    end do TT_Loop
    !!!! deallocate the RAM memory for array nodeRandUpdate and randNumUseUpdate
    deallocate(nodeRandUpdate)
    deallocate(randNumUseUpdate)
    return 
end subroutine frequencyCalculationStationaryDist