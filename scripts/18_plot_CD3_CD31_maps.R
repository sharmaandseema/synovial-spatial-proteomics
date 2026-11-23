# 18_plot_CD3_CD31_maps.R

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  requireNamespace("ggplot2", quietly = TRUE),
  dir.exists("figures")
)

# Verify that the previous histogram was saved
histogram_saved <- file.exists(
  "figures/A-Zone1a_protein_distributions.png"
)
cat("Histogram saved:", histogram_saved, "\n")
stopifnot(histogram_saved)

input_path <- paste0(
  "data_processed/",
  "A-Zone1a_object_measurements_multimarker.csv"
)
stopifnot(file.exists(input_path))

objects <- read.csv(input_path)

required <- c("x_column", "y_row", "CD3_mean", "CD31_mean")
stopifnot(
  all(required %in% names(objects)),
  nrow(objects) == 3784,
  all(vapply(
    objects[required],
    function(x) all(is.finite(x)),
    logical(1)
  ))
)

maps <- list()

for (marker in c("CD3", "CD31")) {
  plot_data <- objects
  plot_data$mean_signal <- objects[[paste0(marker, "_mean")]]
  
  p <- ggplot2::ggplot(
    plot_data,
    ggplot2::aes(
      x = x_column,
      y = y_row,
      colour = mean_signal
    )
  ) +
    ggplot2::geom_point(size = 0.6) +
    ggplot2::scale_colour_viridis_c(
      name = paste0("Mean ", marker, "\nimage signal")
    ) +
    ggplot2::scale_x_continuous(
      limits = c(0.5, 439.5), expand = c(0, 0)
    ) +
    ggplot2::scale_y_reverse(
      limits = c(1298.5, 0.5), expand = c(0, 0)
    ) +
    ggplot2::coord_fixed() +
    ggplot2::labs(
      title = paste(marker, "signal across segmented objects"),
      subtitle = "A-Zone1a | one point per object",
      x = "Image column (pixels)",
      y = "Image row (pixels)"
    ) +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(panel.grid = ggplot2::element_blank())
  
  figure_path <- paste0(
    "figures/A-Zone1a_", marker, "_object_map.png"
  )
  
  ggplot2::ggsave(
    filename = figure_path,
    plot = p,
    width = 7, height = 10, units = "in", dpi = 150
  )
  
  maps[[marker]] <- p
  cat(marker, "map saved:", file.exists(figure_path), "\n")
}

# Display CD3 first
print(maps[["CD3"]])