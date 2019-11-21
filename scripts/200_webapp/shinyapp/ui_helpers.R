appTitle_ <- "PhenomeXcan"
releaseDate_ <- "Data Release: October 10, 2019."

alertMessage_ <- ""  # Write an alert message here

dataInfo_ <- "S-MultiXcan and fastENLOC results"

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
  p(dataInfo_)
}

modelsInfo <- function(){
  div(
    p("GTEx Prediction models and covariances were built with GTEx V8 on HapMap SNPs."),
    p("Models from MASHR effect sizes on European individuals"),
    p(strong("A p-value displayed as 0 is one to small for available numerical resolution")),
    p(strong("z-scores are truncated to 40"))
  )
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
