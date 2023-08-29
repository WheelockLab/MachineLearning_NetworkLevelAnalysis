# Machine Learning Pipelines with Network Level Analysis
This repository provides a **MATLAB library** for the machine learning pipelines on functional connectivity (FC) data, specifically regarding a predictive linear support vector regression (LSVR) model, implemented by an innovative **K-fold cross-validation** to account for related subjects such as twins and siblings. The **biological interpretation** of the ML results is facilitated by the Network-level enrichment. 
## Example
* **MLCrossVal_testScript.m**: This is an example on Human Connectome Project (HCP) data
## Folders
* **MLCrossVal.m**: This is the main function. Have a try on your data!
* **+featurefilter/**: This contains the code for the optional feature filter applied before fitting the LSVR prediction model. Notably, functional connectivity data always forms a high-dimensional statistical problem, e.g. 333 regions of interests (ROIs) gives 55,611 functional connectivity features, which is much larger than the number of subjects, saying hundreds. Therefore, an additional feature selection step is frequently adopted to avoid overfitting. We include the popular **marginal Pearson correlation feature filter** in **HighestCorr.m**, i.e., selecting N connectivity features with the highest correlations with the label (e.g. age, behavior score). 
* **+traintestdatasplitter/**: This includes the code for the training and test set splitting for the K-fold cross validation. For example, one can set mlCrossVal.testDataFraction = 0.2, and then the test set will be 20% of all subjects, i.e. 5-fold cross validation. 
