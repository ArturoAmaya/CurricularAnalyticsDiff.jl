push!(LOAD_PATH, "../src/")
using Documenter, CurricularAnalyticsDiff

makedocs(
    sitename="CurricularAnalyticsDiff.jl",
    modules=[CurricularAnalyticsDiff],
    pages=[
        "Home" => "index.md"
    ]
)

deploydocs(repo="https://github.com/ArturoAmaya/CurricularAnalyticsDiff")