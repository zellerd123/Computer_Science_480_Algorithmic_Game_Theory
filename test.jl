using Test 
include("lab01.jl")
include("examples.jl")

@testset "checkPureNash" begin
    # Test 1: Simple Pure Nash Equilibrium
    @test checkPureNash(A1, B1, (1, 1)) == true
    # Test 2: No Pure Nash Equilibrium
    @test checkPureNash(A1, B1, (1,2)) == false
    # Test 3: Multiple Pure Nash Equilibria
    @test checkPureNash(A2, B2, (1, 1)) == true
    @test checkPureNash(A2, B2, (2, 2)) == true
    # Test 4: Larger Matrix
    @test checkPureNash(A4, B4, (3, 1)) == true
    # Test 5: Identical Payoffs
    @test checkPureNash(A13, B13, (2, 1)) == true
end

@testset "findPureNash" begin
    #Test 1: Single Pure Nash Equilibrium
    equilibria1 = findPureNash(A1, B1)
    @test length(equilibria1) == 1
    @test (1,1) in equilibria1
    #Test 2: Multiple Pure Nash Equilibria
    equilibria2 = findPureNash(A2, B2)
    @test length(equilibria2) == 2
    @test (1,1) in equilibria2
    @test (2,2) in equilibria2
    #Test 3: No Pure Nash Equilibrium
    equilibria3 = findPureNash(A14, B14)
    @test length(equilibria3) == 0
    #print(equilibria3)
    #Test 4: Identical Payoffs for All Strategies
    equilibria4 = findPureNash(A13, B13)
    @test length(equilibria4) == 4
end

@testset "checkDominant" begin
    #Test 1: Strictly Dominant Strategy (Row)
    @test checkDominant(A1, 1, 1, strict = true) == true
    @test checkDominant(A1, 1, 2, strict = true) == false
    #Test 2: Weakly Dominant Strategy (Column)
    @test checkDominant(A12, 2, 2, strict = false) == true
    @test checkDominant(A12, 2, 2, strict = true) == false
    #Test 3: No Dominant Strategy
    @test checkDominant(A14, 1, 1, strict = false) == false
    @test checkDominant(A14, 1, 1, strict = true) == false
    #Test 4: Larger Matrix with Dominant Strategy
    @test checkDominant(A5, 2, 2, strict = true) == true
    #Test 5: Edge Case with Identical Payoffs
    @test checkDominant(A13, 1, 1, strict = false) == true
    @test checkDominant(A13, 1, 1, strict = true) == false 
end

@testset "findDominant" begin
    #Test 1: Single Strictly Dominant Strategy (Row)
    dom_strat = findDominant(A1, 1, strict = true) 
    @test length(dom_strat) == 1
    @test dom_strat[1] == 1; 
    #Test 2: No Dominated Strategies
    dom_strat2 = findDominant(A14, 1, strict = true)
    dom_strat3 = findDominant(A14, 2, strict = false)
    @test length(dom_strat2) == 0
    @test length(dom_strat3) == 0
end

@testset "iterDelDommed" begin
    #Test 1: No Dominated Strategies
    ans1 = iterDelDominated(A14, B14)
    @test ans1 == [(1, 0) (0, 1); (0, 1) (1, 0)]
    #Test 2: Multiple Iterations Required
    ans2 = iterDelDominated(A5, B5)
    @test vec(ans2) == [(5, 5)]
end