# 12_measure_first_region.R
# Measure original image values within each positive mask label.

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  requireNamespace("tiff", quietly = TRUE),
  dir.exists("data_processed")
)

region_path <- "data_raw/data_tiff/001-A-C/A-Zone1a"

mask_path <- list.files(
  region_path, pattern = "_mask\\.tiff$", full.names = TRUE
)
stopifnot(length(mask_path) == 1)

mask <- tiff::readTIFF(mask_path, as.is = TRUE)
dna <- tiff::readTIFF(
  file.path(region_path, "DNA1_Ir191.tiff"),
  as.is = TRUE
)
cd68 <- tiff::readTIFF(
  file.path(region_path, "CD68_Tb159.tiff"),
  as.is = TRUE
)

stopifnot(
  is.matrix(mask),
  identical(dim(mask), dim(dna)),
  identical(dim(mask), dim(cd68)),
  all(is.finite(mask)),
  all(is.finite(dna)),
  all(is.finite(cd68)),
  all(mask >= 0 & mask == round(mask))
)

# Exclude zero-labelled pixels
keep <- mask > 0
stopifnot(any(keep))

# Sum measurements separately for each mask label
totals <- rowsum(
  cbind(
    pixel_count = rep(1, sum(keep)),
    column_sum = col(mask)[keep],
    row_sum = row(mask)[keep],
    DNA1_sum = dna[keep],
    CD68_sum = cd68[keep]
  ),
  group = mask[keep],
  reorder = TRUE
)

objects <- data.frame(
  region_id = "A-Zone1a",
  mask_label = as.integer(rownames(totals)),
  area_pixels = totals[, "pixel_count"],
  x_column = totals[, "column_sum"] / totals[, "pixel_count"],
  y_row = totals[, "row_sum"] / totals[, "pixel_count"],
  DNA1_mean = totals[, "DNA1_sum"] / totals[, "pixel_count"],
  CD68_mean = totals[, "CD68_sum"] / totals[, "pixel_count"],
  row.names = NULL
)

# Check against the object count confirmed earlier
stopifnot(
  nrow(objects) == 3784,
  !anyDuplicated(objects$mask_label),
  sum(objects$area_pixels) == sum(keep),
  all(is.finite(objects$DNA1_mean)),
  all(is.finite(objects$CD68_mean))
)

output_path <- "data_processed/A-Zone1a_object_measurements.csv"

write.csv(objects, output_path, row.names = FALSE)

cat("Number of measured objects:", nrow(objects), "\n")
print(head(objects, 6), row.names = FALSE)

cat("\nAverage CD68 signal across objects:\n")
print(summary(objects$CD68_mean))

cat("\nTable saved:", file.exists(output_path), "\n")