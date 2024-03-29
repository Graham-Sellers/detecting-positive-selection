
# ----------------------------------------------------------------------------------------------------------------

# Manhattan plotter:

# ----------------------------------------------------------------------------------------------------------------

man.plot = function(df, chroms, threshold, highlight, point.cex, point.cols, line.col) {
  
  # deal with missing inputs and set defaults:
  if(missing(chroms)){
    df = df
  } else {
      df = df[df$chrom %in% chroms,]}
  
  if(missing(threshold)) {
    significance = -log10(5e-8)
  } else {
    significance = threshold}
  
  if(missing(point.cols)) {
    point.cols = rep(c('grey75', 'grey50'), length(unique(df$chrom)))[1:length(unique(df$chrom))]
    names(point.cols) = unique(df$chrom)
  } else {
    point.cols = rep(point.cols, length(unique(df$chrom)))[1:length(unique(df$chrom))]
      names(point.cols) = unique(df$chrom)}
  
  if(missing(line.col)) {
    line.col = 'black'
  } else {
    line.col = line.col[1]}

  if(missing(highlight)){
    cols = 'red'
  } else {
    cols = highlight}

  if(missing(point.cex)){
    point.cex = 0.4
  } else {
    point.cex = point.cex}
  
  # transform the data:
  full_df = as.data.frame(df[FALSE,])
  full_df$chrom = as.character(full_df$chrom)
  
  for(chromosome in unique(df$chrom)){
    chromosome_df = df[df$chrom == chromosome,]
    chromosome_df = chromosome_df[order(chromosome_df$bp),]
    chromosome_df$relative_bp = c(1, diff(chromosome_df$bp))
    chromosome_df$transformed_pvalue = -log10(chromosome_df$pvalue)
    full_df = rbind(full_df, chromosome_df)
  }
  
  full_df = full_df[,c('chrom', 'bp', 'relative_bp', 'transformed_pvalue', 'gene')]
  df = full_df
  
  # gap between chromosomes:
  space = max(cumsum(df$relative_bp))/length(unique(df$chrom)) * 0.25
  
  # set the colours for the plot:
  df$cols =  point.cols[as.character(df$chrom)]

  # set plot points for each SNP:
  for(c in unique(df$chrom)){
    df[df$chrom == c,][1,]$relative_bp = space}
  
  df$plot_points = cumsum(df$relative_bp)
  
  # SNPs of interest:
  genes_df = df[df$transformed_pvalue >= significance,]
  genes_df = genes_df[!grepl('LOC', genes_df$gene),]
  genes_df = genes_df[!genes_df$gene == '',]
  genes_df = genes_df[!colnames(genes_df) %in% 'cols']
  
  genes_top = genes_df[FALSE,]
  
  for(gene in unique(genes_df$gene)){
    hip = genes_df[genes_df$gene == gene,]
    gene_top = hip[hip$transformed_pvalue == max(hip$transformed_pvalue),]
    genes_top = rbind(genes_top, gene_top)
  }
  genes_df = genes_top
  
  # set x axis label points for chromosomes:
  chrom_labs = c()
  for(c in unique(df$chrom)){
    daf = df[df$chrom == c,]
    chrom_labs = c(chrom_labs, mean(range(daf$plot_points)))}
  
  # set the upper limit for y:
  y_max = max(df$transformed_pvalue) * 1.2
  x_max = max(cumsum(df$relative_bp))
  
  # make the basic plot with no axes:
  plot(1, 1,
       ylim = c(0, y_max), xlim = c(0, x_max),
       cex = 0, axes = F,
       col = df$cols,
       ylab = NA,
       xlab = NA)
  
  #add the points:
  points(df$plot_points, df$transformed_pvalue,
    col = df$cols,
    pch = 16, cex = point.cex)
  
  # add significance threshold dotted line
  segments(0, significance, max(df$plot_points) + space, significance, lty = 5, lwd = 2, col = line.col)

  # add higlighted SNPs of interest:
  points(df[df$transformed_pvalue >= significance,]$plot_points,
         df[df$transformed_pvalue >= significance,]$transformed_pvalue,
         col = cols,
         pch = 16, cex = point.cex)
  
  # add axes:
  axis(1, at = chrom_labs, labels = unique(df$chrom), lwd = 0, lwd.ticks = 1.5,
       las = 1, pos = -1, tck = -0.01, cex.axis = 0.6)
  axis(2, at = c(seq(0, y_max, 5)), labels = c(seq(0, y_max, 5)), lwd = 0, lwd.tick = 1.5,
       las = 1, pos = 0, tck = -0.01, cex.axis = 0.6, xpd = T)
  segments(0, -1, max(df$plot_points) + space, -1, xpd = T)
  segments(0, -1, 0, y_max, xpd = T)
  
  mtext(expression(paste('-log10(', italic('P'), ')')), side = 2, cex = 1.2)
  
  # label significant genes:
  top_genes = genes_df[FALSE,]
  
  for(chromosome in unique(genes_df$chrom)){
    hip = genes_df[genes_df$chrom == chromosome,]
    top_gene = hip[hip$transformed_pvalue == max(hip$transformed_pvalue),]
    top_genes = rbind(top_genes, top_gene)
  }

  text(top_genes$plot_points, top_genes$transformed_pvalue, top_genes$gene, pos=4, cex = 0.6, xpd = T)
  
  return(genes_df)
  
}
