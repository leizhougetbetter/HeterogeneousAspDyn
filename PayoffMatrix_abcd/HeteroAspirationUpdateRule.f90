subroutine HeteroAspirationUpdateRule(nodeUpdate, payoffUpdate, randNumUpdate)
    use global
    implicit none
    integer,intent(in)::nodeUpdate
    real(8),intent(in)::payoffUpdate
    real(8), intent(in)::randNumUpdate
    !!!
    real(8)::switchProbContributionUpdateFunction1
    real(8)::switchProbContributionUpdateFunction2
    real(8)::switchProbContributionUpdateFunction3
    real(8)::switchProb
    real(8)::AspirationMinusPayoffTimesSelectionIntensity
    real(8)::expBetaU
    !!
    AspirationMinusPayoffTimesSelectionIntensity = selectionIntensity * (aspirationValueNode(nodeUpdate, strategyGame(nodeUpdate) + 1) - payoffUpdate)
    expBetaU = exp(-AspirationMinusPayoffTimesSelectionIntensity)
    !!!! the variable u = selectionIntensity * (aspirationValue - payoff)
    !!!! base update function #1: 1 /(1 + exp(-u))
    !!!! base update function #2: 1 /(1 + 10*exp(-u))
    !!!! base update function #3: 1 /(1 + 0.1*exp(-u))
    !!!! each individual's update function is 
    !!!! param1* baseUpdateFunction1 + param2* baseUpdateFunction2 + (1-param1-param2)*baseUpdateFunction3
    !!!! all update function parameters are in [0,1]
    switchProbContributionUpdateFunction1 = updateFunctionParams(nodeUpdate, 1) / (real(1.0,8) + expBetaU)
    switchProbContributionUpdateFunction2 = updateFunctionParams(nodeUpdate, 2) / (real(1.0,8) + real(10,8)*expBetaU)
    switchProbContributionUpdateFunction3 = (real(1.0,8)-updateFunctionParams(nodeUpdate, 1)-updateFunctionParams(nodeUpdate, 2)) / (real(1.0,8) + real(0.1,8)*expBetaU)
    !!!! calculating the switching probability
    switchProb = switchProbContributionUpdateFunction1 + switchProbContributionUpdateFunction2 + switchProbContributionUpdateFunction3
    !!! 
    if(randNumUpdate < switchProb)then
        strategyGame(nodeUpdate) = 1 - strategyGame(nodeUpdate)
    end if
    
    return 
end subroutine HeteroAspirationUpdateRule