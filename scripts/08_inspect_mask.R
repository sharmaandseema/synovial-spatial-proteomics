# 08_inspect_mask.R
# Check mask labels and segmented-object sizes.

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  requireNamespace("tiff", quietly = TRUE),
  dir.exists("results")
)

region_path <- file.path(
  "data_raw", "data_tiff", "001-A-C", "A-Zone1a"
)

mask_path <- list.files(
  region_path,
  pattern = "_mask\\.tiff$",
  full.names = TRUE
)

stopifnot(length(mask_path) == 1)

mask <- tiff::readTIFF(mask_path, as.is = TRUE)

stopifnot(
  is.matrix(mask),
  all(is.finite(mask)),
  all(mask >= 0),
  all(mask == round(mask))
)

# Count pixels for each positive label.
# Treat zero as unassigned background.
label_counts <- table(mask[mask > 0])

stopifnot(length(label_counts) > 0)

object_sizes <- data.frame(
  mask_label = as.integer(names(label_counts)),
  area_pixels = as.integer(label_counts)
)

write.csv(
  object_sizes,
  "results/A-Zone1a_mask_object_sizes.csv",
  row.names = FALSE
)

cat("Number of positive mask labels:\n")
print(nrow(object_sizes))

cat("\nLargest label number:\n")
print(max(object_sizes$mask_label))

cat("\nPercentage of pixels labelled zero:\n")
print(round(100 * mean(mask == 0), 1))

cat("\nObject sizes in pixels:\n")
print(summary(object_sizes$area_pixels))