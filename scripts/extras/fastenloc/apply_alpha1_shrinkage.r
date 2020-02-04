args <- commandArgs(trailingOnly = TRUE)
input_file = args[1]
output_file = args[2]

d = read.table(input_file, head=T)
attach(d)
d[1,]
var = alpha1_se^2
var_post = (1+1/var)^{-1}
alpha1_post = alpha1/(1+var)
summary(alpha1_post)
summary(var_post)
outd  = cbind(d, alpha1_post, sqrt(var_post))
dim(outd)
write(file=output_file, ncol=8, t(outd))
