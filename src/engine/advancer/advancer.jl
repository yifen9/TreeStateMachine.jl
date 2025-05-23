module Advancer

export advance!

using ..Model
using ..Callback
using ..Mode

function advance!(node::Model.Node)::Nothing
    if node.status === :idle
        node.status = :running
        Callback.run(node, :enter)

        if isa(node, Model.Group)
            child_list    = node.child_list
            mode_function = Mode.get_function(node.mode)
            while true
                child_queue = mode_function(node)
                isempty(child_queue) && break
                Threads.@sync for child in child_queue
                    Threads.@spawn advance!(child_list[child])
                end
            end
        end

        Callback.run(node, :exit)
        node.status = :done
    end
    return nothing
end

end