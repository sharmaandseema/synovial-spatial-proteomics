# 03_inspect_archive.R
# List archive contents without extracting the files.

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  dir.exists("docs")
)

zip_path <- file.path(
  "data_raw",
  "DeLima2023-IMC-RAW.zip"
)

stopifnot(file.exists(zip_path))

# Read the file list
archive_files <- unzip(zip_path, list = TRUE)

# Save the full list for reference
write.csv(
  archive_files,
  file = file.path("docs", "archive_file_list.csv"),
  row.names = FALSE
)

# Display a small preview
cat("Number of archive entries:", nrow(archive_files), "\n")
print(head(archive_files, 15), row.names = FALSE)

# Find spreadsheets and documentation
info_files <- archive_files[
  grepl(
    "\\.(xlsx?|csv|txt|md|pdf)$",
    archive_files$Name,
    ignore.case = TRUE
  ),
]

cat("\nSpreadsheets and documentation:\n")
print(info_files, row.names = FALSE)
