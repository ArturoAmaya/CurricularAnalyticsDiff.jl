using CurricularAnalyticsDiff
using CurricularAnalytics

using JSON
using Test

@testset "Diff tests" begin
    test = read_csv("./files/SY-CurriculumPlan-BE25.csv")

    # curricular diff
    ## same curriculum. 
    ### No params Requires some visual check that all the printed lines are using the checkmark emoji
    @test curricular_diff(test, test) == JSON.parsefile("./test/test_w_itself.json")

    ## same curriculum   
    ### verbose off. Shouldn't ever detect there's a difference and should just return empty values
    @test curricular_diff(test, test, false) == Dict{Any,Any}()

    ## same curriculum
    ### redundants... TODO

    ## different years of the same curriculum - CE25 2015 and 2016
    test1 = read_csv("./files/SY-Curriculum Plan-CE25 2015.csv")
    test2 = read_csv("./files/SY-Curriculum Plan-CE25 2016.csv")

    # no params
    @test curricular_diff(test1, test2) == JSON.parsefile("./test/ce252015_toce252016.json")

end

