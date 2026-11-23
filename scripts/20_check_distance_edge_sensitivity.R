# 20_check_distance_edge_sensitivity.R

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  dir.exists("results")
)

input_path <- paste0(
  "data_processed/",
  "A-Zone1a_object_measurements_spatial.csv"
)
stopifnot(file.exists(input_path))

objects <- read.csv(input_path)

stopifnot(
  is.logical(objects$touches_image_edge),
  !anyNA(objects$touches_image_edge),
  all(is.finite(objects$nearest_distance_pixels)),
  all(objects$nearest_distance_pixels >= 0)
)

summarise_distances <- function(x, label) {
  stopifnot(length(x) > 0)
  
  data.frame(
    analysis = label,
    number_of_objects = length(x),
    mean_pixels = mean(x),
    median_pixels = median(x),
    percentile_90_pixels = unname(quantile(x, 0.90)),
    maximum_pixels = max(x)
  )
}

comparison <- rbind(
  summarise_distances(
    objects$nearest_distance_pixels,
    "All objects"
  ),
  summarise_distances(
    objects$nearest_distance_pixels[
      !objects$touches_image_edge
    ],
    "Exclude image-edge objects from summary"
  )
)

output_path <- "results/A-Zone1a_distance_edge_sensitivity.csv"

write.csv(comparison, output_path, row.names = FALSE)

print(comparison, row.names = FALSE, digits = 4)
cat("\nComparison saved:", file.exists(output_path), "\n")