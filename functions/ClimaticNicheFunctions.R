# Climatic Niche Functions
## ML Gaynor


## Plotting_pca_theme
plotting_pca_theme <- function(theme){
     if(theme == TRUE){
      theme <-  theme(panel.background = element_blank(),
                      panel.border = element_rect(fill = NA),
                      panel.grid.major = element_blank(),
                      panel.grid.minor = element_blank(),
                      strip.background = element_blank(),
                      axis.ticks = element_line(colour = "black"),
                      plot.margin = unit(c(1,1,1,1),"line"), 
                      axis.text = element_text(size = 12), 
                      legend.text = element_text(size = 12), 
                      legend.title = element_text(size = 12), 
                      text = element_text(size = 12))
      return(theme)
    } else {
      theme <- NA
      return(theme)
    }
}

## aov_to_group
aov_to_group <- function(b_aov){
  b <- HSD.test(b_aov, trt = "species", alpha = 0.05)  
  bio_group <- b$groups
  bio_group <- rownames_to_column(bio_group, var = "species")
  return(bio_group)
}

## plotting aov
plotting_aov <- function(biopl, bio_group){
                bio_aov_plot <- ggplot(biopl, aes(x = species, y = bio)) +
                                 geom_boxplot(aes(fill = groups)) +
                                 geom_text(data = bio_group, 
                                           mapping = aes(x = species,
                                                         y = (max(biopl$bio) + 30), 
                                                         label = groups), 
                                 size = 5, inherit.aes = FALSE) +
                                theme(axis.text.x = element_text(angle = 90, 
                                                                 size = 8, 
                                                                 face = 'italic'))
                return(bio_aov_plot)
}