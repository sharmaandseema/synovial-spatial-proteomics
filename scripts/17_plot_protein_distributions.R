# 17_plot_protein_distributions.R
# Plot mean protein signals across all segmented objects.

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  requireNamespace("ggplot2", quietly = TRUE),
  dir.exists("figures")
)

input_path <- paste0(
  "data_processed/",
  "A-Zone1a_object_measurements_multimarker.csv"
)

stopifnot(file.exists(input_path))
objects <- read.csv(input_path)

measurements <- c("CD68_mean", "CD3_mean", "CD31_mean")

stopifnot(
  all(measurements %in% names(objects)),
  nrow(objects) == 3784,
  all(vapply(
    objects[measurements],
    function(x) all(is.finite(x) & x >= 0),
    logical(1)
  ))
)

# Arrange the three measurements in one plotting table
plot_data <- do.call(
  rbind,
  lapply(measurements, function(measurement) {
    data.frame(
      marker = sub("_mean$", "", measurement),
      mean_signal = objects[[measurement]]
    )
  })
)

plot_data$marker <- factor(
  plot_data$marker,
  levels = c("CD68", "CD3", "CD31")
)

p <- ggplot2::ggplot(
  plot_data,
  ggplot2::aes(x = mean_signal)
) +
  ggplot2::geom_histogram(
    bins = 40,
    fill = "steelblue",
    colour = "white"
  ) +
  ggplot2::facet_wrap(
    ~ marker,
    ncol = 1,
    scales = "free_x"
  ) +
  ggplot2::labs(
    title = "Protein-signal distributions: A-Zone1a",
    subtitle = "All 3,784 objects, including image-edge objects",
    x = "Mean image signal per object",
    y = "Number of objects",
    caption = "Each panel has its own horizontal scale."
  ) +
  ggplot2::theme_minimal(base_size = 11)

figure_path <- "figures/A-Zone1a_protein_distributions.png"

ggplot2::ggsave(
  filename = figure_path,
  plot = p,
  width = 8,
  height = 9,
  units = "in",
  dpi = 150
)

print(p)
cat("Distribution figure saved:", file.exists(figure_path), "\n")