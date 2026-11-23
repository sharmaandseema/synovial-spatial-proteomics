# 15_check_image_edge_sensitivity.R

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  dir.exists("results")
)

input_path <- "data_processed/A-Zone1a_object_measurements_qc.csv"
stopifnot(file.exists(input_path))

objects <- read.csv(input_path)

stopifnot(
  is.logical(objects$touches_image_edge),
  !anyNA(objects$touches_image_edge),
  all(is.finite(objects$CD68_mean))
)

summarise_cd68 <- function(x, label) {
  stopifnot(length(x) > 0)
  
  data.frame(
    analysis = label,
    number_of_objects = length(x),
    mean_CD68 = mean(x),
    median_CD68 = median(x),
    percentile_90_CD68 = unname(quantile(x, 0.90))
  )
}

comparison <- rbind(
  summarise_cd68(
    objects$CD68_mean,
    "All objects"
  ),
  summarise_cd68(
    objects$CD68_mean[!objects$touches_image_edge],
    "Exclude image-edge objects"
  )
)

output_path <- "results/A-Zone1a_CD68_edge_sensitivity.csv"
write.csv(comparison, output_path, row.names = FALSE)

print(comparison, row.names = FALSE, digits = 4)
cat("\nComparison saved:", file.exists(output_path), "\n")