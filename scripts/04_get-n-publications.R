source(here::here("scripts", "environment.R"))

# Read in full dataset for UH and UMC articles 
data_articles <- read_csv(file.path(data_dir, "2021-03-04_uh-umc-pubs-2018-articles.csv"), col_types = "ccdc")

# Read in full dataset for UH and UMC articles with Syrcle/PAM query
data_animal <- read_csv(file.path(data_dir, "2021-03-05_11-54-53-uh-umc-2018-syrcle-pam.csv"), col_types = "ccdcdd") %>%
  select(city, pmid, institution, syrcle, pam)

# Read in full dataset for UH and UMC articles with clinical/observational query
data_clinical <- read_csv(file.path(data_dir, "2021-03-10_16-17-02-uh-umc-2018-clinical-observational.csv"), col_types = "ccdcdd") %>%
  select(city, pmid, institution, clinical, observational)

# Create merged dataset
combined_animal <- left_join(data_articles, data_animal, by = c("city", "pmid", "institution"))
merged_data <- left_join(combined_animal, data_clinical, by = c("city", "pmid", "institution"))

all_results <- data.frame(city=unique(merged_data$city))

filter_articles <- function(df) {
  return(list("articles", df))
}

filter_pmid <- function(df) {
  df <- df %>%
    filter(! is.na(pmid))

  return(list("pmid", df))
}

gen_filter <- function(name) {
  fn <- function(df) {
    df <- df %>%
      filter(.data[[name]]==1)
    
    return(list(name, df))
  }
  return(fn)
}

for (f in c(filter_articles, filter_pmid, gen_filter("syrcle"), gen_filter("pam"), gen_filter("clinical"), gen_filter("observational"))) {
  
  res <- f(merged_data)
  p <- res[[1]]
  data <- res[[2]]

  foo <- data.frame(city=character(),
                    a=numeric(),
                    b=numeric(),
                    c=numeric(),
                    stringsAsFactors=FALSE)
  names(foo) <- c("city", paste0("n_uh_", p), paste0("n_umc_", p), paste0("intersection_", p))
  
  for (c in unique(data$city)) {
    uh <- data %>%
      filter(city == c) %>%
      filter(institution == "UH") %>%
      select(doi, city)
    
    n_uh <- nrow(uh)
    
    umc <- data %>%
      filter(city == c) %>%
      filter(institution == "UMC") %>%
      select(doi, city)
    
    n_umc <- nrow(umc)
    
    intersection <- intersect(uh, umc) %>%
      nrow()
    
    foo[c, ] = c(c, n_uh, n_umc, intersection)
  }
  
  all_results <- left_join(all_results, foo, by="city")
}

# write to disk
