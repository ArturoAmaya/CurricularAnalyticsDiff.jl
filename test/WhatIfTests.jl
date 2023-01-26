using CurricularAnalyticsDiff
using CurricularAnalytics
using Test

@testset "What If Tests" begin
    # test add course
    curr = read_csv("./files/SY-CurriculumPlan-BE25.csv")

    new_course_name = "BENG 114"
    new_course_credit_hours = 4.0 # defualt, you can change it to 1.0,2.0,3.0, etc
    prereqs = Dict("BENG 122A" => pre,
        "MATH 18" => pre,
        "MAE 140" => pre)
    dependencies = Dict("TE 2" => pre,
        "MAE 107" => pre,
        "CHEM 7L" => pre)

    new_curric = add_course(new_course_name, curr, new_course_credit_hours, prereqs, dependencies)
    errors = IOBuffer()
    @test isvalid_curriculum(new_curric, errors) == true
    @test length(curr.courses) + 1 == length(new_curric.courses)
    # test that the course has the right credit new_course_credit_hours
    @test course_from_name(new_course_name, new_curric).credit_hours == 4.0
    @test course_from_name(new_course_name, new_curric).name == "BENG 114"
    @test course_from_name(new_course_name, new_curric).requisites == Dict(course_from_name("BENG 122A", new_curric).id => pre,
        course_from_name("MATH 18", new_curric).id => pre,
        course_from_name("MAE 140", new_curric).id => pre,)
    # check that the dependencies have it as a prereq
    @test course_from_name(new_course_name, new_curric) in get_course_prereqs(course_from_name("TE 2", new_curric), new_curric)
    @test course_from_name(new_course_name, new_curric) in get_course_prereqs(course_from_name("MAE 107", new_curric), new_curric)
    @test course_from_name(new_course_name, new_curric) in get_course_prereqs(course_from_name("CHEM 7L", new_curric), new_curric)

    # check that it's not in the old curriculum
    @test course_from_name(new_course_name, curr) == nothing

    # Bad Input:
    # bad course name shouldn't change anything
    new_course_name_bad = "BENG 114A"
    new_course_credit_hours_bad = 4.0 # defualt, you can change it to 1.0,2.0,3.0, etc
    prereqs_bad = Dict("BENG 122A" => pre,
        "MATH 18" => pre,
        "MAE 140" => pre)
    dependencies_bad = Dict("TE 2" => pre,
        "MAE 107" => pre,
        "CHEM 7L" => pre)
    @test isvalid_curriculum(add_course(new_course_name_bad, curr, new_course_credit_hours_bad, prereqs_bad, dependencies_bad), errors) == true

    # bad credit hours should also be fine
    new_course_credit_hours_bad = 5.0
    @test isvalid_curriculum(add_course(new_course_name_bad, curr, new_course_credit_hours_bad, prereqs_bad, dependencies_bad), errors) == true

    # changing the name of a prereq should throw it way off
    prereqs_bad = Dict("BENG 122AA" => pre, #DNE
        "MATH 18" => pre,
        "MAE 140" => pre)
    # this isn't the canonical best way to do this but it should work here
    # https://discourse.julialang.org/t/how-to-test-a-default-error-raising-methods-message/19224/3
    @test_throws ArgumentError("I'm sorry, we couldn't find your requested prerequisite in the given curriculum. Are you sure its name matched the one in the file exactly?") add_course(new_course_name_bad, curr, new_course_credit_hours_bad, prereqs_bad, dependencies_bad)

    # changing the name of a dependency should also throw it off
    prereqs_bad = Dict("BENG 122A" => pre, #DNE
        "MATH 18" => pre,
        "MAE 140" => pre)
    dependencies_bad = Dict("TE 22" => pre, #DNE
        "MAE 107" => pre,
        "CHEM 7L" => pre)
    @test_throws ArgumentError("I'm sorry, we couldn't find your requested dependent course in the given curriculum. Are you sure its name matched the one in the file exactly?") add_course(new_course_name_bad, curr, new_course_credit_hours_bad, prereqs_bad, dependencies_bad)

    #= 
    -------------------------------------------------------
    Remove a course
    -------------------------------------------------------
    =#
    curr = read_csv("./files/SY-CurriculumPlan-BE25.csv")

    course_to_remove = "MATH 20D"

    new_curric = remove_course(course_to_remove, curr)
    errors = IOBuffer()

    @test isvalid_curriculum(new_curric, errors) == true
    @test !("MATH 20D" in courses_to_course_names(new_curric.courses))
    @test ("MATH 20D" in courses_to_course_names(curr.courses))
    @test length(course_from_name("BENG 130", curr).requisites) == length(course_from_name("BENG 130", new_curric).requisites) + 1
    @test length(courses_that_depend_on_me(course_from_name("MATH 20C", curr), curr)) == length(courses_that_depend_on_me(course_from_name("MATH 20C", new_curric), new_curric)) + 1

    # bad input
    # Just a bad name
    course_to_remove = "MATH 20DD"
    @test_throws ArgumentError("I'm sorry, we couldn't find your requested course in the given curriculum. Are you sure its name matched the one in the file exactly?") remove_course(course_to_remove, curr)
    #= 
    -------------------------------------------------------
    Add a Prerequisite
    -------------------------------------------------------
    =#
    curr = read_csv("./files/SY-CurriculumPlan-BE25.csv")

    course_name = "BENG 140B"
    prerequisite = "BENG 125"
    req_type = pre

    new_curric = add_prereq(course_name, prerequisite, curr, req_type)
    errors = IOBuffer()
    @test isvalid_curriculum(new_curric, errors) == true

    # test it's hooked up right
    @test length(courses_that_depend_on_me(course_from_name("BENG 125", curr), curr)) == length(courses_that_depend_on_me(course_from_name("BENG 125", new_curric), new_curric)) - 1
    @test course_from_name("BENG 140B", new_curric).requisites[course_from_name("BENG 125", new_curric).id] == pre

    # TODO 
    # bad course name will throw it off
    course_name = "BENG 140BB"
    @test_throws ArgumentError("I'm sorry, we couldn't find your requested course in the given curriculum. Are you sure its name matched the one in the file exactly?") add_prereq(course_name, prerequisite, curr, req_type)

    course_name = "BENG 140B"
    # bad prerequisite throws it off
    prerequisite = "BENG 1255"
    @test_throws ArgumentError("I'm sorry, we couldn't find your requested prerequisite in the given curriculum. Are you sure its name matched the one in the file exactly?") add_prereq(course_name, prerequisite, curr, req_type)

    #= 
    -------------------------------------------------------
    Remove a Prerequisite
    -------------------------------------------------------
    =#
    curr = read_csv("./files/SY-CurriculumPlan-BE25.csv")

    course_name = "BENG 100"
    prerequisite = "MATH 20C"

    new_curric = remove_prereq(course_name, prerequisite, curr)
    errors = IOBuffer()
    @test isvalid_curriculum(new_curric, errors) == true

    @test length(course_from_name("BENG 100", curr).requisites) == length(course_from_name("BENG 100", new_curric).requisites) + 1
    @test length(courses_that_depend_on_me(course_from_name("MATH 20C", curr), curr)) == length(courses_that_depend_on_me(course_from_name("MATH 20C", new_curric), new_curric)) + 1
    @test course_from_name("BENG 100", new_curric).requisites == Dict(course_from_name("BENG 1", new_curric).id => pre, course_from_name("MATH 18", new_curric).id => pre)

    # bad input
    # bad course name will throw it off
    course_name = "beng 1000"
    @test_throws ArgumentError("I'm sorry, we couldn't find your requested course in the given curriculum. Are you sure its name matched the one in the file exactly?") remove_prereq(course_name, prerequisite, curr)

    # bad prereq name will throw it off
    course_name = "BENG 100"
    prerequisite = "MATH 2C"
    @test_throws ArgumentError("I'm sorry, we couldn't find your requested prerequisite in the given curriculum. Are you sure its name matched the one in the file exactly?") remove_prereq(course_name, prerequisite, curr)

end
