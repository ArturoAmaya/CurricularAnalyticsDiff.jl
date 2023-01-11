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


end
