using JuMP, HiGHS

function introLP()
    model = Model(HiGHS.Optimizer)

    @variable(model, x[1:2] >= 0)
    @objective(model, Max, x[1] + 6x[2])
    @constraint(model, c1, x[1] <= 200)
    @constraint(model, c2, x[2] <= 300)
    @constraint(model, c3, x[1]+x[2] <= 400)

    print(model)

    optimize!(model)

    return model
end

function introDual()
    model = Model(HiGHS.Optimizer)
    @variable(model, y[1:3] >= 0) #creates the 3 y variables 
    @objective(model, Min, 200y[1] + 300y[2] + 400y[3]) #assigns it for min bc dual flip 
    @constraint(model, y[1] + y[3] >= 1)
    @constraint(model, y[2] + y[3] >= 6)

    #print(model)

    optimize!(model)

    return model
end

function feasibility_test(a, b, c)
    model = Model(HiGHS.Optimizer)

    @variable(model, x >= 0)
    @variable(model, y >= 0)
    @objective(model, Max, x + y)
    @constraint(model, a * x + b * y <= c)

    optimize!(model)

    return model
end

#=
1. As C gets bigger, the constraint area grows so the values of x/y are larger
2. When a == b (slope = 1), any point along the constraint line is ok 
3. When a > b, you will have 0 as the x variable value and a positive y value, vice versa for x and y if b > a  
=#

function partB2()

    model1 = feasibility_test(1, 1, 1)
    model2 = feasibility_test(1, 1, 2)
    model3 = feasibility_test(2, 1, 4)
    model4 = feasibility_test(1, 2, 4)

    return model1, model2, model3, model4
end

partB3() = feasibility_test(0,0,3)

#=
It is unbounded because if either a or b is equal to zero you could increase x or y (depending on if a or b is 0) 
infinitely, you can tell this using the interpreter from the line that says "Model Status : Unbounded"
=#

partB4() = feasibility_test(1,2,-1)

#=
It is infeasible because if a and b are positive, there is no way for them to reach a negative number,
you can tell this using the interpreter from the line that says "Problem status detected on presolve: Infeasible"
=#

function bestFitLines(points) 
    model = Model(HiGHS.Optimizer)
    #defines variables 
    @variable(model, z >= 0)
    @variable(model, a)
    @variable(model, b)
    @variable(model, c)
    @objective(model, Min, z) #get the minimum value of z

    for (x_i, y_i) in points
        @constraint(model, a * x_i + b * y_i - c <= z) #contrains upper bound
        @constraint(model, -a * x_i - b * y_i + c <= z)#constrains lower bound
    end
    @constraint(model, a + b >= 1) #edge case to prevent 0, 0 result 

    optimize!(model)
    return round(value(a), digits = 2 ), round(value(b),digits = 2), round(value(c),digits = 2)
end

function determineInvestors(costs, investments, requirements)
    n = length(costs)
    m = length(investments)

    model = Model(HiGHS.Optimizer)
    @variable(model, x[1:n], Bin) #creates the binary variables for all costs
    @variable(model, y[1:m], Bin) #creates the binary variables for all investments

    #aims to find the maximum investments - costs, multipled by x & y to be 1 or 0 for each cost/benifit
    @objective(model, Max, sum(investments[j] * y[j] for j in 1:m) - sum(costs[i] * x[i] for i in 1:n))

    #goes through all the investors
    for j in 1:m
        #goes through each of their requirements 
        for i in requirements[j]
            #if the investor is engaging, their costs must be incurred, this handles that
            @constraint(model, y[j] <= x[i])
        end
    end 

    optimize!(model)
    #adds the investor if their binary variable is 1
    engaged_investors = [j for j in 1:m if value(y[j]) > 0] 
    return engaged_investors
end