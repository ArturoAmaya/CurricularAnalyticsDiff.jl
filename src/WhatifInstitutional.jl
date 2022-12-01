function delete_prerequisite_institutional(curriculum::Curriculum, target::AbstractString, prereq::AbstractString)
    target_course = course_from_name(curriculum, target)
    # error check
    if typeof(target_course) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your target course in the given curriculum. Make sure you got the name exactly right."))
    end
    prereq_course = course_from_name(curriculum, prereq)
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
    print_affected_plans(ret)
    println("Number of affected plans: $(length(ret))")
    return ret
end

function delete_prerequisite_institutional!(curriculum::Curriculum, target::AbstractString, prereq::AbstractString)
    target_course = course_from_name(curriculum, target)
    # error check
    if typeof(target_course) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your target course in the given curriculum. Make sure you got the name exactly right."))
    end
    prereq_course = course_from_name(curriculum, prereq)
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
    print_affected_plans(ret)
    println("Number of affected plans: $(length(ret))")
    return ret
end

function delete_course_institutional(curriculum::Curriculum, course_to_remove_name::AbstractString)
    course_to_remove = course_from_name(curriculum, course_to_remove_name)
    if typeof(course_to_remove) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your target course in the given curriculum. Make sure you got the name exactly right."))
    end
    affected_majors = split(course_to_remove.canonical_name, ",")
    print_affected_plans(affected_majors)
    println("Affected plans: $(length(affected_majors))")
    # NOTE THIS DOESNT ACTUALLY CHANGE THE CURRICULUM OBJECT OK?
    return affected_majors
end

function delete_course_institutional!(curriculum::Curriculum, course_to_remove_name::AbstractString)
    course_to_remove = course_from_name(curriculum, course_to_remove_name)
    if typeof(course_to_remove) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your target course in the given curriculum. Make sure you got the name exactly right."))
    end
    affected_majors = split(course_to_remove.canonical_name, ",")
    print_affected_plans(affected_majors)
    println("Affected plans: $(length(affected_majors))")

    # let's change the curriculum
    # note: this works on a technicality, pending ! versions of the core what if functions
    curriculum = remove_course(curriculum, course_to_remove_name)
    println(length(curriculum.courses))
    return (affected_majors, curriculum)
end


function add_course_institutional(curriculum::Curriculum, course_name::AbstractString, new_course_credit_hours::Real, prereqs::Dict, dependencies::Dict)
    new_curriculum = add_course(curriculum, course_name, new_course_credit_hours, prereqs, dependencies)
    # TODO error checking on this one
    errors = IOBuffer()
    isvalid_curriculum(new_curriculum, errors)
    # get all the paths that depend on me
    ## first, get me
    #UCSD = read_csv("./targets/condensed.csv");
    course = course_from_name(new_curriculum, new_course_name)
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
        print_affected_plans(full_set)
        # look at all the paths that depend on me and for each path take the union of their majors
        # then combine the two sets
        return full_set
    else
        # ok this seems to not affect any majors because it's not been hooked up to anything
        println("This course hasn't been hooked up to anything, it didn't affect any majors other than the one it is in")
        full_set = Set()
        return full_set
    end
end

# TODO: edit to add the 
function add_course_institutional!(curriculum::Curriculum, course_name::AbstractString, new_course_credit_hours::Real, prereqs::Dict, dependencies::Dict)
    new_curriculum = add_course(curriculum, course_name, new_course_credit_hours, prereqs, dependencies)
    # TODO error checking on this one
    errors = IOBuffer()
    isvalid_curriculum(new_curriculum, errors)
    # get all the paths that depend on me
    ## first, get me
    #UCSD = read_csv("./targets/condensed.csv");
    course = course_from_name(new_curriculum, new_course_name)
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
        print_affected_plans(full_set)
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

function add_prereq_institutional(curriculum::Curriculum, course_with_new_prereq::AbstractString, prereq::AbstractString)
    course_with_new_prereq = course_from_name(curriculum, course_with_new_prereq)
    if typeof(course_with_new_prereq) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your target course in the given curriculum. Make sure you got the name exactly right."))
    end
    affected_majors = split(course_with_new_prereq.canonical_name, ",")

    print_affected_plans(affected_majors)
    println("Affected plans: $(length(affected_majors))")
    # NOTE THIS DOESNT ACTUALLY CHANGE THE CURRICULUM OBJECT OK?
    # also note that this doesn't explain HOW the affected plans are affected, simply that they are
    return affected_majors
end

function add_prereq_institutional!(curriculum::Curriculum, course_with_new_prereq::AbstractString, prereq::AbstractString)
    course_with_new_prereq_course = course_from_name(curriculum, course_with_new_prereq)
    if typeof(course_with_new_prereq) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your target course in the given curriculum. Make sure you got the name exactly right."))
    end
    new_curric = add_prereq(curriculum, course_with_new_prereq, prereq, pre)
    affected_majors = split(course_with_new_prereq_course.canonical_name, ",")

    print_affected_plans(affected_majors)
    println("Affected plans: $(length(affected_majors))")
    # NOTE THIS DOESNT ACTUALLY CHANGE THE CURRICULUM OBJECT OK?
    # also note that this doesn't explain HOW the affected plans are affected, simply that they are
    return affected_majors, new_curric
end

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
end

## what is in the 20c canon name but not in the calculated set
#sort(collect(setdiff(Set(split(course.canonical_name,",")),affected)))
