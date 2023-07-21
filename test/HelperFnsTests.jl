using CurricularAnalyticsDiff
using CurricularAnalytics
using Test


@testset "HelperFns tests" begin
    test = read_csv("./files/SY-CurriculumPlan-BE25.csv")

    # prereq_print 
    @test typeof(prereq_print(Set{AbstractString}(["MATH 20A", "MATH 20B", "MATH 20E"]))) == String
    @test prereq_print(Set{AbstractString}(["MATH 20A", "MATH 20B", "BENG 110", "CALC 87"])) == join(
        append!([" "], [p * " " for p in Set{AbstractString}(["MATH 20A", "MATH 20B", "BENG 110", "CALC 87"])]))
    @test prereq_print(Set{AbstractString}([""])) == "  "
    @test prereq_print(Set{AbstractString}()) == " "


    # course from name
    @test course_from_name("MATH 20A", test) === test.courses[2]
    @test course_from_name("PHYS 2A", test) === test.courses[5]
    @test typeof(course_from_name("BENG 130", test)) == Course
    # test for 0.1.5 course name update
    test2 = read_csv("./files/massive/output2022/MA30/FI.csv")
    # these courses are called MATH 20D/MATH 109 and MATH 109/MATH 20D but one has prefix + name MATH 20D and the other has prefix + name MATH 109
    @test course_from_name("MATH 20D", test2.curriculum) === test2.curriculum.courses[8]
    @test course_from_name("MATH 109", test2.curriculum) === test2.curriculum.courses[10]

    # get course prereqs
    @test get_course_prereqs(test.courses[2], test) == Vector{Course}()
    @test get_course_prereqs(test.courses[5], test) == Vector{Course}([test.courses[2]])
    @test typeof(get_course_prereqs(test.courses[5], test)) == Vector{Course}
    @test get_course_prereqs(test.courses[22], test) == Vector{Course}([test.courses[6], test.courses[15], test.courses[7]])
    @test get_course_prereqs(test.courses[26], test) == Vector{Course}([test.courses[5], test.courses[4], test.courses[2], test.courses[11], test.courses[8], test.courses[14], test.courses[3]])
    @test get_course_prereqs(test.courses[26], test) != Vector{Course}([test.courses[4], test.courses[5], test.courses[11], test.courses[8], test.courses[14], test.courses[2], test.courses[3]])
    @test Set(get_course_prereqs(test.courses[26], test)) == Set(Vector{Course}([test.courses[4], test.courses[5], test.courses[11], test.courses[8], test.courses[14], test.courses[2], test.courses[3]]))

    # courses that depend on me (first level only)
    @test typeof(courses_that_depend_on_me(test.courses[10], test)) == Vector{Course}
    @test courses_that_depend_on_me(test.courses[1], test) == [test.courses[3], test.courses[16]]
    @test courses_that_depend_on_me(test.courses[8], test) == [test.courses[13], test.courses[16], test.courses[26]]
    @test courses_that_depend_on_me(test.courses[8], test) != [test.courses[16], test.courses[13], test.courses[26]]

    # longest path to me
    @test typeof(longest_path_to_me(test.courses[11], test, test.courses[11], false)) == Vector{Course}
    @test longest_path_to_me(test.courses[11], test, test.courses[11], false) == [test.courses[2], test.courses[4], test.courses[7], test.courses[11]]
    @test longest_path_to_me(course_from_name("BENG 110", test), test, test.courses[24], false) == [course_from_name("MATH 20A", test), course_from_name("MATH 20B", test), course_from_name("MATH 20C", test), course_from_name("MATH 20D", test), course_from_name("BENG 110", test)]
    # canonical longest path through to phys 2b is math 20a phys 2a phys2b
    @test longest_path_to_me(course_from_name("PHYS 2B", test), test, test.courses[8], false) == [test.courses[2], test.courses[5], test.courses[8]]
    # alt longest path through to phys2b is math20a, math20b, phys 2b. This should return math20b, phys 2b
    @test longest_path_to_me(course_from_name("PHYS 2B", test), test, test.courses[4], true) == [test.courses[4], test.courses[8]]
    @test longest_path_to_me(course_from_name("PHYS 2B", test), test, test.courses[9], true) == [course_from_name("PHYS 2B", test)]

    # course to course names
    @test typeof(courses_to_course_names([test.courses[11], test.courses[12], test.courses[15], test.courses[18]])) == Vector{AbstractString}
    @test courses_to_course_names([test.courses[11], test.courses[12], test.courses[15], test.courses[18]]) == ["MATH 20D", "CHEM 7L", "MATH 18", "MAE 8"]

    # blocking factor investigator 
    @test Set(blocking_factor_investigator(test.courses[8], test)) == Set([test.courses[13], test.courses[26], test.courses[16], test.courses[20], test.courses[28], test.courses[29], test.courses[25]])
    @test blocking_factor_investigator(test.courses[8], test) == [test.courses[13], test.courses[16], test.courses[26], test.courses[25], test.courses[20], test.courses[28], test.courses[29]]
    @test Set(blocking_factor_investigator(test.courses[11], test)) == Set([test.courses[24], test.courses[26], test.courses[27], test.courses[31], test.courses[30], test.courses[34], test.courses[38], test.courses[32], test.courses[33], test.courses[36], test.courses[37]])
    @test blocking_factor_investigator(test.courses[11], test) == [test.courses[24], test.courses[26], test.courses[27], test.courses[34], test.courses[30], test.courses[31], test.courses[32], test.courses[38], test.courses[33], test.courses[36], test.courses[37]]
    @test blocking_factor_investigator(test.courses[43], test) == []

    # delay factor investigator
    # Note that this doesn't match the canonical longest path determined in the visualization software. This is interesting.
    @test delay_factor_investigator(test.courses[8], test) == [test.courses[2], test.courses[5], test.courses[8], test.courses[13], test.courses[25], test.courses[28]]
    @test typeof(delay_factor_investigator(test.courses[8], test)) == Vector{Course}
    @test delay_factor_investigator(test.courses[43], test) == [test.courses[43]]

    # centrality investigator
    ## the centrlaity investigator doesn't track centrality paths for sink or source nodes. It should though. that's an issue for later TODO
    @test centrality_investigator(test.courses[1], test) == []
    @test centrality_investigator(test.courses[37], test) == []
    # a simple one path test
    @test centrality_investigator(test.courses[35], test) == [[course_from_name("MAE 140", test), course_from_name("BENG 122A", test), course_from_name("BENG 125", test)]]
    # a multiple path test
    @test Set(centrality_investigator(course_from_name("PHYS 2B", test), test)) == Set([
        [course_from_name("MATH 20A", test), course_from_name("MATH 20B", test), course_from_name("PHYS 2B", test), course_from_name("PHYS 2CL", test), course_from_name("MAE 170", test), course_from_name("BENG 186B", test)],
        [course_from_name("MATH 20A", test), course_from_name("MATH 20B", test), course_from_name("PHYS 2B", test), course_from_name("PHYS 2CL", test), course_from_name("MAE 170", test), course_from_name("BENG 172", test)],
        [course_from_name("MATH 20A", test), course_from_name("MATH 20B", test), course_from_name("PHYS 2B", test), course_from_name("BENG 130", test)],
        [course_from_name("MATH 20A", test), course_from_name("MATH 20B", test), course_from_name("PHYS 2B", test), course_from_name("BENG 140A", test), course_from_name("BENG 140B", test)],
        [course_from_name("MATH 20A", test), course_from_name("PHYS 2A", test), course_from_name("PHYS 2B", test), course_from_name("PHYS 2CL", test), course_from_name("MAE 170", test), course_from_name("BENG 186B", test)],
        [course_from_name("MATH 20A", test), course_from_name("PHYS 2A", test), course_from_name("PHYS 2B", test), course_from_name("PHYS 2CL", test), course_from_name("MAE 170", test), course_from_name("BENG 172", test)],
        [course_from_name("MATH 20A", test), course_from_name("PHYS 2A", test), course_from_name("PHYS 2B", test), course_from_name("BENG 130", test)],
        [course_from_name("MATH 20A", test), course_from_name("PHYS 2A", test), course_from_name("PHYS 2B", test), course_from_name("BENG 140A", test), course_from_name("BENG 140B", test)]
    ])
    # a second multiple path test
    @test Set(centrality_investigator(course_from_name("MATH 20D", test), test)) == Set([
        [course_from_name("MATH 20A", test), course_from_name("MATH 20B", test), course_from_name("MATH 20C", test), course_from_name("MATH 20D", test), course_from_name("BENG 130", test)],
        [course_from_name("MATH 20A", test), course_from_name("MATH 20B", test), course_from_name("MATH 20C", test), course_from_name("MATH 20D", test), course_from_name("BENG 110", test), course_from_name("BENG 112A", test), course_from_name("BENG 103B", test)],
        [course_from_name("MATH 20A", test), course_from_name("MATH 20B", test), course_from_name("MATH 20C", test), course_from_name("MATH 20D", test), course_from_name("BENG 110", test), course_from_name("BENG 112A", test), course_from_name("BENG 112B", test), course_from_name("BENG 186A", test)],
        [course_from_name("MATH 20A", test), course_from_name("MATH 20B", test), course_from_name("MATH 20C", test), course_from_name("MATH 20D", test), course_from_name("BENG 110", test), course_from_name("BENG 112A", test), course_from_name("BENG 187A", test), course_from_name("BENG 187B", test), course_from_name("BENG 187C", test), course_from_name("BENG 187D", test)],
        [course_from_name("MATH 20A", test), course_from_name("MATH 20B", test), course_from_name("MATH 20C", test), course_from_name("MATH 20D", test), course_from_name("BENG 110", test), course_from_name("MAE 150", test)]
    ])
end
