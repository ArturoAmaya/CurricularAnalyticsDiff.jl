push!(LOAD_PATH, "../src/")
using Documenter, CurricularAnalyticsDiff

makedocs(
    sitename="CurricularAnalyticsDiff.jl",
    modules=[CurricularAnalyticsDiff],
    pages=[
        "Home" => "index.md",
        "Installation" => "install.md"
    ]
)
# push to master
deploydocs(repo="github.com/ArturoAmaya/CurricularAnalyticsDiff.jl", push_preview=true)
