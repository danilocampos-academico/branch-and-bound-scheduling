module TransportModelModule

using JuMP, HiGHS

using ..JobModule

export solve_transport_relaxation

# modelo usado como relaxação para cálculo do LB
function solve_transport_relaxation(
    # vetor de jobs com cada job já contendo o respectivo p, d e w
    jobs::Vector{Job},
    # parametro opcional: dicionário contendo um vetor de posições ja alocadas para determinados jobs (recebido pelo o bnb)
    pre_sequence = Dict{Int, Vector{Int}}()
    )

    # quantidade de jobs
    n = length(jobs)

    # tempo máximo de processamento
    Pmax = sum(job -> job.p, jobs)

    # Conjunto de jobs
    J = 1:n

    # Conjunto de posições (tempo)
    K = 1:Pmax

    # custo de atraso c[j,k], que é 0 se o job está dentro do pazo d[j] ou w[j] se está fora
    c = [ (k > jobs[j].d) ? jobs[j].w : 0.0 for j in J, k in K]
    
    # instancia do modelo utilizando HiGHS como solver
    model = Model(HiGHS.Optimizer)
    set_silent(model)

    # variáveis x[job,tempo] representando se o job j está ativo no tempo k (está entre 0 e 1 mas o modelo já faz aceitar somente 0 ou 1)
    @variable(model, x[J,K], lower_bound=0, upper_bound=1)

    # restrições

    # se tiver recebido uma sequência prévia
    if !isempty(pre_sequence)
        for (j,positions) in pre_sequence
            for k in positions
                # obriga o job k a ocupar o tempo k
                @constraint(model, x[j,k] == 1)
                for i in J
                    if i != j 
                        # impede que qualquer outro job ocupe o tempo k
                        @constraint(model, x[i,k] == 0)
                    end
                end
            end
        end
    end

    #cada job deve ter p[j] unidades alocadas
    @constraint(model, [j=J], sum(x[j,k] for k=K) == jobs[j].p)

    # cada posição k deve ser ocupado por 1 unidade
    @constraint(model, [k=K], sum(x[j,k] for j=J) == 1)

    # função objetivo
    @objective(model, Min, sum(c[j,k]*x[j,k] for j in J, k in K))

    # execução
    optimize!(model)

    # avisa caso nao encontre solução ótima
    status = termination_status(model)
    if status != MOI.OPTIMAL && status != MOI.LOCALLY_SOLVED
        error("Solver não encontrou solução ótima. Status = $status")
    end

    obj = objective_value(model)

    # retorna o valor da função objetivo
    return obj

end

end