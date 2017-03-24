# read in the csv file
mission.df = read.csv(file.choose(),header=T, stringsAsFactors=F, encoding="UTF-8")
mission.df[5,]

# load library tm (install if needed)
library(tm)
#see what can be read by tm
getSources()
help(VectorSource)

mission = VCorpus(VectorSource(mission.df[,"mission.txt"])) #create the volatile corpus
# exploring the mission corpus
# number of documents
num.docs = length(mission)
num.docs

#overall stats
print(mission)

#item by item stats, just for documents 2 and 3 in this example
inspect(mission[2:3])  # inspect is a tm function that used item numbers

# meta data
meta(mission[[5]])  # use [[ ... ]]  because it is a list

#see the text content of document 5
as.character(mission[[5]])

# or see them all
# first using a for loop
for (i in 1:length(mission)) print(as.character(mission[[i]]))

# or use the shortcut lapply - apply function to a list
# lapply(list, function)
lapply(mission[1:9], as.character)

# now for some transformations
# let us start with the meta content
for (i in 1:num.docs) meta(mission[[i]], tag="id") = mission.df[i,1]
# you can see it in meta
meta(mission[[5]])
# plus now the id helps us identify the text
lapply(mission[1:9], as.character)

# now onto text transformations
# you must use content_transformer() or it might spoil the data structure
#     without it seems to work, but not really
# we will use mission[[5]] as the running example
as.character(mission[[5]])
# all to lower case
mission = tm_map(mission, content_transformer(tolower))
as.character(mission[[5]])

#remove punctuation
mission = tm_map(mission, content_transformer(removePunctuation))
as.character(mission[[5]])

#remove numbers
mission = tm_map(mission, content_transformer(removeNumbers))
as.character(mission[[5]])

# now let us remove stopwords, you can make your own list or 
#   use the one built in
mission = tm_map(mission, removeWords, stopwords("english"))
as.character(mission[[5]])

#now let us stem it
# install SnowballC if you have not done so yet
library(SnowballC)
# before we do it, save the corpus for later use
mission.dict = mission
# now for stemming
mission = tm_map(mission, stemDocument)
as.character(mission[[5]])

# lets remove some stems that are not informative
# example: "busi" and "school"
as.character(mission[[8]])
mission = tm_map(mission, removeWords, c("busi", "school", "mission"))
as.character(mission[[8]])

# it is best to remove white space after other transformations
#  because some transformations insert white space for replacement
as.character(mission[[5]])
mission = tm_map(mission, content_transformer(stripWhitespace))
as.character(mission[[5]])

# this completes our preprocessing

# now let us do something with it
# we will create the document term matrix, which has a row for each document, 
#  and a column for each term/word/stem
#  the cell contains 0/1 indicating presence or absence or a the frequency

mission.dtm = DocumentTermMatrix(mission)
dim(mission.dtm)  # shows the number of docs and terms (in that order)
mission.dtm  # give basic summary info (more detailed than above) 
# note that it is 85% sparse, i.e. 85% of the cells have a zero
inspect(mission.dtm[5:6,40:45])  # shows the matrix

# now let us find the more frequent terms
findFreqTerms(mission.dtm, lowfreq=2)  #show only those with freq 2 or higher

#get full details on terms
term.freq =colSums(as.matrix(mission.dtm))
term.freq[order(term.freq, decreasing=T)]  # in order of decreasing freq
# let us make a dataframe of it
term.df = data.frame(word=names(term.freq), freq = term.freq)


#lets plot the frequency of the terms - but only for terms with freq > 1
library(ggplot2)
ggplot(subset(term.df, freq>1), aes(word, freq)) + 
     geom_bar(stat="identity") +
     theme(axis.text.x=element_text(angle=45, hjust=1, size=20))

#now let us make a word cloud, make sure it is installed
library(wordcloud)
set.seed(367)
wordcloud(term.df$word, term.df$freq, min.freq=1)
# now in color, 
# look at build in color palletes
display.brewer.all()
# let us pick set1, 7 colors
wordcloud(term.df$word, term.df$freq, min.freq=1, colors=brewer.pal(7, "Set1"))
# or try
wordcloud(term.df$word, term.df$freq, min.freq=1, colors=brewer.pal(9, "Blues"))
# if you want it a little darker
pal = brewer.pal(9,"Blues")
pal
pal = pal[-(1:3)] # remove the three lightest
wordcloud(term.df$word, term.df$freq, min.freq=1, colors=pal)
# or make your own choice
# a good web site is colorbrewer2.org
# copied from the web site
pal = c("#d40a0c", "#377eb8", "#4daf4a", "#984ea3", "#ff7f00","#ffff33", "#a65628")
wordcloud(term.df$word, term.df$freq, min.freq=2, colors=pal)

# now for some prettyness
#  complete stems so that the words appear natural
#  with so few terms with freq > 1, set rot.per = 0.2 to rotate some words
term.df$cword = stemCompletion(term.df$word, dictionary=mission.dict)
wordcloud(term.df$cword, term.df$freq, min.freq=2, colors=pal, rot.per=0.2)

