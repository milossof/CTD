#' Generate patient-specific bitstrings from adaptive network walk.
#'
#' This function calculates the bitstrings (1 is a hit; 0 is a miss) associated with the adaptive network walk
#' made by the diffusion algorithm trying to find the variables in the encoded subset, given the background knowledge graph.
#' @param data_mx - The matrix that gives the perturbation strength (z-score) for all variables (rows) for each patient (columns).
#' @param ptID - The identifier associated with the patient being processed.
#' @param perms - The list of permutations calculated over all possible nodes, starting with each node in subset of interest.
#' @param kmx - The maximum size of variable sets for which you want to calculate probabilities.
#' @return pt.byK - a list of bitstrings, with the names of the list elements the node names of the encoded nodes
#' @export mle.getPtBSbyK
#' @examples
#' # Look at main_CTD.r script for full analysis script: https://github.com/BRL-BCM/CTD.
#' # Get bitstrings associated with each patient's top kmx variable subsets
#' kmx = 15
#' ptBSbyK = list()
#' for (pt in 1:ncol(data_mx)) {
#'   S = data_mx[order(abs(data_mx[,pt]), decreasing=TRUE),pt][1:kmx]
#'   ptBSbyK[[ptID]] = mle.getPtBSbyK(S, perms)
#' }
mle.getPtBSbyK = function(S, perms) {
  pt.byK = list()
  for (k in 1:length(S)) {
    sig.nodes = S[1:k]
    pt.bitString = list()
    for (p in 1:length(sig.nodes)) {
      pt.bitString[[sig.nodes[p]]] = as.numeric(perms[[sig.nodes[p]]] %in% sig.nodes)
      names(pt.bitString[[sig.nodes[p]]]) = perms[[sig.nodes[p]]]
      ind = which(pt.bitString[[sig.nodes[p]]] == 1)
      pt.bitString[[sig.nodes[p]]] = pt.bitString[[sig.nodes[p]]][1:ind[length(ind)]]
    }
    # Which found the most nodes
    bestInd = vector("numeric", length(sig.nodes))
    for (p in 1:length(sig.nodes)) {
      bestInd[p] = sum(pt.bitString[[p]])
    }
    pt.bitString = pt.bitString[which(bestInd==max(bestInd))]
    # Which found the most nodes soonest
    bestInd = vector("numeric", length(pt.bitString))
    for (p in 1:length(pt.bitString)) {
      bestInd[p] = sum(which(pt.bitString[[p]] == 1))
    }
    pt.byK[[k]] = pt.bitString[[which.min(bestInd)]]
  }
  return(pt.byK)
}

mle.getPtBSbyK_sn = function(S1, S2, S12, perms) {
  pt.byK = list()
  for (k in 1:length(S1)) {
    p1.sig.nodes = S1[1:k]
    p2.sig.nodes = S2[1:k]
    p12.sig.nodes = unique(c(p1.sig.nodes, p2.sig.nodes))

    pt.bitString = list(S1=vector("numeric", length=length(perms)), S2=vector("numeric", length=length(perms)), S12=vector("numeric", length=length(perms)))
    for (p in 1:length(p12.sig.nodes)) {
      if (p12.sig.nodes[p] %in% p1.sig.nodes) {
        pt.bitString[[p12.sig.nodes[p]]]$S1 = as.numeric(perms[[p12.sig.nodes[p]]] %in% p1.sig.nodes)
        names(pt.bitString[[p12.sig.nodes[p]]]$S1) = perms[[p12.sig.nodes[p]]]
        ind = which(pt.bitString[[p12.sig.nodes[p]]]$S1 == 1)
        pt.bitString[[p12.sig.nodes[p]]]$S1 = pt.bitString[[p12.sig.nodes[p]]][1:ind[length(ind)]]
      }
      if (p12.sig.nodes[p] %in% p2.sig.nodes) {
        pt.bitString[[p12.sig.nodes[p]]]$S2 = as.numeric(perms[[p12.sig.nodes[p]]] %in% p2.sig.nodes)
        names(pt.bitString[[p12.sig.nodes[p]]]$S2) = perms[[p12.sig.nodes[p]]]
        ind = which(pt.bitString[[p12.sig.nodes[p]]]$S2 == 1)
        pt.bitString[[p12.sig.nodes[p]]]$S2 = pt.bitString[[p12.sig.nodes[p]]][1:ind[length(ind)]]
      }
      pt.bitString[[p12.sig.nodes[p]]]$S12 = as.numeric(perms[[p12.sig.nodes[p]]] %in% p12.sig.nodes)
      names(pt.bitString[[p12.sig.nodes[p]]]$S12) = perms[[p12.sig.nodes[p]]]

      ind = which(pt.bitString[[p12.sig.nodes[p]]]$S12 == 1)
      pt.bitString[[p12.sig.nodes[p]]]$S12 = pt.bitString[[p12.sig.nodes[p]]][1:ind[length(ind)]]
    }
    # Which found the most nodes
    bestInd = vector("numeric", length(sig.nodes))
    for (p in 1:length(sig.nodes)) {
      bestInd[p] = sum(pt.bitString[[p]])
    }
    pt.bitString = pt.bitString[which(bestInd==max(bestInd))]
    # Which found the most nodes soonest
    bestInd = vector("numeric", length(pt.bitString))
    for (p in 1:length(pt.bitString)) {
      bestInd[p] = sum(which(pt.bitString[[p]] == 1))
    }
    pt.byK[[k]] = pt.bitString[[which.min(bestInd)]]
  }

  return(pt.byK)
}





mle.getPtBSbyK_memoryless = function(S, perms, num.misses=NULL) {
  if (is.null(num.misses)) {
    num.misses = ceiling(log2(length(perms)))
  }
  pt.byK = list()
  for (k in 1:length(S)) {
    sig.nodes = S[1:k]
    pt.bitString = list()
    for (p in 1:length(sig.nodes)) {
      miss = 0
      for (ii in 1:length(perms[[sig.nodes[p]]])) {
        ind_t = as.numeric(perms[[sig.nodes[p]]][ii] %in% sig.nodes)
        if (ind_t==0) {
          miss = miss + 1
          if (miss >= num.misses) {
            thresh = ii
            break;
          }
        } else {
          miss = 0
        }
        pt.bitString[[sig.nodes[p]]][ii] = ind_t
      }
      pt.bitString[[sig.nodes[p]]] = pt.bitString[[sig.nodes[p]]][1:thresh]
      names(pt.bitString[[sig.nodes[p]]]) = perms[[sig.nodes[p]]][1:thresh]
      ind = which(pt.bitString[[sig.nodes[p]]] == 1)
      pt.bitString[[sig.nodes[p]]] = pt.bitString[[sig.nodes[p]]][1:ind[length(ind)]]
    }
    # Which found the most nodes
    bestInd = vector("numeric", length(sig.nodes))
    for (p in 1:length(sig.nodes)) {
      bestInd[p] = sum(pt.bitString[[p]])
    }
    pt.bitString = pt.bitString[which(bestInd==max(bestInd))]
    # Which found the most nodes soonest
    bestInd = vector("numeric", length(pt.bitString))
    for (p in 1:length(pt.bitString)) {
      bestInd[p] = sum(which(pt.bitString[[p]] == 1))
    }
    pt.byK[[k]] = pt.bitString[[which.min(bestInd)]]
  }

  return(pt.byK)
}


