include("./Diff.jl")
@enum DesiredStat ALL CEN COM BLO DEL PRE

function executive_summary_course(results::Dict{String,Any}, course_name::AbstractString)
    println("----------------")
    println("$course_name:")
    if (results["contribution to curriculum differences"]["centrality"] != 0.0)
        if (length(results["centrality"]["paths not in c2"]) != 0)
            # find the total sum of paths not in c2
            lost_paths = sum(length(path) for path in results["centrality"]["paths not in c2"])
            print(GREEN_BG, "Lost $(lost_paths) centrality ")
            print(Crayon(reset=true), "due to:\n")
            for (key, course) in results["centrality"]["courses not in c2 paths"]
                if (length(course["gained prereqs"]) != 0 || length(course["lost prereqs"]) != 0)
                    print("\t$key:")
                    if (length(course["lost prereqs"]) != 0)
                        print("\t losing")
                        for loss in course["lost prereqs"]
                            print(" $loss")
                        end
                    end
                    if (length(course["gained prereqs"]) != 0)
                        print("\t gaining")
                        for gain in course["gained prereqs"]
                            print(" $gain")
                        end
                    end
                    println("")
                end
            end
        end
        if (length(results["centrality"]["paths not in c1"]) != 0)
            # find the total sum of paths not in c1
            gained_paths = sum(length(path) for path in results["centrality"]["paths not in c1"])
            print(RED_BG, "Gained $(gained_paths) centrality ")
            print(Crayon(reset=true), "due to:\n")
            for (key, course) in results["centrality"]["courses not in c1 paths"]
                if (length(course["gained prereqs"]) != 0 || length(course["lost prereqs"]) != 0)
                    print("\t$key:")
                    if (length(course["lost prereqs"]) != 0)
                        print("\t losing")
                        for loss in course["lost prereqs"]
                            print(" $loss")
                        end
                    end
                    if (length(course["gained prereqs"]) != 0)
                        print("\t gaining")
                        for gain in course["gained prereqs"]
                            print(" $gain")
                        end
                    end
                    println("")
                end
            end
        end
    end
    if (results["contribution to curriculum differences"]["blocking factor"] != 0.0)
        if (results["blocking factor"]["length not in c2 ufield"] != 0)
            print(GREEN_BG, "Lost $(results["blocking factor"]["length not in c2 ufield"]) courses in blocking factor ")
            print(Crayon(reset=true), "due to:\n")
            for (key, course) in results["blocking factor"]["not in c2 ufield"]
                if (length(course["gained prereqs"]) != 0 || length(course["lost prereqs"]) != 0 || length(course["in_both"]) != 0)
                    print("\t$key")
                    if (length(course["lost prereqs"]) != 0)
                        print("\t losing")
                        for loss in course["lost prereqs"]
                            print(" $loss")
                        end
                    end
                    if (length(course["gained prereqs"]) != 0)
                        print("\t gaining")
                        for gain in course["gained prereqs"]
                            print(" $gain")
                        end
                    end
                    if (length(course["in_both"]) != 0)
                        print("\tdepending on")
                        for overlap in course["in_both"]
                            print(" $overlap")
                        end
                    end
                    println("")
                end

            end
        end
        if (results["blocking factor"]["length not in c1 ufield"] != 0)
            print(RED_BG, "Gained $(results["blocking factor"]["length not in c1 ufield"]) courses in blocking factor ")
            print(Crayon(reset=true), "due to:\n")
            for (key, course) in results["blocking factor"]["not in c1 ufield"]
                if (length(course["gained prereqs"]) != 0 || length(course["lost prereqs"]) != 0 || length(course["in_both"]) != 0)
                    print("\t$key")
                    if (length(course["lost prereqs"]) != 0)
                        print("\t losing")
                        for loss in course["lost prereqs"]
                            print(" $loss")
                        end
                    end
                    if (length(course["gained prereqs"]) != 0)
                        print("\t gaining")
                        for gain in course["gained prereqs"]
                            print(" $gain")
                        end
                    end
                    if (length(course["in_both"]) != 0)
                        print("\tdepending on")
                        for overlap in course["in_both"]
                            print(" $overlap")
                        end
                    end
                    println("")
                end
            end
        end
    end
    if (results["contribution to curriculum differences"]["delay factor"] != 0.0)
        print("Delay Factor: ")
        if (results["contribution to curriculum differences"]["delay factor"] > 0)
            print(RED_BG, "Gained $(abs(results["contribution to curriculum differences"]["delay factor"]))")
        else
            print(GREEN_BG, "Lost $(abs(results["contribution to curriculum differences"]["delay factor"]))")
        end
        print(Crayon(reset=true), "\nWent from: ") # important, stops red/green from overflowing for some reason
        pretty_print_course_names(results["delay factor"]["df path course 1"])
        print("Length: $(results["delay factor"]["course 1 score"])\n")
        print("To: ")
        pretty_print_course_names(results["delay factor"]["df path course 2"])
        print("Length: $(results["delay factor"]["course 2 score"])\n")
        print("Due to:\n")
        for (key, course) in results["delay factor"]["courses involved"]
            if (length(course["gained prereqs"]) != 0 || length(course["lost prereqs"]) != 0)
                print("\t$key")
                if (length(course["lost prereqs"]) != 0)
                    print("\t losing")
                    for loss in course["lost prereqs"]
                        print(" $loss")
                    end
                end
                if (length(course["gained prereqs"]) != 0)
                    print("\t gaining")
                    for gain in course["gained prereqs"]
                        print(" $gain")
                    end
                end
                println("")
            end
        end
    end
end

function executive_summary_unmatched_course(results::Dict{}, course_name::AbstractString)
    println("----------------")
    println("$course_name:")
    if (results["contribution to curriculum differences"]["centrality"] != 0.0)
        # if it's a C1-only course, it lost everything
        results["c1"] ? print(GREEN_BG("Lost $(results["centrality"]) centrality. "), Crayon(reset=true), "Course doesn't exist in curriculum 2") :
        print(RED_BG("Gained $(results["centrality"]) centrality. "), Crayon(reset=true), "Course doesn't exist in curriculum 1")

        print(Crayon(reset=true), "\n")
    end
    if (results["contribution to curriculum differences"]["blocking factor"] != 0.0)
        # if it's a C1-only course, it lost everything
        results["c1"] ? print(GREEN_BG("Lost $(results["blocking factor"]) blocking factor. "), Crayon(reset=true), "Course doesn't exist in curriculum 2") :
        print(RED_BG("Gained $(results["blocking factor"]) blocking factor. "), Crayon(reset=true), "Course doesn't exist in curriculum 1")

        print(Crayon(reset=true), "\n")
    end
    if (results["contribution to curriculum differences"]["delay factor"] != 0.0)
        # if it's a C1-only course, it lost everything
        results["c1"] ? print(GREEN_BG("Lost $(results["delay factor"]) delay factor. "), Crayon(reset=true), "Course doesn't exist in curriculum 2") :
        print(RED_BG("Gained $(results["delay factor"]) delay factor. "), Crayon(reset=true), "Course doesn't exist in curriculum 1")

        print(Crayon(reset=true), "\n")
    end

end

function executive_summary_curriculum(curriculum_results::Dict{})
    for (key, value) in curriculum_results["matched courses"]
        if (value["contribution to curriculum differences"]["centrality"] != 0.0 || value["contribution to curriculum differences"]["blocking factor"] != 0.0 || value["contribution to curriculum differences"]["delay factor"] != 0.0)
            executive_summary_course(value, key)
        end
    end
    if (length(curriculum_results["unmatched courses"]) != 0)
        println("******************")
        println("Unmatched Courses")
        for (key, value) in curriculum_results["unmatched courses"]
            if (value["contribution to curriculum differences"]["centrality"] != 0.0 || value["contribution to curriculum differences"]["blocking factor"] != 0.0 || value["contribution to curriculum differences"]["delay factor"] != 0.0)
                executive_summary_unmatched_course(value, key)
            end
        end
    end
end

# pretty print section
function pretty_print_centrality_results(results::Dict{String,Any})
    # CENTRALITY -----------------------------------------------------------------------
    print("Centrality: ")
    # highlight the centrality change: if its negative, that's good, so green. Else red
    results["contribution to curriculum differences"]["centrality"] <= 0 ?
    print(GREEN_BG, results["contribution to curriculum differences"]["centrality"]) :
    print(RED_BG, results["contribution to curriculum differences"]["centrality"])
    print(Crayon(reset=true), "\n")

    print(Crayon(reset=true), "Curriculum 1 score: $(results["centrality"]["course 1 score"])\tCurriculum 2 score: $(results["centrality"]["course 2 score"])\n")

    if ("paths not in c2" in keys(results["centrality"]))
        print("Paths not in Curriculum 2:\n")
        for path in results["centrality"]["paths not in c2"]
            pretty_print_course_names(path)
        end

        print("Courses in lost paths that have changed:\n")
        for (key, value) in results["centrality"]["courses not in c2 paths"]
            if (length(value["gained prereqs"]) != 0 || length(value["lost prereqs"]) != 0)
                print("$key: ")
                if (length(value["gained prereqs"]) != 0)
                    print("\tgained:")
                    for gain in value["gained prereqs"]
                        print(" $gain")
                    end
                else
                    print("\tdidn't gain any prereqs")
                end
                print("\tand")
                if (length(value["lost prereqs"]) != 0)
                    print("\tlost:")
                    for loss in value["lost prereqs"]
                        print(" $loss")
                    end
                else
                    print("\tdidn't lose any prereqs")
                end
                print("\n")
            end
        end
    end

    if ("paths not in c1" in keys(results["centrality"]))
        print("Paths not in Curriculum 1:\n")
        for path in results["centrality"]["paths not in c1"]
            pretty_print_course_names(path)
        end

        print("Courses in gained paths that have changed: \n")
        for (key, value) in results["centrality"]["courses not in c1 paths"]
            if (length(value["gained prereqs"]) != 0 || length(value["lost prereqs"]) != 0)
                print("$key: ")
                if (length(value["gained prereqs"]) != 0)
                    print("\tgained:")
                    for gain in value["gained prereqs"]
                        print(" $gain")
                    end
                else
                    print("\tdidn't gain any prereqs")
                end
                print("\tand")
                if (length(value["lost prereqs"]) != 0)
                    print("\tlost:")
                    for loss in value["lost prereqs"]
                        print(" $loss")
                    end
                else
                    print("\tdidn't lose any prereqs")
                end
                print("\n")
            end
        end
    end
end

function pretty_print_complexity_results(results::Dict{String,Any})
    print("Complexity: ")
    results["contribution to curriculum differences"]["complexity"] <= 0 ?
    print(GREEN_BG, results["contribution to curriculum differences"]["complexity"]) :
    print(RED_BG, results["contribution to curriculum differences"]["complexity"])

    print(Crayon(reset=true), "\n")

    print(Crayon(reset=true), "Score in Curriculum 1: $(results["complexity"]["course 1 score"]) \t Score in Curriculum 2: $(results["complexity"]["course 2 score"])\n")

    pretty_print_blocking_factor_results(results)
    pretty_print_delay_factor_results(results)
end

function pretty_print_blocking_factor_results(results::Dict{String,Any})
    # Print the blocking factor results
    print("Blocking Factor: ")
    results["contribution to curriculum differences"]["blocking factor"] <= 0 ?
    print(GREEN_BG, results["contribution to curriculum differences"]["blocking factor"]) :
    print(RED_BG, results["contribution to curriculum differences"]["blocking factor"])
    print(Crayon(reset=true), "\n")

    print(Crayon(reset=true), "Score in Curriculum 1: $(results["blocking factor"]["course 1 score"])")
    print(Crayon(reset=true), "\t")
    print(Crayon(reset=true), "Score in Curriculum 2: $(results["blocking factor"]["course 2 score"])")
    print(Crayon(reset=true), "\n")

    if ("not in c2 ufield" in keys(results["blocking factor"]))
        if (length(results["blocking factor"]["not in c2 ufield"]) != 0)
            print("Courses not in this course's unblocked field in curriculum 2:\n")
            for (key, value) in results["blocking factor"]["not in c2 ufield"]
                print("$(key):\n")
                if (length(value["gained prereqs"]) != 0)
                    print("\tgained:")
                    for gain in value["gained prereqs"]
                        print(" $gain")
                    end
                else
                    print("\tno gained prereqs")
                end
                print("\n")
                if (length(value["lost prereqs"]) != 0)
                    print("\tlost:")
                    for loss in value["lost prereqs"]
                        print(" $loss")
                    end
                else
                    print("\tno lost prereqs")
                end
                print("\n")
                if (length(value["in_both"]) != 0)
                    print("\talso has as prereq:")
                    for overlap in value["in_both"]
                        print(" $(overlap)")
                    end
                else
                    print("\tno dependency on another course in this list")
                end
                print("\n")
            end
        else
            println("All courses in the Curriculum 1 unblocked field are in the Curriculum 2 unblocked field")
        end
    end

    if ("not in c1 ufield" in keys(results["blocking factor"]))
        if (length(results["blocking factor"]["not in c1 ufield"]) != 0)
            print("Courses not in this course's unblocked field in curriculum 1:\n")
            for (key, value) in results["blocking factor"]["not in c1 ufield"]
                print("$(key):\n")
                if (length(value["gained prereqs"]) != 0)
                    print("\tgained:")
                    for gain in value["gained prereqs"]
                        print(" $gain")
                    end
                else
                    print("\tno gained prereqs")
                end
                print("\n")
                if (length(value["lost prereqs"]) != 0)
                    print("\tlost:")
                    for loss in value["lost prereqs"]
                        print(" $loss")
                    end
                else
                    print("\tno lost prereqs")
                end
                print("\n")
                if (length(value["in_both"]) != 0)
                    print("\talso has as prereq:")
                    for overlap in value["in_both"]
                        print(" $(overlap)")
                    end
                else
                    print("\tno dependency on another course in this list")
                end
                print("\n")
            end
        else
            println("All courses in the Curriculum 2 unblocked field are in the Curriculum 1 unblocked field")
        end
    end
end

function pretty_print_delay_factor_results(results::Dict{String,Any})
    # Delay factor 
    print("Delay Factor: ")
    results["contribution to curriculum differences"]["delay factor"] <= 0 ?
    print(GREEN_BG, results["contribution to curriculum differences"]["delay factor"]) :
    print(RED_BG, results["contribution to curriculum differences"]["delay factor"])
    print(Crayon(reset=true), "\n")

    print(Crayon(reset=true), "Score in Curriculum 1: $(results["delay factor"]["course 1 score"])\t Score in Curriculum 2: $(results["delay factor"]["course 2 score"])\n")

    if ("df path course 1" in keys(results["delay factor"])) # if there's one there both
        print("Delay Factor Path in Curriculum 1:\n")
        pretty_print_course_names(results["delay factor"]["df path course 1"])

        print("Delay Factor Path in Curriculum 2:\n")
        pretty_print_course_names(results["delay factor"]["df path course 2"])

        println("Courses involved that changed:")
        for (key, value) in results["delay factor"]["courses involved"]
            if (length(value["gained prereqs"]) != 0 || length(value["lost prereqs"]) != 0)
                print("$key:\n")
                if (length(value["gained prereqs"]) != 0)
                    print("\tgained:")
                    for gain in value["gained prereqs"]
                        print(" $gain")
                    end
                else
                    print("\tno gained prereqs")
                end
                print("\n")
                if (length(value["lost prereqs"]) != 0)
                    print("\tlost:")
                    for loss in value["lost prereqs"]
                        print(" $loss")
                    end
                else
                    print("\tno lost prereqs")
                end
                print("\n")
            end
        end
    end
end

function pretty_print_prereq_changes(results::Dict{String,Any})
    if (length(results["prereqs"]["gained prereqs"]) != 0)
        println("Gained prereqs:")
        for course in results["prereqs"]["gained prereqs"]
            print(" $course")
        end
        println("")
    end

    if (length(results["prereqs"]["lost prereqs"]) != 0)
        println("Lost prereqs:")
        for course in results["prereqs"]["lost prereqs"]
            print(" $course")
        end
        println("")
    end

end

function pretty_print_course_results(results::Dict{String,Any}, course_name::AbstractString, desired_stat::DesiredStat)
    # this should pretty print results

    # separator
    println("-------------")
    println(course_name)

    if (desired_stat == ALL || desired_stat == CEN)
        pretty_print_centrality_results(results)
    end
    if (desired_stat == ALL || desired_stat == COM)
        pretty_print_complexity_results(results)
    end
    if (desired_stat == BLO)
        pretty_print_blocking_factor_results(results)
    end
    if (desired_stat == DEL)
        pretty_print_delay_factor_results(results)
    end
    if (desired_stat == ALL || desired_stat == PRE)
        println("Prereq Changes:")
        pretty_print_prereq_changes(results)
    end
end

function pretty_print_curriculum_results(curriculum_results::Dict{}, desired_stat::DesiredStat)
    for (key, value) in curriculum_results["matched courses"]
        pretty_print_course_results(value, key, desired_stat)
    end
    if (length(curriculum_results["unmatched courses"]) != 0)
        println("*******")
        println("Unmatched courses:")
        for (key, value) in curriculum_results["unmatched courses"]
            executive_summary_unmatched_course(value, key)
        end
    end
end