# 02_download_data.R
# Download the original data and verify file integrity.

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  dir.exists("data_raw")
)

url <- paste0(
  "https://zenodo.org/records/23392665/files/",
  "DeLima2023-IMC-RAW.zip?download=1"
)

zip_path <- file.path(
  "data_raw",
  "DeLima2023-IMC-RAW.zip"
)

# Allow enough time for the download
options(timeout = max(1800, getOption("timeout")))

# Avoid downloading again if the file already exists
if (!file.exists(zip_path)) {
  download.file(
    url = url,
    destfile = zip_path,
    mode = "wb",
    method = "libcurl"
  )
}

# Compare the file's fingerprint with Zenodo's fingerprint
expected_md5 <- "8be86adedb5832645fe20aabe7241012"
actual_md5 <- unname(tools::md5sum(zip_path))

verified <- identical(actual_md5, expected_md5)

print(data.frame(
  file = basename(zip_path),
  size_MB = round(file.info(zip_path)$size / 1e6, 1),
  checksum_matches = verified
))

if (!verified) {
  stop("File verification failed. Share this output before continuing.")
}

file.exists("scripts/02_download_data.R")
