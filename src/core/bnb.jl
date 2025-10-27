module BnBModule

using ..JobModule
using ..NodeModule
using ..PinedoLemaModule
using ..TransportModelModule
using ..BnBGraphModule

export runBnB

# função auxiliar para o calculo da função objetivo de uma sequencia
function calculate_real_cost(sequence::Vector{Job})
    completion = 0
    total_cost = 0

    for job in reverse(sequence)
        completion += job.p
        Tj = max(0, completion - job.d)
        total_cost += job.w * Tj
    end

    return total_cost
end

# função principal com a lógica do Branch-and-Bound
function runBnB(jobs::Vector{Job})

    makespan = sum(job -> job.p, jobs)

    # cria nó raiz
    level = 0
    id = 0
    sequence = Job[]
    lower_bound = 0.0
    parent = nothing
    root = Node(id, sequence, nothing, lower_bound, parent, 0)

    # vetor para guardar os nós disponíveis
    nodes = [root]
    # vetor para guardar todos os nós (será utilizado para montar o grafo)
    allnodes = Node[]
    # sem UB inicial
    best_upper_bound = Inf
    best_sequence = Job[]

    while !isempty(nodes)

        node = nodes[1]

        # da preferência a nós de maior nível e com o LB menor
        if length(nodes) > 1
            highest_level = maximum(n.level for n in nodes)
            candidates = [n for n in nodes if n.level == highest_level]
            if isempty(candidates)
                node = nodes[1]  # fallback
            else
                values = [n.lower_bound for n in candidates]
                idx = argmin(values)
                node = candidates[idx]
            end

        end

        println("Analisando Nó $(node.id) de nível $(node.level) com sequencia $(node.sequence)")

        push!(allnodes, node)
        index = findfirst(==(node), nodes)
        splice!(nodes, index)

        # se LB > UB atual, poda por bound
        if !isnothing(node.lower_bound) && node.lower_bound > best_upper_bound
            node.is_cuted = true
            println("   Cortado")
            continue
        end

        # se for um nó folha, calcula a função objetivo, se for menor do que o UB atual, atualiza o UB, se não, poda
        if node.level == length(jobs)
            cost = calculate_real_cost(node.sequence)
            node.lower_bound = cost
            if isempty(best_sequence) || cost < best_upper_bound
                best_sequence = copy(node.sequence)
                best_upper_bound = cost
            else
                node.is_cuted = true
            end
            println("   Nó folha com valor de $(cost)")
            continue
        end

        # abre filhos
        remaining_jobs = filter(j -> !(j in node.sequence), jobs)
        # utiliza o lema de pinedo para abrir somente os nós viáveis
        if level == 0
            feasible_jobs = get_feasible_jobs(remaining_jobs)
        else
            feasible_jobs = get_feasible_jobs(remaining_jobs; sequence=node.sequence)
        end

        # para cada nó filho viável
        for f_job in feasible_jobs
            child_sequence = copy(node.sequence)
            push!(child_sequence, f_job)

            # monta o dicionário com os jobs fixos alocados
            fixed = Dict{Int, Vector{Int}}()
            total_time_temp = makespan
            for job in child_sequence
                slots = (total_time_temp - job.p + 1):total_time_temp
                fixed[job.id] = collect(slots)
                total_time_temp -= job.p
            end

            # calcula o LB
            lb_child = solve_transport_relaxation(jobs,fixed)

            # cria o nó filho
            id += 1
            child_node = Node(id, child_sequence, f_job.id, lb_child, node, node.level + 1)
            push!(nodes, child_node)
        end
    end

    # chama a função para plotar o grafo
    plot_bnb_graph(length(jobs), allnodes, best_upper_bound, reverse(best_sequence), "bnb_tree")

    # retorna o resultado ótimo e a sequência ótima
    return best_upper_bound, reverse(best_sequence)
end

end
