##Question 11.1

#Using the crime data set uscrime.txt from Questions 8.2, 9.1, and 10.1, build a regression model using:
#1.	Stepwise regression
#2.	Lasso
#3.	Elastic net


uscrime <- read.delim("~/Documents/ISYE6501/hw8-Fall 21/uscrime.txt", header=TRUE)

library(tidyverse)
library(caret)
library(leaps)
library(MASS)
```
## Initial Linear Model:

model1 <- lm(Crime~., data = uscrime)
summary(model1)

## Stepwise Model:

step_model <- step(model1, 
                   scope = list(lower = formula(lm(Crime~1, data = uscrime)),
                                upper = formula(lm(Crime~., data = uscrime))),
                   direction = "both")

#Creating a new linear model with 8 variables selected by step-wise regression:

model2 <- lm(Crime ~ M + Ed + Po1 + M.F + U1 + U2 + Ineq + Prob, data =uscrime)
summary(model2)

#The new model with reduced variables offers slight improvement in adjusted r-squared over th einitial linear model containing all 15 variables.

## Lasso Model

library(glmnet)

#Running the lasso model with cross validation:

set.seed(2)
lasso.model <- cv.glmnet(x = as.matrix(uscrime[,-16]),
                         y= as.matrix(uscrime[,16]), 
                         alpha=1, 
                         nfolds = 5,
                         nlamda = 10,
                         type.measure="mse", 
                         family="gaussian", 
                         standardize = TRUE)

lasso.model

plot(lasso.model)

lasso.model$lambda.min

#We can see that the optimal value of lambda is 5.2862.

coef(lasso.model, s= lasso.model$lambda.min )

#Creating a model with the 11 variables selected by the Lasso Method:

model3 <- lm(Crime ~ M + So + Ed + Po1 + M.F + NW + U1 + U2 + Wealth + Ineq + Prob, data =uscrime)
summary(model3)
```
This model offers a small improvement in adjusted r-squared over the intital linear model. However, it is not better than the stepwise model.

## Creating Elastic Net Model:

#First finding the best alpha value:
  ```{r}
set.seed(2)

dev_ratios = c()

for (i in 1:10) {
  alpha.model <- cv.glmnet(x = as.matrix(uscrime[,-16]),
                           y = as.matrix(uscrime[,16]), 
                           alpha = i/10, 
                           nfolds = 5,
                           nlamda = 10,
                           type.measure = "mse", 
                           family = "gaussian", 
                           standardize = TRUE)

dev_ratios = cbind(dev_ratios,
                     alpha.model$glmnet.fit$dev.ratio[which(alpha.model$glmnet.fit$lambda 
                                                            ==   alpha.model$lambda.min)])
}

dev_ratios

#Using the best alpha value (.5) to run lasso with cross-validation:

set.seed(2)
en.model <- cv.glmnet(x = as.matrix(uscrime[,-16]),
                      y= as.matrix(uscrime[,16]), 
                      alpha=.5, 
                      nfolds = 5,
                      nlamda = 10,
                      type.measure="mse", 
                      family="gaussian", 
                      standardize = TRUE)

en.model

#Plotting

plot(en.model)

en.model$lambda.min

#The optimal value of lambda is 5.512458. 

coef(en.model, s= en.model$lambda.min )

#Creating linear model with 12 variables selected by elastic net method:

model4<- lm(Crime ~ M + So + Ed + Po1 + M.F + Pop + NW + U1 + U2 + Wealth + Ineq + Prob, data =uscrime)
summary(model4)

#This model also performs slightly better than the initial linear model, but not better than the stepwise model.

#Comparing the model performance of each variable selection method:

r_table <- data.frame(Model = c("Model1 - All Vars", 
                                "Model2 - Stepwise", 
                                "Model3 - Lasso", 
                                "Model4 - Elastic Net"),
                      R2 = c(summary(model1)$r.squared,
                             summary(model2)$r.squared,
                             summary(model3)$r.squared,
                             summary(model4)$r.squared),
                      Adj_R2 = c(summary(model1)$adj.r.squared,
                                 summary(model2)$adj.r.squared,
                                 summary(model3)$adj.r.squared,
                                 summary(model4)$adj.r.squared),
                      Num_Vars = c(length(model1$coefficients)-1,
                                   length(model2$coefficients)-1,
                                   length(model3$coefficients)-1,
                                   length(model4$coefficients)-1))
r_table

#The model with 9 predicting variables selected by the stepwise method performs best judging by adjusted r-squared. So the stepwise model is best among the above models. Model 2 is also desirable because it is the least complex.  Though, it's adjusted r-squared could be artificially low for this same reason since adjusted r-squared takes into account number of predictor variables. Judging by r-squared alone, none of the models are better than the initial model with all predicting variables.  An additional ANOVA test is needed to compare the models.

Comparing the initial linear regressionw with stepwise model:

anova.1.2 <- anova(model1, model2)

anova.1.2

#Comparing the lasso model with the stepwise model:

anova.2.3 <- anova(model2, model3)

anova.2.3

#Comparing the elstic net model with the stepwise model:

anova.2.4 <- anova(model2, model4)

anova.2.4

#A comparison of model 2 (the model with variables selected by the stepwise method) with all other models reveals that there is no statistically significant difference between model 2 and any of the others. The f-test value have extremely high p-values for all the anova test performed above. So even though model 2 had the highest adjusted r-squared, an anova test comparing it to the linear model with all 15 variables and to the models with variables selected by the lasso and elastic net methods shows that none of the variable selection methods produced a model better than the initial linear regression. This could be due in part to the very small data set used.