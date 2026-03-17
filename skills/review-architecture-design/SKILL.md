---
name: review-architecture-design
description: Review design, plan or implementation to identify and reduce complexity
---

# Review architecture design

## Overview
Reduce as much complexity of design as possible. Complexity is defined as anything related to structure of a system that makes it hard to understand and modify the system.

## Philosophy
### Zero tolerance 
- Complexity is incremental, once it accumulated, it is hard to eliminate.  To avoid the compound growth of complexity, adopt the zero tolerance philosophy.

### Working code isn't enough
- Great design compounds, and will overtake tactical solutions in no time, even in fast pace environments.
- Embrace strategic programming rather than tactical programming, it is not acceptable to introduce unnecessary complexities in order to finish current task faster.

## Framework steps to follow when reviewing a design

1. **Read any directly mentioned files first:**
- If the user mentions specific files (tickets, docs, JSON), read them FULLY first
- **IMPORTANT**: Use the Read tool WITHOUT limit/offset parameters to read entire files
- **CRITICAL**: Read these files yourself in the main context before spawning any sub-tasks
- This ensures you have full context before decomposing the design

2. **Analyze and identify these red flags:**
- Changes amplification: simple changes require code modifications in many different places.
- High cognitive load: The amount of information needed to learn before being able to contribute to a part of a system is high.
- Unknown unknown: The amount of non obvious pieces of code that must be modified to complete a task is high.
- Shallow modules: Modules whose interface is complicated relative to the functionality it provides, introducing complexity without providing compensating benefits.
- Classitis: Unnecessary amount of class abstraction without reducing complexity of the system.
- Information leakage: A same knowledge is used in multiple places, such as two different classes that both need to understand the format of a particular type of file.
- Temporal decomposition: Execution order is reflected in the code structure, operations that happen at different times are in different methods or classes. If the same knowledge is used at different points in execution, it gets encoded in multiple places, resulting in information leakage.
- Overexposure: Most commonly used features forces it's users to learn about other features that are rarely used, increasing cognitive load.
- Overhiding information: Hiding important information that's needed outside of the module.

3. **Apply techniques to reduce complexity:**
##### Tackling the causes of complexity
- Reduce the number of dependencies and to make the dependencies that remain as simple and obvious as possible.
- Reduce the number of non obvious important information, such as inconsistency in naming or code structure. Obscurity might come from poor documentation, but clean and obvious design should not need documentation.
- Isolating a complexity in a place where it will never need to be seen is almost as good as eliminating complexity entirely.

##### Modules should be deep
- A module is any unit of code that has an interface and an implementation, seperate interface from its implementation to achieve modules with much simple interface than it's implementation.
- Use clearly defined interfaces and avoid bad abstractions that include details that are not important or omit details that are important.
- Design deep modules, which as simple interfaces yet powerful functionality. For example, Unix I/O interface with only five basic system calls and simple signatures that hidden the complexities of it's implementation.
- Interfaces should be designed to make the common case as simple as possible, while providing powerful optional functionality.

##### Information hiding
- Think carefully about what information can be hidden in a module. The more information you can hide, the simpler the interface can be. Best form of information hiding is when information is totally hidden within a module. So that it is independent and does not affect other modules when changed.
- Partial information hiding also has value, if a particular piece of information is only needed by a few of a class's users, and it is accessed through seperate methods so that it is not visible in the most common use cases, which create fewer dependencies than information that is visible to all users.
- Ask yourself: 
  - "How can I reorganize these classes so that this particular peice of knowledge only affect a single class?" 
- Merge the small and closely tied classes into a single class or pull the information out of all the affected classes and create a new class to encapsulate it with a simple interface.
- Focus on the knowledge that's needed to perform each task, not the order in which tasks occur.
- Information hiding can often be improved by making a class slightly larger.

##### General purpose classes
- Design general purpose classes rather than special-purpose alternatives.
- It usually ended up simpler and deeper than special-purpose alternatives, with better information hiding and a cleaner seperation.
- Ask yourself:
  - "What is the simplest interface that will cover all my current needs?"
  - "In how many situations will this method be used?"
  - "Is this API easy to use for my current needs?"
- Specialized code should be cleanly seperated from general-purpose code, which can be done by pushing the specialized code upwards or downwards. Allowing extension of a base class for specialization without needing to knowing the internals of the general-purpose code.
- Simplify code by eliminating special cases with techniques of designing the code so that the special cases never affect the behaviour.

4. **Deliver and present findings:**
- Show the user the location of the design that is identified as red flags.
- Suggest improvements based on the identified issues and the complexity reducing techniques.
