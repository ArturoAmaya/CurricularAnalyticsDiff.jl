using CurricularAnalytics, Crayons, Crayons.Box, CSV
include("./HelperFns.jl")

# all, centrality, complexity, blocking, delay, prereq

function course_diff_for_unmatched_course(course::Course, curriculum::Curriculum, c1::Bool)
    results = Dict()
    contribution = Dict(
        "complexity" => c1 ? -course.metrics["complexity"] : course.metrics["complexity"],
        "centrality" => c1 ? -course.metrics["centrality"] : course.metrics["centrality"],
        "blocking factor" => c1 ? -course.metrics["blocking factor"] : course.metrics["blocking factor"],
        "delay factor" => c1 ? -course.metrics["delay factor"] : course.metrics["delay factor"]
    )

    results["c1"] = c1
    results["contribution to curriculum differences"] = contribution
    results["complexity"] = course.metrics["complexity"]
    results["centrality"] = course.metrics["centrality"]
    results["prereqs"] = courses_to_course_names(get_course_prereqs(curriculum, course))
    results["blocking factor"] = course.metrics["blocking factor"]
    results["delay factor"] = course.metrics["delay factor"]
    results
end

function course_diff(course1::Course, course2::Course, curriculum1::Curriculum, curriculum2::Curriculum, deep_dive::Bool=true)
    #=relevant_fields = filter(x ->
            x != :vertex_id &&
                x != :cross_listed &&
                x != :requisites &&
                x != :learning_outcomes &&
                x != :metrics &&
                x != :passrate &&
                x != :metadata,
        fieldnames(Course))

    for field in relevant_fields
        field1 = getfield(course1, field)
        field2 = getfield(course2, field)
        if (field1 == field2)
            if (verbose)
                println("✅Course 1 and Course 2 have the same $field: $field1")
            end
        else
            println("❌Course 1 has $(field): $field1 and Course 2 has $(field): $field2")
        end
    end
    =#
    contribution = Dict(
        "complexity" => 0.0,
        "centrality" => 0.0,
        "blocking factor" => 0.0,
        "delay factor" => 0.0
    )

    # METRICS
    # complexity
    explanations_complexity = Dict()
    explanations_complexity["course 1 score"] = course1.metrics["complexity"]
    explanations_complexity["course 2 score"] = course2.metrics["complexity"]
    if (course1.metrics["complexity"] == course2.metrics["complexity"])
        #=if (verbose)
            println("✅Course 1 and Course 2 have the same complexity: $(course1.metrics["complexity"])")
        end=#
    else
        #println("❌Course 1 has complexity $(course1.metrics["complexity"]) and Course 2 has complexity $(course2.metrics["complexity"])")
        contribution["complexity"] = (course2.metrics["complexity"] - course1.metrics["complexity"])
    end
    # centrality
    explanations_centrality = Dict()
    explanations_centrality["course 1 score"] = course1.metrics["centrality"]
    explanations_centrality["course 2 score"] = course2.metrics["centrality"]
    if (course1.metrics["centrality"] == course2.metrics["centrality"] && !deep_dive)
        #=if (verbose)
            println("✅Course 1 and Course 2 have the same centrality: $(course1.metrics["centrality"])")
        end=#
    else
        #println("❌Course 1 has centrality $(course1.metrics["centrality"]) and Course 2 has centrality $(course2.metrics["centrality"])")
        contribution["centrality"] = (course2.metrics["centrality"] - course1.metrics["centrality"])

        # run the investigator and then compare
        centrality_c1 = centrality_investigator(course1, curriculum1)
        centrality_c2 = centrality_investigator(course2, curriculum2)

        # turn those into course names
        # note that its an array of arrays so for each entry you have to convert to course names
        centrality_c1_set = Set()
        centrality_c2_set = Set()
        for path in centrality_c1
            path_names = courses_to_course_names(path)
            push!(centrality_c1_set, path_names)
        end
        for path in centrality_c2
            path_names = courses_to_course_names(path)
            push!(centrality_c2_set, path_names)
        end
        # set diff
        not_in_c2 = setdiff(centrality_c1_set, centrality_c2_set)
        not_in_c1 = setdiff(centrality_c2_set, centrality_c1_set)

        # analyse

        explanations_centrality["paths not in c2"] = collect(not_in_c2)
        explanations_centrality["paths not in c1"] = collect(not_in_c1)
        explanations_centrality["courses not in c2 paths"] = Dict()
        explanations_centrality["courses not in c1 paths"] = Dict()

        # TODO: consider explaining these differences, but they should be explainable by changes in the block and delay factors. 
        # The only complication there is that these changes can be attributed to changes in the prereqs of those block and delay factors so theyre compounded. It's a lot harder
        # Would have to go through all the members of those paths and check each of those for changes. Could be.

        # To explain differences grab all the courses in the set of paths not in c2 
        # check them against the matching courses in c2 looking for changes in prereqs
        # grab all the courses in the set of paths not in c1 
        # check them against the matching courses in c1 looking for changes in prereqs

        # grab all the courses in the set of paths not in c2
        all_courses_not_in_c2 = []
        for path in not_in_c2
            # this is a vector of AbstractString. look in each entry of that vector for course names
            for course in path
                if (!(course in all_courses_not_in_c2))
                    push!(all_courses_not_in_c2, course)
                end
            end
        end
        # check them against matching courses in c2 looking for different prereqs
        for course in all_courses_not_in_c2
            c1 = course_from_name(curriculum1, course)
            c2 = course_from_name(curriculum2, course)
            # find their prerequisites
            prereqs_in_curr1 = Set(courses_to_course_names(get_course_prereqs(curriculum1, c1)))

            isnothing(c2) ? prereqs_in_curr2 = Set() :
            prereqs_in_curr2 = Set(courses_to_course_names(get_course_prereqs(curriculum2, c2)))
            # compare the prerequisites
            # lost prereqs are those that from c1 to c2 got dropped
            # gained prerqs are those that from c1 to c2 got added
            lost_prereqs = setdiff(prereqs_in_curr1, prereqs_in_curr2)
            gained_prereqs = setdiff(prereqs_in_curr2, prereqs_in_curr1)

            explanations_centrality["courses not in c2 paths"][course] = Dict()
            explanations_centrality["courses not in c2 paths"][course]["lost prereqs"] = collect(lost_prereqs)
            explanations_centrality["courses not in c2 paths"][course]["gained prereqs"] = collect(gained_prereqs)
        end

        # grab all the courses in the set of paths not in c1
        all_courses_not_in_c1 = []
        for path in not_in_c1
            # this is a vector of AbstractString. look in each entry of that vector for course names
            for course in path
                if (!(course in all_courses_not_in_c1))
                    push!(all_courses_not_in_c1, course)
                end
            end
        end
        # check them against matching courses in c2 looking for different prereqs
        for course in all_courses_not_in_c1
            c1 = course_from_name(curriculum1, course)
            c2 = course_from_name(curriculum2, course)
            # find their prerequisites
            isnothing(c1) ? prereqs_in_curr1 = Set() :
            prereqs_in_curr1 = Set(courses_to_course_names(get_course_prereqs(curriculum1, c1)))
            prereqs_in_curr2 = Set(courses_to_course_names(get_course_prereqs(curriculum2, c2)))
            # compare the prerequisites
            # lost prereqs are those that from c1 to c2 got dropped
            # gained prerqs are those that from c1 to c2 got added
            lost_prereqs = setdiff(prereqs_in_curr1, prereqs_in_curr2)
            gained_prereqs = setdiff(prereqs_in_curr2, prereqs_in_curr1)

            explanations_centrality["courses not in c1 paths"][course] = Dict()
            explanations_centrality["courses not in c1 paths"][course]["lost prereqs"] = collect(lost_prereqs)
            explanations_centrality["courses not in c1 paths"][course]["gained prereqs"] = collect(gained_prereqs)
        end

    end

    # blocking factor
    explanations_blockingfactor = Dict()
    explanations_blockingfactor["course 1 score"] = course1.metrics["blocking factor"]
    explanations_blockingfactor["course 2 score"] = course2.metrics["blocking factor"]
    if (course1.metrics["blocking factor"] == course2.metrics["blocking factor"] && !deep_dive)
        #=if (verbose)
            println("✅Course 1 and Course 2 have the same blocking factor: $(course1.metrics["blocking factor"])")
        end=#
    else
        #println("❌Course 1 has blocking factor $(course1.metrics["blocking factor"]) and Course 2 has blocking factor $(course2.metrics["blocking factor"])")
        contribution["blocking factor"] = (course2.metrics["blocking factor"] - course1.metrics["blocking factor"])

        # since they have different blocking factors, investigate why and get a set of blocking factors
        unblocked_field_course_1 = blocking_factor_investigator(course1, curriculum1)
        unblocked_field_course_2 = blocking_factor_investigator(course2, curriculum2)
        unblocked_field_course_1_names = Set(courses_to_course_names(unblocked_field_course_1))
        unblocked_field_course_2_names = Set(courses_to_course_names(unblocked_field_course_2))
        # use setdiff to track which courses aren't in course 2's unblocked field and which aren't in course 1's unblocked field
        not_in_c2_unbl_field = setdiff(unblocked_field_course_1_names, unblocked_field_course_2_names)
        not_in_c1_unbl_field = setdiff(unblocked_field_course_2_names, unblocked_field_course_1_names)

        explanations_blockingfactor["length not in c2 ufield"] = length(not_in_c2_unbl_field)
        explanations_blockingfactor["not in c2 ufield"] = Dict()
        if (length(not_in_c2_unbl_field) != 0)
            # there are courses in c1's unblocked that aren't in course2s
            # FIND THE COURSES HERE THAT HAVE CHANGED THEIR PREREQS
            for course_name in not_in_c2_unbl_field
                explanations_blockingfactor["not in c2 ufield"][course_name] = Dict()
                # find course to match name in curriculum1 and curriculum2
                course_in_curr1 = course_from_name(curriculum1, course_name)
                course_in_curr2 = course_from_name(curriculum2, course_name)
                # and find c1 prereqs
                prereqs_in_curr1 = Set(courses_to_course_names(get_course_prereqs(curriculum1, course_in_curr1)))
                if (!isnothing(course_in_curr2))
                    # find their prerequisites
                    prereqs_in_curr2 = Set(courses_to_course_names(get_course_prereqs(curriculum2, course_in_curr2)))
                    # compare the prerequisites
                    # lost prereqs are those that from c1 to c2 got dropped
                    # gained prerqs are those that from c1 to c2 got added
                    lost_prereqs = setdiff(prereqs_in_curr1, prereqs_in_curr2)
                    gained_prereqs = setdiff(prereqs_in_curr2, prereqs_in_curr1)
                    explanations_blockingfactor["not in c2 ufield"][course_name]["lost prereqs"] = collect(lost_prereqs)
                    explanations_blockingfactor["not in c2 ufield"][course_name]["gained prereqs"] = collect(gained_prereqs)
                else
                    # if there's no match in curriculum 2, then just say all the prereqs were lost and none were gained
                    explanations_blockingfactor["not in c2 ufield"][course_name]["lost prereqs"] = courses_to_course_names(get_course_prereqs(curriculum1, course_in_curr1))
                    explanations_blockingfactor["not in c2 ufield"][course_name]["gained prereqs"] = []
                end
                # check if the prereqs haven't changed. If they haven't changed, we need to find which of their prereqs did
                if (length(explanations_blockingfactor["not in c2 ufield"][course_name]["lost prereqs"]) == 0 &&
                    length(explanations_blockingfactor["not in c2 ufield"][course_name]["gained prereqs"]) == 0)
                    # find this course's prereqs and match them with any other courses in not_in_c2_unbl_field
                    # find this course's prereqs in curriculum 1
                    prereqs_in_curr1_set = Set(prereqs_in_curr1)
                    # cross reference with the list of courses not in not_in_c2_unbl_field
                    not_in_c2_unbl_field_set = Set(not_in_c2_unbl_field)

                    in_both = intersect(prereqs_in_curr1_set, not_in_c2_unbl_field_set)

                    explanations_blockingfactor["not in c2 ufield"][course_name]["in_both"] = collect(in_both)

                else
                    explanations_blockingfactor["not in c2 ufield"][course_name]["in_both"] = []
                end
            end
        end
        explanations_blockingfactor["length not in c1 ufield"] = length(not_in_c1_unbl_field)
        explanations_blockingfactor["not in c1 ufield"] = Dict()
        if (length(not_in_c1_unbl_field) != 0)
            # there are courses in c2's unblocked that aren't in course1s
            # TODO: FIND THE COURSES HERE THAT HAVE CHANGED THEIR PREREQS
            for course_name in not_in_c1_unbl_field
                explanations_blockingfactor["not in c1 ufield"][course_name] = Dict()
                # find course to match name in curriculum1 and curriculum2
                course_in_curr1 = course_from_name(curriculum1, course_name)
                course_in_curr2 = course_from_name(curriculum2, course_name)
                # find prereqs in c2
                prereqs_in_curr2 = Set(courses_to_course_names(get_course_prereqs(curriculum2, course_in_curr2)))
                if (!isnothing(course_in_curr1))
                    # find their prerequisites
                    prereqs_in_curr1 = Set(courses_to_course_names(get_course_prereqs(curriculum1, course_in_curr1)))

                    # compare the prerequisites
                    lost_prereqs = setdiff(prereqs_in_curr1, prereqs_in_curr2)
                    gained_prereqs = setdiff(prereqs_in_curr2, prereqs_in_curr1)

                    explanations_blockingfactor["not in c1 ufield"][course_name]["lost prereqs"] = collect(lost_prereqs)
                    explanations_blockingfactor["not in c1 ufield"][course_name]["gained prereqs"] = collect(gained_prereqs)
                else
                    # if there's no match in curriculum 2, then just say that all the prereqs have been gained and none were lost
                    explanations_blockingfactor["not in c1 ufield"][course_name]["lost prereqs"] = []
                    explanations_blockingfactor["not in c1 ufield"][course_name]["gained prereqs"] = courses_to_course_names(get_course_prereqs(curriculum2, course_in_curr2))
                end
                # check if the prereqs haven't changed. If they haven't changed, we need to find which of their prereqs did
                if (length(explanations_blockingfactor["not in c1 ufield"][course_name]["lost prereqs"]) == 0 &&
                    length(explanations_blockingfactor["not in c1 ufield"][course_name]["gained prereqs"]) == 0)
                    # find this course's prereqs and match them with any other courses in not_in_c1_unbl_field
                    # find this course's prereqs in curriculum 2
                    prereqs_in_curr2_set = Set(prereqs_in_curr2)
                    # cross reference with the list of courses not in not_in_c1_unbl_field
                    not_in_c1_unbl_field_set = Set(not_in_c1_unbl_field)

                    in_both = intersect(prereqs_in_curr2_set, not_in_c1_unbl_field_set)

                    explanations_blockingfactor["not in c1 ufield"][course_name]["in_both"] = collect(in_both)
                else
                    explanations_blockingfactor["not in c1 ufield"][course_name]["in_both"] = []
                end
            end
        end
    end
    # delay factor
    explanations_delayfactor = Dict()
    explanations_delayfactor["course 1 score"] = course1.metrics["delay factor"]
    explanations_delayfactor["course 2 score"] = course2.metrics["delay factor"]
    if (course1.metrics["delay factor"] == course2.metrics["delay factor"] && !deep_dive)
        #=if (verbose)
            println("✅Course 1 and Course 2 have the same delay factor: $(course1.metrics["delay factor"])")
        end=#
    else
        #println("❌Course 1 has delay factor $(course1.metrics["delay factor"]) and Course 2 has delay factor $(course2.metrics["delay factor"])")
        contribution["delay factor"] = (course2.metrics["delay factor"] - course1.metrics["delay factor"])
        df_path_course_1 = courses_to_course_names(delay_factor_investigator(course1, curriculum1))
        df_path_course_2 = courses_to_course_names(delay_factor_investigator(course2, curriculum2))

        explanations_delayfactor["df path course 1"] = df_path_course_1
        explanations_delayfactor["df path course 2"] = df_path_course_2
        # explain why
        df_set_c1 = Set(df_path_course_1)
        df_set_c2 = Set(df_path_course_2)

        all_courses_in_paths = union(df_set_c1, df_set_c2)
        explanations_delayfactor["courses involved"] = Dict()

        for course in all_courses_in_paths
            explanations_delayfactor["courses involved"][course] = Dict()
            # find course to match name in curriculum1 and curriculum2
            course_in_curr1 = course_from_name(curriculum1, course)
            course_in_curr2 = course_from_name(curriculum2, course)
            # find their prerequisites
            isnothing(course_in_curr1) ? prereqs_in_curr1 = Set() :
            prereqs_in_curr1 = Set(courses_to_course_names(get_course_prereqs(curriculum1, course_in_curr1)))

            isnothing(course_in_curr2) ? prereqs_in_curr2 = Set() :
            prereqs_in_curr2 = Set(courses_to_course_names(get_course_prereqs(curriculum2, course_in_curr2)))
            # compare the prerequisites
            # lost prereqs are those that from c1 to c2 got dropped
            # gained prerqs are those that from c1 to c2 got added
            lost_prereqs = setdiff(prereqs_in_curr1, prereqs_in_curr2)
            gained_prereqs = setdiff(prereqs_in_curr2, prereqs_in_curr1)
            explanations_delayfactor["courses involved"][course]["lost prereqs"] = collect(lost_prereqs)
            explanations_delayfactor["courses involved"][course]["gained prereqs"] = collect(gained_prereqs)
        end

    end
    # requisites
    # collate all the prerequisite names from course 1
    course1_prereqs = Set(courses_to_course_names(get_course_prereqs(curriculum1, course1)))
    course2_prereqs = Set(courses_to_course_names(get_course_prereqs(curriculum2, course2)))

    explanations_prereqs = Dict()
    lost_prereqs = setdiff(course1_prereqs, course2_prereqs)
    gained_prereqs = setdiff(course2_prereqs, course1_prereqs)
    explanations_prereqs["lost prereqs"] = collect(lost_prereqs)
    explanations_prereqs["gained prereqs"] = collect(gained_prereqs)

    Dict(
        "c1 name" => curriculum1.name,
        "c2 name" => curriculum2.name,
        "contribution to curriculum differences" => contribution,
        "complexity" => explanations_complexity,
        "centrality" => explanations_centrality,
        "blocking factor" => explanations_blockingfactor,
        "delay factor" => explanations_delayfactor,
        "prereqs" => explanations_prereqs
    )
end

function curricular_diff(curriculum1::Curriculum, curriculum2::Curriculum, verbose::Bool=true, redundants::Bool=false, redundants_file::String="")
    #= using fieldnames instead of explicit names
    relevant_fields = filter(x ->
            x != :courses &&
                x != :graph &&
                x != :learning_outcomes &&
                x != :learning_outcome_graph &&
                x != :course_learning_outcome_graph &&
                x != :metrics &&
                x != :metadata,
        fieldnames(Curriculum))

    for field in relevant_fields
        field1 = getfield(curriculum1, field)
        field2 = getfield(curriculum2, field)
        if (field1 == field2)
            if (verbose)
                println("✅Curriculum 1 and Curriculum 2 have the same $field: $field1")
            end
        else
            println("❌Curriculum 1 has $(field): $field1 and Curriculum 2 has $(field): $field2")
        end
    end
    =#
    redundant_course_names = []
    if (redundants)
        names = CSV.read(redundants_file)
        redundant_course_names = Matrix(names)
    end
    # compare metrics
    try
        basic_metrics(curriculum1)
    catch
    end
    try
        basic_metrics(curriculum2)
    catch
    end
    all_results = Dict()
    metrics_same = true
    # complexity and max complexity
    if (curriculum1.metrics["complexity"][1] == curriculum2.metrics["complexity"][1])
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same total complexity: $(curriculum1.metrics["complexity"][1])")
        end
    else
        println("❌Curriculum 1 has a total complexity score of $(curriculum1.metrics["complexity"][1]) and Curriculum2 has a total complexity score $(curriculum2.metrics["complexity"][1])")
        metrics_same = false
    end
    if (curriculum1.metrics["max. complexity"] == curriculum2.metrics["max. complexity"])
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same max complexity : $(curriculum1.metrics["max. complexity"])")
        end
    else
        println("❌Curriculum 1 has a max complexity of $(curriculum1.metrics["max. complexity"]) and Curriculum 2 has a max complexity of $(curriculum2.metrics["max. complexity"])")
        metrics_same = false
    end
    # centrality and max centrality
    if (curriculum1.metrics["centrality"][1] == curriculum2.metrics["centrality"][1])
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same total centrality: $(curriculum1.metrics["centrality"][1])")
        end
    else
        println("❌Curriculum 1 has a total centrality score of $(curriculum1.metrics["centrality"][1]) and Curriculum2 has a total centrality score $(curriculum2.metrics["centrality"][1])")
        metrics_same = false
    end
    if (curriculum1.metrics["max. centrality"] == curriculum2.metrics["max. centrality"])
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same max centrality : $(curriculum1.metrics["max. centrality"])")
        end
    else
        println("❌Curriculum 1 has a max centrality of $(curriculum1.metrics["max. centrality"]) and Curriculum 2 has a max centrality of $(curriculum2.metrics["max. centrality"])")
        metrics_same = false
    end
    # blocking factor and max blocking factor
    if (curriculum1.metrics["blocking factor"][1] == curriculum2.metrics["blocking factor"][1])
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same total blocking factor: $(curriculum1.metrics["blocking factor"][1])")
        end
    else
        println("❌Curriculum 1 has a total blocking factor score of $(curriculum1.metrics["blocking factor"][1]) and Curriculum2 has a total blocking factor score $(curriculum2.metrics["blocking factor"][1])")
        metrics_same = false
    end
    if (curriculum1.metrics["max. blocking factor"] == curriculum2.metrics["max. blocking factor"])
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same max blocking factor : $(curriculum1.metrics["max. blocking factor"])")
        end
    else
        println("❌Curriculum 1 has a max blocking factor of $(curriculum1.metrics["max. blocking factor"]) and Curriculum 2 has a max blocking factor of $(curriculum2.metrics["max. blocking factor"])")
        metrics_same = false
    end
    # delay factor and max delay factor
    if (curriculum1.metrics["delay factor"][1] == curriculum2.metrics["delay factor"][1])
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same total delay factor: $(curriculum1.metrics["delay factor"][1])")
        end
    else
        println("❌Curriculum 1 has a total delay factor score of $(curriculum1.metrics["delay factor"][1]) and Curriculum2 has a total delay factor score $(curriculum2.metrics["delay factor"][1])")
        metrics_same = false
    end
    if (curriculum1.metrics["max. delay factor"] == curriculum2.metrics["max. delay factor"])
        if (verbose)
            println("✅Curriculum 1 and Curriculum 2 have the same max delay factor : $(curriculum1.metrics["max. delay factor"])")
        end
    else
        println("❌Curriculum 1 has a max delay factor of $(curriculum1.metrics["max. delay factor"]) and Curriculum 2 has a max delay factor of $(curriculum2.metrics["max. delay factor"])")
        metrics_same = false
    end

    # if the stats don't match up or we asked for a deep dive, take a deep dive!
    if (!metrics_same || verbose)
        #println("Taking a look at courses")
        # make the initial changes array, i.e. what we're trying to explain
        explain = Dict(
            "complexity" => curriculum2.metrics["complexity"][1] - curriculum1.metrics["complexity"][1],
            "centrality" => curriculum2.metrics["centrality"][1] - curriculum1.metrics["centrality"][1],
            "blocking factor" => curriculum2.metrics["blocking factor"][1] - curriculum1.metrics["blocking factor"][1],
            "delay factor" => curriculum2.metrics["delay factor"][1] - curriculum1.metrics["delay factor"][1],
        )

        runningTally = Dict(
            "complexity" => 0.0,
            "centrality" => 0.0,
            "blocking factor" => 0.0,
            "delay factor" => 0.0
        )

        all_results["to explain"] = explain
        all_results["matched courses"] = Dict()
        all_results["unmatched courses"] = Dict()
        # for each course in curriculum 1, try to find a similarly named course in curriculum 2
        for course in curriculum1.courses
            # this is the catch: MATH 20A and MATH 20A or 10A are not going to match
            matching_course = filter(x -> x.name == course.name, curriculum2.courses)
            if (length(matching_course) == 0)
                if (redundants)
                    # try one more time with the course_find method
                    (found, course1_name, course2_name) = course_find(course.name, redundant_course_names, curriculum2)
                    if (found)
                        results = course_diff(course, course_from_name(curriculum2, course2_name), curriculum1, curriculum2, verbose)
                        contribution = results["contribution to curriculum differences"]
                        for (key, value) in runningTally
                            runningTally[key] += contribution[key]
                        end
                        all_results["matched courses"][course.name] = results
                    else
                        # println("No matching course found for $(course.name)")
                        # do stuff for courses with no match from c1 to c2
                        # best idea here is to have a special diff for them 
                        # where everything is gained or lost
                        results = course_diff_for_unmatched_course(course, curriculum1, true)
                        contribution = results["contribution to curriculum differences"]
                        for (key, value) in runningTally
                            runningTally[key] += contribution[key]
                        end
                        all_results["unmatched courses"][course.name] = results
                    end
                else
                    # println("No matching course found for $(course.name)")
                    # do stuff for courses with no match from c1 to c2
                    # best idea here is to have a special diff for them 
                    # where everything is gained or lost
                    results = course_diff_for_unmatched_course(course, curriculum1, true)
                    contribution = results["contribution to curriculum differences"]
                    for (key, value) in runningTally
                        runningTally[key] += contribution[key]
                    end
                    all_results["unmatched courses"][course.name] = results
                end
            elseif (length(matching_course) == 1)
                #println("Match found for $(course.name)")
                course2 = matching_course[1]
                results = course_diff(course, course2, curriculum1, curriculum2, verbose)
                contribution = results["contribution to curriculum differences"]
                for (key, value) in runningTally
                    runningTally[key] += contribution[key]
                end
                all_results["matched courses"][course.name] = results
                # TODO: handle small bug in runningTally only containing the end results and no intermediate values
                #println("explained so far: $(runningTally["complexity"]), $(runningTally["centrality"]), $(runningTally["blocking factor"]), $(runningTally["delay factor"])")
            else
                println("Something weird here, we have more than one match for $(course.name)")
                # A choice... FOR NOW
                course2 = matching_course[1]
                results = course_diff(course, course2, curriculum1, curriculum2, verbose)
                contribution = results["contribution to curriculum differences"]
                for (key, value) in runningTally
                    runningTally[key] += contribution[key]
                end
                all_results["matched courses"][course.name] = results
            end
        end
        for course in curriculum2.courses
            matching_course = filter(x -> x.name == course.name, curriculum1.courses)
            if (length(matching_course) == 0)
                #println("No matching course found for $(course.name)")
                # do stuff for courses with no match to c2 from c2
                # best idea here is to have a special diff for them 
                # where everything is gained or lost
                results = course_diff_for_unmatched_course(course, curriculum2, false)
                contribution = results["contribution to curriculum differences"]
                for (key, value) in runningTally
                    runningTally[key] += contribution[key]
                end
                all_results["unmatched courses"][course.name] = results
            end
        end
        all_results["explained"] = Dict(
            "complexity" => runningTally["complexity"],
            "centrality" => runningTally["centrality"],
            "blocking factor" => runningTally["blocking factor"],
            "delay factor" => runningTally["delay factor"]
        )
    end
    #pretty_print_curriculum_results(all_results, desired_stat)
    #executive_summary_curriculum(all_results)
    all_results
end