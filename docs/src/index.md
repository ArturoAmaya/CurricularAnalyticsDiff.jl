# CurricularAnalyticsDiff.jl

This package was designed with with the intent of being able to see changes between two given curricula in a thorough but easy to understand way. Specifically, the ability to see how certain changes affect curricula that are, say a year apart, was appealing. 

Now, this package does four things:
- [Diff](diff.md) analyzes the aformentioned differences between a pair of curricula (Diff)
- [What If](whatif.md) helps analyze the impact of the following changes to a given curriculum (What If)
  - adding or removing a prerequisite
  - adding or removing a course
- [What if Institutional](whatifinstitutional.md) helps analyze the impact of the following changes to a modified catalog (What If Institutional)
  - adding or removing a prerequisite
  - adding or removing a course
- [Helper Functions](helperfns.md) also has a set of helper functions that can make it easier to interact with a Curricular Analytics Curriculum object (Helper Fns)