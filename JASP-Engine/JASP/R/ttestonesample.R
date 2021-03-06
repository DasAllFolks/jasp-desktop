
TTestOneSample <- function(dataset=NULL, options, perform="run", callback=function(...) 0, ...) {

	all.variables <- unlist(options$variables)

	if (is.null(dataset))
	{
		if (perform == "run") {
		
			if (options$missingValues == "excludeListwise") {
			
				dataset <- .readDataSetToEnd(columns.as.numeric=all.variables, exclude.na.listwise=all.variables)
			}
			else {
			
				dataset <- .readDataSetToEnd(columns.as.numeric=all.variables)
			}
		
		} else {
		
			dataset <- .readDataSetHeader(columns.as.numeric=all.variables)
		}
		
	} else {
	
		if (options$missingValues == "excludeListwise") {
		
			dataset <- .vdf(dataset, columns.as.numeric=all.variables, exclude.na.listwise=all.variables)
		}
		else {
		
			dataset <- .vdf(dataset, columns.as.numeric=all.variables)
		}
	}

	results <- list()
	
	
	
	meta <- list()
	
	meta[[1]] <- list(name="title", type="title")
	meta[[2]] <- list(name="ttest", type="table")
	meta[[3]] <- list(name="descriptives", type="table")
	meta[[4]] <- list(name="normalityTests", type="table")
	
	results[[".meta"]] <- meta
	results[["title"]] <- "T-Test"
	

	ttest <- list()
	descriptives <- list()
	
	ttest[["title"]] <- "One Sample T-Test"

	fields <- list(
		list(name="v", type="string", title=""),
		list(name="t", type="number", format="sf:4;dp:3"),
		list(name="df", type="number", format="sf:4;dp:3"),
		list(name="p", type="number", format="dp:3;p:.001"))
		
	if (options$meanDifference) {
	
		fields[[length(fields) + 1]] <- list(name="Mean Difference", type="number", format="sf:4;dp:3")
	}
	
	if(options$effectSize){
		fields[[length(fields) + 1]] <- list(name="d", title="Cohen's d", type="number", format="sf:4;dp:3")
	}
	
	if (options$confidenceInterval) {
	
		interval <- 100 * options$confidenceIntervalInterval
		title    <- paste(interval, "% Confidence Interval", sep="")

		fields[[length(fields) + 1]] <- list(name="lowerCI", type="number", format="sf:4;dp:3", title="Lower", overTitle=title)
		fields[[length(fields) + 1]] <- list(name="upperCI", type="number", format="sf:4;dp:3", title="Upper", overTitle=title)
	}
	
	ttest[["schema"]] <- list(fields=fields)
	
	footnotes <- .newFootnotes()
	
	if (options$hypothesis == "greaterThanTestValue") {

		message <- paste("All tests, hypothesis is population mean is greater than ", options$testValue, sep="")
		.addFootnote(footnotes, symbol="<em>Note.</em>", text=message)
		
		testType <- "greater"

	} else if (options$hypothesis == "lessThanTestValue") {

		message <- paste("All tests, hypothesis is population mean is less than ", options$testValue, sep="")
		.addFootnote(footnotes, symbol="<em>Note.</em>", text=message)
		
		testType <- "less"
		
	} else {

		if (options$testValue != 0) {
		
			message <- paste("All tests, hypothesis is population mean is different to ", options$testValue, sep="")
			.addFootnote(footnotes, symbol="<em>Note.</em>", text=message)
		}
	
		testType <- "two.sided"	
	}
	
	ttest.rows <- list()
	
	variables <- options[["variables"]]
	if (length(variables) == 0)
		variables = "."
	
	for (variable in variables) {

		if (perform == "run" && length(options$variables) > 0) {

			result <- try (silent = TRUE, expr = {
			
				r <- t.test(dataset[[ .v(variable) ]], alternative=testType, mu=options$testValue,
							conf.level=options$confidenceIntervalInterval)
			
				t  <- as.numeric(r$statistic)
				df <- as.numeric(r$parameter)
				p  <- as.numeric(r$p.value)
				m  <- as.numeric(r$estimate - r$null.value)
				d <- .clean((mean(dataset[[ .v(variable) ]]) - options$testValue) / sd(dataset[[ .v(variable) ]]))
				ciLow <- .clean(as.numeric(r$conf.int[1]))
				ciUp  <- .clean(as.numeric(r$conf.int[2]))
				
				if (is.na(t))
					stop("data are essentially constant")
			
				list(v=variable, t=t, df=df, p=p, "Mean Difference"=m, "d"=d, "lowerCI"=ciLow, "upperCI"=ciUp)
			})
				
			if (class(result) == "try-error") {
			
				errorMessage <- .extractErrorMessage(result)
						
				if (errorMessage == "missing value where TRUE/FALSE needed") {
				
					errorMessage <- paste("t-statistic is undefined - the sample contains infinity")
					
				} else if (errorMessage == "data are essentially constant") {
				
					errorMessage <- paste("t-statistic is undefined - the sample contains all the same value (zero variance)")
				
				} else if (errorMessage == "not enough 'x' observations") {
					
					errorMessage <- "t-statistic is undefined - sample contains only one value"
						
				}
				
				index <- .addFootnote(footnotes, errorMessage)
		
				result <- list(v=variable, t=.clean(NaN), df="", p="", "Mean Difference"="", "lowerCI"="", "upperCI"="", .footnotes=list(t=list(index)))
			}
			
		} else {

			result <- list(v=variable, t=".", df=".", p=".", "Mean Difference"=".", "d"=".", "lowerCI"=".", "upperCI"=".")
		
		}
		
		ttest.rows[[length(ttest.rows)+1]] <- result
	}
	
	ttest[["data"]] <- ttest.rows
	ttest[["footnotes"]] <- as.list(footnotes)
	
	

	if (options$descriptives) {
	
		descriptives[["title"]] <- "Descriptives"
		descriptives[["cases"]] <- I(options$variables)

		fields <- list(
			list(name="v",    title="",   type="string"),
			list(name="N",    title="N",  type="number",   format="sf:4;dp:3"),
			list(name="mean", title="Mean", type="number", format="sf:4;dp:3"),
			list(name="sd",   title="SD", type="number",   format="sf:4;dp:3"),
			list(name="se",   title="SE", type="number",   format="sf:4;dp:3"))

		descriptives[["schema"]] <- list(fields=fields)
		descriptives.results <- list()
		
		variables <- options[["variables"]]
		if (length(variables) == 0)
			variables = "."

		for (variable in variables) {
			
			if (perform == "run" && length(options[["variables"]]) > 0) {

				data <- na.omit(dataset[[ .v(variable) ]])

				if (class(data) != "factor") {

					n    <- .clean(length(data))
					mean <- .clean(mean(data))
					stdDeviation <- .clean(sd(data))
					stdErrorMean <- .clean(sd(data)/sqrt(length(data)))
					
					if(length(descriptives.results) == 0) {
			            newGroup <- TRUE   
			        } else {				
				        newGroup <- FALSE
			        }

					result <- list(v=variable, N=n, mean=mean, sd=stdDeviation, se=stdErrorMean, ".isNewGroup" = newGroup)
				} else {
				
				    if(length(descriptives.results) == 0) {
			            newGroup <- TRUE   
			        } else {				
				        newGroup <- FALSE
			        }
			
					n <- .clean(length(data))
					result <- list(v=variable, N=n, mean="", sd="", se="", ".isNewGroup" = newGroup)
				}
			
			} else {
			
			    if(length(descriptives.results) == 0) {
			        newGroup <- TRUE   
			    } else {				
				    newGroup <- FALSE
			    }
			
				result <- list(v=variable, N=".", mean=".", sd= ".", se=".", ".isNewGroup" = newGroup)			
			
			}
			
			descriptives.results[[length(descriptives.results)+1]] <- result
		}
		
		descriptives[["data"]] <- descriptives.results
	}
	
	if (options$normalityTests) {
	
	    normalityTests <- list()
	
		normalityTests[["title"]] <- "Test of Normality (Shapiro-Wilk)"
		normalityTests[["cases"]] <- I(options$variables)

		fields <- list(
			list(name="v", title="", type="string"),
			list(name="W", title="W", type="number",   format="sf:4;dp:3"),
			list(name="p", title="p", type="number", format="dp:3;p:.001"))

		normalityTests[["schema"]] <- list(fields=fields)
		
		footnotes <- .newFootnotes()
        .addFootnote(footnotes, symbol="<em>Note.</em>", text="Significant results indicate a deviation from normality")
		
		normalityTests.results <- list()
		
		variables <- options[["variables"]]
		if (length(variables) == 0)
			variables = "."

		for (variable in variables) {
			
			if (perform == "run" && length(options[["variables"]]) > 0) {

				data <- na.omit(dataset[[ .v(variable) ]])
				
				row.footnotes <- NULL
                error <- FALSE
                
                if(length(data) < 3) {
                
                    foot.index <- .addFootnote(footnotes, "Too few datapoints (N < 3) to compute statistic reliably")
					row.footnotes <- list(W=list(foot.index), p=list(foot.index))
					error <- TRUE
					
                } else if(length(data) > 5000) {
                
                    foot.index <- .addFootnote(footnotes, "Too many datapoints (N > 5000) to compute statistic reliably")
					row.footnotes <- list(W=list(foot.index), p=list(foot.index))
					error <- TRUE
					
                }

				if (!error) {
                    
                    r <- stats::shapiro.test(data)
                    
					W <- .clean(as.numeric(r$statistic))
					p <- .clean(r$p.value)
					
					if(length(normalityTests.results) == 0) {
			            newGroup <- TRUE   
			        } else {				
				        newGroup <- FALSE
			        }
					
					result <- list("v" = variable, "W" = W, "p" = p, ".isNewGroup" = newGroup)
					
				} else {
			        
			        if(length(normalityTests.results) == 0) {
			            newGroup <- TRUE   
			        } else {				
				        newGroup <- FALSE
			        }
					
					result <- list("v" = variable, "W" = "NaN", "p" = "NaN", ".isNewGroup" = newGroup, .footnotes=row.footnotes)
					
				}
			
			} else {
			
			    if(length(normalityTests.results) == 0) {
			        newGroup <- TRUE   
			    } else {				
				    newGroup <- FALSE
			    }
			
				result <- list("v" = variable, "W" = ".", p = ".", ".isNewGroup" = newGroup)			
			
			}
			
			normalityTests.results[[length(normalityTests.results)+1]] <- result
		}
		
		normalityTests[["data"]] <- normalityTests.results
		
		normalityTests[["footnotes"]] <- as.list(footnotes)
		
		results[["normalityTests"]] <- normalityTests
	}
	
	
	
	results[["ttest"]] <- ttest
	
	if (options$descriptives)
		results[["descriptives"]] <- descriptives

	
	results
}

