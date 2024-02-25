#checkPureNash function checkPureNash(A, B, (row, col)) should 
#determine if the strategy pair (row, col) is a pure Nash equilibrium for a 
#game described by payoff matrices A and B.

    function checkPureNash(A, B, (row,column))
        #function checks if any rows can be moved to with better payoff for A, same with columns for B
        #Function returns the reverse of the recieved boolean value because a Pure NE has no better payoffs
        return !(any(x -> x > A[row, column], A[:, column]) || any(y -> y > B[row, column], B[ row, :]))
        end

#function findPureNash(A, B) returns a list of all row/column pairs 
#(as 2D tuples) that are pure Nash equilibria of the game described by 
#payoff matrices A and B.

function findPureNash(A, B)
    #runs the above function and stores the row and column if is pure nash
    return [(row, col) for row in 1:size(A, 1), col in 1:size(B, 2) if checkPureNash(A, B, (row, col))]
end 

# checkDominant function checkDominant(P, dim, idx; strict=false) should 
#determine if the strategy at index idx is a dominant strategy for a player with
# payoff matrix P operating in the dimension dim. (If dim is 1, then the player is a 
#row player; if dim is 2, then the player is a column player.)
# The optional keyword argument strict indicates if the determination is made based
# on a strictly dominant strategy (better than all others) or
# a weakly dominant strategy (no worse than all others).

function checkDominant(P, dim, idx; strict=false)
    moddedP = (dim == 2) ? transpose(P) : P #first transposes the graph if dim is 2 so second loop isn't needed
    #print(moddedP)
    for i in 1:size(moddedP, 1) #goes through the length/width of array depending on dim
        if (i != idx) 
            for j in 1:size(moddedP, 2) #goes through the opposite coordinate as the last loop
                if (moddedP[i, j] > moddedP[idx, j]) #I could have used the .>= here instead of the elseif
                    return false #but then I would have had to either A) create seperate cases for strictness or B) create my 
                elseif (moddedP[i, j] >= moddedP[idx, j] && strict) #own compareTo method that decides whether to include >= or >, which ended up being unneccesarily complicated.
                    return false #returns false if isn't dominant
                end
            end
        end
    end
return true #no hits on lack of dominance means dominant
end 


#findDominant function findDominant(P, dim; strict=false) returns
# a list of all rows or columns (depending on dim) representing dominant strategies.

function findDominant(P, dim; strict=false)
    dominantStrats = [] #array to store list of rows/columns
    for i in 1:size(P, dim) #iterates
        if (checkDominant(P, dim, i, strict = strict)) #checks if dominant 
            push!(dominantStrats, i) #if so, adds it
        end
    end 
    return dominantStrats
end
    
#function isDominated(P, dim, idx; strict=true) should determine if the
# strategy at index idx is dominated (strongly or weakly, depending on strict) 
#by some other strategy.
function isDominated(P, dim, idx; strict=true)  
    moddedP = (dim == 2) ? transpose(P) : P #Same transposing as above
    #println("This is the size: $(size(moddedP, 2))")
    #println("This is height $(size(moddedP, 1)) This is width: $(size(moddedP, 2))")
    #println(moddedP)
    #println("This is the index $(idx)")
    #if idx == 3 println("here") end
    for i in 1:size(moddedP, 1) #iterator for rows
        #println("this is i $i")
        if (i != idx)
            dominated = true; 
            for j in 1:size(moddedP, 2) #iterator for columns
                #if idx == 3 println("this is j: $j") end
                #if idx == 3 println("this is P[idx, j]: $(moddedP[idx, j]) and this is P[i,j]: $(moddedP[i, j])") end
                if (moddedP[idx, j] > moddedP[i, j]) #checks if our index is bigger, if true, not dominated.
                    dominated = false
                    break
                elseif (moddedP[idx, j] >= moddedP[i, j] && strict) #only needs to check ==, > checked above
                    dominated = false 
                    break
                end
            end
            #println("This is the size: $(size(moddedP, 2))")
            #println(dominated)
            if dominated return true end #if its dominated by any strategy we are done
        end
    end
    return false #can't return false early because another strategy might dominant 
end


#function iterDelDominated(A, B) returns a new pair of payoff matrices as a 
#tuple representing the game after strictly dominated strategies are iteratively deleted.
function iterDelDominated(A, B)
    #println(A)
    #println(B)
   removed = true 
   while removed #iterates through until nothing can be removed in a sweep (meaning done)
        removed = false
        for i in size(A,1):-1:1 #iterating in reverse order prevents indexing issues from concat 
            if (isDominated(A, 1, i, strict = true)) #checks if strictly dominated
                removed = true
                #println("Found strict dominated at A at value $(i)")
                A = vcat(A[1:i-1, :], A[i+1:end, :]) #concacenates two 2D arrays, vars used subarrays excluding i
                B = vcat(B[1:i-1, :], B[i+1:end, :])
                #println(A)
                #println(B)
                
            end
        end
        for j in size(B, 2):-1:1
            #println("This is the size $(size(B, 2))")
            if (isDominated(B, 2, j, strict = true))
                removed = true 
                #println("Found strict dominated at B at value $(j)")
                A = hcat(A[:, 1:j-1], A[:, j+1:end]) #same as vcat, but horizontal
                B = hcat(B[:, 1:j-1], B[:, j+1:end])
                #println("This is A: $(A)")
                #println("This is B: $B")
            end
        end
   end
   P = [(A[i,j], B[i,j]) for i in 1:size(A, 1), j in 1:size(A, 2)] #merges into a tuple
   return P
end