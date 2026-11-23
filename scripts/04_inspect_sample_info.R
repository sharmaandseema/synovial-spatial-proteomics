# 04_inspect_sample_info.R
# Extract only the sample spreadsheet and inspect its first sheet.

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  requireNamespace("readxl", quietly = TRUE)
)

zip_path <- file.path(
  "data_raw", "DeLima2023-IMC-RAW.zip"
)

spreadsheet_entry <- "data_tiff/ImageNb_PatientID.xlsx"

stopifnot(file.exists(zip_path))

unzip(
  zipfile = zip_path,
  files = spreadsheet_entry,
  exdir = "data_raw",
  overwrite = FALSE
)

spreadsheet_path <- file.path(
  "data_raw", spreadsheet_entry
)

stopifnot(file.exists(spreadsheet_path))

sheets <- readxl::excel_sheets(spreadsheet_path)
cat("Sheet names:\n")
print(sheets)

sample_info <- readxl::read_excel(
  spreadsheet_path,
  sheet = sheets[1]
)

cat("\nTable dimensions (rows, columns):\n")
print(dim(sample_info))

cat("\nColumn names:\n")
print(names(sample_info))

cat("\nFirst 10 rows:\n")
print(head(sample_info, 10), width = Inf)

# List image files without extracting them
zip_path <- file.path(
  "data_raw",
  "DeLima2023-IMC-RAW.zip"
)

stopifnot(file.exists(zip_path))

archive_files <- unzip(zip_path, list = TRUE)

# Keep TIFF images, excluding macOS metadata
image_files <- archive_files$Name[
  grepl("\\.tiff?$", archive_files$Name, ignore.case = TRUE) &
    !grepl("(^|/)(__MACOSX|\\._)", archive_files$Name)
]

cat("Number of TIFF files:\n")
print(length(image_files))

cat("\nFirst 20 TIFF paths:\n")
print(head(image_files, 20))

cat("\nImage folders:\n")
print(unique(dirname(image_files)))