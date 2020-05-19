using StochasticDiffEq, DiffEqJump, DiffEqBase
using Test, LinearAlgebra

function regular_rate(out,u,p,t)
    out[1] = (0.1/1000.0)*u[1]*u[2]
    out[2] = 0.01u[2]
end

const dc = zeros(3, 2)
dc[1,1] = -1
dc[2,1] = 1
dc[2,2] = -1
dc[3,2] = 1

function regular_c(du,u,p,t,counts,mark)
    mul!(du,dc,counts)
end

rj = RegularJump(regular_rate,regular_c,2)
jumps = JumpSet(rj)
iip_prob = DiscreteProblem([999.0,1,0],(0.0,250.0))
jump_iipprob = JumpProblem(iip_prob,Direct(),rj)
@time sol = solve(jump_iipprob,TauLeaping())
@time sol = solve(jump_iipprob,SimpleTauLeaping();dt=1.0)
@time sol = solve(jump_iipprob,TauLeaping();dt=1.0,adaptive=false)
@time sol = solve(jump_iipprob,CaoTauLeaping();dt=1.0)
@time sol = solve(jump_iipprob,CaoTauLeaping())

iip_prob = DiscreteProblem([999,1,0],(0.0,250.0))
jump_iipprob = JumpProblem(iip_prob,Direct(),rj)
sol = solve(jump_iipprob,TauLeaping())

function rate_oop(u,p,t)
    [(0.1/1000.0)*u[1]*u[2],0.01u[2]]
end

const dc = zeros(3, 2)
dc[1,1] = -1
dc[2,1] = 1
dc[2,2] = -1
dc[3,2] = 1

function regular_c(u,p,t,counts,mark)
    dc*counts
end

rj = RegularJump(rate_oop,regular_c,2)
jumps = JumpSet(rj)
prob = DiscreteProblem([999.0,1,0],(0.0,250.0))
jump_prob = JumpProblem(prob,Direct(),rj)
sol = solve(jump_prob,TauLeaping(),reltol=5e-2)
