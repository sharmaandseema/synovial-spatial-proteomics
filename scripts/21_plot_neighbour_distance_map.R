# 21_plot_neighbour_distance_map.R

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  requireNamespace("ggplot2", quietly = TRUE),
  dir.exists("figures")
)

input_path <- paste0(
  "data_processed/",
  "A-Zone1a_object_measurements_spatial.csv"
)
stopifnot(file.exists(input_path))

objects <- read.csv(input_path)

required <- c(
  "x_column", "y_row", "nearest_distance_pixels"
)

stopifnot(
  all(required %in% names(objects)),
  all(vapply(
    objects[required],
    function(x) all(is.finite(x)),
    logical(1)
  ))
)

# Draw larger distances last so they remain visible
objects <- objects[
  order(objects$nearest_distance_pixels),
]

p <- ggplot2::ggplot(
  objects,
  ggplot2::aes(
    x = x_column,
    y = y_row,
    colour = nearest_distance_pixels
  )
) +
  ggplot2::geom_point(size = 0.7) +
  ggplot2::scale_colour_viridis_c(
    name = "Nearest centre\ndistance (pixels)"
  ) +
  ggplot2::scale_x_continuous(
    limits = c(0.5, 439.5), expand = c(0, 0)
  ) +
  ggplot2::scale_y_reverse(
    limits = c(1298.5, 0.5), expand = c(0, 0)
  ) +
  ggplot2::coord_fixed() +
  ggplot2::labs(
    title = "Distance to the nearest object",
    subtitle = "A-Zone1a | centre-to-centre distances",
    x = "Image column (pixels)",
    y = "Image row (pixels)"
  ) +
  ggplot2::theme_minimal(base_size = 11) +
  ggplot2::theme(panel.grid = ggplot2::element_blank())

figure_path <- "figures/A-Zone1a_neighbour_distance_map.png"

ggplot2::ggsave(
  filename = figure_path,
  plot = p,
  width = 7, height = 10, units = "in", dpi = 150
)

print(p)
cat("Distance map saved:", file.exists(figure_path), "\n")