# 05_extract_first_region.R
# Extract TIFF files for one selected tissue region.

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj")
)

zip_path <- file.path(
  "data_raw",
  "DeLima2023-IMC-RAW.zip"
)

stopifnot(file.exists(zip_path))

archive_files <- unzip(zip_path, list = TRUE)

region_folder <- "data_tiff/001-A-C/A-Zone1a"

# Select only TIFF files directly inside this region
region_files <- archive_files$Name[
  dirname(archive_files$Name) == region_folder &
    grepl("\\.tiff?$", archive_files$Name, ignore.case = TRUE) &
    !startsWith(basename(archive_files$Name), "._")
]

stopifnot(length(region_files) > 0)

unzip(
  zipfile = zip_path,
  files = region_files,
  exdir = "data_raw",
  overwrite = FALSE
)

# Verify the extracted files
local_paths <- file.path("data_raw", region_files)

stopifnot(all(file.exists(local_paths)))

cat("Region: A-Zone1a\n")
cat("Number of TIFF files:", length(local_paths), "\n\n")
print(sort(basename(local_paths)))