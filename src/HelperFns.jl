using CurricularAnalytics, CSV, Crayons

function course_match(course1_name::AbstractString, course2_name::AbstractString, all_redundants::Matrix)
    if (course1_name == course2_name)
        return (true, course1_name, course2_name)
    else
        course_one = findall(x -> (!ismissing(x) && x == course1_name), all_redundants)
        course_two = findall(x -> (!ismissing(x) && x == course2_name), all_redundants)
        if (isempty(course_one) || isempty(course_two))
            return (false, course1_name, course2_name)
        else
            if (course_one[1][1] == course_two[1][1]) # Same row!
                return (true, first(all_redundants[course_one]), first(all_redundants[course_two]))
            else
                return (false, course1_name, course2_name)
            end
        end
    end
end

function course_find(course_name::AbstractString, alternate_names::Matrix, target_curriculum::Curriculum)
    ret = (false, course_name, course_name)
    # find row that course_name is on
    index = findall(x -> (!ismissing(x) && x == course_name), alternate_names)
    if (!isempty(index)) # i.e., it's in the fun table of weird names
        # get the row that this is on:
        row = index[1][1]
        row_vec = alternate_names[row, :]
        # loop through the equivalent names in the same row and try to match them
        for alt_name in row_vec
            if !ismissing(alt_name) && alt_name in courses_to_course_names(target_curriculum.courses)
                ret = (true, course_name, alt_name)
                break
            end
        end
    end
    ret
end

function prereq_print(prereqs::Set{AbstractString})
    string = " "
    for prereq in prereqs
        string = string * prereq
        string = string * " "
    end
    string
end

function get_course_prereqs(curriculum::Curriculum, course::Course)
    # get all the prereqs
    course_prereqs = Vector{Course}()
    for (key, value) in course.requisites
        # get the course name
        #course = curriculum.courses[key]
        course = course_from_id(curriculum, key)
        push!(course_prereqs, course)
    end
    course_prereqs
end

function course_from_name(curriculum::Curriculum, course_name::AbstractString)
    for c in curriculum.courses
        if c.name == course_name
            return c
        end
    end
end

function pretty_print_course_names(courses::Vector{})
    for course in courses
        print(Crayon(reset=true), "$(course)➡️")
    end
    print(Crayon(reset=true), " \n")
end

function courses_to_course_names(courses::Vector{})
    course_names = AbstractString[]
    for course in courses
        push!(course_names, course.name)
    end
    course_names
end

function courses_that_depend_on_me(course_me::Course, curriculum::Curriculum)
    # me is the course
    courses_that_depend_on_me = Course[]
    # look through all courses in curriculum. if one of them lists me as a prereq, add them to the list
    for course in curriculum.courses
        # look through the courses prerequisite
        for (key, value) in course.requisites
            # the key is what matters, it is the id of the course in the curriculum
            if (key == course_me.id) # let's skip co-reqs for now... interesting to see if this matters later. It does! see MATH 20B of BE25 in the sample data
                push!(courses_that_depend_on_me, course)
            end
        end
    end

    courses_that_depend_on_me
end

function blocking_factor_investigator(course_me::Course, curriculum::Curriculum)
    # this should:
    # check all courses to make a list of courses that consider this one a prereq
    # then for each of those find which courses deem that course a prereq
    # repeat until the list of courses that consider a given course a prereq is empty.
    unblocked_field = courses_that_depend_on_me(course_me, curriculum)
    if (length(unblocked_field) != 0)
        # if theres courses that depend on my current course, find the immediately unblocked field of each of those courses
        # and add it to courses_that_depend_on_me
        for course_A in unblocked_field
            courses_that_depend_on_course_A = courses_that_depend_on_me(course_A, curriculum)
            if (length(courses_that_depend_on_course_A) != 0)
                for course in courses_that_depend_on_course_A
                    if (!(course in unblocked_field)) # avoid duplicates
                        push!(unblocked_field, course)
                    end
                end
            end
        end
    end
    unblocked_field
end

function delay_factor_investigator(course_me::Course, curriculum::Curriculum)
    # this is harder because we need to find the longest path
    # for each course in my unblocked field, calculate the longest path from a sink up to them that includes me
    my_unblocked_field = blocking_factor_investigator(course_me, curriculum)
    delay_factor_path = Course[]
    # if my unblocked field is empty, find the longest path to me
    if (length(my_unblocked_field) == 0)
        # call longest path to me with no filter
        delay_factor_path = longest_path_to_me(course_me, curriculum, course_me, false)
    else
        # select only the sink nodes of my unblocked field. this is bad for time complexity, though
        sinks_in_my_u_field = filter((x) -> length(courses_that_depend_on_me(x, curriculum)) == 0, my_unblocked_field)

        # for each of the sinks, calculate longest path to them, that passes through me
        longest_path_through_me = []
        longest_length_through_me = 0
        for sink in sinks_in_my_u_field
            # NOTE: this will unfortunately produce the longest path stemming from me, not the whole path. *shrug for now*
            path = longest_path_to_me(sink, curriculum, course_me, true)
            if (length(path) > longest_length_through_me)
                longest_length_through_me = length(path)
                longest_path_through_me = path
            end
        end

        # now that you have the longest path stemming from me,
        # find the longest path to me and put em together. They will unfortunately include me twice, so make sure to remove me from one of them
        longest_up_to_me = longest_path_to_me(course_me, curriculum, course_me, false)
        pop!(longest_up_to_me)
        for course in longest_up_to_me
            push!(delay_factor_path, course)
        end
        for course in longest_path_through_me
            push!(delay_factor_path, course)
        end
    end

    delay_factor_path
end

function centrality_investigator(course_me::Course, curriculum::Curriculum)
    # this will return the paths that make up the centrality of a course
    g = curriculum.graph
    course = course_me.vertex_id[curriculum.id]
    centrality_paths = []
    for path in all_paths(g)
        # stole the conditions from the CurricularAnalytics.jl repo
        if (in(course, path) && length(path) > 2 && path[1] != course && path[end] != course)
            # convert this path to courses
            course_path = Vector{Course}()
            for id in path
                push!(course_path, curriculum.courses[id])
            end

            # then add this path to the collection of paths
            push!(centrality_paths, course_path)
        end
    end
    centrality_paths
end

function longest_path_to_me(course_me::Course, curriculum::Curriculum, filter_course::Course, filter::Bool=false)
    # for each prereq of mine find the longest path up to that course
    longest_path_to_course_me = Course[]
    longest_paths_to_me = []
    for (key, value) in course_me.requisites
        #if (value == pre) # reconsider if coreqs count here *shrug*
        longest_path_to_prereq = longest_path_to_me(course_from_id(curriculum, key), curriculum, filter_course, filter)
        push!(longest_paths_to_me, longest_path_to_prereq)
        #end
    end
    # compare the lengths, filter by the ones that contain the filter course if needed
    if (filter)
        # choose the longest path length that contains filter course
        length_of_longest_path = 0
        for array in longest_paths_to_me
            if (length(array) > length_of_longest_path && filter_course in array)
                longest_path_to_course_me = array
                length_of_longest_path = length(array)
            end
        end
    else
        # choose the longest path
        length_of_longest_path = 0
        for array in longest_paths_to_me
            if (length(array) > length_of_longest_path)
                longest_path_to_course_me = array
                length_of_longest_path = length(array)
            end
        end
    end

    # add myself to the chosen longest path and return that
    push!(longest_path_to_course_me, course_me)
    longest_path_to_course_me
end