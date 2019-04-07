library(tidyverse)
library(data.table)
library(dplyr)
scontrino<-readLines(file.choose())
scontrino_header<-scontrino[5:15]
scontrino_footer<-scontrino[16:length(scontrino)]

#trasformazione header
df_header<-data.frame(do.call(rbind, strsplit(scontrino_header, "(?<=[A-Z]): ",perl = T)),stringsAsFactors = F)
tmydf_header = setNames(data.frame(t(df_header[,-1])), df_header[,1])
head(tmydf_header)
df<-tmydf_header

#trasformazione footer
df<-df%>%
  mutate("CICLO REGOLARE"=ifelse(any(grepl("CICLO IRREGOLARE", scontrino_footer)==TRUE),-1,1))
df

