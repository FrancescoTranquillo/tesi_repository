library(rstanarm)
library(bayestestR)
library(caret)
df <- read.csv(file.choose(),header = T)


model <- stan_glm(ESITO.CICLO~CATEGORIA+NUMERO.SERIALE.LAVAENDOSCOPI+OPERATORE,data = df,
             family = binomial(link="logit"))

summary(model)

library(ggplot2)
pplot<-plot(model, "areas", prob = 0.95, prob_outer = 1)
pplot+ geom_vline(xintercept = 0)

describe_posterior(model)

# “the effect of CATEGORIAGastroscope has a probability of 100% of being negative (Median = -1.1744910, 89% CI [-1.5961847, -0.7833502]) 
# and can be considered as significant (0% in ROPE).”

pred <- predict(model, data.frame("CATEGORIA"="CATEGORIAGastroscope"),type = "response")
y_pred_num <- ifelse(pred > 0.5, 1, 0)
y_pred <- factor(y_pred_num, levels=c("CICLO REGOLARE", "CICLO IRREGOLARE"))
confusionMatrix(data = y_pred,reference = df$ESITO.CICLO,positive = "CICLO IRREGOLARE")


nn <- train(ESITO.CICLO~CATEGORIA+NUMERO.SERIALE.LAVAENDOSCOPI+OPERATORE,data = df,
            method="glm")
nn
summary(nn)
