# Synovial spatial proteomics learning project
# 00_setup.R
# Run with synovial-spatial-proteomics.Rproj open.

# Check the project location
stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj")
)

# Create any missing project folders
folders <- c(
  "scripts",
  "data_raw",
  "data_processed",
  "results",
  "figures",
  "docs"
)

for (folder in folders) {
  dir.create(folder, showWarnings = FALSE)
}

# Record R version, operating system and loaded packages
writeLines(
  capture.output(sessionInfo()),
  con = file.path("docs", "session_info_setup.txt")
)

# Verify the folders and session record
print(data.frame(
  folder = folders,
  exists = dir.exists(folders)
))

print(file.exists(
  file.path("docs", "session_info_setup.txt")
))

file.exists(c(
  "scripts/00_setup.R",
  "docs/session_info_setup.txt"
))

file.exists("scripts/00_setup.R")

# 01_prepare_packages.R
# Install missing packages and check availability.

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj")
)

packages <- c("tiff", "readxl", "ggplot2")

available <- vapply(
  packages,
  requireNamespace,
  logical(1),
  quietly = TRUE
)

if (any(!available)) {
  install.packages(
    packages[!available],
    repos = "https://cloud.r-project.org"
  )
}

# Verify installation
print(data.frame(
  package = packages,
  available = vapply(
    packages,
    requireNamespace,
    logical(1),
    quietly = TRUE
  )
))