library('RCurl')
library('twitteR')
library('readr')
library(rvest)
library(dplyr)
library(stringr)

### Download account list
top50_science_url = "http://www.sciencemag.org/news/2014/09/top-50-science-stars-twitter"
htmlfile = read_html(top50_science_url)

xpath.name = '//*[contains(concat( " ", @class, " " ), concat( " ", "k-index", " " )) and (((count(preceding-sibling::*) + 1) = 31) and parent::*)]//strong'
nds.name = html_nodes(htmlfile, xpath = xpath.name)
top50sci.name = html_text(nds.name)

xpath.id = '//*[contains(concat( " ", @class, " " ), concat( " ", "k-index", " " )) and (((count(preceding-sibling::*) + 1) = 31) and parent::*)]//a'
nds.id = html_nodes(htmlfile, xpath = xpath.id)
top50sci.id = html_text(nds.id)
top50sci.id = gsub('@', '', top50sci.id)

write.table(data.frame(name = top50sci.name, id = top50sci.id), 'top50sci_twitter.txt')
### Download tweets
date.ls = seq(as.Date('2016-10-01'), as.Date('2016-09-06'), by = -5)
tweets.sci = list()

for (date in date.ls){
    date = as.Date(date, origin = '1970-01-01')
    print(date)
    tweets.sci[[as.character(date)]] = list()
    for (id in top50sci.id){
        print(id)
        tweets.url = paste0('https://twitter.com/search?q=from%3A', id, '%20since%3A', 
                            as.character(date-5), '%20until%3A', as.character(date), '&src=typd&lang=en')
        # tweets.url = "https://twitter.com/search?q=from%3AProfBrianCox%20since%3A2016-10-01%20until%3A2016-10-03&src=typd&lang=en"
        htmlfile = read_html(tweets.url)
        ## From 9-28 until 9-29 selects the tweets on 9-28
        xpath.tweets = '//*[contains(concat( " ", @class, " " ), concat( " ", "tweet-text", " " ))]'
        # xpath.tweets = '//*[(@id = "stream-items-id")]'
        tw = html_nodes(htmlfile, xpath = xpath.tweets)
        txt = html_text(tw)
        print(txt)
        tweets.sci[[as.character(date)]][[id]] = txt
        Sys.sleep(30)
    }
    # names(tweets.sci[[id]]) = date.ls
}
