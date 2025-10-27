module JobModule

export Job

# estrutura de um job
mutable struct Job
    id::Int
    p::Int
    d::Int
    w::Int
end

import Base: show

function show(io::IO, job::Job)
    print(io, job.id)
end

function show(io::IO, jobs::Vector{Job})
    ids = [j.id for j in jobs]
    print(io, "[", join(string.(ids), ", "), "]")
end

end