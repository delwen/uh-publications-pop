# uh-publications-pop
Create proof-of-principle publication set from University hospitals based on Dimensions and PubMed.

## Step 1
Query Dimensions API for publications at pre-defined university hospital GRID IDs and years. Get additional metadata:
+ DOI
+ Publication year
+ PMID
+ Publication type
+ Field of Research category (article-level classification into a field)
+ Authors

## Step 2
Query PubMed API for additional metadata:
+ Publication language
+ Publication type
+ Authors