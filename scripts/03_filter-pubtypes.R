source(here::here("scripts", "environment.R"))

#-------------------------------------------------------------------------------------------------------------------
# Read in and process UH data
#-------------------------------------------------------------------------------------------------------------------

# Read in data with combined Dimensions and PubMed metadata
data <- read_csv(file.path(data_dir, "2021-03-03_uh-pubs-2018-pm.csv"), col_types = "ccdcdccccc")

# Recode city names to match the UMC dataset as much as possible
data$city <- recode(data$city,
                    charite = "berlin",
                    duesseldorf = "dusseldorf",
                    goettingen = "gottingen",
                    kiel_luebeck = "kiel_lubeck",
                    koeln = "cologne",
                    muenchenLMU = "munich_lmu",
                    muenchenTU = "munich_tu",
                    muenster = "munster",
                    tuebingen = "tubingen",
                    "witten-herdecke" = "witten",
                    wuerzburg = "wurzburg")

# Filter for "Articles" (any mention of "Journal Article", except if also mention of "Review" -> "Review")
# Filter for "Reviews" (any mention of "Review")
# POSSIBLE ALTERNATIVE: filter for "Journal Article" ONLY or "Review" ONLY (although there are very few
# publications with "Review" as single category)

data_pubtypes <- data %>%
  mutate(article = ifelse(grepl("Journal Article", pubtypes_pubmed) & !grepl("Review", pubtypes_pubmed), TRUE, FALSE)) %>%
  #mutate(article = ifelse(grepl("[\"Journal Article\"]", pubtypes_pubmed, fixed = TRUE), TRUE, FALSE)) %>%
  mutate(review = ifelse(grepl("Review", pubtypes_pubmed), TRUE, FALSE)) %>%
  #mutate(review = ifelse(grepl("[\"Review\"]", pubtypes_pubmed, fixed = TRUE), TRUE, FALSE)) %>%
  mutate(english = ifelse(grepl("English", languages_pubmed), TRUE, FALSE)) %>%
  mutate(article = ifelse(is.na(pubtypes_pubmed) | pubtypes_pubmed == "[]", na_if(article, FALSE), article)) %>%
  mutate(review = ifelse(is.na(pubtypes_pubmed) | pubtypes_pubmed == "[]", na_if(review, FALSE), review)) %>%
  mutate(institution = "UH") %>%
  filter(article == TRUE)

# Throw an error if a publication is an article AND a review
test <- data_pubtypes %>%
  verify(article != review)

# Get number of publications without a DOI
n_no_dois <- data_pubtypes %>%
  filter(is.na(doi)) %>%
  nrow()

# Remove entries without a DOI
data_pubtypes <- data_pubtypes %>%
  filter(! is.na(doi))

# Find number of unique publications which have several PMIDs
n_problematic_pmids <- nrow(distinct(data_pubtypes, doi, city, pmid, .keep_all = TRUE)) - nrow(distinct(data_pubtypes, doi, city, .keep_all = TRUE))

# Convert DOI to lowercase
data_pubtypes$doi <- tolower(data_pubtypes$doi)

# Keep unique DOI and city entries (we keep duplicates between cities)
data_pubtypes <- distinct(data_pubtypes, doi, city, .keep_all = TRUE)

# Select DOI and city
uh_data <- data_pubtypes %>%
  select(doi, city, pmid, institution)

#-------------------------------------------------------------------------------------------------------------------
# Print out number of publications retrieved
#-------------------------------------------------------------------------------------------------------------------

print(paste0("There were ", n_no_dois, " entries without a DOI."))
print(paste0("There were ", n_problematic_pmids, " entries which had 2 different PMIDs."))
print(paste0("The dataset contains ", nrow(distinct(data_pubtypes, doi, city)), " unique DOI and city combinations."))
print(paste0("The dataset contains ", nrow(distinct(data_pubtypes, doi)), " unique DOIs."))

#-------------------------------------------------------------------------------------------------------------------
# Read in and process UMC data
#-------------------------------------------------------------------------------------------------------------------

# Read in main data
main <- read_csv(file.path(data_dir, "main.csv"), col_types = "ccdddcccccdccccdlllllc") %>%
  filter(approach == "approach_3") %>%
  filter(year_published == 2018) %>%
  filter(type != "Review") %>%
  filter(city != "greifswald") %>%
  mutate(institution = "UMC")

main$city <- recode(main$city,
                    giessen = "giessen_marburg",
                    marburg = "giessen_marburg",
                    kiel = "kiel_lubeck",
                    lubeck = "kiel_lubeck",
                    greifswald_gms = "greifswald")

main$doi <- tolower(main$doi)

main <- distinct(main, doi, city, .keep_all = TRUE)

umc_data <- main %>%
  rename("pmid" = pmid_dimensions) %>%
  select(doi, city, pmid, institution)

joined_data <- rbind(uh_data, umc_data) %>%
  write_csv(file.path(data_dir, paste0(Sys.Date(), "_uh-umc-pubs-2018-articles.csv")))

joined_data_pmid <- joined_data %>%
  filter(! is.na(pmid)) %>%
  write_csv(file.path(data_dir, paste0(Sys.Date(), "_uh-umc-pubs-2018-articles-pmid.csv")))
  