app <- ShinyDriver$new("../")
app$snapshotInit("mytest")

app$setInputs(`esq-controls-filter-data-ehmijjyvte_Sepal_Length` = c(4.3, 7.9))
app$setInputs(`esq-controls-filter-data-ehmijjyvte_Sepal_Width` = c(2, 4.4))
app$setInputs(`esq-controls-filter-data-ehmijjyvte_Petal_Length` = c(1, 6.9))
app$setInputs(`esq-controls-filter-data-ehmijjyvte_Petal_Width` = c(0.1, 2.5))
app$setInputs(`esq-controls-filter-data-ehmijjyvte_Species` = c("setosa", "versicolor", "virginica"))
app$setInputs(`esq-controls-filter-data-ehmijjyvte_Sepal_Length_na_remove` = TRUE)
app$setInputs(`esq-controls-filter-data-ehmijjyvte_Sepal_Width_na_remove` = TRUE)
app$setInputs(`esq-controls-filter-data-ehmijjyvte_Petal_Length_na_remove` = TRUE)
app$setInputs(`esq-controls-filter-data-ehmijjyvte_Petal_Width_na_remove` = TRUE)
app$setInputs(`esq-controls-filter-data-ehmijjyvte_Species_na_remove` = TRUE)
app$setInputs(`esq-controls-filter-data-ehmijjyvte_Species-selectized` = "")
app$setInputs(sidebarItemExpanded = "<strong>Caricamentoscontrini</strong>")
app$uploadFile(txt = c("2016-03-07 12.12 01 Strumento-G111106 Operatore-Technical.txt", "2016-03-07 12.35 02 Strumento-G120029 Operatore-D.M..txt", "2016-03-07 12.38 03 Strumento-G120029 Operatore-T.M..txt", "2016-03-07 12.48 04 Strumento-G120029 Operatore-D.M..txt", "2016-03-07 14.18 05 Strumento-212095 Operatore-Technical.txt", "2016-03-07 14.27 06 Strumento-0042014 Operatore-V.M.L..txt", "2016-03-07 14.41 07 Strumento-0042014 Operatore-Technical.txt", "2016-03-07 15.19 08 Strumento-0042014 Operatore-C.G..txt", "2016-03-07 15.45 09 Strumento-0042014 Operatore-S.C..txt")) # <-- This should be the path to the file, relative to the app's tests/ directory
# Input 'scontrino_table_rows_current' was set, but doesn't have an input binding.
# Input 'scontrino_table_rows_all' was set, but doesn't have an input binding.
# Input 'scontrino_table_rows_selected' was set, but doesn't have an input binding.
# Input 'scontrino_table_row_last_clicked' was set, but doesn't have an input binding.
# Input 'scontrino_table_cell_clicked' was set, but doesn't have an input binding.
# Input 'scontrino_table_rows_selected' was set, but doesn't have an input binding.
# Input 'scontrino_table_cell_clicked' was set, but doesn't have an input binding.
# Input 'scontrino_table_rows_selected' was set, but doesn't have an input binding.
# Input 'scontrino_table_rows_selected' was set, but doesn't have an input binding.
# Input 'scontrino_table_row_last_clicked' was set, but doesn't have an input binding.
# Input 'scontrino_table_cell_clicked' was set, but doesn't have an input binding.
# Input 'scontrino_table_rows_selected' was set, but doesn't have an input binding.
# Input 'scontrino_table_rows_selected' was set, but doesn't have an input binding.
# Input 'scontrino_table_row_last_clicked' was set, but doesn't have an input binding.
# Input 'scontrino_table_cell_clicked' was set, but doesn't have an input binding.
app$setInputs(`esq-dragvars` = c("INIZIO CICLO", "TIPO CICLO", "NUMERO SERIALE", "STRUMENTO", "CATEGORIA", "MATRICOLA", "IDENTIFICATIVO", "OPERATORE", "NUMERO CICLO", "ALLARMI", "INIZIO CICLO", character(0), character(0), character(0), character(0), character(0)))
app$setInputs(`esq-dragvars` = c("INIZIO CICLO", "TIPO CICLO", "NUMERO SERIALE", "STRUMENTO", "CATEGORIA", "MATRICOLA", "IDENTIFICATIVO", "OPERATORE", "NUMERO CICLO", "ALLARMI", "INIZIO CICLO", "TIPO CICLO", character(0), character(0), character(0), character(0)))
app$setInputs(`esq-dragvars` = c("INIZIO CICLO", "TIPO CICLO", "NUMERO SERIALE", "STRUMENTO", "CATEGORIA", "MATRICOLA", "IDENTIFICATIVO", "OPERATORE", "NUMERO CICLO", "ALLARMI", "INIZIO CICLO", character(0), "TIPO CICLO", character(0), character(0), character(0)))
app$setInputs(`esq-dragvars` = c("INIZIO CICLO", "TIPO CICLO", "NUMERO SERIALE", "STRUMENTO", "CATEGORIA", "MATRICOLA", "IDENTIFICATIVO", "OPERATORE", "NUMERO CICLO", "ALLARMI", "TIPO CICLO", character(0), "TIPO CICLO", character(0), character(0), character(0)))
app$setInputs(`esq-dragvars` = c("INIZIO CICLO", "TIPO CICLO", "NUMERO SERIALE", "STRUMENTO", "CATEGORIA", "MATRICOLA", "IDENTIFICATIVO", "OPERATORE", "NUMERO CICLO", "ALLARMI", "TIPO CICLO", character(0), "ALLARMI", character(0), character(0), character(0)))
app$setInputs(`esq-dragvars` = c("INIZIO CICLO", "TIPO CICLO", "NUMERO SERIALE", "STRUMENTO", "CATEGORIA", "MATRICOLA", "IDENTIFICATIVO", "OPERATORE", "NUMERO CICLO", "ALLARMI", "TIPO CICLO", character(0), "STRUMENTO", character(0), character(0), character(0)))
app$setInputs(`esq-dragvars` = c("INIZIO CICLO", "TIPO CICLO", "NUMERO SERIALE", "STRUMENTO", "CATEGORIA", "MATRICOLA", "IDENTIFICATIVO", "OPERATORE", "NUMERO CICLO", "ALLARMI", "TIPO CICLO", character(0), "CATEGORIA", character(0), character(0), character(0)))
app$setInputs(`esq-dragvars` = c("INIZIO CICLO", "TIPO CICLO", "NUMERO SERIALE", "STRUMENTO", "CATEGORIA", "MATRICOLA", "IDENTIFICATIVO", "OPERATORE", "NUMERO CICLO", "ALLARMI", "TIPO CICLO", character(0), "NUMERO CICLO", character(0), character(0), character(0)))
app$setInputs(`esq-dragvars` = c("INIZIO CICLO", "TIPO CICLO", "NUMERO SERIALE", "STRUMENTO", "CATEGORIA", "MATRICOLA", "IDENTIFICATIVO", "OPERATORE", "NUMERO CICLO", "ALLARMI", "TIPO CICLO", character(0), "OPERATORE", character(0), character(0), character(0)))
app$snapshot()
