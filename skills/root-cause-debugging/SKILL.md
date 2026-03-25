---
name: root-cause-debugging
description: debug issue's root cause
---

You are tasked with conducting comprehensive analysis across the codebase to identify the root cause of user issues by spawning parallel sub-agents and synthesizing their findings.

CRITICAL: NEVER START FIXING WITHOUT IDENTIFYING THE ROOT CAUSE

## Steps to follow after understanding the user issues
1. **Read any directly mentioned files first:**
   - If the user mentions specific files (docs, JSON, plan file, error logs), read them FULLY first
   - **IMPORTANT**: Use the Read tool WITHOUT limit/offset parameters to read entire files
   - **CRITICAL**: Read these files yourself in the main context before spawning any sub-tasks
   - This ensures you have full context before decomposing the issues

2. **Analyze and decompose the issues:**
   - Break down the user's issues into composable debug areas
   - Identify and locate any relevant logs 
   - Take time to ultrathink about the specific components, files, integration layers and contracts that are relevant to the issues
   - If the logs does not provide enough information, identify the exact location to add debug logging to collect the information needed

3. **Create a debug todo list** using TodoWrite to track logging and exploration tasks

4. **Spawn parallel sub-tasks for comprehensive research**:
   - Create multiple Task agents to research different aspects concurrently
   - Use the right agent for each type of research:

   **For deeper investigation:**
   - **codebase-locator** - To find more specific files (e.g., "find all files that handle [specific component]")
   - **codebase-analyzer** - To understand implementation details (e.g., "analyze how [system] works")
   - **codebase-pattern-finder** - To find similar patterns that wasn't follow that causes the issue

   Each agent knows how to:
   - Find the right files and code patterns
   - Identify conventions and patterns established accross codebase
   - Look for integration points and dependencies
   - Return specific file:line references
   - Find tests and examples

## Work with the user to debug and find the exact root cause
1. **Present the root cause analysis**
  - Include file locations and multiline code snippets showing the exact causes of the issues and the location to add debug logging if needed
  - Reproduce the issues until enough information is collected to identify the exact root cause

2. **Discuss iterate approaches**
  - For each root cause, present options with pros/cons on how to iterate it
  - Make recommendations based on codebase conventions

3. **If the user gives any input along the way**:
  - DO NOT just accept the correction
  - Spawn new research tasks to verify the correct information
  - Read the specific files/directories they mention
  - Only proceed with updates once you've verified the facts yourself

4. **Iterative debugging process**
  - Go back and forth and iterate with the user until all issues are solved
