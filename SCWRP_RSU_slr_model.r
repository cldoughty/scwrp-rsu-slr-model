##Set Working Directory
setwd("C:/Users/GitHubRepository/scwrp-rsu-slr-model")

##Set Desired Output Directory
OutputDirectory="C:/Users/GitHubRepository/scwrp-rsu-slr-model/model output/"
  #This directory is set as a variable that will be used below to output the model data
  #Suggested output directory is a subdirectory of the working directory
  #Output directory path must end with a forward slash "/"

##############################################################################
#Part 1
##Import csv with input data for all sites in the region
input <- read.csv(file="SLR_Model_Inputs.csv", head=TRUE, sep=",")

##Create input variables for model
#Time points for baseline and SLR projections
t0 <- 2016
t1 <- 2050
t2 <- 2100

##Relative SLR (mm/yr)
SL2050 <-input$SLR_2050_mmyr*(t1-t0)
SL2100 <-input$SLR_2100_mmyr*(t2-t0)

##Accretion: inputs from Lit Review (mm/yr)
Acr2050 <- input$Accretion_mmyr*(t1-t0)
Acr2100 <- input$Accretion_mmyr*(t2-t0)

##Change in Elevation (m)
Elev2050 <- Acr2050*0.001 #convert accretion to m
Elev2100 <- Acr2100*0.001


##Change in Water level: inputs from rSLR and Mouth Dynamics Modeling
#Mouth Dynamics contribution (m)
MD2050 <- input$MD_WL_2050
MD2100 <- input$MD_WL_2100

#Change in Water level (m)
WL2050 <-(SL2050*0.001)+(MD2050) #SLR contribution (m)
WL2100 <-(SL2100*0.001)+(MD2100)

#Intermediate outputs for elevation and water level
output <-cbind(input, Elev2050, Elev2100, WL2050, WL2100)
  #Appends elevation and water level calculations per site to input data

##Hypsometric curves
Hyps <- read.csv(file="Hypsometry.csv", head=TRUE, sep=",")
  #Import long-format csv containing hypsometrtic curves (standardized to Z*) for all sites in the region

###Z breaks, by archetype
zbreaks <- read.csv(file="Zbreaks_Archetypes.csv", head=TRUE, sep=",")

##############################################################################
#Part 2
#Create list of sites from input/intermediate output
Sites=output$Site_Name
Sites = levels(Sites)

for (i in 1:length(Sites)){

  #SITE Inputs
  Site = subset(Hyps, Name==Sites[i]) #extracts site hypsometry data
  PC = subset(output, Site_Name==Sites[i], select=Perch.Correction) #site perch correction
  z.bin.max.pc = Site$z.bin.max - (PC[1,1]*1.25) #adjusts Z* (elevation) to correct for perched systems
  Site = cbind.data.frame(Site, z.bin.max.pc) #appends adjusted Z* (elevation)
  Site_archetype = subset(output, Site_Name==Sites[i], select=ArchetypeCode) #Site-specific archetype classification
  
  ##Archetype-specific Z* breaks
  z.subtidal=subset(zbreaks, Arch_Code==Site_archetype[1,1], select="Subtidal")
  z.mudflat=subset(zbreaks, Arch_Code==Site_archetype[1,1], select="Intertidal.Mudflat")
  z.low=subset(zbreaks, Arch_Code==Site_archetype[1,1], select="Low.Marsh")
  z.mid=subset(zbreaks, Arch_Code==Site_archetype[1,1], select="Mid.Marsh")
  z.high=subset(zbreaks, Arch_Code==Site_archetype[1,1], select="High.Marsh")
  z.trans=subset(zbreaks, Arch_Code==Site_archetype[1,1], select="Transition")
  z.stop=subset(zbreaks, Arch_Code==Site_archetype[1,1], select="Stop")
  
  #Calculate current area 
  subtidal=with(Site, sum(Site[z.bin.max.pc<z.mudflat[1,1], "area.km2"]))
  shallowsubtidal=with(Site, sum(Site[z.bin.max.pc>=z.subtidal[1,1] & z.bin.max.pc<z.mudflat[1,1], "area.km2"]))
  mudflat=with(Site, sum(Site[z.bin.max.pc>=z.mudflat[1,1] & z.bin.max.pc<z.low[1,1], "area.km2"]))
  low=with(Site, sum(Site[z.bin.max.pc>=z.low[1,1] & z.bin.max.pc<z.mid[1,1], "area.km2"]))
  mid=with(Site, sum(Site[z.bin.max.pc>=z.mid[1,1] & z.bin.max.pc<z.high[1,1], "area.km2"]))
  high=with(Site, sum(Site[z.bin.max.pc>=z.high[1,1] & z.bin.max.pc<z.trans[1,1], "area.km2"]))
  trans=with(Site, sum(Site[z.bin.max.pc>=z.trans[1,1] & z.bin.max.pc<z.stop[1,1], "area.km2"]))

  ##Site-specific Change in Z* breaks = CHANGE IN WATER LEVEL
  #convert m to z* = 1.25
  WL2050=subset(output, Site_Name==Sites[i], select=WL2050)
  WL2100=subset(output, Site_Name==Sites[i], select=WL2100)
  
  z.shallowsubtidal.2050=z.subtidal+((SL2050*0.001)*1.25)
  z.mudflat.2050=z.mudflat+(WL2050*1.25)
  z.low.2050=z.low+(WL2050*1.25)
  z.mid.2050=z.mid+(WL2050*1.25)
  z.high.2050=z.high+(WL2050*1.25)
  z.trans.2050=z.trans+(WL2050*1.25)
  z.stop.2050=z.stop+(WL2050*1.25)
  
  z.shallowsubtidal.2100=z.subtidal+((SL2100*0.001)*1.25)
  z.mudflat.2100=z.mudflat+(WL2100*1.25)
  z.low.2100=z.low+(WL2100*1.25)
  z.mid.2100=z.mid+(WL2100*1.25)
  z.high.2100=z.high+(WL2100*1.25)
  z.trans.2100=z.trans+(WL2100*1.25)
  z.stop.2100=z.stop+(WL2100*1.25)
  
  ##Site-specific Change in Z* bin max = CHANGE IN ELEVATION (m)
  Elev2050=subset(output, Site_Name==Sites[i], select=Elev2050)
  Elev2100=subset(output, Site_Name==Sites[i], select=Elev2100)
  
  ##Apply accretion to all marsh zones
  z.bins.2050=(Site$z.bin.max.pc+(Elev2050[1,1]*1.25))
  z.bins.2100=(Site$z.bin.max.pc+(Elev2100[1,1]*1.25))
  
  ##Site-specific output: future hypsometry
  Hyps_future=cbind(Site,z.bins.2050,z.bins.2100)
  #Set output directory to "SCWRP RSU SLR Model Output" folder
  dirname = paste(OutputDirectory, Sites[i],"/",sep="")
  filename = paste(dirname, Sites[i],"_hypsometry.csv",sep="")
  dir.create(file.path(dirname),recursive=TRUE)
  #write.csv(Hyps_future, file=filename) #option to write hypsometry data
  
  #Caluculate 2050 area
  subtidal_2050=with(Hyps_future, sum(Hyps_future[z.bins.2050<z.mudflat.2050[1,1], "area.km2"]))
  #shallowsubtidal_2050=with(Hyps_future, sum(Hyps_future[z.bins.2050>=z.shallowsubtidal.2050[1,1] & z.bins.2050<z.mudflat.2050[1,1], "area.km2"]))
  mudflat_2050=with(Hyps_future, sum(Hyps_future[z.bins.2050>=z.mudflat.2050[1,1] & z.bins.2050<z.low.2050[1,1], "area.km2"]))
  low_2050=with(Hyps_future, sum(Hyps_future[z.bins.2050>=z.low.2050[1,1] & z.bins.2050<z.mid.2050[1,1], "area.km2"]))
  mid_2050=with(Hyps_future, sum(Hyps_future[z.bins.2050>=z.mid.2050[1,1] & z.bins.2050<z.high.2050[1,1], "area.km2"]))
  high_2050=with(Hyps_future, sum(Hyps_future[z.bins.2050>=z.high.2050[1,1] & z.bins.2050<z.trans.2050[1,1], "area.km2"]))
  trans_2050=with(Hyps_future, sum(Hyps_future[z.bins.2050>=z.trans.2050[1,1] & z.bins.2050<z.stop.2050[1,1], "area.km2"]))
  
  #Calculate 2100 area
  subtidal_2100=with(Hyps_future, sum(Hyps_future[z.bins.2100<z.mudflat.2100[1,1], "area.km2"]))
  #shallowsubtidal_2100=with(Hyps_future, sum(Hyps_future[z.bins.2100>=z.shallowsubtidal.2100[1,1] & z.bins.2100<z.mudflat.2100[1,1], "area.km2"]))
  mudflat_2100=with(Hyps_future, sum(Hyps_future[z.bins.2100>=z.mudflat.2100[1,1] & z.bins.2100<z.low.2100[1,1], "area.km2"]))
  low_2100=with(Hyps_future, sum(Hyps_future[z.bins.2100>=z.low.2100[1,1] & z.bins.2100<z.mid.2100[1,1], "area.km2"]))
  mid_2100=with(Hyps_future, sum(Hyps_future[z.bins.2100>=z.mid.2100[1,1] & z.bins.2100<z.high.2100[1,1], "area.km2"]))
  high_2100=with(Hyps_future, sum(Hyps_future[z.bins.2100>=z.high.2100[1,1] & z.bins.2100<z.trans.2100[1,1], "area.km2"]))
  trans_2100=with(Hyps_future, sum(Hyps_future[z.bins.2100>=z.trans.2100[1,1] & z.bins.2100<z.stop.2100[1,1], "area.km2"]))
  
  #Create and export Site-specific output:  habitat area for current, 2050, 2100
  #Aggregate marsh zones to NWI Classes: Sudtidal water, estuarine unvegetated wetland, estuarine vegetated wetland
  Area_output_NWI= cbind.data.frame(Habitat=c("Subtidal Water","Estuarine Unvegetated Wetland","Estuarine Vegetated Wetland"),
                                Current=c(rbind(subtidal, mudflat, sum(low, mid, high))),
                                SLR2050=c(rbind(subtidal_2050, mudflat_2050, sum(low_2050, mid_2050, high_2050))),
                                SLR2100=c(rbind(subtidal_2100, mudflat_2100, sum(low_2100, mid_2100, high_2100))))
  
  filename2 = paste(dirname, Sites[i],"_area_NWIclasses.csv",sep="")
  write.csv(Area_output_NWI, file=filename2)
}
