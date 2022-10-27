module CurricularAnalyticsDiff
using CurricularAnalytics, CSV, JSON, Crayons
# Write your package code here.
include("./Diff.jl")
include("./HelperFns.jl")
include("./ResultPrint.jl")
include("./secret_helper.jl")
include("./Whatif.jl")

export course_diff_for_unmatched_course, course_diff, curricular_diff, course_match, course_find, prereq_print, get_course_prereqs, course_from_name, pretty_print_course_names, courses_to_course_names, courses_that_depend_on_me, blocking_factor_investigator, delay_factor_investigator, centrality_investigator, longest_path_to_me, executive_summary_course, executive_summary_unmatched_course, executive_summary_curriculum, pretty_print_centrality_results, pretty_print_complexity_results, pretty_print_blocking_factor_results, pretty_print_delay_factor_results, pretty_print_prereq_changes, pretty_print_course_results, pretty_print_curriculum_results, find_balanced_out_changes, find_unique_course_names, add_course, remove_course, add_prereq, remove_prereq, add, del, ALL, CEN, COM, BLO, DEL, PRE
end
