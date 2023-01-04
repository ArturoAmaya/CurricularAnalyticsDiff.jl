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
    test1 = read_csv("./files/SY-CurriculumPlan-CE252015.csv")
    test2 = read_csv("./files/SY-CurriculumPlan-CE252016.csv")

    ### no params
    @test curricular_diff(test1, test2) == JSON.parsefile("./test/ce252015_toce252016.json")
    #### verbose off. should return the same as verbose on since there are noticeable differences
    @test curricular_diff(test1, test2, false) == JSON.parsefile("./test/testce2515toce2516false.json")

    ### redundants too because that is a lot of work

    # course diff
    ## same course, same curriculum
    @test course_diff(test1.courses[3], test1.courses[3], test1, test1, false) == Dict{String,Any}("complexity" => Dict{Any,Any}("course 1 score" => 12.7, "course 2 score" => 12.7), "c1 name" => "Chemical Engineering", "centrality" => Dict{Any,Any}("course 1 score" => 0, "course 2 score" => 0), "contribution to curriculum differences" => Dict("complexity" => 0.0, "centrality" => 0.0, "blocking factor" => 0.0, "delay factor" => 0.0), "prereqs" => Dict{Any,Any}("gained prereqs" => AbstractString[], "lost prereqs" => AbstractString[]), "blocking factor" => Dict{Any,Any}("course 1 score" => 12, "course 2 score" => 12), "c2 name" => "Chemical Engineering", "delay factor" => Dict{Any,Any}("course 1 score" => 7.0, "course 2 score" => 7.0))
    # TODO rest

end

