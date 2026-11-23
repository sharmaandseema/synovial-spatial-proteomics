# 16_add_protein_measurements.R
# Add mean CD3 and CD31 signals to the existing object table.

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  requireNamespace("tiff", quietly = TRUE)
)

input_path <- "data_processed/A-Zone1a_object_measurements_qc.csv"
stopifnot(file.exists(input_path))
objects <- read.csv(input_path)

region_path <- "data_raw/data_tiff/001-A-C/A-Zone1a"

mask_path <- list.files(
  region_path, pattern = "_mask\\.tiff$", full.names = TRUE
)
stopifnot(length(mask_path) == 1)

mask <- tiff::readTIFF(mask_path, as.is = TRUE)

stopifnot(
  is.matrix(mask),
  all(is.finite(mask)),
  all(mask >= 0 & mask == round(mask)),
  !anyDuplicated(objects$mask_label),
  setequal(objects$mask_label, unique(mask[mask > 0]))
)

keep <- mask > 0

channel_files <- c(
  CD3_mean = "CD3_Sm152.tiff",
  CD31_mean = "CD31_Eu151.tiff"
)

for (measurement in names(channel_files)) {
  path <- file.path(region_path, channel_files[[measurement]])
  stopifnot(file.exists(path))
  
  signal <- tiff::readTIFF(path, as.is = TRUE)
  
  stopifnot(
    identical(dim(signal), dim(mask)),
    all(is.finite(signal)),
    all(signal >= 0)
  )
  
  totals <- rowsum(
    cbind(
      signal_sum = signal[keep],
      pixel_count = rep(1, sum(keep))
    ),
    group = mask[keep],
    reorder = TRUE
  )
  
  means <- totals[, "signal_sum"] / totals[, "pixel_count"]
  
  # Match by label rather than assuming identical row order
  index <- match(
    objects$mask_label,
    as.integer(rownames(totals))
  )
  stopifnot(!anyNA(index))
  
  objects[[measurement]] <- unname(means[index])
}

output_path <- paste0(
  "data_processed/",
  "A-Zone1a_object_measurements_multimarker.csv"
)

write.csv(objects, output_path, row.names = FALSE)

cat("Number of objects:", nrow(objects), "\n")
print(summary(objects[c("CD68_mean", "CD3_mean", "CD31_mean")]))
cat("\nExpanded table saved:", file.exists(output_path), "\n")