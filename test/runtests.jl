using CurricularAnalyticsDiff
using CurricularAnalytics
using Test

@testset "CurricularAnalyticsDiff.jl" begin
    UCSD = read_csv("./files/SY-Curriculum Plan-BE25.csv")
    @test UCSD != Nothing
end
