# scwrp-rsu-slr-model

This repository includes the sea-level rise (SLR) model and input data used to predict the impacts of SLR to coastal wetlands in Southern California. This SLR modelling analysis was conducted as part of the Southern California Wetland Recovery Project (SCWRP) Regional Strategy Update (RSU) 2018. For more information on the regional effort, visit the SCWRP [homepage](https://scwrp.org/). The information contained in this repository illustrates how the model and input data were applied to 100+ wetlands along the Southern California coast. 

The model incorporates topography, sediment accretion rates, tidal inlet dynamics and plant response to future sea-level rise scenarios. The model was developed to provide habitat change estimates for all sites within a region, by accommodating a diversity of wetland types, i.e. archetypes, and varying amounts of data availability. This model allows for site-specific model parameterization as input data becomes available and relies on regional defaults or archetype averages informed by regional data as the best available option when no information is available for a specific site.

## Getting Started

To run this model, you will need [R](https://www.r-project.org/) and [R studio](https://www.rstudio.com/). To run this model with the SCWRP RSU data, download this repository to a local directory or `git clone` this repository using [git](https://git-scm.com/downloads).

Once the repository is downloaded or cloned, you are ready to run the model in R. Check out “Running the model” below to get started. 

## Files included in this repository
* **SCWRP_RSU_slr_model.r** - R script containing a rule-based model that incorporates topography, sediment accretion rates, tidal inlet dynamics and plant response to future sea-level rise scenarios.
* **SLR_Model_Inputs.csv** – contains site-specific information on future sea-level rise scenarios, sediment accretion rates, tidal inlet dynamics and wetland types, i.e., archetypes for each site in the region
* **Hypsometry.csv** – contains site-specific hypsometric curves developed from topographical data from the 2009-2011 NOAA-CA Coastal Conservancy Coastal Lidar Project [(metadata)](https://coast.noaa.gov/htdata/raster2/elevation/California_Lidar_DEM_2009_1131/ca2010_coastal_dem.xml).
* **Zbreaks_Archetypes.csv** - contains elevational limits as a unitless measure of Z*, that delimit marsh zones. Marsh zone limits were developed for the regional wetland types, i.e., archetypes.

## Running the model
With the repository data saved to your local working directory, open the R script **SCWRP_RSU_slr_model.r**. With the script open in R studio, set the working directory `setwd()` to the same local working directory where you saved the repository. Here, you can also define where you want the model outputs to be saved. These should be the only changes required for the model script to run. 

The code in the model consists of two parts. In part 1, we read in **SLR_Model_Inputs.csv**, **Hypsometry.csv**, and **Zbreaks_Archetypes.csv**, then extract the input data that we need to make intermediate calculations (changes in elevation and water level) that get fed into part 2. Part 2 consists of a loop, where we go through our list of sites from the input data one at a time. This is where we manipulate the site-specific hypsometric curve and the water levels delimiting marsh zones in order to mimic changes caused by accretion, tidal inlet dynamics and sea level rise. Based on the site-specific hypsometric curve, the model calculates the amount of area for each marsh zone under current conditions and 2 future SLR scenarios: 0.6 m by 2050 and 1.7 m by 2100. The area calculations are then saved to the output directory as a subfolder for each site.

To run the model script in R studio, ensure your working directory and output directory are correct, select the entire script `cntl+a` and click `run`.

## License
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
