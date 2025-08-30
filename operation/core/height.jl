function height(root::Model.Node)::Int
    if isa(root, Model.Leaf)
        return 1
    else
        child_list = root.child_list
        result = 1
        for child in child_list
            height_child = height(child)
            result = (height_child > result) ? height_child : result
        end
        return result + 1
    end
end

set!(:height, height)