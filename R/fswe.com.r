
#' guessSep
#' This function assigns a separator for separated values files readers
#' depending on file extension
#' @param filename 
guessSep <- function(filename){
  filename <- gsub(".gz$", "", filename)
  extension <- file_ext(filename)
  if(extension == "tsv") return ("\t")
  else if(extension == "csv") return (",")
  else if(extension == "txt") return ("\t")
  else return(NA)
}

#' guessSoftwareSource
#' @param filename The file name should start by one of the software sources
#' @param software_sources a list defined at the variables file.
guessSoftwareSource <- function(filename, software_sources, allowNA = FALSE){
  softsource <- NA
  grepsw <- function(a, filen) { return(tolower(substring(filen, 1, nchar(a))) == tolower(a)) }
  softsource <- software_sources[unlist(lapply(software_sources, grepsw, filename))]
  
  if(length(softsource) == 0 & !allowNA) {
    stop(
        paste0(
            "Software source can not be guessed by filename!\n",
            "Review file names: they should start by the software source!",
            "File: ", filename)
    )
  } else if (length(softsource) > 1) {
    stop(
        paste0(
            "There are more than one software source after guessing: ",
            softsource,
            "Avoid software with the same lowercase prefix!")
    )
  }
  return(softsource)    
}

#' stopHere
#' A stop with no error messages
stopHere = function() {
  opt <- options(show.error.messages=FALSE) 
  on.exit(options(opt))
  stop()
}


#' take1stentry
#' 
#' this function takes the first entry of a swissprot database header
#' @param entries char variable with the swissprot header
take1stentry <- function(entries){
  
  substrRight <- function(x, n) { substr(x, nchar(x)-n+1, nchar(x)) }
  rmlastchars <- function(x, n) { substr(x, 1, nchar(x) - n) }
  
  first_entry <- strsplit(as.character(entries), "\\||\\/", fixed=F, perl=T)
  first_entry <- first_entry[[1]][4]
  if(substrRight(first_entry, 3)=="/sp") first_entry <- rmlastchars(first_entry, 3)
  return(first_entry)
}

#' guessOrganism
#' 
#' this function uses Swissprot annotations i.e. QXXXXX_HUMAN
#' to guess what's the species of the entry. The header (proteinid)
#' may have several entries, and thus it can belong to several
#' organisms. In that case, the function returns 'multiple'.
#' 
#' @param proteinid char variable containing the Swissprot header.
#' @param species vector defining the organisms that are part of the experiment. It is defined at fswe.datasets.R
#' 
#' An example of species vector:
#' species <- vector(mode="list", length=3)
#' names(species) <- c("HUMAN", "YEAST", "ECOLI")
#' species[[1]] <- "_HUMAN"
#' species[[2]] <- "_YEAS"
#' species[[3]] <- "_ECOLI"
#' 
guessOrganism <- function(proteinid, species){
  sp <- names(which(sapply(species, grepl, proteinid)))
  if(length(sp) == 0) sp <- "NA"
  if(length(sp) > 1) sp <- "multiple"
  sp
}

#' sum_top_n
#' 
#' This function sums the values of the top N values of a vector 'values'. It also allows 
#' to have a minimum number of values to be summed. If the minimum of values is not met, it
#' returns NA. 
#' 
#' This top N approach is INDIVIDUAL, that is, there is no consensus among replicates to 
#' choose the top N peptides.
#' 
#' @param values the vector with the values. 
#' @param n number of top N values to be summed. 
#' @param minimum minimum number of valid (not NA) values allowed in order to return a value.
sum_top_n <- function(values, n, minimum = 1){
  if(length(which(!is.na(values))) < minimum) {return (NA)}
  if (n > length(values)) n <- length(values)
  sum(sort(values, decreasing=T)[1:n], na.rm=T)
}

#' sum_top_n
#' 
#' This function averages the values of the top N values of a vector 'values'. It also allows 
#' to have a minimum number of values to be averaged. If the minimum of values is not met, it
#' returns NA. 
#' 
#' This top N approach is INDIVIDUAL, that is, there is no consensus among replicates to 
#' choose the top N peptides.
#' 
#' @param values the vector with the values. 
#' @param n number of top N values to be averaged. 
#' @param minimum minimum number of valid (not NA) values allowed in order to return a value.
#' 
avg_top_n <- function(values, n, minimum = 1){
  # This top N approach is INDIVIDUAL, that is, there is no consensus among replicates to 
  # choose the top N peptides.
  if(length(which(!is.na(values))) < minimum) {return (NA)}
  if (n > length(values)) n <- length(values)
  mean(sort(values, decreasing=T)[1:n], na.rm=T)
}

#' median_all
#' 
#' @param values the vector with the values. 
#' @param minimum minimum number of valid (not NA) values allowed in order to return a value.
#' 
median_all <- function(values, minimum = 1){
    # This approach is INDIVIDUAL, that is, there is no consensus among replicates to 
    # choose the contributing peptides.
    if(length(which(!is.na(values))) < minimum) {return (NA)}
    # if (n > length(values)) n <- length(values)
    median(values, na.rm = T)
    #mean(sort(values, decreasing=T)[1:n], na.rm=T)
}

#' median_quench
#' 
#' @param values the vector with the values. 
#' @param minimum minimum number of valid (not NA) values allowed in order to return a value.
#' @param minPepsToRemove minimum number of peptides the protein must have in order to remove the top N peptides
#' @param removeTop number of peptides to be removed when the protein has more than minPepsToRemove   
#' 
median_quench <- function(values, minimum = 1, minPepsToRemove = 10, removeTop = 3){
    # This approach is INDIVIDUAL, that is, there is no consensus among replicates to 
    # choose the contributing peptides.

    if(length(which(!is.na(values))) < minimum) {return (NA)}

    removeIndex = removeTop + 1
    if(length(values) >= minPepsToRemove){
        values <- sort(values, decreasing = T)[removeIndex:length(values)]
    }
    
    median(values, na.rm = T)
}



#' sumNA
#' 
#' sums values substituting NAs by zeroes
#' This is useful for summary functions in dplyr, for example
#' 
#' @param values
sumNA <- function(values){ 
  sumv <- sum(values, na.rm=T)
  if(sumv == 0) sumv <- NA
  sumv
}

#' avgNA
#' 
#' averages values substituting NAs by zeroes
#' This is useful for summary functions in dplyr, for example
#' 
#' @param values
avgNA <- function(values){ 
  avgv <- mean(values, na.rm=T)
  if(avgv == 0) avgv <- NA
  avgv
}

#' single_hits
#' 
#' This function filters vectors by returning NA if the vector has more than one valid element.
#' This is useful for summary functions in dplyr, for example
#' 
#' @param values
single_hits <- function(values){
  # choose single hit proteins.
  if(length(which(!is.na(values))) > 1) {return (NA)}
  sum(values)
}

### Common functions for formatting Software inputs 

## Depends on: fswe.variables.R 

guessExperiment <- function(exp, injections){
    # exp: one of the experiments: i.e. experiments[[1]]
    # injections: list of injections (preferably a unique list!) of the experiment
    
    #remove extensions
    injections <- as.vector(sapply(injections, file_path_sans_ext))
    all(sapply(injections, is.element, exp ))
}

guessInjection <- function(varname, injections){
    as.character( 
        injections[ 
            which( 
                sapply(injections,  grepl, varname, ignore.case = T)
            ) 
        ]
    )
}

guessExperiment_wide <- function(exp, varnames){
    # exp: one of the experiments: i.e. experiments[[1]]
    # varnames: column names of the data frame
    any(sapply(exp, grepl, varnames, ignore.case = T))
}

getProteinKeys <- function(pepsProtein, suffix){
    proteinKeys = character()
    for(i in 1:length(pepsProtein)){
        proteinKeys = c(proteinKeys, rep( paste0(suffix, i), pepsProtein[i]))    
    }     
    return(proteinKeys)
} 

getPeptideKeys <- function(pepsProtein, proteinKeys) {
    pepKeys = character()
    for(i in 1:length(pepsProtein)){
        pepKeys = c( pepKeys, paste0("_", 1:pepsProtein[i]))
    }
    pepKeys = paste0(proteinKeys, pepKeys)
    return(pepKeys)
}

getPeptideIntensities <- function(peptidesProtein, AbsoluteIntensityProtein){
    PeptideIntensities = numeric()
    for(i in 1:length(peptidesProtein)){
        # plot(1:25, sort( rlnorm(25, meanlog = 20, sd = 2), decreasing = T))
        # Simulate the total intensity of each peptide of the protein -- we use a logarithmic distribution
        PeptideInt_i =rlnorm(peptidesProtein[i], meanlog = AbsoluteIntensityProtein[i], sdlog = 1) # TODO: sdlog ??
        PeptideIntensities = c(PeptideIntensities, PeptideInt_i)
    }
    return(PeptideIntensities)
}

#' FSWE.simExperiment
#' 
#' This function simulates a complete experiment that can be read by FSWE.
#' 
#' @param numReplicates number of replicates of the experiment (same number for samples A and B)
#' @param species vector with species tag names. Example: species = c("HUMAN", "YEAST", "ECOLI")
#' @param speciesRatios vector with expected log ratios for each species. Example: speciesRatios = c(0.0, 1.0, -2.0)
#' @param stdDevRatios biological/prep variation. Example: stdDeviations = c(0.05, 0.1, 0.1)
#' @param numProteinsSpecies vector with number of proteins simulated per species. Example: numProteins = c(2000, 1500, 1000)
#' @param peptidesPerProtein vector with the average number of peptides per protein simulated. Example: peptidesPerProtein = c(10, 8, 5)
#' @param proteinAbundanceDistribution vector containing mean and sd values defining the protein distribution intensities desired. Example: proteinAbundanceDistribution = c(10.0, 5.0) 
#' @param stdDeviationFactorMS standard deviation factor (0 to 1) due to MS. Example: stdDeviationFactorMS = 0.03
#' @param BackgroundSignalLevel A threshold value limiting the signal. Every peptide signal estimated under this will be transformed to NA. 
#' @param NMARFactor factor of Not Missing At Random missing values in the experiment. They are intensity-dependant!
#' @param MARFactor factor of Missing At Random missing values in the experiment. Taken from a uniform distribution.
#' @param ProteinAbundanceErrorFactor error factor applied to the protein abundance. 
#' @param weibullShape shape of the Weibull distribution used to model the probabilities peptides being selected as NMAR value. 
#' @export
FSWE.simExperiment <- function(numReplicates, 
                               species, 
                               speciesRatios, 
                               stdDevRatios, 
                               numProteinsSpecies, 
                               peptidesPerProtein, 
                               proteinAbundanceDistribution,
                               stdDeviationFactorMS,
                               BackgroundSignalLevel,
                               NMARFactor,
                               MARFactor,
                               ProteinAbundanceErrorFactor,
                               weibullShape = 0.5){
    
    pepsProtein = numeric()
    proteinKeys = character()
    AbsIntProtein = numeric()
    
    experiment <- data.frame(peptideKeys = character(),
                                proteinKeys = character(),
                                speciesKeys = character())
    
    for(i in 1:(2*numReplicates)){
        varname = paste0("V", i)
        experiment[varname] = numeric()
    }
        
    
    for(i in 1:length(species)){
        #i = 1
        
        # Simulate the number of peptides per protein
        pepsProtein = rpois(numProteinsSpecies[i], peptidesPerProtein[i])
        pepsProtein[pepsProtein == 0] = 1  # Fix at the case no peptides assigned to a protein
        numPeps = sum(pepsProtein)
        
        # Assign to each peptide a protein key
        proteinKeys = getProteinKeys(pepsProtein, paste0("_",species[i]))
        peptideKeys = getPeptideKeys(pepsProtein, proteinKeys)
        speciesKeys = rep(species[i], numPeps)
        
        # Simulate the total intensity of each protein
        AbsIntProtein = rnorm(numProteinsSpecies[i], mean = proteinAbundanceDistribution[1], sd = proteinAbundanceDistribution[2])
        
        # Simulate the total intensity of each peptide of the protein -- we use a logarithmic distribution
        AbsPepInt = getPeptideIntensities(pepsProtein, AbsIntProtein)
        
        # minAbsPepInt = min(AbsPepInt)
        # maxAbsPepInt = max(AbsPepInt)
        # deltaAbsPepInt = maxAbsPepInt - minAbsPepInt 
        
        # Simulate peptide ratios according to species ratios
        logs <- rnorm( n = numPeps, mean = speciesRatios[i], sd = stdDevRatios[i])  # * (AbsPepInt / max(AbsPepInt)) )
        
        # Calculate A and B quantities and write them into a data frame
        AInt <- AbsPepInt / (1 + 2^logs)
        BInt <- AInt / (2^logs)
        # log2AB = log(AInt/BInt, 2)
        
        # Generate replicates in the experiment
        rnormfunct <- function(meanInt, sd, n){
            rnorm(n = n, mean = meanInt, sd = sd * meanInt) # This defines the instrument error (between replicates)
        }

        # Replicates for A and B        
        dfA = as.data.frame(t(sapply(AInt, rnormfunct, stdDeviationFactorMS, numReplicates)))
        dfB = as.data.frame(t(sapply(BInt, rnormfunct, stdDeviationFactorMS, numReplicates)))
        
        # add random values (normal distributed) to all replicates, regardless the intensity
        rndMean = 0
        rndSD = (2 ^ abs(proteinAbundanceDistribution[1] - proteinAbundanceDistribution[2])) * ProteinAbundanceErrorFactor 
        for(rep in 1:numReplicates){
            rndNoiseA = rnorm(length(AInt), mean = rndMean, sd = rndSD)
            rndNoiseB = rnorm(length(BInt), mean = rndMean, sd = rndSD)
            dfA[, rep] = dfA[, rep] + rndNoiseA
            dfB[, rep] = dfB[, rep] + rndNoiseB
            dfA[ dfA <= 0] = 0.01  # This is necessary to avoid negative probabilities at NMAR simulation.
            dfB[ dfB <= 0] = 0.01
            dfA[ is.na(dfA)] = 0.01
            dfB[ is.na(dfB)] = 0.01
        }
        
        df = cbind(peptideKeys, proteinKeys, speciesKeys, dfA, dfB)
        
        experiment = rbind(experiment, df)
    }
    
    names(experiment) = c("peptide", "protein", "species", paste0("quant_A", 1:numReplicates) , paste0("quant_B", 1:numReplicates) )
    experiment_bcp <- experiment
    # Entry missing values
    numericCols <- sapply(experiment, is.numeric)
    keyCols <- names(numericCols[numericCols == FALSE])
    numericCols <- names(numericCols[numericCols == TRUE])

    # Add text columns to classify missing values
    for(repl in numericCols){
        varname <- paste0("MissingValue.", repl)
        experiment <- experiment %>% mutate(tempname = "")
        colnames(experiment)[grep("tempname", colnames(experiment))] <- varname
    }
    
        
    # We entry missing not at random values (MNAR) to each of the replicates: a total of length(replicate) * NMARFactor
    # The probability a peptide (peak) is taken as missing value follows a weibull distribution scaled to the highest signal detected 
    # and shape given by a user parameter
    
    # MVP = 0.001
    expLength = nrow(experiment)
    numNAsPerReplicate = as.integer(expLength * NMARFactor)
    
    for(repl in numericCols){
        # repl = numericCols[1]
        maxSignalExp = log( max(experiment[, repl], na.rm=T) )
        minSignalExp = log( min( experiment[experiment[, repl] > 0, repl], na.rm = T  ) )
        currRepl = experiment[, repl]
        experiment_tmp <- experiment %>%
                        mutate(MVprob = dweibull(experiment[, repl], shape = weibullShape, scale = maxSignalExp)) %>%
                        # mutate(MVprob = 1 - (( log(currRepl) - minSignalExp)/(maxSignalExp - minSignalExp)) ) %>% 
                        rowwise() %>%
                        # mutate(MVprob = max(MVprob, MVP)) %>% 
                        ungroup()
        
        #scale probabilities 
        maxProb <- max(experiment_tmp$MVprob, na.rm = T)
        minProb <- min(experiment_tmp$MVprob, na.rm = T)
        experiment_tmp <- experiment_tmp %>% mutate(MVprob = (MVprob - minProb) / (maxProb - minProb) )
        
        naList <- sample.int(n = expLength, size = numNAsPerReplicate, replace = F, prob = experiment_tmp$MVprob)
        experiment[naList, repl] <- NA
        varname <- paste0("MissingValue.", repl)
        experiment[naList, varname] <- "NMAR"
    }

    
    
    # We entry missing at random values (MAR) to each of the replicates: a total of length(replicate) * MARFactor
    # The probability a peptide (peak) is taken as missing value is uniform for all peptides.
    
    expLength = nrow(experiment)
    numMARPerReplicate = as.integer(expLength * MARFactor)
    for(repl in numericCols){
        naList <- sample.int(n = expLength, size = numMARPerReplicate, replace = F)
        experiment[naList, repl] <- NA
        varname <- paste0("MissingValue.", repl)
        experiment[naList, varname] <- "MAR"
    }

    # Replace values under BackgroundSignalLevel by NA
    for(repl in numericCols){
        underBG <- experiment[,repl] < BackgroundSignalLevel & !is.na(experiment[,repl] )
        experiment[underBG, repl] <- NA  
        varname <- paste0("MissingValue.", repl)
        experiment[underBG, varname] <- "under BackgroundSignalLevel"   
    }

    experiment$charge = 2
    
    return(experiment) 
}



