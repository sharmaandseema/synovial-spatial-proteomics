# 13_plot_CD68_object_map.R

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  requireNamespace("ggplot2", quietly = TRUE),
  dir.exists("figures")
)

input_path <- "data_processed/A-Zone1a_object_measurements.csv"
stopifnot(file.exists(input_path))

objects <- read.csv(input_path)

required_columns <- c(
  "region_id", "mask_label", "x_column", "y_row", "CD68_mean"
)

stopifnot(
  all(required_columns %in% names(objects)),
  nrow(objects) == 3784,
  all(is.finite(objects$x_column)),
  all(is.finite(objects$y_row)),
  all(is.finite(objects$CD68_mean))
)

p <- ggplot2::ggplot(
  objects,
  ggplot2::aes(
    x = x_column,
    y = y_row,
    colour = CD68_mean
  )
) +
  ggplot2::geom_point(size = 0.6) +
  ggplot2::scale_colour_viridis_c(
    name = "Mean CD68\nimage signal"
  ) +
  ggplot2::scale_x_continuous(
    limits = c(0.5, 439.5),
    expand = c(0, 0)
  ) +
  ggplot2::scale_y_reverse(
    limits = c(1298.5, 0.5),
    expand = c(0, 0)
  ) +
  ggplot2::coord_fixed() +
  ggplot2::labs(
    title = "CD68 signal across segmented objects",
    subtitle = "A-Zone1a | one point per object",
    x = "Image column (pixels)",
    y = "Image row (pixels)"
  ) +
  ggplot2::theme_minimal(base_size = 11) +
  ggplot2::theme(panel.grid = ggplot2::element_blank())

figure_path <- "figures/A-Zone1a_CD68_object_map.png"

ggplot2::ggsave(
  filename = figure_path,
  plot = p,
  width = 7,
  height = 10,
  units = "in",
  dpi = 150
)

print(p)
cat("Map saved:", file.exists(figure_path), "\n")