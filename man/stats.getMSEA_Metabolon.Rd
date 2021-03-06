% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stats.getMSEA_Metabolon.r
\name{stats.getMSEA_Metabolon}
\alias{stats.getMSEA_Metabolon}
\title{Metabolite set enrichment analysis (MSEA) using pathway knowledge curated by Metabolon}
\usage{
stats.getMSEA_Metabolon(data, class.labels,
  pathway_knowledgebase = "Metabolon")
}
\arguments{
\item{data}{- A data matrix, where rows are metabolites and columns are sample IDs.}

\item{class.labels}{- A vector of binary indicators, where 1 is phenotype1 and 0 is phenotype2.}

\item{pathway.knowledgebase}{- The filename of the .gmt file associated with the pathway knowledge desired.
Currently only "Metabolon" is offered, though "KEGG", "WikiPathways", "SMPDB"
and/or "Reactome" can be added in future versions.}
}
\description{
A function that returns the pathway enrichment score for all perturbed metabolites in a patient's full metabolomic profile.
}
\examples{
data(Miller2015)
# Get class labels for diagnostic class "diagClass"
diagClass = [insert diagnosis here]
class.labels = diagnoses$id
class.labels[which(!(class.labels \%in\% cohorts[[diagClass]]))] = 0
class.labels[which(class.labels \%in\% cohorts[[diagClass]])] = 1
class.labels = as.numeric(class.labels)

# Create the data matrix 
data_mx = Miller2015[,grep("IEM", colnames(Miller2015))]
data_mx = data_mx[, order(class.labels)]

# Generate a .gmt file.
population = names(met.profile)
paths.hsa = list.dirs(path="../inst/extdata", full.names = FALSE)
paths.hsa = paths.hsa[-which(paths.hsa \%in\% c("", "RData", "allPathways"))]
sink(system.file("extdata/Pathway_GMTs/Metabolon.gmt", package="CTD"))
for (p in 1:length(paths.hsa)) {
  load(sprintf("../inst/extdata/RData/\%s.RData", paths.hsa[p]))
  pathway.compounds = V(ig)$label[which(V(ig)$shape=="circle")]
  pathCompIDs = unique(tolower(pathway.compounds[which(pathway.compounds \%in\% population)]))
  print(sprintf("\%s         \%s", paths.hsa[p], paste(pathCompIDs, collapse="    ")), quote=FALSE)
}
sink()
print("test")
pathway.data = stats.getMSEA_Metabolon(data_mx, class.labels, pathway_knowledgebase = "Metabolon")
}
