push!(LOAD_PATH, "../src/")
using Documenter, CurricularAnalyticsDiff

makedocs(
    sitename="CurricularAnalyticsDiff.jl",
    modules=[CurricularAnalyticsDiff],
    pages=[
        "Home" => "index.md"
    ]
)
# this runs on pushes to master so let's see what happens
deploydocs(repo="https://github.com/ArturoAmaya/CurricularAnalyticsDiff")