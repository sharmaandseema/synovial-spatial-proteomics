# 14_flag_boundary_objects.R

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  requireNamespace("tiff", quietly = TRUE),
  dir.exists("results")
)

input_path <- "data_processed/A-Zone1a_object_measurements.csv"
stopifnot(file.exists(input_path))

objects <- read.csv(input_path)

mask_path <- list.files(
  "data_raw/data_tiff/001-A-C/A-Zone1a",
  pattern = "_mask\\.tiff$",
  full.names = TRUE
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

# Collect labels present on the four outer image edges
edge_labels <- unique(c(
  mask[1, ],
  mask[nrow(mask), ],
  mask[, 1],
  mask[, ncol(mask)]
))
edge_labels <- edge_labels[edge_labels > 0]

objects$touches_image_edge <- objects$mask_label %in% edge_labels

output_path <- "data_processed/A-Zone1a_object_measurements_qc.csv"
write.csv(objects, output_path, row.names = FALSE)

edge_summary <- data.frame(
  group = c("Touches image edge", "Does not touch image edge"),
  objects = c(
    sum(objects$touches_image_edge),
    sum(!objects$touches_image_edge)
  )
)

edge_summary$percent <- round(
  100 * edge_summary$objects / nrow(objects), 1
)

write.csv(
  edge_summary,
  "results/A-Zone1a_image_edge_summary.csv",
  row.names = FALSE
)

print(edge_summary, row.names = FALSE)
cat("\nQC table saved:", file.exists(output_path), "\n")