subroutine PairwiseGame_AnyWeightedGraph(nodeChosenUpdate, payoffUpdate, networkMain)
    use global
    implicit none
    type(structuredPopulations),intent(in)::networkMain(Ntotal)
    integer,intent(in)::nodeChosenUpdate
    real(8),intent(out)::payoffUpdate
    !!!
    integer::totalTimesInteractionsWithAInNeighbor
    integer::totalTimesInteractionsWithNeighbor
    !!!
    real::randNodeUpdate
    integer::nodeNeighNow, indexNeigh
    integer::strategyUpdateNode, strategyNeighNode
    
    !!! strategy of the node chosen to update
    strategyUpdateNode = strategyGame(nodeChosenUpdate)
    !!! initialize the payoff
    payoffUpdate = 0
    !!! the number of interactions in total
    totalTimesInteractionsWithNeighbor = sum(networkMain(nodeChosenUpdate)%neighborNodeTimesInteraction)
    !!! the number of interactions with A-neighbors in total
    totalTimesInteractionsWithAInNeighbor = sum(networkMain(nodeChosenUpdate)%neighborNodeTimesInteraction * strategyGame(networkMain(nodeChosenUpdate)%neighborNode))
    if(strategyUpdateNode == 1)then
        payoffUpdate = payoffUpdate + totalTimesInteractionsWithAInNeighbor * AA + (totalTimesInteractionsWithNeighbor - totalTimesInteractionsWithAInNeighbor) * AB
    else
        payoffUpdate = payoffUpdate + totalTimesInteractionsWithAInNeighbor * BA + (totalTimesInteractionsWithNeighbor - totalTimesInteractionsWithAInNeighbor) * BB
    end if
    !!!!!! accumulated payoff (set isPayoffAveraged = 0)
    !!!!!! average payoff (set isPayoffAveraged = 1)
    payoffUpdate = payoffUpdate / real(totalTimesInteractionsWithNeighbor ** isPayoffAveraged, 8)
    
    return
end subroutine PairwiseGame_AnyWeightedGraph