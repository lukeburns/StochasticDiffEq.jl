using StochasticDiffEq, DiffEqProblemLibrary, DiffEqBase, Base.Test

probs = Vector{SDETestProblem}(2)
add_probs = Vector{SDETestProblem}(2)
probs[1] = prob_sde_2Dlinear
probs[2] = prob_sde_linear
add_probs[1] = prob_sde_additive
add_probs[2] = prob_sde_additivesystem


for i in 1:2
  bigprob = SDETestProblem(probs[i].f,probs[i].g,big(probs[i].u0),probs[i].analytic,(big(probs[i].tspan[1]),big(probs[i].tspan[2])),noise=probs[i].noise)
  add_bigprob = SDETestProblem(add_probs[i].f,add_probs[i].g,big(add_probs[i].u0),add_probs[i].analytic,(big(add_probs[i].tspan[1]),big(add_probs[i].tspan[2])),noise=add_probs[i].noise)
  ## SRIW1

  srand(100)
  sol =solve(probs[i],SRI(error_terms=2),dt=1/2^(4),abstol=1,reltol=0)
  err1 = sol.errors[:final]

  sol2 =solve(probs[i],SRI(error_terms=2),dt=1/2^(4),abstol=1e-1,reltol=0)
  err2 = sol2.errors[:final]

#  No bigfloat RNG
#  sol3 =solve(bigprob,SRI(),dt=BigInt(1)/BigInt(2)^(4),abstol=1e-2,reltol=0)
#  err3 = sol3.errors[:final]
#  @test err1 > err3

  sol4 =solve(probs[i],SRI(error_terms=2),dt=1/2^(4),abstol=1e-3,reltol=0)
  err4 = sol4.errors[:final]
  @test err2 > err4

  srand(100)
  sol =solve(probs[i],SRIW1(),dt=1/2^(4),abstol=1,reltol=0)
  err21 = sol.errors[:final]
  @test err1 ≈ err21
  # p1 = plot(sol,plot_analytic=true)

  sol2 =solve(probs[i],SRIW1(),dt=1/2^(4),abstol=1e-1,reltol=0)
  err22 = sol2.errors[:final]
  @test err2 ≈ err22
  #TEST_PLOT && p2 = plot(sol2,plot_analytic=true)

#  No bigfloat rng
#  sol3 =solve(bigprob,SRIW1(),dt=BigInt(1)/BigInt(2)^(4),abstol=1e-2,reltol=0)
#  err23 = sol3.errors[:final]
#  @test ≈(err3,err23,rtol=1e-7)
  #TEST_PLOT && p3 = plot(sol3,plot_analytic=true)

  sol4 =solve(probs[i],SRIW1(),dt=1/2^(4),abstol=1e-3,reltol=0)
  err24 = sol4.errors[:final]
  @test err4 ≈ err24

  ## SRA1

  srand(100)
  sol =solve(add_probs[i],SRA(),dt=1/2^(4),abstol=1,reltol=0)
  err1 = sol.errors[:final]

  sol2 =solve(add_probs[i],SRA(),dt=1/2^(4),abstol=1e-1,reltol=0)
  err2 = sol2.errors[:final]

# No BigFloat RNG
#  sol3 =solve(add_bigprob,SRA(),dt=BigInt(1)/BigInt(2)^(4),abstol=1e-2,reltol=0)
#  err3 = sol3.errors[:final]#
#  @test err1 > err3

  sol4 =solve(add_probs[i],SRA(),dt=1/2^(4),abstol=1e-4,reltol=0)
  err4 = sol4.errors[:final]
  @test err2 > err4

  srand(100)
  sol =solve(add_probs[i],SRA1(),dt=1/2^(4),abstol=1,reltol=0)
  err21 = sol.errors[:final]
  @test err1 ≈ err21
  # p1 = plot(sol,plot_analytic=true)

  sol2 =solve(add_probs[i],SRA1(),dt=1/2^(4),abstol=1e-1,reltol=0)
  err22 = sol2.errors[:final]
  @test err2 ≈ err22
  #TEST_PLOT && p2 = plot(sol2,plot_analytic=true)

#  No BigFloat RNG
#  sol3 =solve(add_bigprob,SRA1(),dt=BigInt(1)/BigInt(2)^(4),abstol=1e-2,reltol=0)
#  err23 = sol3.errors[:final]
#  @test ≈(err3,err23,rtol=1e-7)
  #TEST_PLOT && p3 = plot(sol3,plot_analytic=true)

  sol4 =solve(add_probs[i],SRA1(),dt=1/2^(4),abstol=1e-4,reltol=0)
  err24 = sol4.errors[:final]
  @test isapprox(err4,err24;atol=1e-4)
end