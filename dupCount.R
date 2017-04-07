nmol=3e+3
g=1:nmol
gc=as.character(g)

nc=12;frs=c(5,3,2,1,0.5,0.25,0.1)
quartz()
for (f in 1:length(frs)) {
	fr=frs[f]
	nreads=round(fr*nmol,0)
	ufrac=c()
	for (c in 0:nc){
		gcs=rep(gc,2^c)
		if (length(gcs)<nreads) { 
			sa=gcs 
		} else { 
			sa=sample(gcs,nreads)
		}
		ufrac=append(ufrac,length(unique(sa))/nreads)
	}
	uu=data.frame(cbind(ufrac,"cycles"=0:nc))
	
	if (f==1) { 
		plot(ufrac~cycles,uu,ylim=c(min(ufrac),1),type="l",ylab="fraction of unique reads") 
	} else {
		lines(ufrac~cycles,uu,col=f) 
	}
}