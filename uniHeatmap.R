# launch heatmapEveryWhichWay.R to use this
uniHeatmap=function(vsd,gene.names,metric,cutoff,metric2=NA,sort=NA,pdf=TRUE,pdf.height=15,pdf.width=12,named=TRUE,pattern=NA,heat.color=colorRampPalette(rev(c("chocolate1","#FEE090","grey10", "cyan3","cyan")))(100),...) {

	# vsd=vsd
	# gene.names=gg
	# metric=result$adjp.su
	# cutoff=1e-1
	# sort=order(surv$survival)  # overrides sorting of columns according to hierarchical clustering
	# pattern="TNF"
	# cex=0.9
	# pdf=FALSE  
	# metric2=NA
	# named=T
	# heat.color=colorRampPalette(rev(c("chocolate1","#FEE090","grey10", "cyan3","cyan")))(100)


	require(pheatmap)
	num.total=0
	select=(metric<=cutoff)
	if (!is.na(metric2)) {
		select=metric/(metric2<=cutoff)
	} 
	pdfname=paste(cutoff,"_heatmap.pdf",sep="")
	hmap=vsd[select,]
	hmap=hmap[!is.na(row.names(hmap)),]
#	length(hmap[,1])
	num.total=length(hmap[,1])
	
	# attaching gene names
	gnames=c();counts=0;num.match=0;num.named=0
	for(i in 1:length(hmap[,1])) {
		if (row.names(hmap)[i] %in% gene.names$V1) { 
			counts=counts+1
			gn=as.character(gene.names[gene.names$V1==row.names(hmap)[i],2])
			if (gn %in% gnames) {
				gn=paste(gn,counts,sep=".")
			}
			gnames=append(gnames,gn) 
		} else { 
			gnames=append(gnames,i)
		}
	} 
	row.names(hmap)=gnames
	if (named==TRUE) {
		#selecting only named genes
		hmap.n=hmap[grep('[a-z]',row.names(hmap)),]
		num.named=length(hmap.n[,1])
	}
	
	if (!is.na(pattern)){
		hmap.n=hmap[grep(pattern,gnames),]
		num.match=length(hmap.n[,1])
	}

	if (named==TRUE){
		pdfname=paste("named_",pdfname,sep="")
		if (pdf== TRUE) { pdf(pdfname,height=pdf.height,width=pdf.width) }
		if (!is.na(sort[1])) {
			hmap.n=hmap.n[,sort]
			pheatmap(hmap.n,scale="row",color=heat.color,border_color=NA,
				clustering_distance_rows="correlation",
				cluster_cols=F,...)
		} else {
			pheatmap(hmap.n,scale="row",color=heat.color,border_color=NA,
				 clustering_distance_rows="correlation",
				 clustering_distance_cols="correlation",
				 ...
				)
		}
		if (pdf==TRUE) { dev.off() }
	} else { 
		if (pdf== TRUE) { pdf(pdfname,height=pdf.height,width=pdf.width) }
		if (!is.na(sort)) {
			hmap=hmap[,order(sort)]
			pheatmap(hmap,scale="row",color=heat.color,border_color=NA,
				clustering_distance_rows="correlation",
				cluster_cols=F,...)
		} else {
			pheatmap(hmap,scale="row",color=heat.color,border_color=NA,
				 clustering_distance_rows="correlation",
				 clustering_distance_cols="correlation",
				 ...
				)
		}
		if (pdf== TRUE) { dev.off() }
	}
	return(c(num.total,num.named,num.match))
}

