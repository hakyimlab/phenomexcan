extract_by_keyword = function(traits, kw, rm = NA) {
  idx = 1 : length(traits)
  pool = tolower(traits)
  matched = my_match_keyword(pool, kw) 
  if(!is.na(rm)) {
    removed = my_match_keyword(pool, rm)
  } else {
    removed = rep(F, length(traits))
  }
  idx[matched & (! removed)]
}

my_match_keyword = function(str, pattern) {
  before_after = list(
    pattern_as_first = c('^', ''),
    pattern_as_middle = c(' ', ' '), 
    pattern_as_last = c('', '$'),
    pattern_in_bracket = c('\\(', '\\)')
  )
  o = rep(F, length(str))
  for(i in names(before_after)) {
    before = before_after[[i]][1]
    after = before_after[[i]][2]
    this_pattern = paste0(before, pattern, after)
    hitted = !is.na(stringr::str_match(str, this_pattern))
    o = o | hitted
  }
  o
}

myfunc_mim2gene = function(mim_str, db_mim, db_gene_id) {
  db = data.frame(mim = as.character(db_mim), gene = db_gene_id, stringsAsFactors = F)
  o = c()
  for(i in mim_str) {
    temp = strsplit(as.character(mim_str), ';')[[1]]
    query = data.frame(mim = temp, stringsAsFactors = F)
    db_sub = inner_join(query, db, by = 'mim')
    gene_str = paste0(db_sub$gene, collapse = ';')
    o = c(o, gene_str)
  }
  o
}

myfunc_pheno_mim_to_any_mim = function(query_pheno_mim, db_pheno_mim_decription, db_gene_mim) {
  idx = my_match_keyword(db_pheno_mim_decription, query_pheno_mim)
  mim_gene_extracted = db_gene_mim[idx]
  mim_gene_extracted
}
