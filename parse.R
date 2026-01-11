library(ggplot2)
data = data.table::fread("/tmp/change.csv", sep=",")
#data = data.table::fread("data.csv", sep=",")
#data$`Day Max` = pmax(data$Low, data$High, data$Open, data$Close)
#data$`Day Mean` = (data$Low + data$High + data$Open + data$Close) / 4
#data = data[!is.na(data$`Day Mean`),]
#data$Date = as.Date(data$Date, "%d-%m-%Y")
#data$Value = data$`Day Mean` / data$Max
stocks = unique(data$Stock)
stocks = c('BAC', 'CFG', 'FITB', 'HBAN', 'JPM', 'KEY', 'LNC', 'MET', 'PRU', 'RF', 'RJF', 'USB', 'ZION')
stocks = stocks[order(stocks)]
data = data[data$Stock %in% stocks,]
data$Week = strftime(as.character(data$Date), format="%Y-%U")
print("Week starts.")
week_start = aggregate(data.frame(`Week Start`=data$Date, check.names=FALSE), by=list(Week=data$Week), FUN="min")
print("Week ends")
week_start = aggregate(data.frame(`Week Start`=data$Date, check.names=FALSE), by=list(Week=data$Week), FUN="min")
week_end = aggregate(data.frame(`Week End`=data$Date, check.names=FALSE), by=list(Week=data$Week), FUN="max")
print("Aggregating.")
data = aggregate(data.frame(Change=data$Change, check.names=FALSE), by=list(Week=data$Week, Stock=data$Stock), FUN="sum")
data = merge(data, week_start, by=c("Week"))
data = merge(data, week_end, by=c("Week"))
most_correlated = 0
most_inversely_correlated = 0
print(paste(stocks[length(stocks)], stocks[length(stocks)], 1))
for (i in 1:(length(stocks) - 1)) {
	stock_a = stocks[i]
	print(paste(stock_a, stock_a, 1, sep=","))
	for (j in (i + 1):length(stocks)) {
		stock_b = stocks[j]
		a = data[data$Stock == stock_a,]
		b = data[data$Stock == stock_b,]
		both = merge(a, b, by=c("Week Start"))
		if (nrow(both) > 0) {
			correlation = cor(both$`Change.x`, both$`Change.y`)
			print(paste(stock_a, stock_b, correlation, sep=","))
			print(paste(stock_b, stock_a, correlation, sep=","))
			if (!is.na(correlation)) {
				if (correlation > 0.78) {
					most_correlated = correlation
					#print(paste(stock_a, stock_b, correlation))
					#g = ggplot(both, aes(x=Change.x, y=Change.y, colour=`Week Start`)) + geom_point() + xlab(stock_b) + ylab(stock_a)
					#ggsave("plot.png", g)
				}
				if (correlation < -0.8) {
					most_inversely_correlated = correlation
					#print(paste(stock_a, stock_b, correlation))
					#g = ggplot(both, aes(x=Change.x, y=Change.y, colour=`Week Start`)) + geom_point() + xlab(stock_b) + ylab(stock_a)
					#ggsave("inverse.png", g)
				}
			}
		}
	}
}
#apply_y = function(x) {
#	a=0.03
#	b=0.000000002
#	c=1970
#	d=2
#	return(a + b * (x - c) ^ d)
#}
#fit_model <- nls(
#	y ~ a + b * (x - c) ^ d,
#	data=data.frame(x=as.numeric(data$Date), y=data$Value),
#	start=list(a=0.03, b=0.000000002, c=1970, d=2),
#	lower=list(a=0.03, b=0.000000002, c=1970, d=2),
#	upper=list(a=0.03, b=0.000000002, c=1970, d=2),
#	alg="default",
#	control=nls.control(maxiter=5000),
#	trace=TRUE
#)
#x_range_labels <- as.Date(seq(as.numeric(min(data$Date)), as.numeric(max(data$Date)), length.out = 100))
#x_range <- seq(as.numeric(min(data$Date)), as.numeric(max(data$Date)), length.out = 100)
#predictions_df <- data.frame(
#	x=x_range_labels,
#	y=predict(fit_model, newdata=list(x=x_range))
#	#y=sapply(x_range, apply_y)
#)
#print(predictions_df[1:10,])
exit()
