var documenterSearchIndex = {"docs":
[{"location":"whatifinstitutional/#","page":"What If Instituional","title":"What If Instituional","text":"Under construction","category":"page"},{"location":"diff/#Diff-1","page":"Diff","title":"Diff","text":"","category":"section"},{"location":"diff/#","page":"Diff","title":"Diff","text":"This is the original functionality of the package. It lets a user see the differences in the important metrics of a curriculum - blocking factor, delay factor and centrality. The basic idea is to run through a curriculum and try to find a match for each of its courses in the other curriculum. We can then analyze the differences between these pairs of courses.","category":"page"},{"location":"diff/#","page":"Diff","title":"Diff","text":"curricular_diff","category":"page"},{"location":"diff/#CurricularAnalyticsDiff.curricular_diff","page":"Diff","title":"CurricularAnalyticsDiff.curricular_diff","text":"curricular_diff(curriculum1, curriculum2, verbose, redundants, redundants_file)\n\nAnalyzes differences between two given curricula. Results are should be interpreted as differences from curriculum1 to curriculum2.\n\n\n\n\n\n","category":"function"},{"location":"diff/#","page":"Diff","title":"Diff","text":"course_diff","category":"page"},{"location":"diff/#CurricularAnalyticsDiff.course_diff","page":"Diff","title":"CurricularAnalyticsDiff.course_diff","text":"course_diff(course1, course2, curriculum1, curriculum2, deepdive)\n\nAnalyzes differences in the key curriculum metrics between course1 in curriculum1 and course2 in curriculum2. deepdive determines whether or not it should stop upon finding no difference in the metric values.\n\n\n\n\n\n","category":"function"},{"location":"diff/#","page":"Diff","title":"Diff","text":"course_diff_for_unmatched_course","category":"page"},{"location":"diff/#CurricularAnalyticsDiff.course_diff_for_unmatched_course","page":"Diff","title":"CurricularAnalyticsDiff.course_diff_for_unmatched_course","text":"course_diff_for_unmatched_course(course,curriculum,c1)\n\n\"Analyzes\" differences in the key curriculum metrics for a course that has no match in the other curriculum. c1 indicates if the curriculum the course with no match is the first or the second curriculum.\n\n\n\n\n\n","category":"function"},{"location":"whatif/#","page":"What If","title":"What If","text":"Under construction","category":"page"},{"location":"helperfns/#","page":"Helper Functions","title":"Helper Functions","text":"Under construction","category":"page"},{"location":"install/#Installation-1","page":"Installation","title":"Installation","text":"","category":"section"},{"location":"install/#","page":"Installation","title":"Installation","text":"From the Julia REPL enter package mode using ] and then type:","category":"page"},{"location":"install/#","page":"Installation","title":"Installation","text":"pkg> add https://github.com/ArturoAmaya/CurricularAnalyticsDiff.jl","category":"page"},{"location":"install/#","page":"Installation","title":"Installation","text":"This is because this package hasn't been published publically yet. Hopefully, it will be soon.","category":"page"},{"location":"install/#","page":"Installation","title":"Installation","text":"In order to use the package, type:","category":"page"},{"location":"install/#","page":"Installation","title":"Installation","text":"using CurricularAnalyticsDiff","category":"page"},{"location":"install/#","page":"Installation","title":"Installation","text":"Please remember that every time you restart the Julia REPL you must re-run the using command","category":"page"},{"location":"#CurricularAnalyticsDiff.jl-1","page":"Home","title":"CurricularAnalyticsDiff.jl","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"This package was designed with with the intent of being able to see changes between two given curricula in a thorough but easy to understand way. Specifically, the ability to see how certain changes affect curricula that are, say a year apart, was appealing. ","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Now, this package does four things:","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Diff analyzes the aformentioned differences between a pair of curricula\nWhat If helps analyze the impact of the following changes to a given curriculum\nadding or removing a prerequisite\nadding or removing a course\nWhat if Institutional helps analyze the impact of the following changes to a modified catalog\nadding or removing a prerequisite\nadding or removing a course\nHelper Functions also has a set of helper functions that can make it easier to interact with a Curricular Analytics Curriculum object","category":"page"}]
}