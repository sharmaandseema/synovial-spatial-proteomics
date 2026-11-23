# 22_run_all.R
# Run scripts 00–21 and compare the main measurement table.

run_project <- function() {
  stopifnot(
    file.exists("synovial-spatial-proteomics.Rproj"),
    dir.exists("docs")
  )
  
  scripts <- sort(list.files(
    "scripts",
    pattern = "^([01][0-9]|2[01])_.*\\.R$",
    full.names = TRUE
  ))
  
  # Require exactly one script for each number, 00–21
  stopifnot(
    length(scripts) == 22,
    identical(
      substr(basename(scripts), 1, 2),
      sprintf("%02d", 0:21)
    )
  )
  
  measurement_path <- paste0(
    "data_processed/",
    "A-Zone1a_object_measurements_spatial.csv"
  )
  
  baseline <- if (file.exists(measurement_path)) {
    read.csv(measurement_path)
  } else {
    NULL
  }
  
  sink("docs/reproducibility_run_log.txt", split = TRUE)
  on.exit(sink(), add = TRUE)
  
  # Use a separate environment for the analysis objects
  analysis_environment <- new.env(parent = globalenv())
  
  for (script in scripts) {
    cat("\nRunning:", basename(script), "\n")
    source(
      script,
      local = analysis_environment,
      echo = FALSE
    )
  }
  
  rerun <- read.csv(measurement_path)
  
  if (!is.null(baseline)) {
    comparison <- all.equal(
      baseline,
      rerun,
      tolerance = 1e-10
    )
    
    cat("\nMeasurement table comparison:\n")
    print(comparison)
    
    if (!isTRUE(comparison)) {
      stop("Measurements differ. Review the comparison before continuing.")
    }
  }
  
  writeLines(
    capture.output(sessionInfo()),
    "docs/session_info_rerun.txt"
  )
  
  cat("\nRERUN COMPLETED SUCCESSFULLY\n")
}

run_project()