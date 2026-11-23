# 19_measure_nearest_neighbours.R
# Calculate nearest-object distances in pixel units.

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  dir.exists("data_processed"),
  dir.exists("results")
)

input_path <- paste0(
  "data_processed/",
  "A-Zone1a_object_measurements_multimarker.csv"
)
stopifnot(file.exists(input_path))

objects <- read.csv(input_path)

required <- c(
  "region_id", "mask_label", "x_column", "y_row",
  "touches_image_edge"
)

stopifnot(
  all(required %in% names(objects)),
  nrow(objects) > 1,
  length(unique(objects$region_id)) == 1,
  !anyDuplicated(objects$mask_label),
  all(is.finite(objects$x_column)),
  all(is.finite(objects$y_row))
)

nearest_index <- integer(nrow(objects))
nearest_distance <- numeric(nrow(objects))

for (i in seq_len(nrow(objects))) {
  squared_distance <-
    (objects$x_column - objects$x_column[i])^2 +
    (objects$y_row - objects$y_row[i])^2
  
  # An object cannot be its own neighbour
  squared_distance[i] <- Inf
  
  nearest_index[i] <- which.min(squared_distance)
  nearest_distance[i] <- sqrt(
    squared_distance[nearest_index[i]]
  )
}

objects$nearest_object_label <-
  objects$mask_label[nearest_index]

objects$nearest_distance_pixels <- nearest_distance

stopifnot(
  all(is.finite(objects$nearest_distance_pixels)),
  all(objects$nearest_object_label != objects$mask_label)
)

output_path <- paste0(
  "data_processed/",
  "A-Zone1a_object_measurements_spatial.csv"
)

write.csv(objects, output_path, row.names = FALSE)

distance_summary <- data.frame(
  statistic = c("Minimum", "25th percentile", "Median",
                "Mean", "75th percentile", "Maximum"),
  distance_pixels = c(
    min(nearest_distance),
    unname(quantile(nearest_distance, 0.25)),
    median(nearest_distance),
    mean(nearest_distance),
    unname(quantile(nearest_distance, 0.75)),
    max(nearest_distance)
  )
)

write.csv(
  distance_summary,
  "results/A-Zone1a_nearest_distance_summary.csv",
  row.names = FALSE
)

print(distance_summary, row.names = FALSE)
cat("\nSpatial table saved:", file.exists(output_path), "\n")