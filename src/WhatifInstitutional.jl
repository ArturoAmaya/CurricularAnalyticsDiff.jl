function filter_centrality_paths(paths)
    strict_paths = []
    for path in paths
        canon = Set()
        approved = true
        for course in reverse(path)
            if course.canonical_name != ""
                if length(canon) == 0
                    # if the course is not "me" (the added course) and canon hasn't been populated
                    canon = Set(split(course.canonical_name, ","))
                else
                    # if it's not me, but canon's been populated
                    if (intersect(Set(split(course.canonical_name, ",")), canon) != canon)
                        approved = false
                        break
                    end
                end
            end
        end
        if approved
            push!(strict_paths, path)
        end
    end
    return strict_paths
end
"""
    delete_prerequisite_institutional(target::AbstractString, prereq::AbstractString, curriculum::Curriculum)
Remove the course with name `prereq` from being a prerequisite to the course with name `target` in `curriculum` and print how many degree plans were affected.
"""
function delete_prerequisite_institutional(target::AbstractString, prereq::AbstractString, curriculum::Curriculum)
    target_course = course_from_name(target, curriculum)
    # error check
    if typeof(target_course) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your target course in the given curriculum. Make sure you got the name exactly right."))
    end
    prereq_course = course_from_name(prereq, curriculum)
    # error check
    if typeof(prereq_course) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your prerequisite course in the given curriculum. Make sure you got the name exactly right."))
    end
    # deepcopy to leave the curriculum unaltered
    target_course = deepcopy(target_course)
    prereq_course = deepcopy(prereq_course)

    delete_requisite!(prereq_course, target_course)

    target_course_majors = split(target_course.canonical_name, ",")
    prereq_course_majors = split(prereq_course.canonical_name, ",")
    println()
    ret = intersect(Set(target_course_majors), Set(prereq_course_majors))
    ret = sort(collect(ret))
    if ret[1] == ""
        popfirst!(ret)
    end
    count = print_affected_plans(ret)
    println("Number of affected plans: $(count)")
    return ret
end


function delete_prerequisite_institutional!(target::AbstractString, prereq::AbstractString, curriculum::Curriculum)
    target_course = course_from_name(target, curriculum)
    # error check
    if typeof(target_course) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your target course in the given curriculum. Make sure you got the name exactly right."))
    end
    prereq_course = course_from_name(prereq, curriculum)
    # error check
    if typeof(prereq_course) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your prerequisite course in the given curriculum. Make sure you got the name exactly right."))
    end

    # no deepcopy here
    delete_requisite!(prereq_course, target_course)

    target_course_majors = split(target_course.canonical_name, ",")
    prereq_course_majors = split(prereq_course.canonical_name, ",")
    println()
    ret = intersect(Set(target_course_majors), Set(prereq_course_majors))
    ret = sort(collect(ret))
    if ret[1] == ""
        popfirst!(ret)
    end
    count = print_affected_plans(ret)
    println("Number of affected plans: $(count)")
    return ret
end

"""
    delete_course_institutional(course_to_remove_name::AbstractString, curriculum::Curriculum)
Remove the course with name `course_to_remove_name` from `curriculum` and print how many degree plans were affected.
"""
function delete_course_institutional(course_to_remove_name::AbstractString, curriculum::Curriculum, strict::Bool=true)
    course_to_remove = course_from_name(course_to_remove_name, curriculum)
    if typeof(course_to_remove) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your target course in the given curriculum. Make sure you got the name exactly right."))
    end
    centrality_paths = centrality_investigator(course_to_remove, curriculum)
    strict ? my_centrality_paths = filter_centrality_paths(my_centrality_paths) : my_centrality_paths = my_centrality_paths
    if length(centrality_paths) > 0
        prereq_set = Set()
        dep_set = Set()
        for path in centrality_paths
            my_index = findall(x -> x == course_to_remove, path)[1]
            my_prereqs = path[1:my_index-1]
            my_deps = path[my_index+1:end]
            path_set = Set()
            for dep in my_deps
                if isempty(path_set)
                    path_set = Set(split(dep.canonical_name, ","))
                else
                    union!(path_set, Set(split(dep.canonical_name, ",")))
                end
            end
            union!(dep_set, path_set)
        end
        full_set = union(prereq_set, dep_set)
        # don't forget all the instances where the removed course is the end of a chain and has no prereqs
        # this was what we used to take a look at: just the course's majors. now use the dependents to
        # so that courses listed under a different name also get factored in here. MATH 20C vs MATH 20C/31BH
        union!(full_set, Set(split(course_to_remove.canonical_name, ",")))
        full_set = sort(collect(full_set))
        count = print_affected_plans(full_set)
        println("Number of affected plans: $(count)")
        return full_set
    else
        #println("This course hasn't been hooked up to anything. It doesn't affect any plans other than the one it is in")
        full_set = sort(collect(Set(split(course_to_remove.canonical_name, ","))))
        count = print_affected_plans(full_set)
        println("Number of affected plans: $(count)")
        return full_set
    end
end

function delete_course_institutional!(course_to_remove_name::AbstractString, curriculum::Curriculum)
    course_to_remove = course_from_name(course_to_remove_name, curriculum)
    if typeof(course_to_remove) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your target course in the given curriculum. Make sure you got the name exactly right."))
    end
    affected_majors = split(course_to_remove.canonical_name, ",")
    count = print_affected_plans(affected_majors)
    println("Number of affected plans: $(count)")

    # let's change the curriculum
    # note: this works on a technicality, pending ! versions of the core what if functions
    curriculum = remove_course(curriculum, course_to_remove_name)
    println(length(curriculum.courses))
    return (affected_majors, curriculum)
end

"""
    add_course_institutional(new_course_name::AbstractString, curriculum::Curriculum, new_course_credit_hours::Real, prereqs::Dict, dependencies::Dict)
Add a course with name `new_course_name` and provided characteristics to `curriculum`` and print how many degree plans are affected.
"""
function add_course_institutional(new_course_name::AbstractString, curriculum::Curriculum, new_course_credit_hours::Real, prereqs::Dict, dependencies::Dict, strict::Bool=true)
    new_curriculum = add_course(new_course_name, curriculum, new_course_credit_hours, prereqs, dependencies)
    # TODO error checking on this one
    errors = IOBuffer()
    isvalid_curriculum(new_curriculum, errors)
    # get all the paths that depend on me
    ## first, get me
    #UCSD = read_csv("./targets/condensed.csv");
    course = course_from_name(new_course_name, new_curriculum)
    my_centrality_paths = centrality_investigator(course, new_curriculum)
    strict ? my_centrality_paths = filter_centrality_paths(my_centrality_paths) : my_centrality_paths = my_centrality_paths
    # for debug #my_centrality_paths = sort(my_centrality_paths, lt=(x, y) -> x[1].name < y[1].name)
    if length(my_centrality_paths) > 0
        # ok actually do stuff
        # the gist is:
        # look at all the paths that I'm a prereq for and for each path take the intersection of their majors
        ## get all the paths that depend on me:
        prereq_set = Set()
        dep_set = Set()
        for path in my_centrality_paths
            my_index = findall(x -> x == course, path)[1]
            # course is path[my_index]
            # TODO: edge cases based on length
            my_prereqs = path[1:my_index-1]
            my_deps = path[my_index+1:end]
            #= HUGE EDIT: only analyze the dependencies
            path_set = Set()
            for prereq in my_prereqs
                if isempty(path_set)
                    path_set = Set(split(prereq.canonical_name,","))
                else
                    intersect!(path_set,Set(split(prereq.canonical_name,",")))
                end
            end
            union!(prereq_set,path_set)
            =#
            path_set = Set()
            for dep in my_deps
                if isempty(path_set)
                    path_set = Set(split(dep.canonical_name, ","))
                else
                    union!(path_set, Set(split(dep.canonical_name, ",")))
                end
            end
            union!(dep_set, path_set)

        end
        full_set = union(prereq_set, dep_set)
        full_set = sort(collect(full_set))
        count = print_affected_plans(full_set)
        println("Number of affected plans: $(count)")
        # look at all the paths that depend on me and for each path take the union of their majors
        # then combine the two sets
        return full_set
        # if we're adding riiiight at the beginning of the sequence it is a sink (centrality 0) but definitely affects a lot of majors
    elseif length(my_centrality_paths) == 0
        full_set = Set()
        for dep in courses_that_depend_on_me(course, new_curriculum)
            full_set = union(full_set, Set(split(dep.canonical_name, ",")))
        end
        full_set = sort(collect(full_set))
        println(full_set)
        println("Added to the beginning, or not hooked up to anything important")
        return full_set
    else
        # ok this seems to not affect any majors because it's not been hooked up to anything
        println("This course hasn't been hooked up to anything, it didn't affect any majors other than the one it is in")
        full_set = Set()
        return full_set
    end
end

# TODO: edit to add the 
function add_course_institutional!(course_name::AbstractString, curriculum::Curriculum, new_course_credit_hours::Real, prereqs::Dict, dependencies::Dict)
    new_curriculum = add_course(curriculum, course_name, new_course_credit_hours, prereqs, dependencies)
    # TODO error checking on this one
    errors = IOBuffer()
    isvalid_curriculum(new_curriculum, errors)
    # get all the paths that depend on me
    ## first, get me
    #UCSD = read_csv("./targets/condensed.csv");
    course = course_from_name(new_course_name, new_curriculum)
    my_centrality_paths = centrality_investigator(course, new_curriculum)
    if length(my_centrality_paths) > 0
        # ok actually do stuff
        # the gist is:
        # look at all the paths that I'm a prereq for and for each path take the intersection of their majors
        ## get all the paths that depend on me:
        prereq_set = Set()
        dep_set = Set()
        for path in my_centrality_paths
            my_index = findall(x -> x == course, path)[1]
            # course is path[my_index]
            # TODO: edge cases based on length
            my_prereqs = path[1:my_index-1]
            my_deps = path[my_index+1:end]
            #= HUGE EDIT: only analyze the dependencies
            path_set = Set()
            for prereq in my_prereqs
                if isempty(path_set)
                    path_set = Set(split(prereq.canonical_name,","))
                else
                    intersect!(path_set,Set(split(prereq.canonical_name,",")))
                end
            end
            union!(prereq_set,path_set)
            =#
            path_set = Set()
            for dep in my_deps
                if isempty(path_set)
                    path_set = Set(split(dep.canonical_name, ","))
                else
                    union!(path_set, Set(split(dep.canonical_name, ",")))
                end
            end
            union!(dep_set, path_set)

        end
        full_set = union(prereq_set, dep_set)
        full_set = sort(collect(full_set))
        count = print_affected_plans(full_set)
        println("Number of affected plans: $(count)")
        # look at all the paths that depend on me and for each path take the union of their majors
        # then combine the two sets
        return full_set, new_curriculum
    else
        # ok this seems to not affect any majors because it's not been hooked up to anything
        println("This course hasn't been hooked up to anything, it didn't affect any majors other than the one it is in")
        full_set = Set()
        return full_set, new_curriculum
    end
end

"""
    add_prereq_institutional(curriculum::Curriculum, course_with_new_prereq::AbstractString, prereq::AbstractString)
Print how many plans are affected by adding a prerequisite to `course_with_new_prereq` in `curriculum`.

Note that it currently does not actually add `prereq` as a prerequisite to `course_with_new_prereq`
"""
function add_prereq_institutional(curriculum::Curriculum, course_with_new_prereq::AbstractString, prereq::AbstractString)
    # TODO: actually add in the prereq
    course_with_new_prereq = course_from_name(course_with_new_prereq, curriculum)
    if typeof(course_with_new_prereq) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your target course in the given curriculum. Make sure you got the name exactly right."))
    end
    affected_majors = split(course_with_new_prereq.canonical_name, ",")

    count = print_affected_plans(affected_majors)
    println("Number of affected plans: $(count)")
    # NOTE THIS DOESNT ACTUALLY CHANGE THE CURRICULUM OBJECT OK?
    # also note that this doesn't explain HOW the affected plans are affected, simply that they are
    return affected_majors
end

function add_prereq_institutional!(curriculum::Curriculum, course_with_new_prereq::AbstractString, prereq::AbstractString)
    course_with_new_prereq_course = course_from_name(course_with_new_prereq, curriculum)
    if typeof(course_with_new_prereq) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your target course in the given curriculum. Make sure you got the name exactly right."))
    end
    new_curric = add_prereq(curriculum, course_with_new_prereq, prereq, pre)
    affected_majors = split(course_with_new_prereq_course.canonical_name, ",")

    count = print_affected_plans(affected_majors)
    println("Number of affected plans: $(count)")
    # NOTE THIS DOESNT ACTUALLY CHANGE THE CURRICULUM OBJECT OK?
    # also note that this doesn't explain HOW the affected plans are affected, simply that they are
    return affected_majors, new_curric
end

"""
    print_affected_plans(affected_plans::Vector{String})
Print a list of the plans affected by a change and return how many plans were affected.
"""
function print_affected_plans(affected_plans)
    prev_major = "PL99"
    count = 0
    for major in affected_plans
        if major != ""
            if major[1:4] != prev_major[1:4]
                prev_major = major
                print("\n$(major[1:4]): $(major[5:end]), ")
                count += 1
            elseif major != prev_major # don't ask me why for some reason each plan code shows up multiple times
                prev_major = major
                print("$(major[5:end]), ")
                count += 1
            end
        end
    end
    println()
    return count
end

## what is in the 20c canon name but not in the calculated set
#sort(collect(setdiff(Set(split(course.canonical_name,",")),affected)))
