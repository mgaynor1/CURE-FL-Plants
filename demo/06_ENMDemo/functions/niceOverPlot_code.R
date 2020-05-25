 
# niceOverPlot function is based of this two posts:
# http://stackoverflow.com/questions/20474465/using-different-scales-as-fill-based-on-factor
# http://rforpublichealth.blogspot.com.es/2014/02/ggplot2-cheatsheet-for-visualizing.html

# niceOverPlot function can be used in several ways. See example above to learn the basic use. Different 
# approaches will be posted as soon as possible.

niceOverPlot<-function(sc1, sc2=NULL,n1=NULL,n2=NULL, plot.axis = TRUE, bw = NULL, b=NULL, a1cont=NULL, a2cont=NULL){
  
  # prepare the data, depending of the type of input ("pca"/"dudi" object or raw scores)
  if (is.null(sc2))
  {sc_1<-sc1
  sc_2<-sc1
  sc1<- sc_1$li[1:n1,]
  sc2<- sc_1$li[(n1+1):((n1+1)+n2),]
  }
  
  if (class(sc1)==c("pca","dudi") && class(sc2)==c("pca","dudi")) 
  {sc_1<-sc1
  sc_2<-sc1
  sc1<- sc1$li
  sc2<- sc2$li}
  
  # recognize both species
  scores<-rbind(sc1,sc2)
  g<-c(rep(0,nrow(sc1)),rep(1,nrow(sc2)))
  df<-data.frame(cbind(scores$Axis1,scores$Axis2,g))
  names(df)<-c("x","y","g")
  df$g<-as.factor(df$g)
  
  # establish an empty plot to be placed at top-right corner (X)
  empty <- ggplot()+geom_point(aes(1,1), colour="white") +
    theme(                              
      plot.background = element_blank(), 
      panel.grid.major = element_blank(), 
      panel.grid.minor = element_blank(), 
      panel.border = element_blank(), 
      panel.background = element_blank(),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank()
    )
  # sp1
  p1 <- ggplot(data = df, aes(x, y,color = as.factor(g))) +
    stat_density2d(aes(fill = ..level..), alpha = 0.2, bins=b, geom = "polygon", h=c(bw,bw)) +
    scale_fill_continuous(low = "#fdae61", high = "#d7191c", space = "Lab", name = "sp1") +
    scale_colour_discrete(guide = FALSE) + scale_x_continuous(name = "axis1", limits= c(min(df$x)-100, max(df$x)+100))+
    scale_y_continuous(name = "axis2", limits= c(min(df$y)-100, max(df$y)+100))+
    theme(legend.position="none")
  # sp2
  p2 <- ggplot(data = df, aes(x, y, color = as.factor(g))) +
    stat_density2d(aes(fill = ..level..), alpha = 0.2, bins=b, geom = "polygon", h=c(bw,bw)) +
    scale_fill_continuous(low = "#abd9e9", high = "#2b83ba", space = "Lab", name = "sp2") +
    scale_colour_discrete(guide = FALSE) +  scale_x_continuous(name = "axis1", limits=c(min(df$x)-100, max(df$x)+100))+
    scale_y_continuous(name = "axis2", limits= c(min(df$y)-100, max(df$y)+100))+
    theme(legend.position="none")
  
  pp1 <- ggplot_build(p1)
  ppp1 <- ggplot_build(p1 + aes(alpha=0.15) + theme_classic() + theme(legend.position="none") + theme(text = element_text(size=15)) + xlab("axis1") + ylab("axis2") + xlim(c(min(pp1$data[[1]]$x)-0.5,max(pp1$data[[1]]$x)+0.5)) + ylim(c(min(pp1$data[[1]]$y)-0.5,max(pp1$data[[1]]$y)+0.5)))
  pp2 <- ggplot_build(p2 + aes(alpha=0.15) + theme_classic() + theme(legend.position="none")+ xlab("axis1") + ylab("axis2")  + xlim(c(min(pp1$data[[1]]$x)-0.5,max(pp1$data[[1]]$x)+0.5)) + ylim(c(min(pp1$data[[1]]$y)-0.5,max(pp1$data[[1]]$y)+0.5)))$data[[1]]
  
  ppp1$data[[1]]$fill[grep(pattern = "^2", pp2$group)] <- pp2$fill[grep(pattern = "^2", pp2$group)]
  
  grob1 <- ggplot_gtable(ppp1)
  grob2 <- ggplotGrob(p2)
  grid.newpage()
  grid.draw(grob1)
  
  #marginal density of x - plot on top
  
  if (class(sc_1)==c("pca","dudi") && class(sc_2)==c("pca","dudi")) 
  {plot_top <- ggplot(df, aes(x, y=..scaled..,fill=g)) + 
    geom_density(position="identity",alpha=.5) +
    scale_x_continuous(name = paste("Contribution ",(round((sc_1$eig[1]*100)/sum(sc_1$eig),2)),"%",sep=""), limits=c(min(pp1$data[[1]]$x)-0.5,max(pp1$data[[1]]$x)+0.5))+
    scale_fill_brewer(palette = "Set1") + 
    theme_classic() + theme(legend.position = "none")
  }
  
  else {
    
    if(is.null(a1cont)) plot_top <- ggplot(df, aes(x, y=..scaled..,fill=g)) + 
        geom_density(position="identity",alpha=.5) +
        scale_x_continuous(name = "axis1", limits=c(min(pp1$data[[1]]$x)-0.5,max(pp1$data[[1]]$x)+0.5))+
        scale_fill_brewer(palette = "Set1") + 
        theme_classic() + theme(legend.position = "none")  
    
    
    
    else plot_top <- ggplot(df, aes(x, y=..scaled..,fill=g)) + 
        geom_density(position="identity",alpha=.5) +
        scale_x_continuous(name = paste("Contribution ",a1cont,"%",sep=""), limits=c(min(pp1$data[[1]]$x)-0.5,max(pp1$data[[1]]$x)+0.5))+
        scale_fill_brewer(palette = "Set1") +
        theme_classic() + theme(legend.position = "none")
    
  }
  #marginal density of y - plot on the right
  
  if (class(sc_1)==c("pca","dudi") && class(sc_2)==c("pca","dudi")) 
  {plot_right <- ggplot(df, aes(y, y=..scaled.., fill=g)) + 
    geom_density(position="identity",alpha=.5) + 
    scale_x_continuous(name = paste("Contribution ",(round((sc_1$eig[2]*100)/sum(sc_1$eig),2)),"%",sep=""), limits= c(min(pp1$data[[1]]$y)-0.5,max(pp1$data[[1]]$y)+0.5)) +
    coord_flip() + 
    scale_fill_brewer(palette = "Set1") + 
    theme_classic() + theme(legend.position = "none") 
  }
  
  else {
    
    if(is.null(a2cont)) plot_right <- ggplot(df, aes(y, y=..scaled.., fill=g)) + 
        geom_density(position="identity",alpha=.5) + 
        scale_x_continuous(name = "axis2", limits= c(min(pp1$data[[1]]$y)-0.5,max(pp1$data[[1]]$y)+0.5)) +
        coord_flip() + 
        scale_fill_brewer(palette = "Set1") + 
        theme_classic() + theme(legend.position = "none") 
    
    
    else plot_right <- ggplot(df, aes(y, y=..scaled.., fill=g)) + 
        geom_density(position="identity",alpha=.5) + 
        scale_x_continuous(name = paste("Contribution ",a2cont,"%",sep=""), limits= c(min(pp1$data[[1]]$y)-0.5,max(pp1$data[[1]]$y)+0.5)) +
        coord_flip() + 
        scale_fill_brewer(palette = "Set1") +
        theme_classic() + theme(legend.position = "none") 
    
  }
  
  if (plot.axis == TRUE) grid.arrange(plot_top, empty , grob1, plot_right, ncol=2, nrow=2, widths=c(4, 1), heights=c(1, 4))
  else grid.draw(grob1)
  
}


