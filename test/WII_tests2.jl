using CurricularAnalyticsDiff
using CurricularAnalytics
using Test

#new_plans = add_course_compound("MATH 30", 5.0, Dict("MATH 20A" => pre), Dict("MATH 20B" => pre), condensed, [""], prereq_df, plans, new_plans)
condensed = read_csv("./files/condensed2.csv")
affected = add_course_institutional("MATH 30", condensed, 5.0, Dict("MATH 20A" => pre), Dict("MATH 20B" => pre))
println("done")