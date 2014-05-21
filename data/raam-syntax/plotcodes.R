library("foreign")


data = read.octave("codesx.mat");
d = dist(data$codes);
#pdf("codesx.pdf")
plot(as.dendrogram(hclust(d, method='complete')), horiz=TRUE)
