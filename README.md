# Goal 
The goal of this project is to build a sentiment analysis model which will allow us to categorize words in the Harry Potter series based on their sentiments, that is whether they are positive, negative or neutral using the lexicons from the tidytext package and get insights like to know what are the most frequent words used in the series through word count and word clouds which determine important characters, to know top positive-negative words with the help of bing lexicon, to determine  which book has the highest negative or positive emotional score, to compare the three lexicons to see how the sentiment over the series changes with the changing lexicon and to analyze the text further more using bigrams.

# Abstract
The project is mainly based on Sentiment Analysis within R using tidytext package that comprises of sentiment lexicons like AFINN, BING and NRC that are present in the dataset of “sentiments”. The text data that is used in this project was provided by the Harry Potter R package (harrypotter) on GitHub that contains the text for all seven books in the Harry Potter series, by JK Rowling. The visualization used in this project were created using R programming on R Studio.
The list of seven novels that are used in this analysis are as below:
Harry Potter and the Philosophers Stone (1997)
Harry Potter and the Chamber of Secrets (1998)
Harry Potter and the Prisoner of Azkaban (1999)
Harry Potter and the Goblet of Fire (2000)
Harry Potter and the Order of the Phoenix (2003)
Harry Potter and the Half Blood Prince (2005)
Harry Potter and the Deathly Hallows (2007)

# Packages Used
The required text data was loaded into RStudio from the harrypotter package along with the other packages that are required for this analysis like tidytext, textdata, worldcloud2, ggplot2, RColorBrewer, dplyr, rshape2, tidyverse, tidyr.

# Conclusion
•	Most frequent words in the series are: Harry, Ron, Hermione and Dumbledore
•	We saw how three lexicons show effect on the text by visualizing comparison cloud, emotional score and different categorized emotions using nrc lexicon
•	“Deathly Hallows” has the highest negative score in entire series and “Half Blood Prince” has the most positive score
•	Since mostly the series is dominated by negative words NRC and Bing lexicons showcased this properly
•	Using Bigrams made us analyze in even more detail about the top characters that played a prominent role in the entire series
•	“Order of Phoenix” is the lengthiest book keeping “Philosophers Stone” the shortest.

