# LASSO in High-Frequency-Trading

## Summary
The goal of the project is to explore the effect of Least Absolute Shrinkage and Selection
Operator (LASSO) in the prediction of rolling 1-minute-ahead return. We are motivated by an
awesome paper Sparse Signals in the Cross-Section of Returns (Alex, Adam, & Mao, 2017),
which was published on the Journal of Finance. It is an explosive experiment for us, since some
important details of how to implement the strategy are not disclosed in the paper. Our report
mainly focuses on these details and how we really implement this algorithm to avoid similar
content with the paper. We do get some meaningful results like average of 0.6% out-of-sample
𝑅2 for the combination strategy of LASSO and AR(3) model. We mainly implement the project
on Python and some SAS.


## Motivation
Traditionally, researchers identity some candidate predictors like the unemployment rate, CPI,
some indices, etc., measure their quality and build some models to predict future stock returns.
But modern financial market is quite complex, it is hard to use intuition or some simple statistics
to identify candidate predictors. Recently, some algorithmic traders predict stock price through
sentiment analysis based on news, twitters, etc. LASSO is also a new way. The motivation of
LASSO is simple. If we fit the linear regression by using all US stocks, there will be overfitting
problems, since we get limited number of observations but too many predictors. LASSO is often
used when the number of variables exceed the number of observations to avoid overfitting
problem, which is exactly our case

Note: read report.pdf first, then codes.
