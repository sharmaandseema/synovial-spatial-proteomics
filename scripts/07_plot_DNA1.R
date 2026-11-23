# 07_plot_DNA1.R
# Display DNA1 and save the figure.

stopifnot(
  file.exists("synovial-spatial-proteomics.Rproj"),
  requireNamespace("tiff", quietly = TRUE),
  dir.exists("figures")
)

dna_path <- file.path(
  "data_raw", "data_tiff", "001-A-C", "A-Zone1a",
  "DNA1_Ir191.tiff"
)

stopifnot(file.exists(dna_path))

dna <- tiff::readTIFF(dna_path, as.is = TRUE)

stopifnot(
  is.matrix(dna),
  all(is.finite(dna)),
  all(dna >= 0)
)

# Adjust brightness for display only
brightness_limit <- unname(quantile(dna, 0.995))
stopifnot(brightness_limit > 0)

display_image <- pmin(dna / brightness_limit, 1)

draw_dna <- function() {
  plot(
    NA,
    xlim = c(0, ncol(dna)),
    ylim = c(0, nrow(dna)),
    asp = 1,
    axes = FALSE,
    xlab = "", ylab = "",
    main = "A-Zone1a: DNA1",
    xaxs = "i", yaxs = "i"
  )
  
  rasterImage(
    as.raster(display_image),
    0, 0, ncol(dna), nrow(dna),
    interpolate = FALSE
  )
}

# Save the figure
figure_path <- "figures/A-Zone1a_DNA1.png"

png(figure_path, width = 700, height = 1500, res = 150)
draw_dna()
dev.off()

# Also display it in RStudio
draw_dna()

cat("Figure saved:", file.exists(figure_path), "\n")