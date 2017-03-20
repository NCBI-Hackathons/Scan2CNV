#' return the median intensity of an idat file
#' @export
#' @title return the median intensity of an idat file
#' @name medianIntensIdat
#' @param idatBase full path to idat file without "_Red.idat" or "_Grn.idat"
#' @return a vector
#' @author Eric Karlins
medianIntensIdat <- function(idatBase){
        require(illuminaio)
	red <- readIDAT(paste(idatBase, "_Red.idat", sep = ""))
	green <- readIDAT(paste(idatBase, "_Grn.idat", sep = ""))
	Intens <- red$Quants[,1] + green$Quants[,1]
	median(Intens)
}
