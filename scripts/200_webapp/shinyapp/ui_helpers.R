appTitle_ <- "PhenomeXcan"
releaseDate_ <- "Release date: December 3, 2019."

alertMessage_ <- ""  # Write an alert message here

dataInfo_ <- "PhenomeXcan synthesizes 8.87 million variants from GWAS on 4,091 traits with transcriptome
regulation data from 49 tissues in GTEx v8 into an innovative, gene-based resource including 22,255 genes. See
documentation below for more details on how to use this resource."

appTitle <- function(){
  titlePanel(appTitle_) 
}

releaseDate <- function(){
  p(releaseDate_)
}

alertMessage <- function(){
  if(alertMessage_ != "") 
    return(p(strong(alertMessage_, style="color:red")))
  else
    return()
}

dataInfo <- function(){
    div(
        p(dataInfo_),
        p(strong('Please CITE if you are using this resource.'), 'See references below.')
    )
}

modelsInfo <- function(){
    h1 <- h3("Documentation")
    d1 <- div(
        p("Select the 'Result set' from 'PhenomeXcan' (4,091 traits and 22,255 gene associations) and 'PhenomeXcan_ClinVar'
        (integration with 5,104 ClinVar traits). A p-value displayed as 0 is one to small for available numerical resolution."),
    )
    h2 <- h4("PhenomeXcan")
    d2 <- div(
        p("Columns meaning: phenotype_source ('UK Biobank' refer to our 4,049 traits from this cohort, other values indicate
        different cohorts); rcp (Regional Colocalization Probability from fastENLOC); pvalue (p-value from S-MultiXcan),
        effect_direction (contains the direction of effect of both the most significant tissue [first + or - sign] and the consensus among those
        tissues with pvalue < 1e-4 [second +/- sign]); n_tissues (number of tissues available to S-MultiXcan when computing
        significance for a gene); n_indep (number of independent components of variations among n_tissues);
        best_ (single tissue S-PrediXcan stats)")
    )
    h3 <- h4("PhenomeXcan_ClinVar")
    d3 <- div(
        p("Columns meaning: zscore (this value is the average squared z-score from S-MultiXcan considering the genes
        associated to the ClinVar trait; z-scores are truncated to 40); gene_names (genes name and band reported for
        the ClinVar trait).")
    )
    
    dd <- div(h1, d1, h2, d2, h3, d3)
    dd
}

disclaimer <- function() {
  h <- h3("Disclaimer")
  t <- paste0('These data are provided "as is", and without any warranty, for scientific and educational use only.',
              ' If you use or download these data, you acknowledge that ',
              ' that the investigator is in compliance with all applicable state, local, and federal laws ',
              'or regulations and institutional policies regarding human subjects and genetics research; ',
              ' that secondary distribution of the data without registration by secondary parties is prohibited; ',
              ' and that the investigator will cite the appropriate publication in any communications ',
              ' or publications arising directly or indirectly from these data.',
              ' Further restrictions may be imposed by the source of the summary statistics data linked with each phenotype.')
  
  d <- div(h, p(t))
  d
}

cites <- function() {
  
  h <- h3('References:')
  p1 <-p(strong('PhenomeXcan: Mapping the genome to the phenome through the transcriptome'),
         'Milton Pividori, Padma S. Rajagopal, Alvaro Barbeira, Yanyu Liang, Owen Melia, Lisa Bastarache, YoSon Park, The GTEx Consortium, Xiaoquan Wen, Hae K. Im (2019)',
         a(href='https://doi.org/10.1101/833210', "Link to Preprint"))

  p2 <-p(strong('Widespread dose-dependent effects of RNA expression and splicing on complex diseases and traits'),
         'Alvaro N Barbeira, Rodrigo Bonazzola, Eric R Gamazon, Yanyu Liang, YoSon Park, Sarah Kim-Hellmuth, Gao Wang, Zhuoxun Jiang, Dan Zhou, Farhad Hormozdiari, Boxiang Liu, Abhiram Rao, Andrew R Hamel, Milton Pividori, François Aguet, GTEx GWAS Working Group, Lisa Bastarache, Daniel M Jordan, Marie Verbanck, Ron Do, GTEx Consortium, Matthew Stephens, Kristin Ardlie, Mark McCarthy, Stephen B Montgomery, Ayellet V Segrè, Christopher D. Brown, Tuuli Lappalainen, Xiaoquan Wen, Hae Kyung Im (2019)',
         a(href='https://doi.org/10.1101/814350', "Link to Preprint"))
  
  div(h,
      tags$ul(tags$li(p1), tags$li(p2)))
  
}
