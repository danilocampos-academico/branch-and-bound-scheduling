module PinedoLemaModule

using ..JobModule
using ..NodeModule

export get_feasible_jobs

# função auxiliar que retorna true se o job j deve preceder job k
function must_precede(j::Job, k::Job)
    return j.d <= k.d && j.p <= k.p && j.w >= k.w
end

# retorna os jobs que possibilitarão nós viáveis considerando a pré sequência atual recebida
function get_feasible_jobs(all_jobs::Vector{Job}; sequence::Vector{Job}=Job[])
    used_ids = Set(job.id for job in sequence)
    remaining = [job for job in all_jobs if job.id ∉ used_ids]

    feasible = Job[]
    for k in remaining
        ok = true
        for j in remaining
            if j.id != k.id && must_precede(k, j) && j.id ∉ used_ids
                ok = false
                break
            end
        end
        if ok
            push!(feasible, k)
        end
    end

    return feasible
end

end