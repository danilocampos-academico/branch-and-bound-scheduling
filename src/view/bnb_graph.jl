module BnBGraphModule

using ..NodeModule
using ..JobModule

export plot_bnb_graph

# constroi a árvore usando linguagem DOT (GraphViz)
function plot_bnb_graph(jobs_size::Int, nodes::Vector{Node}, best_solution::Int, best_sequence::Vector{Job}, filename::String)

    dot_lines = ["digraph BranchAndBound {",
                 "node [shape=box, style=\"rounded,filled\", fillcolor=lightblue];",
                 "labelloc=\"b\";",
                 "label=\"\\nMelhor solução viavel: $(best_solution) \\n Sequência escolhida: $(best_sequence) \";",
                 "fontsize=14;"]

    # nós,
    for n in nodes
        # define a cor de fundo dependendo se está podado
        fillcolor = n.is_cuted ? "mistyrose" : "lightblue"
        # conteúdo do nó varia se for level 0 ou folha
        if n.level == 0
            label = "Nó Raiz\\n"
        elseif n.level == jobs_size
            label = "Nó $(n.id)\\nJob $(n.job)\\nZ=$(isnothing(n.lower_bound) ? "-" : round(n.lower_bound; digits=2))"
        else
            label = "Nó $(n.id)\\nJob $(n.job)\\nLB=$(isnothing(n.lower_bound) ? "-" : round(n.lower_bound; digits=2))"
        end
        push!(dot_lines, "  n$(n.id) [label=\"$label\", fillcolor=$fillcolor];")
    end

    # arestas
    for n in nodes
        if !isnothing(n.parent) && !n.parent.is_cuted
            push!(dot_lines, "  n$(n.parent.id) -> n$(n.id);")
        end
    end

    push!(dot_lines, "}")

    # salva arquivo .dot
    dot_path = "results/" * filename * ".dot"
    open(dot_path, "w") do f
        write(f, join(dot_lines, "\n"))
    end
end

end