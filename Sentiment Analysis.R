rm(list=ls())
library(devtools)
library(stringr) 
library(tidytext)
library(dplyr)
library(textdata)
library(wordcloud)
library(ggplot2)
library(RColorBrewer)
library(reshape2)

devtools::install_github("bradleyboehmke/harrypotter")
library(harrypotter)

philosophers_stone[1:2]

titles <- c("Philosopher's Stone", "Chamber of Secrets", "Prisoner of Azkaban",
            "Goblet of Fire", "Order of the Phoenix", "Half-Blood Prince",
            "Deathly Hallows")

books <- list(philosophers_stone, chamber_of_secrets, prisoner_of_azkaban,
              goblet_of_fire, order_of_the_phoenix, half_blood_prince,
              deathly_hallows)

#Each book is an array in which each value in the array is a chapter 

series <- tibble()
for(i in seq_along(titles)) {
  
  temp <- tibble(chapter = seq_along(books[[i]]),
                 text = books[[i]]) %>%
    unnest_tokens(word, text) %>%
    ##Here we tokenize each chapter into words
    mutate(book = titles[i]) %>%
    select(book, everything())
  
  series <- rbind(series, temp)
}

#Set factor to keep books in order of publication
series$book <- factor(series$book, levels = rev(titles))
series

#Count of the most frequent words
count = series %>%count(word, sort = TRUE)
count

#Removed stop words using anti_join function
count1 = series %>% anti_join(stop_words) %>%count(word, sort = TRUE)
count1

#Top most frequent words in series
frequent <- series %>% filter(!word %in% c("harry's", "harry"))
frequent %>%
  # delete stopwords
  anti_join(stop_words) %>%
  # summarize count per word per book
  count(book, word, sort = TRUE) %>%
  # get top 15 words per book
  group_by(book) %>%
  top_n(10) %>%
  ungroup() %>%
  mutate(word = reorder_within(word, n, book)) %>%
  # create barplot
  ggplot(aes(x = word, y = n, fill = book)) + 
  geom_col(color = "black") +
  scale_x_reordered() +
  labs(title = "Top 10 Tokens in Harry Potter Series (Except Harry)",
       x = NULL,
       y = "Token count") +
  facet_wrap(~ book, scales = "free") +
  coord_flip() +
  theme(legend.position = "none")

#Word cloud of frequent words all over the series
series$book <- factor(series$book, levels = rev(titles))
filtered = series %>% filter(!word %in% c("ron's", "dumbledore's",
                                           "hagrid's", "hermione's", "harry's"))

filtered %>% 
  anti_join(stop_words) %>%
  count(word) %>%
  with(wordcloud(word, n, max.words = 100, colors=brewer.pal(8, "Dark2")))

#Using NRC sentiment
(hp_nrc <- series %>% 
    inner_join(get_sentiments("nrc")))

hp_senti_sel <- hp_nrc %>% filter(!word %in% c("harry","moody"))

#layout(xaxis=list(title=""), showlegend=FALSE,
hp_senti_sel %>%
  # generate frequency count for each word and sentiment
  group_by(sentiment) %>%
  count(word, sort = TRUE) %>%
  # extract 10 most frequent pos/neg words
  group_by(sentiment) %>%
  top_n(10) %>%
  ungroup() %>%
  # prep data for sorting each word independently by facet
  mutate(word = reorder_within(word, n, sentiment)) %>%
  # generate the bar plot
  ggplot(aes(word, n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  # used with reorder_within() to label the axis tick marks
  scale_x_reordered() +
  facet_wrap(~ sentiment, scales = "free_y") +
  labs(title = "NRC Sentiment",
       x = NULL,
       y = "Number of occurences") +
  coord_flip()


# Using bing sentiment
(hp_bing <- series %>% 
    inner_join(get_sentiments("bing")))

hp_senti <- hp_bing %>% filter(!word %in% c("moody", "magical", "dead", "darkness", "died"))

hp_senti %>%
  right_join(get_sentiments("bing")) %>%
  filter(!is.na(sentiment)) %>%
  count(sentiment, sort = TRUE)

hp_senti %>%
  # generate frequency count for each word and sentiment
  group_by(sentiment) %>%
  count(word, sort = TRUE) %>%
  # extract 10 most frequent pos/neg words
  group_by(sentiment) %>%
  top_n(10) %>%
  ungroup() %>%
  # prep data for sorting each word independently by facet
  mutate(word = reorder_within(word, n, sentiment)) %>%
  # generate the bar plot
  ggplot(aes(word, n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  # used with reorder_within() to label the axis tick marks
  scale_x_reordered() +
  facet_wrap(~ sentiment, scales = "free_y") +
  labs(title = "BING Sentiment",
       x = NULL,
       y = "Number of occurences") +
  coord_flip()

# Word Cloud for bing sentiment
bingcloud <- hp_senti %>%
  anti_join(stop_words) %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = "n", fill = 0)%>% 
  comparison.cloud(colors = c("#F8766D", "#00BFC4"),
                   max.words = 50)

# AFINN sentiment
(hp_afinn <- series %>% 
    inner_join(get_sentiments("afinn")))

hp_afinn %>% 
  inner_join(get_sentiments("afinn")) %>%
  group_by(book, chapter) %>%
  summarize(value = sum(value)) %>%
  ggplot(aes(chapter, value, fill = book)) +
  geom_col() +
  facet_wrap(~ book, scales = "free_x") +
  labs(title = "AFINN Sentiment",
       x = "Chapter",
       y = "Emotional score") +
  theme(legend.position = "none")

# Comparing the three lexicons
afinn <- series %>%
  group_by(book) %>% 
  mutate(word_count = 1:n(),
         index = word_count %/% 500 + 1) %>% 
  inner_join(get_sentiments("afinn")) %>%
  group_by(book, index) %>%
  summarise(sentiment = sum(value)) %>%
  mutate(method = "AFINN")

bing_and_nrc <- bind_rows(series %>%
                            group_by(book) %>% 
                            mutate(word_count = 1:n(),
                                   index = word_count %/% 500 + 1) %>% 
                            inner_join(get_sentiments("bing")) %>%
                            mutate(method = "Bing"),
                          series %>%
                            group_by(book) %>% 
                            mutate(word_count = 1:n(),
                                   index = word_count %/% 500 + 1) %>%
                            inner_join(get_sentiments("nrc") %>%
                                         filter(sentiment %in% c("positive", "negative"))) %>%
                            mutate(method = "NRC")) %>%
  count(book, method, index = index , sentiment) %>%
  ungroup() %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative) %>%
  select(book, index, method, sentiment)

bind_rows(afinn, 
          bing_and_nrc) %>%
  ungroup() %>%
  mutate(book = factor(book, levels = titles)) %>%
  ggplot(aes(index, sentiment, fill = method)) +
  geom_bar(alpha = 0.8, stat = "identity", show.legend = FALSE) +
  facet_grid(book ~ method)

# Using bigrams

series <- tibble()
for(i in seq_along(titles)) {
  
  temp <- tibble(chapter = seq_along(books[[i]]),
                 text = books[[i]]) %>%
    unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
    ##Here we tokenize each chapter into bigrams
    mutate(book = titles[i]) %>%
    select(book, everything())
  
  series <- rbind(series, temp)
}

# Set factor to keep books in order of publication
series$book <- factor(series$book, levels = rev(titles))
series

series %>%
  count(bigram, sort = TRUE)

bigrams_separated <- series %>%
  separate(bigram, c("word1", "word2"), sep = " ")
bigrams_filtered <- bigrams_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word)

# new bigram counts:
bigrams_united <- bigrams_filtered %>%
  unite(bigram, word1, word2, sep = " ")
bigrams_united %>% 
  count(bigram, sort = TRUE)

#Td-idf
bigram_tf_idf <- bigrams_united %>%
  count(book, bigram) %>%
  bind_tf_idf(bigram, book, n) %>%
  arrange(desc(tf_idf))
bigram_tf_idf

plot_potter<- bigram_tf_idf %>%
  arrange(desc(tf_idf)) %>%
  mutate(bigram = factor(bigram, levels = rev(unique(bigram))))
plot_potter %>% 
  top_n(20) %>%
  ggplot(aes(bigram, tf_idf, fill = book)) +
  geom_col() +
  labs(x = NULL, y = "tf-idf") +
  coord_flip()

