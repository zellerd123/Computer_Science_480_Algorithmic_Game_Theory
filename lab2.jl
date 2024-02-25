using Polynomials, Optim
#=
Define a function `social_cost` that takes two inputs:
    - $c$, a polynomial representing a cost function in terms of $x$; and
    - $r$, the traffic rate
    and produces a polynomial representing the social cost as a function of $x$. 
    The variable $x$, as above, is the amount of traffic flowing on the lower edge.
    =#
ducks = Polynomial(([0,1]))

social_cost(c, r) = c * Polynomial([0,1])  + ( r - Polynomial([0,1])) * c(r)

equilibrium_cost(c, r) = c(r) * r

optimal_cost(c, r) = minimum(social_cost(c,r).(filter(v -> isreal(v) && real(v) >= 0 && real(v) <= r, roots(derivative(social_cost(c, r))))))

function POAold(d, r) 
    c = monomial(d)
    return equilibrium_cost(c, r)/optimal_cost(c, r)
end

POA(c, r) = (equilibrium_cost(c, r))/(Optim.minimum(optimize(social_cost(c, r), 0.0, r)))

#f(c) = v -> # insert code for 1/POA, in terms of v[1], v[2], and c
f(c) = v -> 1/( equilibrium_cost(c, v[1])/social_cost(c, v[1])(v[2]))
function POA(c)
    r_0 = 1.0
    x_0 = 1.0
    res = optimize(f(c),[r_0, x_0], LBFGS(); autodiff = :forward)
    return res
end

function monomial(d)
  coeff = zeros(d+1)
  coeff[d + 1] = 1
  return Polynomial(coeff)
end


#Testing 
function runTests()
    degrees = [1,2, 3, 4, 5]
    r_settings = [1, 100]
    poa_results = Dict()
    poa_old_results = Dict()
    for d in degrees
        for r in r_settings
            curr_c = monomial(d)
            poa_old = POAold(d, r)
            poa = POA(curr_c, r)
            poa_results = poa
            poa_old_results = poa_old
            println("This is the degree: ", d,"\n This is the r val: ", r)
            print("This is new: ")
            println(poa_results)
            print("This is old: ")
            println(poa_old_results)
        end
    end
end



    

