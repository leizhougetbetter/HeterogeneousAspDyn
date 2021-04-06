subroutine readNetwork(networkMain)
    use global
    implicit none
    type(structuredPopulations),intent(out)::networkMain(Ntotal) 
    !!!
    integer::nodeIndex
    integer::degreeNow
    character(50)::neighFormat
    !!!
    
    !!!! read network structure from file
    open(unit = 121, file = "NetworkStructure_AspDyn_"//trim(adjustl(networkType))//"_Weighted_"//trim(adjustl(weightsDistType)))
    write(*,*) "----------------------------------------------------"
    write(*,*) "Network File Read = ", "NetworkStructure_AspDyn_"//trim(adjustl(networkType))//"_Weighted_"//trim(adjustl(weightsDistType))
    write(*,*) "----------------------------------------------------"
    
    do nodeIndex = 1, Ntotal
        !!!! current node's degree (i.e., number of neighors)
        read(121, "(I4)") degreeNow
        degreeMain(nodeIndex) = degreeNow
        write(neighFormat, *) "(",degreeNow,"(I4,1X))"
        !!!! read neighbor indices
        allocate(networkMain(nodeIndex)%neighborNode(degreeNow))
        read(121,neighFormat) networkMain(nodeIndex)%neighborNode
        !!!! read associated weights
        allocate(networkMain(nodeIndex)%neighborNodeTimesInteraction(degreeNow))
        read(121,neighFormat) networkMain(nodeIndex)%neighborNodeTimesInteraction
    end do
    close(121)
    !!!
    return
    end subroutine readNetwork