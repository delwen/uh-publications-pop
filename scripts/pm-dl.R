library(tidyverse)
library(xml2)
library(httr)
library(jsonlite)

apikey <- readLines("api_key.txt")

data <- read_csv("dimensions-data.csv", col_types = "ccdcdcc")

unique_data <- distinct(data, pmid) %>% select(pmid) %>% drop_na()

output_filename <- Sys.time() %>%
    str_replace_all(":", "-") %>%
    str_replace_all(" ", "_") %>%
    paste0("-pubmed-metadata.csv")

tribble(
    ~pmid, ~languages_pubmed, ~pubtypes_pubmed, ~authors_pubmed
) %>%
    write_csv(output_filename)

download_pubmed_metadata <- function (pmid, api_key) {

    out <- tryCatch({

        pubmed_search <- list(
            api_key = apikey,
            db = "pubmed",
            id = pmid,
            retmode="xml"
        )

        res <- POST(
            "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi",
            body=pubmed_search,
            encode="form"
        )
        
        result <- read_xml(res)

        closeAllConnections()

        languages <- xml_find_all(
            result,
            "/eSummaryResult/DocSum/Item[contains(@Name, 'LangList')]/Item[contains(@Name, 'Lang')]"
        ) %>%
            xml_text()

        pubtypes <- xml_find_all(
            result,
            "/eSummaryResult/DocSum/Item[contains(@Name, 'PubTypeList')]/Item[contains(@Name, 'PubType')]"
        ) %>%
            xml_text()

        authors <- xml_find_all(
            result,
            "/eSummaryResult/DocSum/Item[contains(@Name, 'AuthorList')]/Item[contains(@Name, 'Author')]"
        ) %>%
            xml_text()

        return (tribble(
            ~languages, ~pubtypes, ~authors,
            toJSON(languages), toJSON(pubtypes), toJSON(authors)
        ))
        
    },
    error=function(cond) {
        message(
            paste(
                "Error:",
                cond
            )
        )

        return(NA)
    },
    warning=function(cond) {
        message(
            paste(
                "Warning:",
                cond
            )
        )

        return(NA)
    },
    finally={
    })

    return(out)
    
}

for (pmid in unique_data$pmid) {
    
    meta <- download_pubmed_metadata(pmid)

    tribble(
        ~pmid, ~languages_pubmed, ~pubtypes_pubmed, ~authors_pubmed,
        pmid, meta$languages, meta$pubtypes, meta$authors
    ) %>%
        write_csv(output_filename, append=TRUE)
}

pubmed_metadata <- read_csv(output_filename, col_types = "dccc")

result <- left_join(data, pubmed_metadata, by="pmid")
write_csv(result, "dimensions-pubmed-data.csv")
