# Get UH publications with a match to the PAM filter
# Draw a random sample 

source(here::here("scripts", "environment.R"))

# Draw too many samples so that we still have enough after duplicate removal
sample_size <- 60

# Filter for publications from UH with a match to the PAM filter
data <- read_csv(file.path(data_dir, "2021-03-05_11-54-53-uh-umc-2018-syrcle-pam.csv"), col_types = "ccdcdd") %>%
  filter(institution == "UH") %>%
  filter(pam == 1) %>%
  select(doi, city, pmid, institution, pam)

# Create a reproducible sample
set.seed(15)

n <- as.numeric(count(data))
sample <- sample_n(data, ifelse(n < sample_size, n, sample_size))

sample <- distinct(sample, doi, .keep_all = TRUE)

# Keep the first 50 results
sample <- head(sample, 50)

# Add columns to enter results of the specificity checks
q1 <- "animal_study"
q2 <- "title"
q3 <- "abstract"
q4 <- "comments"
q5 <- "link"
columns_to_add <- c(q1, q2, q3, q4, q5)
sample[,columns_to_add] = ""

sample <- sample %>%
  mutate(link = xl_hyperlink(paste0("https://pubmed.ncbi.nlm.nih.gov/", pmid)))

write_xlsx(sample, file.path(data_dir, paste0(Sys.Date(), "_uh-umc-2018-sample.xlsx")))
