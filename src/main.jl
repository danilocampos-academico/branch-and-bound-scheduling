module MainApp

include("core/job.jl")
include("core/node.jl")
include("core/pinedo_lema.jl")
include("core/transport_model.jl")
include("view/bnb_graph.jl")
include("core/bnb.jl")


using .JobModule
using .NodeModule
using .PinedoLemaModule
using .TransportModelModule
using .BnBGraphModule
using .BnBModule

# instância do problema
jobs = [
    Job(1, 17, 25, 5),
    Job(2, 10, 30, 15),
    Job(3, 15,70,15),
    Job(4, 12, 25, 20),
    Job(5, 8, 50, 10),
    Job(6, 10, 60, 10),
]

# executa o Branch and Bound e mostra o resultado
println("Iniciando Branch and Bound...")
best_solution, best_sequence = runBnB(jobs)
println("------------ Resultado --------------")
println("Melhor solução: $(best_solution)")
println("Melhor sequência: $(best_sequence)")

end
