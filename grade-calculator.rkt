#lang dssl2

# HW1: Grade Calculator

###
### Data Definitions
###

let outcome? = OrC("got it", "almost there", "on the way", "not yet",
                   "missing honor code", "cannot assess")

struct homework:
    let outcome: outcome?
    let self_eval_score: nat?

struct project:
    let outcome: outcome?
    let docs_modifier: int?

let letter_grades = ["F", "D", "C-", "C", "C+", "B-", "B", "B+", "A-", "A"]
def letter_grade? (str):
    let found? = False
    for g in letter_grades:
        if g == str: found? = True
    return found?


###
### Modifiers
###

def worksheets_modifier (worksheet_percentages: TupC[num?, num?]) -> int?:
    # pass
    #   ^ YOUR WORK GOES HERE
    let score1 = worksheet_percentages[0] # First worksheet score from the tuple 
    let score2 = worksheet_percentages[1] # Second worksheet score from the tuple 
    let average_score = (score1 + score2) / 2 # Calculates average of the two worksheets

    if average_score >= 0.8: # Checks if the average score is 80% or higher
        return 1 # Return +1 modifier for average score of 80% or higher
    elif average_score >= 0.6: # Checks if the average score is 60% or higher
        return 0 # Return 0 modifier for average score between 60 and 80%
    else: # If the average score is below 60%
        return -1 # Return -1 modifier for average score below 60%
    
def exams_modifiers (exam1: nat?, exam2: nat?) -> int?:
    pass
    #   ^ YOUR WORK GOES HERE
    let improvement_bonus = 0 # Initialize the improvement bonus to 0
    if exam2 > exam1: 
        improvement_bonus = 1 # Set the improvement bonus to 1 if the second exam score is higher than the first

    let total_score = exam1 + exam2 # Calculates the total score by adding the scores from both exams

    if total_score == 0: 
         return -6 # Return -6 if the total score is 0
    elif total_score <= 5:
        return -5 + improvement_bonus # Return -5 + improvement bonus for total score between 1 and 5
    elif total_score <= 10:
        return -4 + improvement_bonus # Return -4 + improvement bonus for total score between 6 and 10
    elif total_score <= 15:
        return -3 + improvement_bonus # Return -3 + improvement bonus for total score between 11 and 15
    elif total_score <= 20:
        return -2 + improvement_bonus # Return -2 + improvement bonus for total score between 16 and 20
    elif total_score <= 25:
        return -1 + improvement_bonus # Return -1 + improvement bonus for total score between 21 and 25
    elif total_score <= 30:
        return 0 + improvement_bonus # Return 0 + improvement bonus for total score between 26 and 30
    elif total_score <= 35:
        return 1 + improvement_bonus # Return 1 + improvement bonus for total score between 31 and 35
    else:
        return 2 + improvement_bonus # Return 2 + improvement bonus for total score above 35
    
def self_evals_modifier (hws: VecC[homework?]) -> int?:
    pass
    #   ^ YOUR WORK GOES HERE
    if len(hws) != 5: # Check if the number of homeworks is 5
         print("ERROR: Incorrect number of homeworks") # prints an error message if number of homeworks is not 5

    let total_self_eval_score = 0 # Initialize the total self-evaluation score to 0
    
    for hw in hws: # Iterate through each homework in the list of homeworks
        if hw.self_eval_score is not None: # Checks if the self-evaluation score for the homework is not None
            total_self_eval_score = total_self_eval_score + hw.self_eval_score # Add the self-evaluation score to the total

    let average_self_eval_score = total_self_eval_score / 5 # Calculates the average self-evaluation score

    if average_self_eval_score >= 4:
        return 1 # Return a modifier of +1 if the average score is 4 or higher
    elif average_self_eval_score >= 3:
        return 0 # Return a modifier of 0 if the average score is 3 or higher but less than 4
    else:
        return -1 # Return a modifier of -1 if the average score is less than 3


###
### Letter Grade Helpers
###

# Is outcome x enough to count as outcome y?
def is_at_least (x:outcome?, y:outcome?) -> bool?:
    if x == "got it": return True
    if x == "almost there" \
        and (y == "almost there" or y == "on the way" or y == "not yet"):
        return True
    if x == "on the way" and (y == "on the way" or y == "not yet"): return True
    return False

def apply_modifiers (base_grade: letter_grade?, total_modifiers: int?) -> letter_grade?:
    pass
    #   ^ YOUR WORK GOES HERE
    let base_grade_index = 0 # Initialize the base grade index to 0
    let i = 0 # Initialize a counter i to 0 for the loop
    
    while i < len(letter_grades): # Loop that runs as i is less than the number of letter grades
        if letter_grades[i] == base_grade: # Checks if the current letter grade in the iteration matches the base grade
            base_grade_index = i # If match is found, set base_grade_index to the current index of i
        i = i + 1 # Increments i by 1 for next iteration

    let final_grade_index = base_grade_index + total_modifiers # Calculates the final grade index by adding the total modifiers to the base grade index
    
    if final_grade_index < 0:
        final_grade_index = 0 # If the final grade index is less than 0, set it to 0 
    elif final_grade_index >= len(letter_grades):
        final_grade_index = len(letter_grades) - 1 # If final grade index => than the length of the letter_grades, set it to the last index

    return letter_grades[final_grade_index] # Return the letter grade from the letter_grades at the final_grade_index

###
### Students
###

class Student:
    let name: str?
    let homeworks: TupC[homework?, homework?, homework?, homework?, homework?]
    let project: project?
    let worksheet_percentages: TupC[num?, num?]
    let exam_scores: TupC[nat?, nat?]

    def __init__ (self, name, homeworks, project, worksheet_percentages, exam_scores):
        pass
    #   ^ YOUR WORK GOES HERE
        # Constructor for student class, initializes a new instance of class
        # Initalizes all the variables 
        self.name = name
        self.homeworks = homeworks
        self.project = project
        self.worksheet_percentages = worksheet_percentages
        self.exam_scores = exam_scores

    def get_homework_outcomes(self) -> VecC[outcome?]:
        pass
    #   ^ YOUR WORK GOES HERE
        return [hw.outcome for hw in self.homeworks] # Return a list of homework outcomes by iterating over each homework in self.homeworks

    def get_project_outcome(self) -> outcome?:
        pass
    #   ^ YOUR WORK GOES HERE
        return self.project.outcome # Return the outcome of the project 

    def resubmit_homework (self, n: nat?, new_outcome: outcome?) -> NoneC:
        pass
    #   ^ YOUR WORK GOES HERE
        if n < 1 or n > len(self.homeworks): # Checks if the specified homework number is within the range
         print( "ERROR: Homework doesn't exist") # Print an error message if the homework number is outside the range
        self.homeworks[n - 1].outcome = new_outcome # Update the outcome of the specified homework to the new outcome

    def resubmit_project (self, new_outcome: outcome?) -> NoneC:
        pass
    #   ^ YOUR WORK GOES HERE
        self.project.outcome = new_outcome # Update the outcome of the project to the new outcome

    def base_grade (self) -> letter_grade?:
        let n_got_its       = 0
        let n_almost_theres = 0
        let n_on_the_ways   = 0
        for o in self.get_homework_outcomes():
            if is_at_least(o, "got it"):
                n_got_its       = n_got_its       + 1
            if is_at_least(o, "almost there"):
                n_almost_theres = n_almost_theres + 1
            if is_at_least(o, "on the way"):
                n_on_the_ways   = n_on_the_ways   + 1
        let project_outcome = self.get_project_outcome()
        if n_got_its == 5 and project_outcome == "got it": return "A-"
        # the 4 "almost there"s or better include the 3 "got it"s
        if n_got_its >= 3 and n_almost_theres >= 4 and n_on_the_ways >= 5 \
           and is_at_least(project_outcome, "almost there"):
            return "B"
        if n_got_its >= 2 and n_almost_theres >= 3 and n_on_the_ways >= 4 \
           and is_at_least(project_outcome, "on the way"):
            return "C+"
        if n_got_its >= 1 and n_almost_theres >= 2 and n_on_the_ways >= 3 \
           and is_at_least(project_outcome, "on the way"):
            return "D"
        return "F"

    def project_above_expectations_modifier (self) -> int?:
        let base_grade = self.base_grade()
        if base_grade == 'A-': return 0 # expectations are already "got it"
        if base_grade == 'B':
            if is_at_least(self.project.outcome, 'got it'):       return 1
            else: return 0
        else:
            # two steps ahead of expectations
            if is_at_least(self.project.outcome, 'got it'):       return 2
            # one step ahead of expectations
            if is_at_least(self.project.outcome, 'almost there'): return 1
            else: return 0

    def total_modifiers (self) -> int?:
        pass
    #   ^ YOUR WORK GOES HERE
        # Calculates the worksheets modifier using the worksheets_modifier function and the worksheet percentages
        let worksheets_modifier_value = worksheets_modifier(self.worksheet_percentages) 
        
        # Calculates the exams modifier using the exams_modifiers function and the exam scores
        let exams_modifier_value = exams_modifiers(self.exam_scores[0], self.exam_scores[1])
        
        # Calculates the self evaluations modifier using the self_evals_modifier function and the homeworks
        let self_evals_modifier_value = self_evals_modifier(self.homeworks)
        
        # Get the project documents modifier using the value from the project's docs_modifier or default to 0 if None
        let project_docs_modifier = self.project.docs_modifier if self.project.docs_modifier is not None else 0
        
        # Calculates the project above expectations modifier using the project_above_expectations_modifier method
        let project_above_expectations_modifier_value = self.project_above_expectations_modifier()

        # Return the sum of all the calculated modifiers
        return (worksheets_modifier_value +
                exams_modifier_value +
                self_evals_modifier_value +
                project_docs_modifier +
                project_above_expectations_modifier_value)

    def letter_grade (self) -> letter_grade?:
        pass
    #   ^ YOUR WORK GOES HERE
        let base_grade = self.base_grade() # Calculates the base grade of the student using the base_grade method
        let total_modifiers = self.total_modifiers() # Calculates the total modifiers for the student using the total_modifiers method

        # Return the final letter grade by applying the total modifiers to the base grade using the apply_modifiers function
        return apply_modifiers(base_grade, total_modifiers) 
        
###
### Feeble attempt at a test suite
###

test 'Student#letter_grade, worst case scenario':
    let s = Student('Everyone, right now',
                    [homework("not yet", 0),
                     homework("not yet", 0),
                     homework("not yet", 0),
                     homework("not yet", 0),
                     homework("not yet", 0)],
                    project("not yet", -1),
                    [0.0, 0.0],
                    [0, 0])
    assert s.base_grade() == 'F'
    assert s.total_modifiers() == -9
    assert s.letter_grade() == 'F'

test 'Student#letter_grade, best case scenario':
    let s = Student("You, if you work harder than you've ever worked",
                    [homework("got it", 5),
                     homework("got it", 5),
                     homework("got it", 5),
                     homework("got it", 5),
                     homework("got it", 5)],
                    project("got it", 1),
                    [1.0, 1.0],
                    [20, 20])
    assert s.base_grade() == 'A-'
    assert s.total_modifiers() == 5
    assert s.letter_grade() == 'A'
#-------------------------------------------------------------------------------------------------------------------------
    # Additional tests for letter grades B, C+, and D
    
# Test for a B grade
test 'Student#letter_grade, B grade scenario':
    let s = Student('B Grade Student',
                    [homework("got it", 5),
                     homework("got it", 5),
                     homework("got it", 5),
                     homework("almost there", 4),
                     homework("on the way", 3)],
                    project("almost there", 0),
                    [1.0, 1.0],
                    [8, 8])
    assert s.base_grade() == 'B'
    assert s.total_modifiers() == 0 
    assert s.letter_grade() == 'B'
    
# Test for a C+ grade
test 'Student#letter_grade, C+ grade scenario':
    let s = Student('C+ Grade Student',
                    [homework("got it", 5),
                     homework("got it", 5),
                     homework("almost there", 4),
                     homework("almost there", 4),
                     homework("almost there", 4)],
                    project("on the way", -1),
                    [0.8, 0.7],
                    [10, 12])
    assert s.base_grade() == 'C+'
    assert s.total_modifiers() == 0  
    assert s.letter_grade() == 'C+'

# Test for a D grade    
test 'Student#letter_grade, D grade scenario':
    let s = Student('D Grade Student',
                    [homework("got it", 5),
                     homework("almost there", 4),
                     homework("almost there", 4),
                     homework("on the way", 3),
                     homework("not yet", 0)],
                    project("on the way", -1),
                    [0.8, 0.8],
                    [15, 12])
    assert s.base_grade() == 'D'
    assert s.total_modifiers() == 0
    assert s.letter_grade() == 'D'