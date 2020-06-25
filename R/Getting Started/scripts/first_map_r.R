## Preparing R -------------------------------------------------------------------------------------------

## Obtain current dir
getwd()

## Assign a workspace
workspace <-"C:/Users/jf_ph/OneDrive/Documentos/R/R Scripts" ##you can define your workspace
setwd(workspace)

## Install libraries
libraries <-c("sp","sf", "ggplot2","ggspatial", "googledrive")
install.packages(libraries)

## Call libraries
library(googledrive)#Download large file from Google Drive
library(dplyr) ## For pipelines %>% 
library(sp) ## Required for sf
library(sf)
library(ggplot2)
library(ggspatial) ## For annotations in the plot

## Downloading files ---------------------------------------------------------------------------------------------

## Create a subfolder for extracted data
dir.create(file.path(workspace,"data"))


##"https://drive.google.com/file/d/0By1rYqKYtPp5RUZpdHo4OHNvQkE", Vegetation Cover link
##"https://drive.google.com/file/d/1Mrgi6TycuZHFNWfWZrH5NioBwJ6gRoiO/view?usp=sharing",  Metropolitan Lima link

#Downloading and unziping files (you must authorize to googledrive API)

## Diferent tempfile for safety
temp<-tempfile(fileext = ".zip")
drive_download(as_id("1Mrgi6TycuZHFNWfWZrH5NioBwJ6gRoiO"),path=temp,overwrite = TRUE) 
unzip(temp, exdir = file.path(workspace,"data"))

temp_1<-tempfile(fileext = ".zip")
drive_download(as_id("0By1rYqKYtPp5RUZpdHo4OHNvQkE"),path=temp_1,overwrite = TRUE) 
unzip(temp_1, exdir = file.path(workspace,"data"))

## Optional ----------------------------------------------------------------------------------------------

## Since not all are shapefiles, in this case I use geopackages
## First, I view the saved files on my workspace
list.files(file.path(workspace,"data"))

## I read the shapefiles and I've write them on a new geopackage that I created
## In different st_write for integrity
file.path( workspace,"data","CobVeg_180615.shp") %>% 
  st_read()  %>% 
  st_write(file.path(workspace,"data","cov_veg.gpkg"), "vegetation")

file.path( workspace,"data","lima_callao.shp") %>% 
  st_read()  %>% 
  st_write(file.path(workspace,"data","cov_veg.gpkg"),"district",append=TRUE)

## Visualizing layers
st_layers(file.path(workspace,"data","cov_veg.gpkg")) ## There are two layers

## View files---------------------------------------------------------------------------------------------

## Using a geopackage for better management
cob_veg <- file.path( workspace,"data","cov_veg.gpkg")

## Vegetation cover feature
veg <-cob_veg %>% 
      st_read(layer="vegetation") %>% 
      st_transform(4326)  

## Metropolitan Lima districts feature
district <- cob_veg %>% 
            st_read(layer="district") %>% 
            st_transform(st_crs(veg))

#Verifyng crs
st_crs(veg)==st_crs(district)

## Intersecting features
district_veg<- st_intersection(veg,district)


## Mapping ---------------------------------------------------------------------------------------------------

## 1st way (easiest way to plot)
district_veg %>% 
  select("CobVeg2013") %>% 
  plot(graticule = TRUE, axes = TRUE)

## 2nd way with ggplot
ggplot() + 
  geom_sf(data = district_veg, aes(fill=CobVeg2013),color=NA) + ## Add clipped vegetation cover by types ##
  geom_sf(data=district, color="black", fill=NA)+ ## Add districts ##
  scale_fill_manual(name = "Cobertura Vegetal", ## Set manual type legend (name and colors) ##
                    values=c("green","gray30","orange","#C19A6B","#10CB9B","#75C36E","#A5A200","blue")) +
  coord_sf(datum=sf::st_crs(district))+ ## To adjust the coords between features ##
  theme_gray()+ # Add light theme ##
  ggtitle("Cobertura Vegetal en Lima Metropolitana")+ ## Add title to plot ##
  theme(plot.title = element_text(hjust= 0.5, face="bold", size="16"))+ ## Plot a tittle as theme ##
  annotation_scale(location="bl",width_hint=.6)+ ## Add scale bar ##
  annotation_north_arrow(location= "tr",height = unit(2.5, "cm"),width = unit(2.5, "cm"),
                         style=north_arrow_fancy_orienteering) ## Add north arrow ##

## Saving map------------------------------------------------------------------------------------------------

## Creating a subfolder for outputs
dir.create(file.path(workspace,"outputs"))

ggsave( filename="firstmap_r.png",
        path=file.path( workspace,"outputs"),
        width = 20,
        height=20,
        units = "cm",
        dpi=300)

## Saving R Script ------------------------------------------------------------------------------------------

dir.create(file.path(workspace,"scripts"))
# To save a R script : ctrl+S in the new created subfolder
#To save the currently open script file to disk.
rstudioapi::documentSave()
rstudioapi::documentSave(rstudioapi::getActiveDocumentContext()$id)
