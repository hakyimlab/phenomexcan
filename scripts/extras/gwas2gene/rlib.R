read_gz_and_merge = function(prefix, suffix, tissues, cmd = 'zcat < ', filter = NULL, filter_col = 'variant_id', ...) {
  if(tools::file_ext(suffix) == 'gz') {
    cmd = 'zcat < '
  }
  o = data.frame()
  for(i in tissues) {
    filename = paste0(prefix, i, suffix)
    if(!file.exists(filename)) {
      message(filename)
      next
    }
    temp = fread(cmd = paste0(cmd, filename), header = T, fill = TRUE, ...)
    if(nrow(temp) == 0) {
      next
    }
    if(!is.null(filter)) {
      temp = temp[temp[, filter_col] %in% filter, ]
    }
    if(nrow(temp) == 0) {
      next
    }
    temp$tissue = i
    o = rbind(o, temp)
  }
  o
}

post_filter_gwas_by_causal_gene_position = function(gwas_lead, causal_gene_chr, causal_gene_tss, dist_to_tss_cutoff = 1e6) {
  loci_pos = gwas_lead[, c('chr', 'pos', 'lead_var')]
  gene_map = data.frame(chr = causal_gene_chr, tss = causal_gene_tss)
  gwas_loci_selected = c()
  for(i in 1 : nrow(loci_pos)) {
    sub = gene_map %>% filter(chr == loci_pos$chr[i])
    sub = sub %>% mutate(dist_to_tss = abs(tss - loci_pos$pos[i]))
    if(nrow(sub) == 0) {
      next
    }
    if(sum(sub$dist_to_tss <= dist_to_tss_cutoff) == 0) {
      next
    }
    gwas_loci_selected = c(gwas_loci_selected, as.character(loci_pos$lead_var[i]))
  }
  gwas_lead %>% filter(lead_var %in% gwas_loci_selected)
}

post_filter_gwas_by_causal_gene_position_by_gene_body = function(gwas_lead, causal_gene_chr, causal_gene_start, causal_gene_end, dist_to_gene_body_cutoff = 1e6) {
  loci_pos = gwas_lead[, c('chr', 'pos', 'lead_var')]
  gene_map = data.frame(chr = causal_gene_chr, start = causal_gene_start, end = causal_gene_end)
  gwas_loci_selected = c()
  for(i in 1 : nrow(loci_pos)) {
    sub = gene_map %>% filter(chr == loci_pos$chr[i])
    sub = sub %>% mutate(dist_to_gene_body = get_distance(start, end, loci_pos$pos[i]))
    if(nrow(sub) == 0) {
      next
    }
    if(sum(sub$dist_to_gene_body <= dist_to_gene_body_cutoff) == 0) {
      next
    }
    gwas_loci_selected = c(gwas_loci_selected, as.character(loci_pos$lead_var[i]))
  }
  gwas_lead %>% filter(lead_var %in% gwas_loci_selected)
}

get_smr_by_heidi_cutoff = function(smr, heidi, cutoff = 1 / exp(1)) {
  if(sum(!is.na(heidi) & heidi > cutoff) == 0) {
    return(NA)
  } else {
    smr = smr[!is.na(heidi) & heidi > cutoff]
    return(min(smr, na.rm = T))
  }
}

assign_gene_to_variant = function(df_lead_var, gene, chr, start, end, strand) {
  o = data.frame()
  df_gene = data.frame(gene = gene, chr = chr, start = start, end = end, strand = strand, stringsAsFactors = F)
  df_gene = df_gene %>% mutate(tss = get_tss(start, end, strand))
  for(i in 1 : nrow(df_lead_var)) {
    df_gene_sub = df_gene %>% filter(chr == df_lead_var$chr[i]) %>% mutate(lead_var = df_lead_var$lead_var[i])
    df_gene_sub = df_gene_sub %>% mutate(dist_to_gene_body = get_distance(start, end, df_lead_var$pos[i]), dist_to_tss = abs(tss - df_lead_var$pos[i]))
    o = rbind(o, df_gene_sub)
  }
  o
}

iterative_strategy = function(score_list, score_info, method_idx_in_order, gwas_var_with_genes, use_nearest_gene = T, debug = F) {
  df_gene_candidates = score_list[[method_idx_in_order[1]]]
  df_gene_candidates$score = 0
  message('---')
  message(length(unique(paste(gwas_var_with_genes$lead_var, gwas_var_with_genes$trait))), ' at the beginning')
  if(debug == F) {
    for(i in method_idx_in_order) {
      temp = left_join(gwas_var_with_genes, score_list[[i]], by = c('gene_trait_pair', 'gene'))
      if(score_info$method[i] == 'gt') {
        temp_target = temp %>% filter(score != score_info$fill.na[i], score > score_info$per_locus_cutoff[i]) %>% group_by(lead_var, trait)
      } else if (score_info$method[i] == 'lt'){
        temp_target = temp %>% filter(score != score_info$fill.na[i], score < score_info$per_locus_cutoff[i]) %>% group_by(lead_var, trait)
      }

      if(score_info$method[i] == 'gt') {
        temp_target = temp_target %>% summarize(score = max(score, na.rm = T)) %>% ungroup()
      } else if (score_info$method[i] == 'lt'){
        temp_target = temp_target %>% summarize(score = min(score, na.rm = T)) %>% ungroup()
      }
      temp = left_join(temp_target, temp, by = c('trait', 'lead_var', 'score')) %>% mutate(gene_trait_pair = paste(gene, '--', trait))
      gwas_var_with_genes = gwas_var_with_genes %>% filter(!paste(lead_var, trait) %in% paste(temp$lead_var, temp$trait))
      df_gene_candidates$score[df_gene_candidates$gene_trait_pair %in% temp$gene_trait_pair] = 1
      message(length(unique(paste(gwas_var_with_genes$lead_var, gwas_var_with_genes$trait))), ' left')
    }
    message('---')
  }
  if((use_nearest_gene == T & nrow(gwas_var_with_genes) > 0) | debug == T) {
    temp = gwas_var_with_genes %>% group_by(trait, lead_var) %>% summarize(dist_to_gene_body = min(dist_to_gene_body, na.rm = NA)) %>% ungroup()
    temp = left_join(temp, gwas_var_with_genes, by = c('trait', 'lead_var', 'dist_to_gene_body')) %>% mutate(gene_trait_pair = paste(gene, '--', trait))
    df_gene_candidates$score[df_gene_candidates$gene_trait_pair %in% temp$gene_trait_pair] = 1
  }
  df_gene_candidates
}

do_transformation = function(score, transform) {
  if(is.na(transform) | transform == 'none') {
    score
  } else if(transform == '-log10') {
    o = -log10(score)
    o[is.infinite(o)] = max(o[!is.infinite(o)]) + 1
    o
  } else if(transform == '-') {
    - score
  }
}

perform_logistic_test = function(result, score_info, random_result_raw, causal_gene_trait_pairs) {
  df_score = random_result_raw %>% select(lead_var, gene, trait, gene_trait_pair)
  for(i in 1 : length(score_info$name)) {
    df_score = left_join(df_score, result[[i]] %>% select(gene_trait_pair, gene, score) %>% mutate(score = do_transformation(score, score_info$transformation[i])), by = c('gene_trait_pair', 'gene'))
    colnames(df_score)[which(colnames(df_score) == 'score')] = score_info$tag[i]
  }
  df_rank = random_result_raw %>% select(lead_var, gene, trait)
  for(i in 1 : length(score_info$name)) {
    df_sub = df_score[, c('lead_var', 'gene', 'trait', score_info$tag[i])]
    colnames(df_sub)[4] = 'temp'
    df_sub = df_sub %>% group_by(lead_var, trait) %>% mutate(rank = rank(-temp) - 1) %>% ungroup() %>% select(-temp)
    colnames(df_sub)[4] = score_info$tag[i]
    df_rank = left_join(df_rank, df_sub, by = c('lead_var', 'gene', 'trait'))
    # colnames(df_rank)[which(colnames(df_rank) == 'rank')] = score_info$tag[i]
  }
  df_percentage = random_result_raw %>% select(lead_var, gene, trait)
  for(i in 1 : length(score_info$name)) {
    df_sub = df_score[, c('lead_var', 'gene', 'trait', score_info$tag[i])]
    colnames(df_sub)[4] = 'temp'
    df_sub = df_sub %>% group_by(lead_var, trait) %>% mutate(percentage = (rank(-temp) - 1) / n()) %>% ungroup() %>% select(-temp)
    colnames(df_sub)[4] = score_info$tag[i]
    df_percentage = left_join(df_percentage, df_sub, by = c('lead_var', 'gene', 'trait'))
    # print(colnames(df_sub))
    # colnames(df_rank)[which(colnames(df_percentage) == 'percentage')] = score_info$tag[i]
  }
  df_rank_proximity = random_result_raw %>% group_by(lead_var, trait) %>% mutate(rank_proximity = rank(dist_to_gene_body) - 1) %>% ungroup()
  df_percentage_proximity = random_result_raw %>% group_by(lead_var, trait) %>% mutate(percentage_proximity = (rank(dist_to_gene_body) - 1) / n()) %>% ungroup()
  y_is_omim = random_result_raw$gene_trait_pair %in% causal_gene_trait_pairs

  # rank based
  # glm(is_omim ~ proximity + other-scores, family = 'binomial')
  df = data.frame(is_omim = y_is_omim, rank_proximity = df_rank_proximity$rank_proximity)
  df = cbind(df, df_score[, score_info$tag])
  formula = as.formula(paste('is_omim', '~', 'rank_proximity', '+', paste0(score_info$tag, collapse = ' + ')))
  mod1 = glm(formula, family = 'binomial', data = df)

  # glm(is_omim ~ proximity + other-scores, family = 'binomial')
  df = data.frame(is_omim = y_is_omim, rank_proximity = df_rank_proximity$rank_proximity)
  df = cbind(df, df_rank[, score_info$tag])
  formula = as.formula(paste('is_omim', '~', 'rank_proximity', '+', paste0(score_info$tag, collapse = ' + ')))
  mod2 = glm(formula, family = 'binomial', data = df)

  # percentage based
  # glm(is_omim ~ proximity + other-scores, family = 'binomial')
  df = data.frame(is_omim = y_is_omim, percentage_proximity = df_percentage_proximity$percentage_proximity)
  df = cbind(df, df_score[, score_info$tag])
  formula = as.formula(paste('is_omim', '~', 'percentage_proximity', '+', paste0(score_info$tag, collapse = ' + ')))
  mod3 = glm(formula, family = 'binomial', data = df)

  # glm(is_omim ~ proximity + other-scores, family = 'binomial')
  df = data.frame(is_omim = y_is_omim, percentage_proximity = df_percentage_proximity$percentage_proximity)
  df = cbind(df, df_percentage[, score_info$tag])
  formula = as.formula(paste('is_omim', '~', 'percentage_proximity', '+', paste0(score_info$tag, collapse = ' + ')))
  mod4 = glm(formula, family = 'binomial', data = df)
  return(list(rank_based = list(with_score = mod1, without_score = mod2), percentage_based = list(with_score = mod3, without_score = mod4)))
}

check_two_region_overlap = function(region_s, region_e, gene_s, gene_e) {
  # case1
  #   region -----|-------|------
  #   gene          |---------|
  case1 = gene_s < region_e & gene_s >= region_s
  # case2
  #   region -----|-------|------
  #   gene    |---------|
  case2 = gene_e < region_e & gene_e >= region_s
  # case3
  #   region -----|-------|------
  #   gene    |---------------|
  case3 = gene_e >= region_e & gene_s <= region_s
  case1 | case2 | case3
}

post_filter_region_by_causal_gene_position = function(gwas_lead, causal_gene_chr, causal_gene_start, causal_gene_end) {
  region_pos = gwas_lead[, c('chr', 'region_start', 'region_end', 'cs_idx')]
  gene_map = data.frame(chr = causal_gene_chr, start = causal_gene_start, end = causal_gene_end)
  region_selected = c()
  for(i in 1 : nrow(region_pos)) {
    sub = gene_map %>% filter(chr == region_pos$chr[i])
    sub = sub %>% mutate(if_in_region = check_two_region_overlap(region_pos$region_start[i], region_pos$region_end[i], start, end))
    if(nrow(sub) == 0) {
      next
    }
    if(sum(sub$if_in_region) == 0) {
      next
    }
    region_selected = c(region_selected, as.character(region_pos$cs_idx[i]))
  }
  gwas_lead %>% filter(cs_idx %in% region_selected)
}

assign_gene_to_variant_by_region = function(df_lead_var, gene, chr, start, end, strand) {
  o = data.frame()
  df_gene = data.frame(gene = gene, chr = chr, start = start, end = end, strand = strand, stringsAsFactors = F)
  df_gene = df_gene %>% mutate(tss = get_tss(start, end, strand))
  for(i in 1 : nrow(df_lead_var)) {
    df_gene_sub = df_gene %>% filter(chr == df_lead_var$chr[i]) %>% mutate(lead_var = df_lead_var$lead_var[i], cs_idx = df_lead_var$cs_idx[i])
    df_gene_sub =  df_gene_sub %>% filter(check_two_region_overlap(df_lead_var$region_start[i], df_lead_var$region_end[i], start, end))
    df_gene_sub = df_gene_sub %>% mutate(dist_to_gene_body = get_distance(start, end, df_lead_var$pos[i]), dist_to_tss = abs(tss - df_lead_var$pos[i]))
    o = rbind(o, df_gene_sub)
  }
  o
}

random_guess = function(score_list, gwas_var_with_genes) {
  df_gene_candidates = score_list
  df_gene_candidates$score = 0
  gwas_var_with_genes = gwas_var_with_genes %>% group_by(lead_var, trait) %>% summarize(gene_trait_pair = gene_trait_pair[sample(1 : n(), size = 1)]) %>% ungroup()
  df_gene_candidates$score[df_gene_candidates$gene_trait_pair %in% gwas_var_with_genes$gene_trait_pair] = 1
  df_gene_candidates
}
compute_power_and_fdr = function(discovered_genes, true_genes) {
  true_positive_genes = true_genes[ true_genes %in% discovered_genes ]
  nTP = length(true_positive_genes)
  nT = length(true_genes)
  nP = length(discovered_genes)
  if(nP == 0) {
    nP = 1
  }
  data.frame(power = nTP / nT, fdr = 1 - nTP / nP, nTP = nTP, nP = nP, nT = nT)
}

compute_tpr_and_fpr = function(tested_genes, discovered_genes, true_genes) {
  true_positive_genes = true_genes[ true_genes %in% discovered_genes ]
  nTP = length(true_positive_genes)
  nT = length(true_genes)

  all_genes = union(tested_genes, true_genes)
  not_true_genes = all_genes[!all_genes %in% true_genes]
  nNT = length(not_true_genes)
  false_positive_genes = not_true_genes[ not_true_genes %in% discovered_genes ]
  nFP = length(false_positive_genes)
  if(nNT == 0) {
    nNT = 1
  }
  data.frame(tpr = nTP / nT, fpr = nFP / nNT, nTP = nTP, nT = nT, nFP = nFP, nNT = nNT)
}

get_distance = function(s, e, p) {
  o = cbind(abs(s - p), abs(e - p))
  o = apply(o, 1, min)
  o[p <= e & p >= s] = 0
  o
}

get_nearest_gene = function(var_id, gene_name, gene_chr, gene_start, gene_end) {
  pos = get_chr_pos_sep(var_id)
  o = data.frame()
  for(i in 1 : length(var_id)) {
    g = data.frame(gene = gene_name, chr = gene_chr, start = gene_start, end = gene_end)
    g = g %>% filter(chr == pos$chr[i]) %>% mutate(dist = get_distance(start, end, pos$pos[i]))
    dist_min = min(g$dist)
    g = g %>% filter(dist == dist_min)
    g$var = var_id[i]
    o = rbind(o, g)
  }
  o
}

is_sig = function(score, threshold, method, tie = T) {
  if(method == 'gt') {
    if(tie == T) {
      return(score >= threshold)
    } else {
      return(score > threshold)
    }
  } else if(method == 'lt') {
    if(tie == T) {
      return(score <= threshold)
    } else {
      return(score < threshold)
    }
  } else {
    return(NA)
  }
}


gen_fdr_power_curve = function(true_genes, gene, score, method = 'gt', cutoff = NULL) {
  if(is.null(cutoff)) {
    true_cutoffs = sort(unique(score[gene %in% true_genes]))
  } else {
    true_cutoffs = cutoff
  }
  if(method == 'lt') {
    true_cutoffs = sort(true_cutoffs, decreasing = T)
  }
  df_curve = data.frame()
  for(i in true_cutoffs) {
    positive_genes = gene[is_sig(score, i, method)]
    sub = compute_power_and_fdr(positive_genes, true_genes)
    sub$cutoff = i
    sub$include_tie = T
    df_curve = rbind(df_curve, sub)
    positive_genes = gene[is_sig(score, i, method, tie = F)]
    sub = compute_power_and_fdr(positive_genes, true_genes)
    sub$cutoff = i
    sub$include_tie = F
    df_curve = rbind(df_curve, sub)
  }
  df_curve = df_curve %>% mutate(precision = 1 - fdr, recall = power)
  df_curve$precision[df_curve$nP == 0] = 1
  if(is.null(cutoff)) {
    df_curve = df_curve[-nrow(df_curve), ]
  }
  df_curve
}

gen_fdr_power_curve_fixed_joint = function(true_genes, gene, score_vary, score_fix, cutoff_fix, method_vary = 'gt', method_fix = 'gt', by = 1, cutoff = NULL) {
  if(is.null(cutoff)) {
    true_cutoffs = sort(unique(score_vary[gene %in% true_genes]))
  } else {
    true_cutoffs = cutoff
  }
  if(method_vary == 'lt') {
    true_cutoffs = sort(true_cutoffs, decreasing = T)
  }
  df_curve = data.frame()
  for(i in true_cutoffs) {
    positive_genes = gene[is_sig(score_vary, i, method_vary) & is_sig(score_fix, cutoff_fix, method_fix, tie = F)]
    sub = compute_power_and_fdr(positive_genes, true_genes)
    sub$cutoff = i
    sub$include_tie = T
    df_curve = rbind(df_curve, sub)
    positive_genes = gene[is_sig(score_vary, i, method_vary, tie = F) & is_sig(score_fix, cutoff_fix, method_fix, tie = F)]
    sub = compute_power_and_fdr(positive_genes, true_genes)
    sub$cutoff = i
    sub$include_tie = F
    df_curve = rbind(df_curve, sub)
  }
  df_curve = df_curve %>% mutate(precision = 1 - fdr, recall = power)
  df_curve$precision[df_curve$nP == 0] = 1
  df_curve[-nrow(df_curve), ]
}

gen_fdr_power_curve_joint = function(true_genes, gene, score1, score2, method1 = 'gt', method2 = 'gt', by1 = 10, by2 = 10, cutoff1 = NULL, cutoff2 = NULL) {
  if(is.null(cutoff1)) {
    true_cutoffs1 = sort(unique(score1[gene %in% true_genes]))
    true_cutoffs_sub1 = true_cutoffs1[seq(1, length(true_cutoffs1), by = by1)]
  } else {
    true_cutoffs_sub1 = cutoff1
  }
  if(is.null(cutoff2)) {
    true_cutoffs2 = sort(unique(score2[gene %in% true_genes]))
    true_cutoffs_sub2 = true_cutoffs2[seq(1, length(true_cutoffs2), by = by2)]
  } else {
    true_cutoffs_sub2 = cutoff2
  }
  df_curve_join = data.frame()
  for(i in true_cutoffs_sub1) {
    for(j in true_cutoffs_sub2) {
      positive_genes = gene[is_sig(score1, i, method1) & is_sig(score2, j, method2)]
      sub = compute_power_and_fdr(positive_genes, true_genes)
      sub$cutoff1 = i
      sub$cutoff2 = j
      df_curve_join = rbind(df_curve_join, sub)
    }
  }
  df_curve_join %>% mutate(precision = 1 - fdr, recall = power)
}

gen_roc_curve = function(true_genes, gene, score, method = 'gt', cutoff = NULL) {
  if(is.null(cutoff)) {
    true_cutoffs = sort(unique(score[gene %in% true_genes]))
  } else {
    true_cutoffs = cutoff
  }
  if(method == 'lt') {
    true_cutoffs = sort(true_cutoffs, decreasing = T)
  }
  df_curve = data.frame()
  for(i in true_cutoffs) {
    positive_genes = gene[is_sig(score, i, method)]
    sub = compute_tpr_and_fpr(gene, positive_genes, true_genes)
    sub$cutoff = i
    sub$include_tie = T
    df_curve = rbind(df_curve, sub)
    positive_genes = gene[is_sig(score, i, method, tie = F)]
    sub = compute_tpr_and_fpr(gene, positive_genes, true_genes)
    sub$cutoff = i
    sub$include_tie = F
    df_curve = rbind(df_curve, sub)
  }
  # sub = compute_tpr_and_fpr(gene, union(gene, true_genes), true_genes)
  # sub$cutoff = NA
  # df_curve = rbind(df_curve, sub)
  if(is.null(cutoff)) {
    df_curve = df_curve[-1, ]
  }
  df_curve
}

# DEPRECATED
# Need to fix how to handle tie if want to use it
# gen_roc_curve_joint = function(true_genes, gene, score1, score2, method1 = 'gt', method2 = 'gt', by1 = 10, by2 = 10, cutoff1 = NULL, cutoff2 = NULL) {
#   if(is.null(cutoff1)) {
#     true_cutoffs1 = sort(unique(score1[gene %in% true_genes]))
#     true_cutoffs_sub1 = true_cutoffs1[seq(1, length(true_cutoffs1), by = by1)]
#   } else {
#     true_cutoffs_sub1 = cutoff1
#   }
#   if(is.null(cutoff2)) {
#     true_cutoffs2 = sort(unique(score2[gene %in% true_genes]))
#     true_cutoffs_sub2 = true_cutoffs2[seq(1, length(true_cutoffs2), by = by2)]
#   } else {
#     true_cutoffs_sub2 = cutoff2
#   }
#   df_curve_join = data.frame()
#   for(i in true_cutoffs_sub1) {
#     for(j in true_cutoffs_sub2) {
#       positive_genes = gene[is_sig(score1, i, method1) & is_sig(score2, j, method2)]
#       sub = compute_tpr_and_fpr(gene, positive_genes, true_genes)
#       sub$cutoff1 = i
#       sub$cutoff2 = j
#       df_curve_join = rbind(df_curve_join, sub)
#     }
#   }
#   df_curve_join
# }
# END

process_susie_output = function(cs, var) {
  dcs = fread(paste0('zcat < ', cs), header = T)
  dvar = fread(paste0('zcat < ', var, '| grep -v \'\\-1\' |awk -v OFS="\t" \'{split($4,a,"_"); print $0,a[1],a[2]}\''), header = T)
  ncol = ncol(dvar)
  colnames(dvar)[(ncol - 1):ncol] = c('chr', 'pos')
  # pos = get_chr_pos_sep(dvar$variant)
  # dvar$chr = pos$chr
  # dvar$pos = pos$pos
  o = data.frame()
  for(i in 1 : nrow(dcs)) {
    sub = dvar %>% filter(cs == dcs$cs[i]) %>% filter(pos <= dcs$pos_max[i] & pos >= dcs$pos_min[i] & chr == dcs$chr[i]) %>% mutate(cs_idx = i)
    o = rbind(o, sub)
  }
  o
}
match_credible_set = function(cs1, cs2, pip1, pip2) {
  pip1_select = pip1 %>% filter(cluster_id %in% cs1$cluster)
  pip2_select = pip2 %>% filter(cluster_id %in% cs2$cluster)
  overlapped_var = intersect(pip1_select$variant_id, pip2_select$variant_id)
  cs1_overlap = pip1_select %>% filter(variant_id %in% overlapped_var) %>% select(cluster_id, variant_id)
  cs2_overlap = pip2_select %>% filter(variant_id %in% overlapped_var) %>% select(cluster_id, variant_id)
  cs_map = unique(inner_join(cs1_overlap, cs2_overlap, by = 'variant_id', suffix = c('_1', '_2')) %>% select(cluster_id_1, cluster_id_2))
}

rare_var_to_gtexid = function(x) {
  e = strsplit(x, ':')
  f = lapply(e, function(x) {
    paste(c(x, 'b38'), collapse = '_')
  })
  unlist(f)
}

get_chr_pos = function(x) {
  x = as.character(x)
  e = strsplit(x, '_')
  f = lapply(e, function(x) {
    paste(c(x[1:2]), collapse = '_')
  })
  unlist(f)
}

get_chr_pos_sep = function(x) {
  x = as.character(x)
  e = strsplit(x, '_')
  f = lapply(e, function(x) {
    x[1]
  })
  g = lapply(e, function(x) {
    as.numeric(x[2])
  })
  o = data.frame(chr = unlist(f), pos = unlist(g))
  o$chr = as.character(o$chr)
  o
}

get_tss = function(start, end, strand) {
  strand = as.character(strand)
  o = start
  o[strand == '-'] = end[strand == '-']
  o
}

parse_annotation_ng2017 = function(annot) {
  annot = as.character(annot)
  e = strsplit(annot, ':')
  data.frame(gene_name = unlist(lapply(e, function(x) { x[1] })), annotation = unlist(lapply(e, function(x) { x[2] })))
}

parse_finnish_vartest = function(gene_str, trait_str) {
  idx = 1 : length(gene_str)
  o = data.frame()
  for(i in idx) {
    gene_i = strsplit(gene_str[i], ';')[[1]]
    trait_i = strsplit(trait_str[i], ';')[[1]]
    ng = length(gene_i)
    nt = length(trait_i)
    gene_idx = rep(1 : ng, each = nt)
    trait_idx = rep(1 : nt, ng)
    ogene = gene_i[gene_idx]
    otrait = trait_i[trait_idx]
    o = rbind(o, data.frame(gene = ogene, trait = otrait, idx = i))
  }
  o
}
