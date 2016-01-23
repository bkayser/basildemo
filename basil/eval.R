library(data.table)
library(dplyr)

# Evaluate the given dataset using parameters for the number of sigmas of 
# deviation required to violate the threshold of one minute sample means and
# the number of consecutive violations to trigger an anomaly.
# 
# num_sigmas: the parameter for the threshold, a multiplier or percentage value
# lead_time: number of minutes to be in violation before triggering
# baseline_season: the type of summary baseline to use.
#

threshold_eval <- function(all_data,
                           num_sigmas=1,
                           lead_time=5) {
    baseline_season <- 'Mean (inliers)'
    
    results <- list()
    for (metric in unique(all_data$name)) {
        signal <- filter(all_data, Season=='Signal' & name==metric)
        baseline <- filter(all_data, Season==baseline_season & name==metric)
        baseline$threshold <- baseline$sample_sd_from_trend * num_sigmas
        
        baseline_lookup <- unique(select(baseline, period_index, baseline=value, threshold))
        signal <- left_join(signal, baseline_lookup, by='period_index')
        
        processed <- signal_process(signal, lead_time)
        results[[metric]] <- data.frame(name=metric, 
                                        start=signal$start,
                                        baseline=signal$baseline, 
                                        deviation=processed$deviation, 
                                        trigger=processed$trigger,
                                        threshold=signal$threshold,
                                        value=signal$value,
                                        stringsAsFactors=F)
    }
    combined <- bind_rows(results)
    combined$trigger <- factor(combined$trigger, levels=c('0', 'H', 'L'))
    combined$name <- as.factor(combined$name)
    return(combined)
}

signal_process <- function(signal_and_baseline, lead_time) {
    deviation <- signal_and_baseline$value - signal_and_baseline$baseline
    threshold <- signal_and_baseline$threshold
    trigger <- rep('0', length(threshold))
    for (timeslice_num in max(2,lead_time):length(deviation)) {
        if (is.na(deviation[timeslice_num])) {
            next()
        }
        lookbehind_window <- (timeslice_num-lead_time+1):timeslice_num
        last_trigger <- trigger[timeslice_num-1]
        if (last_trigger == 'H' & any(deviation[lookbehind_window] >= threshold[timeslice_num])) {
            trigger[lookbehind_window] = 'H'
        } else if (last_trigger == 'L' & any(deviation[lookbehind_window] <= -threshold[timeslice_num])) {
            trigger[lookbehind_window] = 'L'
        } else if (last_trigger == '0') {
            # Set the lead_time edge of a trigger if we've had N consecutive violations
            if (all(deviation[lookbehind_window] >= threshold[timeslice_num])) {
                trigger[lookbehind_window] = 'H'
            } else if (all(deviation[lookbehind_window] <= -threshold[timeslice_num])) {
                trigger[lookbehind_window] = 'L'
            } 
        } else {
            # Clear the trailing edge of the trigger if we've had N consecutive violations
            trigger[lookbehind_window = '0']
        }
    }
    return (list(deviation=deviation, trigger=trigger))
}