# Get data from simulated-data
# Move 'Class' to first column
# Put these files in reformated-data

library(dplyr)
library(data.table)

set.seed(1618)

mdr_path <- here::here('mb-mdr/')
data_dir <- here::here('simulated-data')
filenames <- list.files(data_dir, pattern = '*.txt')

for (filename in filenames){
  mydat <- paste(data_dir, filename, sep = '/') %>%
    fread() %>%
    dplyr::select(Class, paste0('X', 0:9)) 
  nsamp <- nrow(mydat)
  
  train_idx <- sample(seq(nsamp), floor(nsamp*0.8), replace = F)
  train_dat <- mydat[train_idx, ]
  test_dat <- mydat[-train_idx, ]
  
  # fwrite(mydat, paste0(mdr_path, 'reformatted-data/', filename), sep = '\t')
  fwrite(train_dat, paste0(mdr_path, 'reformatted-data/train/', filename), sep = '\t')
  fwrite(test_dat, paste0(mdr_path, 'reformatted-data/test/', filename), sep = '\t')
}



set.seed(1618)

data_dir <- here::here('real-data')
filename <- list.files(data_dir, pattern = '*.tsv')
mydat <- paste(data_dir, filename, sep = '/') %>%
  fread() %>%
  mutate(Age = 2016 - YOB,
         PHENOTYPE = PHENOTYPE - 1) %>%
  dplyr::select(-c(FID, IID, Site, Platform, YOB)) %>%
  dplyr::select(PHENOTYPE, Age, everything()) %>%
  replace(., is.na(.), -9) # recode NAs as -9 for MB-MDR

# trait: PHENOTYPE
# covariates: Sex, Age, PC1-6
nsamp <- nrow(mydat)
train_idx <- sample(seq(nsamp), floor(nsamp*0.8), replace = F)
train_dat <- mydat[train_idx, ]
test_dat <- mydat[-train_idx, ]

table(train_dat$PHENOTYPE)
table(test_dat$PHENOTYPE)



gwas_cat_snps <-
  readr::read_csv(here::here('gwas-catalog-snps.csv'), col_names = F) %>% pull()
pubmed_snps <-
  readr::read_csv(here::here('pubmed-snps.csv'), col_names = F) %>% pull()
simplified_snps <-
  stringr::str_split(colnames(mydat), '_', simplify = TRUE)[, 1]
overlapping_snps <- union(pubmed_snps, gwas_cat_snps) %>%
  intersect(simplified_snps)



mydat_small <- mydat %>% 
  select(1:100, sapply(overlapping_snps, contains))



mydat_small[train_idx, ] %>%
  fwrite(paste0(mdr_path, 'reformatted-data/real-train/small_',
                gsub('.tsv', '.txt', filename)), sep = '\t')
mydat_small[-train_idx, ] %>%
  fwrite(paste0(mdr_path, 'reformatted-data/real-test/small_',
                gsub('.tsv', '.txt', filename)), sep = '\t')


train_dat %>%
  fwrite(paste0(mdr_path, 'reformatted-data/real-train/', 
                gsub('.tsv', '.txt', filename)), sep = '\t')

test_dat %>%
  fwrite(paste0(mdr_path, 'reformatted-data/real-test/', 
                gsub('.tsv', '.txt', filename)), sep = '\t')


train_dat %>%
  select(-c(Age, Sex, paste0('PC', 1:6))) %>% 
  fwrite(paste0(mdr_path, 'reformatted-data/real-train/', 
                gsub('_covariates.tsv', '.txt', filename)), sep = '\t')

test_dat %>%
  select(-c(Age, Sex, paste0('PC', 1:6))) %>% 
  fwrite(paste0(mdr_path, 'reformatted-data/real-test/', 
                gsub('_covariates.tsv', '.txt', filename)), sep = '\t')
