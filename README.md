# uh-publications-pop
Create a proof-of-principle publication set from University hospitals (UHs) based on Dimensions and PubMed,
and extract the number of publications obtained after applying a set of PubMed MeSH filters. These results
are compared to a previously generated dataset at the level of University Medical Centers (UMCs).

## Step 1
Query Dimensions API for publications at pre-defined university hospital GRID IDs and years. Get additional metadata:
+ DOI
+ Publication year
+ PMID
+ Publication type
+ Field of Research category (article-level classification into a field)
+ Authors

The list of selected GRID IDs can of course be adapted depending on the use case.

## Step 2
Query PubMed API for additional metadata:
+ Publication language
+ Publication type
+ Authors

Merge the Dimensions and PubMed data.

## Step 3
Read in the combined Dimensins/PubMed dataset and process as needed. In this case,
we filtered for journal articles based the PubMed metadata.

Here, we compared this UH dataset to a previously extracted dataset at the
level of UMCs. For this, we read in the UMC dataset and apply the same exclusion
criteria for comparison.

## Step 4
We obtained the intersection of publications in the UH/ UMC datasets and pre-defined
PubMed filters (not covered here). This step generates the number of publications
obtained in each dataset (UH/UMC) and filter.