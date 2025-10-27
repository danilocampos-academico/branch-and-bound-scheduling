module NodeModule

using ..JobModule

export Node

# estrutura de um nó
mutable struct Node 
    id::Int
    sequence::Union{Vector{Job},Nothing}
    job::Union{Int,Nothing}
    lower_bound::Float64
    parent::Union{Node,Nothing}
    level::Int
    is_cuted::Bool

    function Node(id::Int, sequence::Union{Vector{Job},Nothing}, job::Union{Int,Nothing}, lower_bound::Float64, parent::Union{Node,Nothing}, level::Int, is_cuted=false)
        return new(id, sequence, job, lower_bound, parent, level, is_cuted)
    end
end

import Base: show

function show(io::IO, node::Node)
    print(io, node.id)
end

end