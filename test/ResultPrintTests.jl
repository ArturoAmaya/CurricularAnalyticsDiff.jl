using CurricularAnalyticsDiff
using CurricularAnalytics
using Test

@testset "Result Print Tests" begin
    # dummy test for now
    #=
    test1 = read_csv("./files/SY-CurriculumPlan-CE252015.csv")
    test2 = read_csv("./files/SY-CurriculumPlan-CE252016.csv")

    rdstdout, wrstdout = redirect_stdout()
    result = curricular_diff(test1, test2)
    pretty_print_curriculum_results(result, ALL)

    @test String(readavailable(rdstdout)) == "A"=#
end
