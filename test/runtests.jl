using CurricularAnalyticsDiff
using CurricularAnalytics
using Test

@testset "CurricularAnalyticsDiff.jl" begin
    #UCSD = read_csv("./files/condensed.csv")
    #@test add_course_institutional(UCSD, "MATH 20B.5", 4.0, Dict("MATH 20B" => pre), Dict("MATH 20C" => pre))

    test = read_csv("./files/SY-Curriculum Plan-BE25.csv")
    # course from name
    @test course_from_name("MATH 20A", test) === test.courses[2]
end
