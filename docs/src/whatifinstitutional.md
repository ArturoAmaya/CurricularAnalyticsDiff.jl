# What If Institutional

Whereas What If simply asks how adding/removing a course/prerequisite affects a particular curriculum, these functions attempt to answer the same question for a curriculum that represents all the collected curricula of an institution. The procedure to generate such a file is described elsewhere, as the current build is UCSD-only. The point is that all courses in the special curriculum should have a list of the original curricula they come from in the canonical name field. 

```@docs
delete_prerequisite_institutional
```

```@docs
delete_course_institutional
```

```@docs
add_course_institutional
```

```@docs
add_prereq_institutional
```

```@docs
print_affected_plans
```