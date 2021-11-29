# ISYE6501 HW11 Optimization using Pulp

# 1.	Formulate an optimization model (a linear program) to find the cheapest diet that satisfies
# the maximum and minimum daily nutrition constraints, and solve it using PuLP.  Turn in your code
# and the solution. (The optimal solution should be a diet of air-popped popcorn, poached eggs,
# oranges, raw iceberg lettuce, raw celery, and frozen broccoli. UGH!)

# 2.	Please add to your model the following constraints (which might require adding more variables)
# and solve the new model:
# a.	If a food is selected, then a minimum of 1/10 serving must be chosen. (Hint: now you will need
# two variables for each food i: whether it is chosen, and how much is part of the diet. You’ll also
# need to write a constraint to link them.)
# b.	Many people dislike celery and frozen broccoli. So at most one, but not both, can be selected.
# c.	To get day-to-day variety in protein, at least 3 kinds of meat/poultry/fish/eggs must be
# selected. [If something is ambiguous (e.g., should bean-and-bacon soup be considered meat?),
# just call it whatever you think is appropriate – I want you to learn how to write this type of
# constraint, but I don’t really care whether we agree on how to classify foods!]

from pulp import *
import pandas as pd

# read data

data = pd.read_excel("~/Documents/PyNotebooks/diet.xls", header = 0) # read all data

dataTable = data[0:64] # rows 0:64 (Excel calls them 1-65) is the food data table
dataTable = dataTable.values.tolist() # Convert dataframe to list

nutrientNames = list(data.columns.values) # column headers (nutrient names are in columns 3-13; Excel calls them D-N)

minVal = data[65:66].values.tolist() # minimum nutrient values
maxVal = data[66:67].values.tolist() # maximum nutrient values

# data prep

foods = [j[0] for j in dataTable]

cost = dict([(j[0], float(j[1])) for j in dataTable]) # cost for each food

nutrients = []
for i in range(0,11): # for loop running through each nutrient: 11 times starting with 0
    nutrients.append(dict([(j[0], float(j[i+3])) for j in dataTable])) # amount of nutrient i in food j

# create objective function

prob = LpProblem('Diet Optimization', LpMinimize)

foodVars = LpVariable.dicts("Foods", foods, 0)
foodVars_selected = LpVariable.dicts("food_select",foods,0,1,LpBinary) #binary integer variables for whether a food chosen


prob += lpSum([cost[f] * foodVars[f] for f in foods]), 'Total Cost'

# constraints

for i in range(0,11): # for loop running through each nutrient: 11 times starting with 0
    prob += lpSum([nutrients[i][j] * foodVars[j] for j in foods]) >= minVal[0][i+3], 'min nutrient ' + nutrientNames[i]
    prob += lpSum([nutrients[i][j] * foodVars[j] for j in foods]) <= maxVal[0][i+3], 'max nutrient ' + nutrientNames[i]


# constraint a
# If a food is eaten, must eat at least 0.1 serving

for food in foods:
    prob += foodVars[food] >= 0.1 * foodVars_selected[food]

# If any of a food is eaten, its binary variable must be 1

for food in foods:
    prob += foodVars_selected[food] >= foodVars[food]*0.0000001 

# constraint b

# Include at most 1 of celery and frozen brocolli

prob += foodVars_selected['Frozen Broccoli'] + foodVars_selected['Celery, Raw'] <= 1 

# CONSTRAINT C

# At least 3 kinds of meat/poultry/fish/eggs

prob += foodVars_selected['Roasted Chicken'] + foodVars_selected['Poached Eggs'] \
        + foodVars_selected['Scrambled Eggs'] + foodVars_selected['Bologna,Turkey'] \
        + foodVars_selected['Frankfurter, Beef'] + foodVars_selected['Ham,Sliced,Extralean'] \
        + foodVars_selected['Kielbasa,Prk'] + foodVars_selected['Pizza W/Pepperoni'] \
        + foodVars_selected['Hamburger W/Toppings'] \
        + foodVars_selected['Hotdog, Plain'] + foodVars_selected['Pork'] \
        + foodVars_selected['Sardines in Oil'] + foodVars_selected['White Tuna in Water'] \
        + foodVars_selected['Chicknoodl Soup'] + foodVars_selected['Splt Pea&Hamsoup'] \
        + foodVars_selected['Vegetbeef Soup'] + foodVars_selected['Neweng Clamchwd'] \
        + foodVars_selected['New E Clamchwd,W/Mlk'] + foodVars_selected['Beanbacn Soup,W/Watr'] >= 3

prob.solve()

print()
print("SOLUTION")
for var in prob.variables():
    if var.varValue > 0 and "food_select" not in var.name: # Print non binary variables
        print(str(var.varValue)+" units of "+str(var).replace('Foods_','') )
print()
print("Total cost of food = $%.2f" % value(prob.objective))        
