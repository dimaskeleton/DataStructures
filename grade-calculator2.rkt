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
    
    # Get the first and second score from the worksheet tuples
    let score1 = worksheet_percentages[0] 
    let score2 = worksheet_percentages[1] 

    # Check if both scores are a 100 
    if score1 == 1.0 and score2 == 1.0:
        # returns a full modifier for both 100% scores
        return 1  
        
    # Check if one of the scores is less than 80 
    elif score1 < 0.8 or score2 < 0.8:
        # returns a modifier of -1 if one of the scores is less than 80%
        return -1  
    
    # If neither condition is met, the scores are between 80 and 100 but not perfect     
    else:
        # returns a modifier of 0 showing satisfactory but not perfect
        return 0
    

def exams_modifiers (exam1: nat?, exam2: nat?) -> int?:
    pass
    #   ^ YOUR WORK GOES HERE
    def score_to_modifier(score):
        
        # Calculate the total percentage score out of 20
        let percentage = (score / 20) * 100
        
        # Checks if the percentage is 90 or higher, giving the highest modifier
        if percentage >= 90:
            # returns an exam modifier of 1 for scores greater than 90 
            return 1
        
        # Checks if the percentage is 60 or higher but less than 90, giving the neutral modifier       
        elif percentage >= 60:
            # returns an exam modifier of 0 for scores between 60 and 90
            return 0
        
        # Checks if the percentage is 40 or higher but less than 60, giving a small negative modifier       
        elif percentage >= 40:
            # returns an exam modifier of -1 for scores between 40 and 60
            return -1
        
        # Checks if the percentage is 20 or higher but less than 40, giving a medium negative modifier           
        elif percentage >= 20:
            # returns an exam modifier of -2 for scores between 20 and 40 
            return -2
        
        # Checks if the percentage is less than 20, giving the lowest modifier        
        else:
            # returns an exam modifier of -3 for scores below 20
            return -3

            
    # Calculates the modifier for each exam through the score_to_modifier        
    let modifier1 = score_to_modifier(exam1)
    let modifier2 = score_to_modifier(exam2)

    # Calculates the sum of both exam modifiers to get the combined modifier 
    let combined_modifier = modifier1 + modifier2

    # If the second exam modifier is atleast 2 points higher than the first, improvement bonus is added
    if modifier2 >= modifier1 + 2:
        # Adds the improvement bonus point to the combined_modifier 
        combined_modifier + 1 
    
    # Makes sure that the combined modifier falls between the bounds of -6 and 2
    combined_modifier = max(-6, min(2, combined_modifier))
    
    # returns the final processed combined_modifier 
    return combined_modifier
    

def self_evals_modifier (hws: VecC[homework?]) -> int?:
    pass
    #   ^ YOUR WORK GOES HERE
    
    # Checks to make sure the vector has 5 homeworks
    if len(hws) != 5:
        # Raise an error if the amount of homeworks isn't 5
        error("ERROR: Incorrect number of homeworks")
     
    # Counters for each category of homework based on the self_eval score  
    let hw_count_5: int = 0 # Count of homeworks with a self_eval score of 5
    let hw_count_3_to_4: int = 0 # Count of homeworks with a self_eval score between 3 and 4
    let hw_count_2_below: int = 0 # Count of homeworks with a self_eval score 2 and below 
    
    # Iterate through each homework assignment to categorize it based on the self_eval score
    for hw in hws:
        
        # Checks if the self_eval score is 5
        if hw.self_eval_score == 5:
            # Increments hw_count_5 for each homework with a self_eval score of 5
            hw_count_5 = hw_count_5 + 1
        
        # Checks if the self_eval score is between 3 and 4
        if hw.self_eval_score >= 3:
            # Increments hw_count_3_to_4 for each homework with a self_eval score between 3 and 4
            hw_count_3_to_4 = hw_count_3_to_4 + 1
        
        # Checks if the self_eval score is 2 or lower         
        if hw.self_eval_score <= 2:
            # Increments hw_count_2_below for each homework with a self_eval score of 2 or lower
            hw_count_2_below = hw_count_2_below + 1
    
            
            
    # Find the modifier based on the homework counts for each category
    # Checks if there are atleast 4 homeworks with a score of 5
    if hw_count_5 >= 4:
        # returns a modifier of 1 for atleast 4 homeworks with score of 5
        return 1
        
    # Checks if there are atleast 3 homeworks with scores between 3 and 4   
    elif hw_count_3_to_4 >= 3 and hw_count_2_below <= 2:
        # returns a modifier of 0 if there are atleast 3 homeworks with scores between 3 and 4   
        return 0
    
    # Checks if there are 3 or more homeworks with a score of 2 or lower 
    elif hw_count_2_below >= 3:
        # returns a modifier of -1 if there are 3 or more homeworks with a score of 2 or lower 
        return -1
        
    # If no other condition is met, return a default modifier of -1    
    else:
        return -1


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
    
    # if base_grade is 'F' and positive modifiers are applied, grade stays an F
    if base_grade == 'F' and total_modifiers > 0:
        return 'F' # returns 'F' if base grade is 'F' and positive modifiers are applied
    
    # Initilize index for base_grade in the letter_grades list
    let base_grade_index = 0
    
    # Iterates through the letter grades list to find index of the base_grade
    for i in range(len(letter_grades)):
        
        # Checks if the current index matches the base grade
        if letter_grades[i] == base_grade:
            # Updates base_grade_index when the base_grade is found 
            base_grade_index = i

    # Calculates the final grade index adding the total modifiers to the base_grade index
    let final_grade_index = base_grade_index + total_modifiers
    
    # Checks to make sure that final_grade_index isn't less than 0
    if final_grade_index < 0:
        # if final_grade_index is less than 0, return 0 for an 'F' grade
        final_grade_index = 0
        
    # Checks to make sure that final_grade_index doesn't exceed the length of letter_grades list    
    elif final_grade_index >= len(letter_grades):
        # if final_grade_index is greater than the length of the letter_grades list, subtract 1 to stay in bounds
        final_grade_index = len(letter_grades) - 1

    # returns the letter_grades at it's index including the modifier adjustments 
    return letter_grades[final_grade_index]


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
        # return a list of homework outcomes by iterating over each homework in self.homeworks
        return [hw.outcome for hw in self.homeworks]

    def get_project_outcome(self) -> outcome?:
        pass
    #   ^ YOUR WORK GOES HERE
        # Return the outcome of the project 
        return self.project.outcome

    def resubmit_homework (self, n: nat?, new_outcome: outcome?) -> NoneC:
        pass
    #   ^ YOUR WORK GOES HERE
        # Checks if the specified homework number is within the range
        if n < 1 or n > 5:
            # return an error message if the homework number is outside the range
            error("ERROR: Homework out of range")
        
        # Update the outcome of the specified homework to the new outcome    
        self.homeworks[n - 1].outcome = new_outcome

    def resubmit_project (self, new_outcome: outcome?) -> NoneC:
        pass
    #   ^ YOUR WORK GOES HERE
        # Update the outcome of the project to the new outcome
        self.project.outcome = new_outcome

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
        
        # returns the sum of all modifiers to calculate the total modifiers
        return worksheets_modifier_value + exams_modifier_value + self_evals_modifier_value + project_docs_modifier

    def letter_grade (self) -> letter_grade?:
        pass
    #   ^ YOUR WORK GOES HERE
        # returns the final letter grade by applying the total modifiers to the base grade using the apply_modifiers function
        return apply_modifiers(self.base_grade(), self.total_modifiers()) 

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
    
#Additional tests from self evaluation-----------------------------------------------
test 'worksheets_modifier, Mixed Scores (1)':
    let worksheet_scores = [0.85, 0.75]  
    let modifier = worksheets_modifier(worksheet_scores)
    
    assert modifier == -1
    
test 'apply_modifiers, Out of Bounds (2)':
    let base_grade = 'A-'
    let total_modifiers = 2
    let final_grade = apply_modifiers(base_grade, total_modifiers)
    
    assert final_grade == 'A'

test 'apply_modifiers, Out of Bounds (3)':
    let base_grade = 'D'
    let total_modifiers = -4
    let final_grade = apply_modifiers(base_grade, total_modifiers)
    
    assert final_grade == 'F'

#Worksheet modifier tests------------------------------------------------------------
test 'worksheets_modifier scores [0.8, 0.8] should return 0 (1)':
    let result = worksheets_modifier([0.8, 0.8])
    assert result == 0

test 'worksheets_modifier scores [4/5, 4/5] should return 0 (2)':
    let result = worksheets_modifier([4/5, 4/5])
    assert result == 0

test 'worksheets_modifier scores [0.79, 0.6] should return -1 (3)':
    let result = worksheets_modifier([0.79, 0.6])
    assert result == -1

test 'worksheets_modifier scores [0.79, 1.0] should return -1 (4)':
    let result = worksheets_modifier([0.79, 1.0])
    assert result == -1

test 'worksheets_modifier scores [1.0, 0.6] should return -1 (5)':
    let result = worksheets_modifier([1.0, 0.6])
    assert result == -1

#Exams modifier tests----------------------------------------------------------------
test 'exams_modifiers scores (17, 17) should return 0 (1)':
    let result = exams_modifiers(17, 17)
    assert result == 0

test 'exams_modifiers scores (12, 12) should return 0 (2)':
    let result = exams_modifiers(12, 12)
    assert result == 0

test 'exams_modifiers scores (11, 11) should return -2 (3)':
    let result = exams_modifiers(11, 11)
    assert result == -2

test 'exams_modifiers scores (7, 7) should return -4 (4)':
    let result = exams_modifiers(7, 7)
    assert result == -4

test 'exams_modifiers scores (3, 3) should return -6 (5)':
    let result = exams_modifiers(3, 3)
    assert result == -6

test 'exams_modifiers scores (17, 20) should return 1 (6)':
    let result = exams_modifiers(17, 20)
    assert result == 1

test 'exams_modifiers scores (4, 8) should return -3 (7)':
    let result = exams_modifiers(4, 8)
    assert result == -3

test 'exams_modifiers scores (13, 15) should return 0 (8)':
    let result = exams_modifiers(13, 15)
    assert result == 0

test 'exams_modifiers scores (12, 8) should return -1 (9)':
    let result = exams_modifiers(12, 8)
    assert result == -1

# Self evaluation modifier tests-----------------------------------------------------
    
test 'self_evals_modifier: High Mixed Scores to 0 Modifier (1)':
    let mixed_scores = [homework("got it", 4), homework("got it", 4),
                        homework("got it", 5), homework("got it", 5),
                        homework("got it", 5)]
                        
    assert self_evals_modifier(mixed_scores) == 0

test 'self_evals_modifier: High Mixed Scores to 0 Modifier (2)':
    let scores_4_and_5 = [homework("got it", 4), homework("got it", 5),
                          homework("got it", 5), homework("got it", 5),
                          homework("got it", 4)]
                          
    assert self_evals_modifier(scores_4_and_5) == 0

test 'self_evals_modifier: High/Low Mixed Scores to 0 Modifier (3)':
    let scores_with_lows = [homework("got it", 4), homework("got it", 5),
                            homework("got it", 0), homework("got it", 0),
                            homework("got it", 4)]
                            
    assert self_evals_modifier(scores_with_lows) == 0
    
test 'self_evals_modifier: Med/Low Mixed Scores to 0 Modifier (4)':
    let scores_3_and_0 = [homework("got it", 3), homework("got it", 3),
                            homework("got it", 0), homework("got it", 0),
                            homework("got it", 3)]
                            
    assert self_evals_modifier(scores_3_and_0) == 0

test 'self_evals_modifier: Med/Low Mixed Scores to 0 Modifier (5)':
    let scores_0s_and_3s = [homework("got it", 0), homework("got it", 0),
                            homework("got it", 3), homework("got it", 3),
                            homework("got it", 3)]
                            
    assert self_evals_modifier(scores_0s_and_3s) == 0

test 'self_evals_modifier: Mixed Scores to 0 Modifier (6)':
    let varied_scores = [homework("got it", 5), homework("got it", 0),
                         homework("got it", 3), homework("got it", 0),
                         homework("got it", 3)]
                         
    assert self_evals_modifier(varied_scores) == 0

test 'self_evals_modifier: Mixed Scores to -1 Modifier (7)':
    let mix_scores = [homework("got it", 2), homework("got it", 5),
                      homework("got it", 2), homework("got it", 2),
                      homework("got it", 5)]
                      
    assert self_evals_modifier(mix_scores) == -1

test 'self_evals_modifier: 6 Homeworks Error (8)':
    let six_homeworks = [homework("got it", 5), homework("got it", 5),
                         homework("got it", 5), homework("got it", 5),
                         homework("got it", 5), homework("got it", 5)]
                         
    assert_error self_evals_modifier(six_homeworks)

test 'self_evals_modifier: 4 Homeworks Error (9)':
    let four_homeworks = [homework("got it", 4), homework("got it", 5),
                          homework("got it", 5), homework("got it", 5)]
                          
    assert_error self_evals_modifier(four_homeworks)

test 'self_evals_modifier: 0 Homeworks Error (10)':
    let no_homeworks = []
      
    assert_error self_evals_modifier(no_homeworks)
    
#Total modifier tests----------------------------------------------------------------
    
test 'total_modifiers: Worst Case Scenario (1)':
    let worst_case_hw = [homework("not yet", 0), homework("not yet", 0),
                                homework("not yet", 0), homework("not yet", 0),
                                homework("not yet", 0)]
                                
    let worst_case_project = project("not yet", -1)  
    let worst_case_worksheets = [0.0, 0.0] 
    let worst_case_exams = [0, 0]  
    
    let student_worst_case = Student("Worst Case Scenario", worst_case_hw,
                                     worst_case_project, worst_case_worksheets,
                                     worst_case_exams)
                                     
    assert student_worst_case.total_modifiers() == -9

test 'total_modifiers: Best Case Scenario (2)':
    let best_case_hw = [homework("got it", 5), homework("got it", 5),
                        homework("got it", 5), homework("got it", 5),
                        homework("got it", 5)]
                        
    let best_case_project = project("got it", 1) 
    let best_case_worksheets = [1.0, 1.0] 
    let best_case_exams = [20, 20]
    
    let best_case = Student("Best Case Scenario", best_case_hw,
                                    best_case_project, best_case_worksheets,
                                    best_case_exams)
                                    
    assert best_case.total_modifiers() == 5
    
test 'total_modifiers: All Neutral (3)':
    let neutral_hw = [homework("on the way", 3), homework("on the way", 3),
                             homework("on the way", 3), homework("on the way", 3),
                             homework("on the way", 3)]
                             
    let neutral_project = project("on the way", 0) 
    let neutral_worksheets = [0.8, 0.8] 
    let neutral_exams = [12, 12] 
    
    let neutral_case = Student("Neutral Case Student", neutral_hw,
                                       neutral_project, neutral_worksheets,
                                       neutral_exams)
                                       
    assert neutral_case.total_modifiers() == 0


test 'total_modifiers: Positive Self-Evaluation (4)':
    let positive_self_eval_hw = [homework("on the way", 5), homework("on the way", 5),
                                        homework("on the way", 5), homework("on the way", 5),
                                        homework("on the way", 5)]
                                        
    let neutral_project = project("on the way", 0)
    let neutral_worksheets = [0.8, 0.8]
    let neutral_exams = [12, 12]
    
    let positive_self_eval_case = Student("Positive Self_Eval Test", positive_self_eval_hw,
                                                  neutral_project, neutral_worksheets,
                                                  neutral_exams)

    assert positive_self_eval_case.total_modifiers() == 1

test 'total_modifiers: Negative Self-Evaluation (5)':
    let negative_self_eval_hw = [homework("on the way", 2), homework("on the way", 2),
                                        homework("on the way", 2), homework("on the way", 2),
                                        homework("on the way", 2)]
                                        
    let neutral_project = project("on the way", 0) 
    let neutral_worksheets = [0.8, 0.8]  
    let neutral_exams = [12, 12]  
    
    let negative_self_eval_case = Student("Negative Self_Eval Test", negative_self_eval_hw,
                                                  neutral_project, neutral_worksheets,
                                                  neutral_exams)

    assert negative_self_eval_case.total_modifiers() == -1
    
#Apply modifier tests----------------------------------------------------------------
    
test 'apply_modifiers: +1 to base grade F (1)':
    let base_grade = 'F'
    let modifier = 1
    let final_grade = apply_modifiers(base_grade, modifier)
    
    assert final_grade == 'F'

test 'apply_modifiers: +3 to base grade F (2)':
    let base_grade = 'F'
    let modifier = 3
    let final_grade = apply_modifiers(base_grade, modifier)

    assert final_grade == 'F'
    
#Letter Grade tests------------------------------------------------------------------
test 'letter_grade: Base Grade B With 0 Modifier (1)':
    let base_grade = 'B'
    let total_modifiers = 0
    let final_grade = apply_modifiers(base_grade, total_modifiers)

    assert final_grade == 'B'

test 'letter_grade: Base Grade C+ With -1 Modifier (2)':
    let base_grade = 'C+'
    let total_modifiers = -1
    let final_grade = apply_modifiers(base_grade, total_modifiers)

    assert final_grade == 'C'

test 'letter_grade: Base Grade B With -1 Modifier (3)':
    let base_grade = 'B'
    let total_modifiers = -1
    let final_grade = apply_modifiers(base_grade, total_modifiers)

    assert final_grade == 'B-'

test 'letter_grade: Base Grade B With +2 Modifier (4)':
    let base_grade = 'B'
    let total_modifiers = 2
    let final_grade = apply_modifiers(base_grade, total_modifiers)

    assert final_grade == 'A-'

test 'letter_grade: Base Grade C+ With -4 Modifier (5)':
    let base_grade = 'C+'
    let total_modifiers = -4
    let final_grade = apply_modifiers(base_grade, total_modifiers)

    assert final_grade == 'F'

test 'letter_grade: Base Grade D With +1 Modifier (6)':
    let base_grade = 'D'
    let total_modifiers = 1
    let final_grade = apply_modifiers(base_grade, total_modifiers)

    assert final_grade == 'C-'
    
test 'letter_grade: Base Grade D With -1 Modifier (7)':
    let base_grade = 'D'
    let total_modifiers = -1
    let final_grade = apply_modifiers(base_grade, total_modifiers)

    assert final_grade == 'F'

test 'letter_grade: Base Grade F With 0 Modifiers (8)':
    let base_grade = 'F'
    let total_modifiers = 0
    let final_grade = apply_modifiers(base_grade, total_modifiers)

    assert final_grade == 'F'

test 'letter_grade: Syllabus Example is B+ (9)':
    let base_grade = 'B+'
    let total_modifiers = 0
    let final_grade = apply_modifiers(base_grade, total_modifiers)

    assert final_grade == 'B+'

test 'letter_grade: Syllabus Example is B- (10)':
    let base_grade = 'B-'
    let total_modifiers = 0
    let final_grade = apply_modifiers(base_grade, total_modifiers)
    
    assert final_grade == 'B-'
    
    