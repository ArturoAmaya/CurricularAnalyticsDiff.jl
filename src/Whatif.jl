using CurricularAnalytics
#include("./Diff.jl")
#include("./ResultPrint.jl")

## WHAT IF:
#=
I add a course?
I remove a course?
I add a prereq?
I remove a prereq?
=#
@enum Edit_Type add del

# What if I add a course?
"""
    add_course(course_name, curr, credit_hours, prereqs, dependencies)
Return a copy of `curr` where a new course with the provided information has been added.

# Arguments
- `course_name::AbstractString`: The name of the course to add.
- `curr::Curriculum`: The curriculum to add a course to.
- `credit_hours::Real`: How many credit hours the new course is worth.
- `prereqs::Dict`: The names of the prerequisites for the new course and their requisite type.
- `dependencies::Dict`: The names of the courses that would have the new course as a prerequisite and the requisite type.
"""
function add_course(course_name::AbstractString, curr::Curriculum, credit_hours::Real, prereqs::Dict, dependencies::Dict)
    ## create the course in the curricular analytics sense
    new_course = Course(course_name, credit_hours)
    modded_curric = deepcopy(curr)
    ## hook it up to the curriculum
    # loop through the names of its prereqs and find them in modded_curric (so we don't alter the original)
    for (prereq, req_type) in prereqs
        prereq_course = course_from_name(prereq, modded_curric)
        if typeof(prereq_course) == Nothing
            throw(ArgumentError("I'm sorry, we couldn't find your requested prerequisite in the given curriculum. Are you sure its name matched the one in the file exactly?"))
        end
        add_requisite!(prereq_course, new_course, req_type)
    end
    # loop through the names of its dependencies and find them in modded_curric
    for (dep, type) in dependencies
        dependent_course = course_from_name(dep, modded_curric)
        if typeof(dependent_course) == Nothing
            throw(ArgumentError("I'm sorry, we couldn't find your requested dependent course in the given curriculum. Are you sure its name matched the one in the file exactly?"))
        end
        add_requisite!(new_course, dependent_course, type)
    end

    ## make a new curriculum after modifying these courses
    course_list = modded_curric.courses
    push!(course_list, new_course)

    new_curric = Curriculum("Proposed Curriculum", course_list, system_type=curr.system_type)

end

# What if I remove a course?
"""
    remove_course(course_name::AbstractString, curr::Curriculum)
Return a copy of `curr` where the course with name `course_name` has been removed.

It is removed from all of the prerequisite chains it was in.
"""
function remove_course(course_name::AbstractString, curr::Curriculum,)
    modded_curric = deepcopy(curr)
    course = course_from_name(course_name, modded_curric)
    if typeof(course) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your requested course in the given curriculum. Are you sure its name matched the one in the file exactly?"))
    end
    # unhook it from the curriculum
    # loop through its dependents and unhook
    dependents = courses_that_depend_on_me(course, modded_curric)

    for dep in dependents
        delete_requisite!(course, dep)
    end

    # technically we should unhook from the given course TOO
    for (req_id, type) in course.requisites
        req = course_from_id(modded_curric, req_id)
        delete_requisite!(req, course)
    end

    # Make a new curriculum
    new_course_list = AbstractCourse[]
    for crs in modded_curric.courses
        if (crs != course)
            push!(new_course_list, crs)
        end
    end

    new_curric = Curriculum("Proposed Curriculum", new_course_list, system_type=curr.system_type)
end

# What if I add a prereq to this course?
"""
    add_prereq(course_name::AbstracString, added_prereq::AbstracString, curr::Curriculum, reqtype::Requisite)
Return a copy of `curr` where the course with name `added_prereq` has been added as a requisite of type `reqtype` to the course with name `course_name`.
"""
function add_prereq(course_name::AbstractString, added_prereq::AbstractString, curr::Curriculum, reqtype::Requisite)
    modded_curric = deepcopy(curr)

    target_course = course_from_name(course_name, modded_curric)
    if typeof(target_course) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your requested course in the given curriculum. Are you sure its name matched the one in the file exactly?"))
    end
    added_prq = course_from_name(added_prereq, modded_curric)
    if typeof(added_prq) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your requested prerequisite in the given curriculum. Are you sure its name matched the one in the file exactly?"))
    end
    add_requisite!(added_prq, target_course, reqtype)
    new_curric = Curriculum("Proposed Curriculum", modded_curric.courses, system_type=curr.system_type)
end

# What if I remove to_remove from course_name?
"""
    remove_prereq(course_name::AbstractString, to_remove::AbstractString, curr::Curriculum)
Return a copy of `curr` where the course with name `to_remove` has been removed as a prerequisite of the course with name `course_name`.
"""
function remove_prereq(course_name::AbstractString, to_remove::AbstractString, curr::Curriculum,)
    modded_curric = deepcopy(curr)

    course = course_from_name(course_name, modded_curric)
    if typeof(course) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your requested course in the given curriculum. Are you sure its name matched the one in the file exactly?"))
    end
    to_remove_course = course_from_name(to_remove, modded_curric)
    if typeof(to_remove_course) == Nothing
        throw(ArgumentError("I'm sorry, we couldn't find your requested prerequisite in the given curriculum. Are you sure its name matched the one in the file exactly?"))
    end
    delete_requisite!(to_remove_course, course)
    new_curric = Curriculum("Proposed Curriculum", modded_curric.courses, system_type=curr.system_type)
end