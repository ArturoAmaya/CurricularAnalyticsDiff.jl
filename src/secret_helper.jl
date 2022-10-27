# file for doing analysis stuff

function find_balanced_out_changes(results)
    for (key, major) in results
        println(key)
        for (key2, college) in major
            println("\t$(key2)")
            for (key3, year) in college
                println("\t\t$(key3)")
                for (key4, course) in year["matched courses"]
                    println("\t\t\t$(key4)")
                    if ((course["contribution to curriculum differences"]["centrality"] == 0.0 && length(course["centrality"]["paths not in c2"]) != 0 && length(course["centrality"]["paths not in c1"]) != 0) ||
                        (course["contribution to curriculum differences"]["blocking factor"] == 0.0 && length(course["blocking factor"]["not in c1 ufield"]) != 0 && length(course["blocking factor"]["not in c2 ufield"]) != 0) ||
                        (course["contribution to curriculum differences"]["delay factor"] == 0.0 && course["delay factor"]["df path course 1"] != course["delay factor"]["df path course 2"])
                    )
                        push!(investigating, (key4, course))
                    end
                end
            end
        end
    end
end

function find_unique_course_names(results)
    courses = []
    for (key, major) in results
        println(key)
        for (key2, college) in major
            println("\t$(key2)")
            for (key3, year) in college
                println("\t\t$(key3)")
                if "matched courses" in keys(year)
                    for key4 in keys(year["matched courses"])
                        println("\t\t\t$(key4)")
                        push!(courses, key4)
                    end
                end
                if "unmatched courses" in keys(year)
                    for key4 in keys(year["unmatched courses"])
                        println("\t\t\t$(key4)")
                        push!(courses, key4)
                    end
                end
            end
        end
    end
    courses_set = Set(courses)
end