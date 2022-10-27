using CurricularAnalytics
include("./Diff.jl")
include("./ResultPrint.jl")

## WHAT IF:
#=
I add a course?
I remove a course?
I add a prereq?
I remove a prereq?
=#
@enum Edit_Type add del

# What if I add a course?
function add_course(curr::Curriculum, course_name::AbstractString, credit_hours::Real, prereqs::Dict{String,Requisite}, dependencies::Dict{String,Requisite})
    ## create the course in the curricular analytics sense
    new_course = Course(course_name, credit_hours)

    modded_curric = deepcopy(curr)
    ## hook it up to the curriculum
    # loop through the names of its prereqs and find them in modded_curric (so we don't alter the original)
    for (prereq, req_type) in prereqs
        prereq_course = course_from_name(modded_curric, prereq)
        add_requisite!(prereq_course, new_course, req_type)
    end
    # loop through the names of its dependencies and find them in modded_curric
    for (dep, type) in dependencies
        dependent_course = course_from_name(modded_curric, dep)
        add_requisite!(new_course, dependent_course, type)
    end

    ## make a new curriculum after modifying these courses
    course_list = modded_curric.courses
    push!(course_list, new_course)

    new_curric = Curriculum("Proposed Curriculum", course_list, system_type=curr.system_type)

end

# What if I remove a course?
function remove_course(curr::Curriculum, course_name::AbstractString)
    modded_curric = deepcopy(curr)
    course = course_from_name(modded_curric, course_name)
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
function add_prereq(curr::Curriculum, course_name::AbstractString, added_prereq::AbstractString, reqtype::Requisite)
    modded_curric = deepcopy(curr)

    target_course = course_from_name(modded_curric, course_name)
    added_prq = course_from_name(modded_curric, added_prereq)
    add_requisite!(added_prq, target_course, reqtype)
    new_curric = Curriculum("Proposed Curriculum", modded_curric.courses, system_type=curr.system_type)
end

# What if I remove to_remove from course_name?
function remove_prereq(curr::Curriculum, course_name::AbstractString, to_remove::AbstractString)
    modded_curric = deepcopy(curr)

    course = course_from_name(modded_curric, course_name)
    to_remove_course = course_from_name(modded_curric, to_remove)
    delete_requisite!(to_remove_course, course)
    new_curric = Curriculum("Proposed Curriculum", modded_curric.courses, system_type=curr.system_type)
end